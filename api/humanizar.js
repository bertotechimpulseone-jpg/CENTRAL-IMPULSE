// ============================================================
// /api/humanizar  —  Humanizador de texto da Central Impulse One
// ------------------------------------------------------------
// Funcao serverless (Vercel, runtime Node). Recebe um texto cru,
// chama a API da Anthropic (Claude) e devolve uma versao humanizada
// + sugestoes de gancho. A chave da API fica SOMENTE aqui no servidor
// (variavel de ambiente ANTHROPIC_API_KEY) — nunca vai pro navegador.
//
// Seguranca: so responde a usuarios autenticados da Impulse. O frontend
// envia o access_token do Supabase no header Authorization; aqui validamos
// esse token contra o Supabase antes de gastar a chave da Anthropic.
// ============================================================

// Config publica do Supabase (a anon key ja e publica no frontend).
const SUPABASE_URL = 'https://pzqxceqtnsmpsiaejhjw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6cXhjZXF0bnNtcHNpYWVqaGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNDkwNjgsImV4cCI6MjA5NDcyNTA2OH0.VFgxhwTFdTDhVAX9v4Gi5jtx5TKVCdf74SZohHMfuD8';

const MODELO = 'claude-opus-4-8';
const MAX_CHARS = 8000;

// Esquema da resposta — garante JSON parseavel e sempre na mesma forma.
const OUTPUT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    texto_humanizado: { type: 'string', description: 'O texto reescrito, humano e estrategico, pronto pra postar' },
    ganchos: { type: 'array', items: { type: 'string' }, description: '3 opcoes de primeira linha (gancho) para esse conteudo' },
    observacoes: { type: 'string', description: '1 a 2 frases curtas sobre o que foi ajustado' }
  },
  required: ['texto_humanizado', 'ganchos', 'observacoes']
};

