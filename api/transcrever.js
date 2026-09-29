// ============================================================
// /api/transcrever  —  áudio vira texto (Central Impulse One)
// ------------------------------------------------------------
// Função serverless (Vercel, runtime Node). Recebe o áudio gravado no
// navegador, manda pra Groq (Whisper) e devolve o TEXTO pra pessoa revisar
// antes de enviar. A chave fica SOMENTE aqui no servidor (GROQ_API_KEY).
//
// O áudio NÃO é salvo em lugar nenhum: vive no buffer da requisição, vira
// texto e some quando a resposta termina. Só o texto revisado é guardado.
//
// O corpo chega como binário puro (não multipart) — o navegador manda o blob
// direto. Por isso o bodyParser da Vercel fica desligado: ele estragaria os
// bytes do áudio.
//
// Segurança: só responde a usuário autenticado da Impulse. O frontend manda o
// access_token do Supabase no header Authorization e validamos antes de gastar
// a chave.
// ============================================================

const SUPABASE_URL = 'https://pzqxceqtnsmpsiaejhjw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6cXhjZXF0bnNtcHNpYWVqaGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNDkwNjgsImV4cCI6MjA5NDcyNTA2OH0.VFgxhwTFdTDhVAX9v4Gi5jtx5TKVCdf74SZohHMfuD8';

const MODELO = 'whisper-large-v3-turbo';   // rápido e barato; fala português bem
const MAX_BYTES = 20 * 1024 * 1024;        // 20 MB — feedback é curto
const LIMITE_POR_MINUTO = 12;              // freio por usuário

// Desliga o parser da Vercel: precisamos dos bytes crus do áudio.
module.exports.config = { api: { bodyParser: false } };

async function validarUsuario(token) {
  if (!token) return null;
  try {
    const r = await fetch(SUPABASE_URL + '/auth/v1/user', {
      headers: { apikey: SUPABASE_ANON_KEY, Authorization: 'Bearer ' + token }
    });
    if (!r.ok) return null;
    const u = await r.json().catch(() => null);
    return (u && (u.id || (u.user && u.user.id))) || null;
  } catch (e) {
    return null;
  }
}

// Freio simples por usuário. Some quando a função hiberna — é proteção contra
// repetição acidental, não contra ataque.
const _usos = new Map();
function dentroDoLimite(userId) {
  const agora = Date.now();
  const lista = (_usos.get(userId) || []).filter(t => agora - t < 60000);
  if (lista.length >= LIMITE_POR_MINUTO) return false;
  lista.push(agora);
  _usos.set(userId, lista);
  return true;
}

function lerCorpo(req) {
  return new Promise((resolve, reject) => {
    const partes = [];
    let total = 0;
    req.on('data', (c) => {
      total += c.length;
      if (total > MAX_BYTES) { reject(new Error('grande')); req.destroy(); return; }
      partes.push(c);
    });
    req.on('end', () => resolve(Buffer.concat(partes)));
    req.on('error', reject);
  });
}

module.exports = async (req, res) => {
  if (req.method === 'OPTIONS') { res.status(204).end(); return; }
  if (req.method !== 'POST') { res.status(405).json({ ok: false, erro: 'Use POST.' }); return; }

  const API_KEY = (process.env.GROQ_API_KEY || '').trim();
  if (!API_KEY) {
    res.status(503).json({ ok: false, erro: 'A transcrição ainda não foi configurada no servidor (GROQ_API_KEY na Vercel). Você pode escrever o texto normalmente.' });
    return;
  }
  // A chave vai num header HTTP (só aceita Latin1). Colada truncada/mascarada,
  // o fetch quebra com erro críptico — avisa de forma acionável.
  if ([...API_KEY].some(c => c.charCodeAt(0) > 255)) {
    res.status(503).json({ ok: false, erro: 'A chave da transcrição no servidor está malformada. Reconfigure a GROQ_API_KEY na Vercel com a chave completa.' });
    return;
  }

  const auth = req.headers['authorization'] || req.headers['Authorization'] || '';
  const token = auth.replace(/^Bearer\s+/i, '').trim();
  const userId = await validarUsuario(token);
  if (!userId) { res.status(401).json({ ok: false, erro: 'Sessão inválida. Faça login de novo.' }); return; }
  if (!dentroDoLimite(userId)) {
    res.status(429).json({ ok: false, erro: 'Muitas transcrições em pouco tempo. Espere um minutinho.' });
    return;
  }

  let audio;
  try {
    audio = await lerCorpo(req);
  } catch (e) {
    if (String(e.message) === 'grande') {
      res.status(413).json({ ok: false, erro: 'Áudio muito longo. Grave um trecho menor ou escreva o texto.' });
      return;
    }
    res.status(400).json({ ok: false, erro: 'Não consegui ler o áudio.' });
    return;
  }
  if (!audio || !audio.length) { res.status(400).json({ ok: false, erro: 'Sem áudio.' }); return; }

  const tipo = (req.headers['content-type'] || 'audio/webm').split(';')[0].trim();
  const ext = tipo.indexOf('ogg') >= 0 ? 'ogg' : tipo.indexOf('mp4') >= 0 ? 'mp4' : 'webm';

  try {
    const form = new FormData();
    form.append('file', new Blob([audio], { type: tipo }), 'feedback.' + ext);
    form.append('model', MODELO);
    form.append('language', 'pt');
    form.append('response_format', 'json');

    const r = await fetch('https://api.groq.com/openai/v1/audio/transcriptions', {
      method: 'POST',
      headers: { Authorization: 'Bearer ' + API_KEY },
      body: form
    });
    const data = await r.json().catch(() => null);
    if (!r.ok) {
      const msg = (data && (data.error && data.error.message)) || ('erro ' + r.status);
      console.error('[transcrever] groq:', msg);
      res.status(502).json({ ok: false, erro: 'A transcrição falhou (' + msg + '). Escreva o texto se preferir.' });
      return;
    }
    res.status(200).json({ ok: true, texto: (data && data.text) ? String(data.text).trim() : '' });
    // o buffer do áudio morre aqui junto com a requisição — nada é gravado
  } catch (e) {
    console.error('[transcrever]', e);
    res.status(500).json({ ok: false, erro: 'Não consegui transcrever agora. Escreva o texto se preferir.' });
  }
};
