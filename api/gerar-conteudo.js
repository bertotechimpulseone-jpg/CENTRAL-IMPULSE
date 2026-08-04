// ============================================================
// /api/gerar-conteudo  —  Gerador de calendario editorial da Impulse One
// ------------------------------------------------------------
// Funcao serverless (Vercel, runtime Node). Recebe mes, quantidade e temas,
// pesquisa tendencias reais na web (web_search) e devolve um calendario
// editorial completo (chamada, gatilhos, slides, legenda, CTA, hashtags).
// A chave da API fica SOMENTE aqui no servidor (ANTHROPIC_API_KEY).
//
// Seguranca: so responde a usuarios autenticados da Impulse (valida o
// access_token do Supabase antes de gastar a chave da Anthropic).
// Espelha o padrao de api/humanizar.js.
// ============================================================

const SUPABASE_URL = 'https://pzqxceqtnsmpsiaejhjw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6cXhjZXF0bnNtcHNpYWVqaGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNDkwNjgsImV4cCI6MjA5NDcyNTA2OH0.VFgxhwTFdTDhVAX9v4Gi5jtx5TKVCdf74SZohHMfuD8';

const MODELO = 'claude-opus-4-8';
const MAX_CONTEUDOS = 12;

// ---- SYSTEM PROMPT (estrategista) --------------------------------
const SYSTEM_PROMPT = `Voce e um estrategista digital senior e diretor de conteudo da Impulse One, uma agencia de marca e marketing no Brasil. Voce pensa fora da caixa e nunca entrega conteudo generico.

Seu trabalho: pesquisar o que esta EM ALTA de verdade (mundo, regiao e nicho do cliente) usando as ferramentas de busca, e montar o calendario editorial do mes inteiro, peca por peca, pronto pra produzir.

USE as ferramentas web_search e web_fetch antes de gerar, com angulos diferentes: tendencias de marketing e branding do mes, IA aplicada e saturacao de conteudo, movimentos do nicho (arquitetura, engenharia, industria, metalurgica, empresarios) e pautas da regiao informada. Conecte cada conteudo a uma tendencia ou dor real.

DNA DA MARCA:
- Posicionamento: marketing como engenharia (metodo, processo, percepcao), nao sorte. Constroi marcas lembradas e escolhidas.
- Publico: donos de empresa, arquitetos, engenheiros, industria e metalurgica, empresarios de servico.
- FILTRO INVISIVEL: o alvo real sao empresas estabelecidas (faturamento alto), mas isso NUNCA aparece. Filtre pela linguagem (folha pra fechar, equipe, galpao, cliente exigente, sua maior nota fiscal, margem). Nunca cite faturamento.
- Voz: provocativa do jeito certo, direta, autoridade. Estrutura de toda peca: PROVOCA, depois RESOLVE.
- Pilares: Autoridade e Metodo, Provocacao e Dor, Bastidores e Prova, Educacao de Mercado, Oferta e Conversao.
- Gatilhos mentais possiveis: Autoridade, Prova social, Escassez, Urgencia, Reciprocidade, Antecipacao, Inimigo comum, Contraste, Curiosidade, Quebra de padrao, Pertencimento, Novidade, Aversao a perda, Storytelling, Especificidade, Prova e demonstracao.

REGRAS INQUEBRAVEIS DE COPY:
- PROIBIDO travessao (— ou –) em qualquer texto. Use ponto, virgula, dois-pontos ou parenteses.
- Sem cliche generico (alavancar, transformar sua empresa, conteudo de valor, engajamento como meta).
- Gancho nos 3 primeiros segundos, sem oi tudo bem.
- Uma ideia central por peca.
- CTA sempre uma acao concreta e criativa que a pessoa faz na hora (um teste, um print, uma palavra no direct, uma pergunta), nunca apenas me segue.
- So os formatos Carrossel e Estatico. Nada de reels ou video.

FORMATO DA SAIDA (CRITICO):
Responda SOMENTE com um objeto JSON valido, sem cercas de codigo, sem nenhum texto antes ou depois. Forma exata:
{
 "mes": string, "ano": number, "resumo_do_mes": string (2 a 4 frases),
 "conteudos": [
   {
    "id": number,
    "dia_sugerido": string (ex "Seg 07/07"),
    "pilar": string (um dos pilares),
    "formato": "Carrossel" ou "Estatico",
    "objetivo": "Topo" ou "Meio" ou "Fundo",
    "tema": string,
    "chamada": string (o gancho da capa),
    "gancho_tendencia": string (qual tendencia puxa, ou "atemporal"),
    "gatilhos_mentais": [string] (2 a 4),
    "slides": [string] (Carrossel: 4 a 6 slides; Estatico: lista vazia),
    "peca": string (Estatico: a frase autoral; Carrossel: ""),
    "legenda": string,
    "cta": string (acao concreta e criativa),
    "hashtags": [string],
    "direcao_visual": string (curta, coerente com identidade dark premium da marca)
   }
 ]
}
Distribua os dias ao longo do mes em dias uteis, ritmo sustentavel. Portugues do Brasil.`;