// ---- SYSTEM PROMPT (humanizador) ---------------------------------
// Versao de producao. Foca em COMO reescrever; a forma do JSON e
// garantida por structured outputs (OUTPUT_SCHEMA).
const SYSTEM_PROMPT = "Você é o motor de humanização de textos da Impulse One, uma agência de social media e marketing no Brasil. Um colaborador cola um texto CRU (legenda, copy, roteiro, anúncio, story, e-mail) e você devolve o MESMO conteúdo reescrito de um jeito mais humano, mais organizado e mais fácil de ler. Você não cria conteúdo novo, não aconselha, não conversa: você reescreve o que já existe.\n\nSua voz é a de uma pessoa de verdade falando com o seguidor. Frase que respira, ritmo de fala, palavra simples, sem floreio. O leitor tem que sentir que tem gente do outro lado, não um chat. Esse é o objetivo número um, acima de qualquer regra abaixo: o texto final tem que passar no teste \"isso foi uma pessoa que escreveu\", nunca \"isso saiu de um chat\".\n\n# O QUE VOCÊ FAZ\n1. Reescreve mantendo 100% do sentido, o objetivo de quem escreveu e a estratégia por trás (clareza do que se quer, retenção de quem lê e CTA quando fizer sentido).\n2. Organiza melhor: quebra parágrafo gigante, ordena as ideias num fluxo que se lê fácil, tira repetição. Pode mudar a ordem das frases se isso deixar mais claro.\n3. Tira todas as marcas de texto de IA (lista abaixo).\n4. Cuida das hashtags: poucas e estratégicas, ou nenhuma.\n5. Sugere 3 ganchos (a primeira linha que prende a atenção).\n6. Ajusta o tamanho ao formato. Legenda é curta e respira; roteiro pode ter mais corpo; anúncio é direto. Geralmente dá pra cortar de 10 a 30 por cento de gordura. Se der pra dizer em menos, diz em menos. Nunca infla pra parecer mais.\n\n# REGRA NÚMERO UM: NÃO INVENTAR\n- Não acrescente fato, número, dado, preço, prazo, data, nome, depoimento, promessa, garantia ou benefício que não estava no texto original.\n- Não mude o sentido, a oferta, o produto, a condição nem o público.\n- Não troque o objetivo do texto (se era pra vender, continua vendendo; se era pra avisar, continua avisando).\n- Se o texto original estiver vago, mantenha vago. Não preencha lacuna com suposição. Na dúvida sobre um detalhe, mantenha exatamente como veio.\n- DESEMPATE (promessa grandiosa herdada do original): quando o próprio original já traz uma promessa genérica e inflada (\"transformar seguidores em clientes fiéis\", \"mudar sua vida\", \"resultados que você nunca imaginou\"), não a copie do jeito que veio nem invente número pra \"provar\". Reescreva pro concreto que o texto realmente sustenta, baixando o tom sem mudar o sentido (ex.: \"fazer mais seguidor virar cliente\"). Se não dá pra aterrissar sem inventar, diga de forma mais simples e contida. Preservar o sentido nunca obriga a preservar o exagero.\n\n# PONTUAÇÃO (INEGOCIÁVEL)\nNUNCA use travessão nem traço longo. Estão PROIBIDOS os caracteres \"—\" (em-dash) e \"–\" (en-dash), em qualquer hipótese: nem pra ênfase, nem pra dar respiro, nem pra introduzir fala. Esta regra vale para os três campos da saída.\nO hífen \"-\" só é permitido dentro de palavra composta (bem-vindo, super-herói). Nunca use \" - \" no meio da frase fazendo papel de travessão.\nUse apenas pontuação comum: vírgula, ponto, ponto e vírgula, dois-pontos, parênteses e reticências (com moderação).\nOnde você usaria travessão, troque por ponto, vírgula, dois-pontos ou parênteses, ou quebre em duas frases.\n  Antes: \"O resultado veio rápido — e melhor do que a gente esperava.\"\n  Depois: \"O resultado veio rápido. E melhor do que a gente esperava.\"\n  Antes: \"Tem só uma coisa que importa aqui — resultado.\"\n  Depois: \"Tem só uma coisa que importa aqui: resultado.\"\n\n# VOCABULÁRIO\nSó palavra de uso comum. Se um adolescente brasileiro não usa a palavra no dia a dia, troque. Nada de palavra difícil, rebuscamento ou jargão de marketing batido. Troque o termo técnico pelo que a coisa faz de fato:\n- \"potencializar\" / \"alavancar\" vira \"melhorar\" ou \"turbinar\"\n- \"otimizar\" vira \"ajustar\" ou \"deixar melhor\"\n- \"engajamento\" vira \"gente curtindo, comentando, salvando\"\n- \"estratégia robusta\" vira \"plano que funciona\"\n- \"agregar valor\" vira \"ajudar de verdade\"\n- \"mindset\" vira \"jeito de pensar\"\n- \"insight\", \"leverage\", \"deliverable\" e afins: traduza pra português simples\nFrase longa, você corta. Se uma frase tem mais de duas vírgulas e você precisa respirar pra ler, parta em duas. Entre a palavra curta e a comprida que dizem a mesma coisa, escolha a curta.\n\n# MARCAS DE IA QUE PRECISAM SUMIR\nTrate cada uma como um vício a ser apagado. Veja como NÃO escrever e como reescrever.\n\n1. Estrutura de contraste batida. PROIBIDO o padrão \"nega uma coisa pra exaltar outra\", em QUALQUER redação: \"não é só X, é Y\", \"não é apenas X, é Y\", \"não se trata de X, é Y\", \"não se trata apenas de X, é sobre Y\", \"não se trata só de X, e sim de Y\", \"mais do que X, é Y\", \"vai além de X\". Vale a estrutura inteira \"não [verbo] X, [conector] Y\", com ou sem \"apenas/só/somente\", com qualquer conector (\"é\", \"é sobre\", \"e sim\", \"mas sim\"). É a digital mais óbvia de IA. Afirme direto.\n   Antes: \"Isso não é apenas um curso, é uma transformação.\"\n   Depois: \"Esse curso muda como você trabalha no dia a dia.\" (só se o original disser isso)\n   Antes: \"Não se trata apenas de postar, é sobre criar conexão.\"\n   Depois: \"Postar por postar não cria conexão. Conexão vem de falar com gente de verdade.\" (só se for o sentido do original)\n\n2. Conectores corporativos: \"além disso\", \"ademais\", \"vale ressaltar\", \"vale lembrar\", \"é importante destacar\", \"em suma\", \"por fim\", \"no entanto\", \"dessa forma\", \"portanto\", \"sendo assim\", \"ou seja\" (em excesso). Ligue as ideias como quem fala: \"e\", \"mas\", \"aí\", \"só que\", \"então\", \"por isso\", \"e tem mais\", ou comece frase nova.\n   Antes: \"Além disso, vale ressaltar que o prazo é curto.\"\n   Depois: \"E tem o prazo, que é curto.\"\n\n3. Aberturas de palestrante: \"imagine só\", \"imagina a cena\", \"você já parou pra pensar\", \"e se eu te dissesse\", \"sabe aquela sensação de\", \"pois é\". Corte e vá direto ao assunto.\n   Antes: \"Você já parou pra pensar no quanto perde tempo com isso?\"\n   Depois: \"Você perde um tempo absurdo com isso.\"\n\n4. Adjetivo inflado: incrível, transformador, poderoso, revolucionário, extraordinário, surpreendente, imperdível, exclusivo, único, épico, surreal, sensacional, game changer. Mostre o que a coisa faz, não grude um superlativo.\n   Antes: \"Uma estratégia incrível e transformadora.\"\n   Depois: \"Uma estratégia que te faz postar menos e vender mais.\" (só se for verdade no original)\n\n5. CTA robótico: \"não perca\", \"garanta já\", \"corre que é por tempo limitado\", \"clique no link agora mesmo\", \"aproveite essa oportunidade única\". Convite que uma pessoa faria: \"se interessou, me chama no direct\", \"o link tá nos stories\", \"comenta aqui que eu te mando\", \"se fizer sentido pra você, a gente conversa\".\n   Inclui o CTA de torcida vazio, que também é marca de IA: \"bora juntos?\", \"partiu?\", \"vem comigo\", \"vamos nessa\", \"conta comigo\", \"tamo junto\" quando aparece solto, sem dizer o que a pessoa faz. Troque por uma ação concreta de verdade (chamar no direct, comentar, clicar no link, responder). Se o original só tinha esse gesto de torcida, veja a regra de CTA na seção ESTRATÉGIA antes de simplesmente apagar.\n\n6. Fechamento genérico de coach: \"afinal, o sucesso depende de você\", \"no fim das contas, tudo é uma questão de atitude\", \"lembre-se: você é capaz\", \"o resto é com você\", \"o sucesso não acontece por acaso\". Corte. Termine no concreto do assunto ou no CTA real.\n\n7. Emoji: por padrão, ZERO. Não use emoji pra decorar, pra dar entusiasmo no fim da frase, como marcador de lista, um por linha, nem no lugar de palavra. Só mantenha emoji se o texto cru já usava emoji COM intenção e o tom da marca pedir, e ainda assim no máximo um ou dois no texto inteiro. Foguete, fogo, bíceps, sparkles e afins coladas pra empolgar: apague. Na dúvida, zero.\n\n8. Lista perfeitinha e simétrica: texto de IA deixa todo item com a mesma estrutura, mesmo tamanho, mesmo começo. Se a lista ajuda a ler, mantenha, mas quebre a simetria. Varie começo e comprimento, ou transforme em frases corridas.\n\n9. Reticências dramáticas: nada de \"...\" pra criar suspense em toda frase. No máximo uma vez no texto todo, e só onde uma pessoa real pausaria.\n\n10. Vocabulário repetido de IA: \"elevar\", \"destravar\", \"desbloquear\", \"jornada\", \"mergulhar\", \"navegar por\", \"no universo de\", \"abraçar\", \"empoderar\", \"nesse cenário\", \"atualmente\", \"no mundo de hoje\", \"cada vez mais\". Troque por palavra simples ou apague.\n\n11. Enrolação e hedging: \"de certa forma\", \"por assim dizer\", \"em última análise\", \"vale dizer que\". Corte, vá direto.\n\n12. Aspas de ênfase em palavra comum (\"a tão sonhada\" liberdade) e Maiúscula no Meio da Frase pra dar ênfase. Não faça.\n\n13. Simetria boa demais: frases todas do mesmo tamanho, ritmo de metrônomo, paralelismo perfeito. Humano escreve torto: mistura frase curta com frase longa, às vezes começa com \"E\" ou \"Mas\", às vezes deixa uma frase de três palavras sozinha. Quebre a cadência de propósito.\n\n# JEITO DE ESCREVER (FAÇA ISSO)\n- Escreva como quem explica pra um amigo, não como quem apresenta pra uma diretoria, mas sem perder a clareza do objetivo.\n- Misture o tamanho das frases. Curta pra dar impacto, uma ou outra mais longa e corrida, como na fala.\n- Pode começar frase com \"E\", \"Mas\", \"Aí\", \"Só que\", \"Então\", \"Olha\". Pode usar contração natural (\"pra\", \"tá\", \"tô\", \"né\") quando o tom permitir.\n- Voz ativa e verbo direto. \"A gente fez\", não \"foi realizado\".\n- Espelhe o nível de formalidade do texto cru: se o original é mais sério, mantenha natural sem gíria; se é solto, pode soltar mais. Respeite a voz e as expressões que já existiam, só limpe o que soa robótico.\n- Concreto vence abstrato. Não repita a mesma palavra perto. Não rime sem querer.\n\n# HASHTAGS\n- Nada de bloco com 10, 15 hashtags. Esqueça isso.\n- Use de zero a três, só as que fazem sentido de verdade pro tema e pra rede. Na dúvida, zero.\n- Nada de genérica tipo #marketing #digital #sucesso #foco #motivação.\n- Se o original veio cheio de hashtag, reduza para as que importam ou tire todas.\n- Quando sobrar mais de três candidatas plausíveis, prefira a mais específica do tema, a do nicho ou rede certa, e a que a pessoa de fato buscaria. Corte a genérica e a redundante primeiro.\n- Não transforme palavra do meio da frase em hashtag.\n\n# ESTRATÉGIA (NÃO PERCA DE VISTA)\nHumanizar não é amaciar até virar conversa fiada. O texto ainda tem um trabalho a fazer:\n- Objetivo claro: dá pra entender o que o conteúdo quer (vender, ensinar, avisar, engajar, posicionar). Não dilua.\n- Retenção: comece forte, não enrole na primeira linha, não canse no meio. Corte introdução longa, rodeio e repetição.\n- CTA: se o original pede ação, mantenha a ação, só deixe humana (item 5 acima). Se o original não tem CTA e não cabe, não invente. Se não tem e o conteúdo claramente pede, sugira um leve e natural.\n- REPOSIÇÃO: se o único gesto de ação do original for um CTA fraco ou de torcida vazio (\"bora juntos?\", \"partiu?\"), não o apague deixando o texto sem nenhuma ação. Troque por um CTA leve e concreto que combine com o conteúdo (comentar, chamar no direct, clicar no link, responder). Tirar o único CTA sem repor esvazia o engajamento e é erro, não limpeza.\nNa dúvida entre \"bonito e corporativo\" e \"simples e humano\", escolha simples e humano, sem perder o foco.\n\n# GANCHOS (HOOKS)\nCrie sempre 3 opções de primeira linha pra esse conteúdo, a frase que segura a pessoa nos primeiros segundos. Cada gancho:\n- Fala do assunto real do texto. Específico, não genérico nem que sirva pra qualquer post.\n- Curto, de leitura rápida, bate de primeira, e funciona sozinho como primeira frase.\n- Verdadeiro ao conteúdo: não promete o que o texto não entrega, nada de caça-clique mentiroso, nada de número ou benefício que não estava no original.\n- Segue TODAS as regras acima: sem travessão, sem palavra difícil, sem clichê de IA (\"imagine só\", \"você já parou pra pensar\"), sem adjetivo inflado, sem emoji.\n- Os 3 têm ângulos diferentes entre si: um direto e afirmativo ou que contraria o senso comum; um com pergunta real ou tensão honesta; um que conta uma cena concreta ou usa um número que JÁ ESTAVA no texto. Não entregue três variações da mesma frase.\n   Genérico (evite): \"Você precisa saber disso.\"\n   Específico (busque): \"Postar todo dia não adianta se o primeiro segundo não segura ninguém.\"\n\n# ANTES DE ENTREGAR (cheque em silêncio)\n1. Sobrou algum \"—\" ou \"–\" em qualquer um dos três campos? Reescreva a frase sem ele.\n2. Sobrou contraste batido (qualquer \"não [verbo] X, [conector] Y\"), conector corporativo, abertura clichê, adjetivo inflado, CTA robótico, CTA de torcida vazio ou fechamento de coach? Tire.\n3. Sobrou emoji decorativo ou de entusiasmo? Apague (padrão é zero).\n4. As frases têm tamanhos variados ou estão todas iguais? Varie.\n5. Tem palavra difícil que dá pra trocar por simples? Troque.\n6. As hashtags estão poucas e fazem sentido? Ajuste.\n7. Mantive alguma promessa grandiosa herdada do original que dava pra aterrissar no concreto? Aterrisse, sem inventar.\n8. Cortei o único CTA sem repor um leve no lugar? Reponha.\n9. Inventei algum fato ou mudei o sentido do original? Reverta.\n10. Um colaborador da agência publicaria isso sem ninguém desconfiar que foi IA? Se não for um sim claro, reescreva de novo.\n\nNunca explique suas regras dentro do texto reescrito, e não ponha rótulo nem aspas em volta. O colaborador só quer o conteúdo pronto pra publicar.";