function semTravessao(s) {
  if (typeof s !== 'string') return s;
  return s
    .replace(/\s*[—–]\s*/g, ', ')
    .replace(/,\s*,/g, ',')
    .replace(/\s+,/g, ',')
    .replace(/,\s*\./g, '.')
    .replace(/[ \t]{2,}/g, ' ');
}
function limparTravessaoFundo(v) {
  if (typeof v === 'string') return semTravessao(v);
  if (Array.isArray(v)) return v.map(limparTravessaoFundo);
  if (v && typeof v === 'object') { const o = {}; for (const k in v) o[k] = limparTravessaoFundo(v[k]); return o; }
  return v;
}

function extrairJson(txt) {
  if (!txt || typeof txt !== 'string') return null;
  let s = txt.trim();
  const fence = s.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fence) s = fence[1].trim();
  const a = s.indexOf('{'); const b = s.lastIndexOf('}');
  if (a === -1 || b === -1 || b < a) return null;
  try { return JSON.parse(s.slice(a, b + 1)); } catch (e) { return null; }
}

async function validarUsuario(token) {
  if (!token) return null;
  try {
    const r = await fetch(SUPABASE_URL + '/auth/v1/user', {
      headers: { apikey: SUPABASE_ANON_KEY, Authorization: 'Bearer ' + token }
    });
    if (!r.ok) return null;
    const u = await r.json().catch(() => null);
    return (u && (u.id || (u.user && u.user.id))) ? u : null;
  } catch (e) { return null; }
}

const _hits = new Map();
const RL_JANELA_MS = 60 * 1000;
const RL_MAX = 6;
function dentroDoLimite(userId) {
  const agora = Date.now();
  const arr = (_hits.get(userId) || []).filter(t => agora - t < RL_JANELA_MS);
  if (arr.length >= RL_MAX) { _hits.set(userId, arr); return false; }
  arr.push(agora); _hits.set(userId, arr);
  if (_hits.size > 500) { for (const [k, v] of _hits) { if (!v.some(t => agora - t < RL_JANELA_MS)) _hits.delete(k); } }
  return true;
}