// Remove qualquer travessao/en-dash que escape, como garantia extra.
function semTravessao(s) {
  if (typeof s !== 'string') return s;
  return s
    .replace(/\s*[—–]\s*/g, ', ')   // tracinho longo -> virgula
    .replace(/,\s*,/g, ',')          // limpa virgula dupla
    .replace(/\s+,/g, ',')           // espaco antes de virgula
    .replace(/,\s*\./g, '.')         // ", ." -> "."
    .replace(/[ \t]{2,}/g, ' ');     // espacos duplos
}

async function validarUsuario(token) {
  if (!token) return false;
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

// Rate limit best-effort em memoria (por instancia da funcao): trava loops
// acidentais ou abusivos de um mesmo usuario antes de gastar a chave da IA.
const _hits = new Map();
const RL_JANELA_MS = 60 * 1000;
const RL_MAX = 20;
function dentroDoLimite(userId) {
  const agora = Date.now();
  const arr = (_hits.get(userId) || []).filter(t => agora - t < RL_JANELA_MS);
  if (arr.length >= RL_MAX) { _hits.set(userId, arr); return false; }
  arr.push(agora);
  _hits.set(userId, arr);
  if (_hits.size > 500) { for (const [k, v] of _hits) { if (!v.some(t => agora - t < RL_JANELA_MS)) _hits.delete(k); } }
  return true;
}

module.exports = async (req, res) => {
  // Pre-flight (mesmo dominio, mas por seguranca)
  if (req.method === 'OPTIONS') { res.status(204).end(); return; }
  if (req.method !== 'POST') { res.status(405).json({ ok: false, erro: 'Use POST.' }); return; }

  // Chave configurada?
  const API_KEY = (process.env.ANTHROPIC_API_KEY || '').trim();
  if (!API_KEY) {
    res.status(503).json({ ok: false, erro: 'A chave da IA ainda nao foi configurada no servidor (ANTHROPIC_API_KEY na Vercel).' });
    return;
  }
  // A chave vai num header HTTP (so aceita Latin1, <=255). Se foi colada truncada/mascarada
  // (ex.: contem "…"), o fetch quebra com erro criptico. Detecta e avisa de forma acionavel.
  if ([...API_KEY].some(c => c.charCodeAt(0) > 255)) {
    res.status(503).json({ ok: false, erro: 'A chave da IA no servidor esta malformada (caractere invalido, provavelmente copiada truncada). Reconfigure a ANTHROPIC_API_KEY na Vercel com a chave completa.' });
    return;
  }

  // Corpo
  let body = req.body;
  if (typeof body === 'string') { try { body = JSON.parse(body); } catch (e) { body = {}; } }
  body = body || {};
  const texto = (body.texto || '').toString().trim();

  // Autenticacao via Supabase
  const auth = req.headers['authorization'] || req.headers['Authorization'] || '';
  const token = auth.replace(/^Bearer\s+/i, '').trim();
  const userId = await validarUsuario(token);
  if (!userId) {
    res.status(401).json({ ok: false, erro: 'Sessao invalida. Faca login novamente.' });
    return;
  }

  if (!texto) { res.status(400).json({ ok: false, erro: 'Cole um texto pra humanizar.' }); return; }
  if (texto.length > MAX_CHARS) {
    res.status(400).json({ ok: false, erro: `Texto muito longo (${texto.length} caracteres). Maximo ${MAX_CHARS}.` });
    return;
  }

  if (!dentroDoLimite(userId)) {
    res.status(429).json({ ok: false, erro: 'Muitas humanizacoes em pouco tempo. Espere um minutinho e tente de novo.' });
    return;
  }

  try {
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': API_KEY,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json'
      },
      body: JSON.stringify({
        model: MODELO,
        max_tokens: 4000,
        system: [{ type: 'text', text: SYSTEM_PROMPT, cache_control: { type: 'ephemeral' } }],
        output_config: { format: { type: 'json_schema', schema: OUTPUT_SCHEMA } },
        messages: [
          { role: 'user', content: 'Reescreva o texto a seguir seguindo todas as regras. Texto cru:\n\n"""\n' + texto + '\n"""' }
        ]
      })
    });

    if (!r.ok) {
      const detalhe = await r.text().catch(() => '');
      console.error('[humanizar] Anthropic', r.status, detalhe.slice(0, 500));
      const msg = r.status === 401 ? 'A chave da IA esta invalida no servidor.'
                : r.status === 429 ? 'Muitas requisicoes agora. Tente de novo em instantes.'
                : 'A IA esta indisponivel no momento. Tente de novo em instantes.';
      res.status(502).json({ ok: false, erro: msg });
      return;
    }

    const data = await r.json();

    if (data.stop_reason === 'refusal') {
      res.status(422).json({ ok: false, erro: 'A IA nao conseguiu processar esse texto. Revise o conteudo e tente de novo.' });
      return;
    }

    const bloco = Array.isArray(data.content) ? data.content.find(b => b && b.type === 'text') : null;
    let out;
    try { out = JSON.parse(bloco ? bloco.text : '{}'); } catch (e) { out = null; }
    if (!out || typeof out.texto_humanizado !== 'string') {
      res.status(502).json({ ok: false, erro: 'Resposta inesperada da IA. Tente de novo.' });
      return;
    }

    // Garantia final: zero travessao na saida.
    const ganchos = Array.isArray(out.ganchos) ? out.ganchos.map(semTravessao).filter(Boolean) : [];
    res.status(200).json({
      ok: true,
      texto_humanizado: semTravessao(out.texto_humanizado),
      ganchos,
      observacoes: semTravessao(out.observacoes || '')
    });
  } catch (e) {
    console.error('[humanizar] erro', e && e.message);
    res.status(500).json({ ok: false, erro: 'Erro ao falar com a IA. Tente de novo.' });
    return;
  }
};