module.exports = async (req, res) => {
  if (req.method === 'OPTIONS') { res.status(204).end(); return; }
  if (req.method !== 'POST') { res.status(405).json({ ok: false, erro: 'Use POST.' }); return; }

  const API_KEY = process.env.ANTHROPIC_API_KEY;
  if (!API_KEY) {
    res.status(503).json({ ok: false, erro: 'A chave da IA ainda nao foi configurada no servidor (ANTHROPIC_API_KEY na Vercel).' });
    return;
  }
  // A chave precisa ser ASCII puro. Se tiver caractere estranho (ex: "…" de uma chave truncada/preview), avisa claro.
  if (/[^\x00-\xFF]/.test(API_KEY)) {
    res.status(503).json({ ok: false, erro: 'A chave da IA salva no servidor parece truncada (contem o caractere "…" ou similar). Recopie a chave COMPLETA da Anthropic e salve de novo na Vercel.' });
    return;
  }

  let body = req.body;
  if (typeof body === 'string') { try { body = JSON.parse(body); } catch (e) { body = {}; } }
  body = body || {};

  const auth = req.headers['authorization'] || req.headers['Authorization'] || '';
  const token = auth.replace(/^Bearer\s+/i, '').trim();
  const user = await validarUsuario(token);
  if (!user) { res.status(401).json({ ok: false, erro: 'Sessao invalida. Faca login novamente.' }); return; }
  const userId = user.id || (user.user && user.user.id);

  if (!dentroDoLimite(userId)) {
    res.status(429).json({ ok: false, erro: 'Muitas geracoes em pouco tempo. Espere um minutinho e tente de novo.' });
    return;
  }

  const mes = (body.mes || '').toString().trim() || 'este mes';
  const ano = parseInt(body.ano, 10) || new Date().getFullYear();
  let quantidade = parseInt(body.quantidade, 10) || 8;
  quantidade = Math.max(1, Math.min(MAX_CONTEUDOS, quantidade));
  const temas = Array.isArray(body.temas) ? body.temas.filter(Boolean) : (body.temas ? [String(body.temas)] : []);
  const regiao = (body.regiao || '').toString().trim();
  const incluirOferta = !!body.incluirOferta;

  const userMsg = [
    `Mes de referencia: ${mes} de ${ano}.`,
    regiao ? `Regiao para pautas locais: ${regiao}.` : 'Foco nacional (Brasil).',
    `Gere EXATAMENTE ${quantidade} conteudos.`,
    temas.length ? `Temas que devo priorizar: ${temas.join(' | ')}.` : '',
    incluirOferta ? 'Inclua 1 conteudo de Oferta e Conversao sobre a promocao de aniversario: identidade visual completa por 699 reais, por tempo limitado e com vagas.' : '',
    'Pesquise as tendencias reais e entregue o calendario no formato JSON especificado.'
  ].filter(Boolean).join('\n');

  let messages = [{ role: 'user', content: userMsg }];
  const tools = [
    { type: 'web_search_20260209', name: 'web_search' },
    { type: 'web_fetch_20260209', name: 'web_fetch' }
  ];

  try {
    let data, guard = 0;
    do {
      const r = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: { 'x-api-key': API_KEY, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
        body: JSON.stringify({
          model: MODELO,
          max_tokens: 16000,
          system: [{ type: 'text', text: SYSTEM_PROMPT, cache_control: { type: 'ephemeral' } }],
          tools,
          messages
        })
      });
      if (!r.ok) {
        const detalhe = await r.text().catch(() => '');
        console.error('[gerar-conteudo] Anthropic', r.status, detalhe.slice(0, 500));
        const msg = r.status === 401 ? 'A chave da IA esta invalida no servidor.'
                  : r.status === 429 ? 'Muitas requisicoes agora. Tente de novo em instantes.'
                  : 'A IA esta indisponivel no momento. Tente de novo em instantes.';
        res.status(502).json({ ok: false, erro: msg });
        return;
      }
      data = await r.json();
      if (data.stop_reason === 'refusal') {
        res.status(422).json({ ok: false, erro: 'A IA nao conseguiu processar esse pedido. Ajuste os temas e tente de novo.' });
        return;
      }
      if (data.stop_reason === 'pause_turn') messages.push({ role: 'assistant', content: data.content });
    } while (data.stop_reason === 'pause_turn' && guard++ < 6);

    const texto = Array.isArray(data.content)
      ? data.content.filter(b => b && b.type === 'text').map(b => b.text).join('\n')
      : '';
    let cal = extrairJson(texto);
    if (!cal || !Array.isArray(cal.conteudos) || cal.conteudos.length === 0) {
      res.status(502).json({ ok: false, erro: 'Resposta inesperada da IA. Tente de novo (talvez com menos conteudos).' });
      return;
    }
    cal = limparTravessaoFundo(cal);
    cal.mes = cal.mes || mes; cal.ano = cal.ano || ano;
    res.status(200).json({ ok: true, calendario: cal });
  } catch (e) {
    console.error('[gerar-conteudo] erro', e && e.message);
    res.status(500).json({ ok: false, erro: 'Erro ao falar com a IA. Tente de novo.' });
    return;
  }
};
