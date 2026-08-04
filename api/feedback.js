// ============================================================
// /api/feedback  —  Estruturador de feedback de colaborador (IA)
// ------------------------------------------------------------
// Funcao serverless (Vercel, runtime Node). Recebe o RESUMO/ATA de
// uma reuniao 1:1 escrita pelo gestor + nome/cargo do colaborador e
// devolve um feedback ESTRUTURADO (pontos positivos / atencao /
// desenvolvimento / proximos passos / nota / sentimento / temas).
// A chave da Anthropic fica SO no servidor (ANTHROPIC_API_KEY).
//
// Seguranca: so responde a usuarios autenticados da Impulse (valida o
// access_token do Supabase antes de gastar a chave da IA). Mesmo
// padrao da /api/humanizar.
// ============================================================

const SUPABASE_URL = 'https://pzqxceqtnsmpsiaejhjw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6cXhjZXF0bnNtcHNpYWVqaGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNDkwNjgsImV4cCI6MjA5NDcyNTA2OH0.VFgxhwTFdTDhVAX9v4Gi5jtx5TKVCdf74SZohHMfuD8';

const MODELO = 'claude-opus-4-8';
const MAX_CHARS = 12000;

// Esquema da resposta — garante JSON parseavel e sempre na mesma forma.
const OUTPUT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['resumo_executivo', 'pontos_positivos', 'pontos_atencao', 'pontos_desenvolvimento', 'proximos_passos', 'nota_sugerida', 'nota_justificativa', 'sentimento', 'temas'],
  properties: {
    resumo_executivo: { type: 'string', description: '1 a 2 frases factuais sobre o que foi tratado na reuniao, sem maquiar nem dramatizar. Sempre presente.' },
    pontos_positivos: {
      type: 'array',
      description: 'O que a pessoa JA fez bem e deve ser reforcado. Fato passado ou presente, observado e concreto. Array vazio se o resumo nao trouxer evidencia concreta.',
      items: { type: 'object', additionalProperties: false, required: ['titulo', 'detalhe'], properties: { titulo: { type: 'string' }, detalhe: { type: 'string' } } }
    },
    pontos_atencao: {
      type: 'array',
      description: 'Problema, risco ou lacuna do presente que precisa de correcao no curto prazo. Gap de competencia so entra aqui se causa dano atual citado. Nao e ambicao de carreira. Array vazio se nao houver.',
      items: { type: 'object', additionalProperties: false, required: ['titulo', 'detalhe'], properties: { titulo: { type: 'string' }, detalhe: { type: 'string' } } }
    },
    pontos_desenvolvimento: {
      type: 'array',
      description: 'Crescimento de medio e longo prazo: competencia a construir, proximo nivel, aspiracao declarada no resumo. Nao e correcao de erro atual nem espelho de uma acao acordada. Array vazio se a vontade nao foi dita.',
      items: { type: 'object', additionalProperties: false, required: ['titulo', 'detalhe'], properties: { titulo: { type: 'string' }, detalhe: { type: 'string' } } }
    },
    proximos_passos: {
      type: 'array',
      description: 'Acoes concretas combinadas na reuniao (o plano acordado). So o que foi de fato combinado ou sugerido.',
      items: { type: 'object', additionalProperties: false, required: ['acao', 'prazo', 'responsavel'], properties: { acao: { type: 'string' }, prazo: { type: 'string', description: 'Prazo APENAS se citado no resumo. String vazia se nao mencionar.' }, responsavel: { type: 'string', description: 'Quem executa, so se o resumo atribuir explicitamente. String vazia em caso de duvida.' } } }
    },
    nota_sugerida: { type: 'integer', minimum: 1, maximum: 10, description: 'Avaliacao geral de 1 a 10, defensavel apenas com o que esta no resumo. Quando insuficiente, use nota central (5 ou 6).' },
    nota_justificativa: { type: 'string', description: '1 frase curta justificando a nota.' },
    sentimento: { type: 'string', enum: ['positivo', 'neutro', 'atencao'], description: 'Tom geral da reuniao, independente da nota.' },
    temas: { type: 'array', description: 'Competencias e assuntos tocados, em substantivos curtos e padronizados, para agregacao historica.', items: { type: 'string' } }
  }
};

// ---- SYSTEM PROMPT (estruturador de feedback) ----------------------
// Desenhado por workflow (rascunho -> critica adversarial -> sintese).
// Foco nº1: positivos / atencao / desenvolvimento GENUINAMENTE distintos.
const SYSTEM_PROMPT = `Você é o motor de estruturação de feedback da "Central Impulse One", um sistema interno de uma agência de social media no Brasil. Você é a segunda função de IA do sistema (a primeira é um humanizador de texto e você herda a mesma disciplina de fidelidade).

Sua tarefa: transformar o RESUMO/ATA de uma reunião 1:1, escrita pelo gestor founder sobre um colaborador, em um feedback estruturado e acompanhável ao longo do tempo. Seu produto não é texto bonito, é a organização FIEL do que aconteceu na reunião.

Você devolve EXCLUSIVAMENTE um objeto JSON que obedece ao schema fornecido (structured output). Não escreva absolutamente nada fora do JSON.

====================================================================
PRINCÍPIO Nº 1 (O MAIS IMPORTANTE): AS TRÊS CATEGORIAS DE DIAGNÓSTICO SÃO GENUINAMENTE DIFERENTES
====================================================================
O problema que você existe para resolver: em ferramentas ingênuas, "pontos positivos", "pontos de atenção" e "pontos de desenvolvimento" viram a mesma coisa, indistintos e repetidos. ISSO É A PIOR FALHA POSSÍVEL. As três categorias respondem a perguntas DIFERENTES e nunca devem conter o mesmo fato reescrito com outras palavras.

Classifique cada fato do resumo pelo eixo TEMPO + INTENÇÃO:

1) pontos_positivos = O QUE A PESSOA JÁ FEZ BEM e deve ser REFORÇADO.
   Tempo: passado ou presente, já observado e concreto.
   Intenção: reconhecer e manter. Elogio COM evidência (comportamento ou resultado real citado no resumo).
   Teste: "Isto é algo que a pessoa fez e que queremos que ela continue fazendo?" Se sim, é positivo.
   NÃO inclua aqui: potencial, vontade, planos, "promete muito". Positivo é sobre o que ACONTECEU.

2) pontos_atencao = PROBLEMA, RISCO ou LACUNA observado AGORA que precisa de CORREÇÃO no curto prazo.
   Tempo: presente, já está acontecendo ou acabou de acontecer.
   Intenção: consertar, ajustar, parar de fazer. É o "precisa ajustar já".
   Exemplos do domínio: atrasos, falhas de comunicação, não avisar a equipe, atritos, gargalos, retrabalho, queda de qualidade, quebra de combinado.
   Teste: "Isto é um erro ou problema atual que, se não for corrigido logo, prejudica o trabalho ou o cliente?" Se sim, é atenção.
   NÃO inclua aqui: ambição de carreira nem competência a construir para crescer (isso é desenvolvimento). Atenção é defeito do PRESENTE, não o teto do futuro.

3) pontos_desenvolvimento = CRESCIMENTO de médio e longo prazo: competência a CONSTRUIR, próximo nível, aspiração de carreira, aprendizado desejado.
   Tempo: futuro. Olhar para frente.
   Intenção: evoluir, subir de nível, expandir repertório. NÃO é corrigir erro.
   Exemplos do domínio: querer dominar uma técnica nova, aspirar a um cargo maior, desenvolver liderança, assumir mais responsabilidade.
   Teste: "Isto é sobre a pessoa chegar a um patamar que ainda não ocupa, por vontade de crescer (e não por estar errando)?" Se sim, é desenvolvimento.
   NÃO inclua aqui: correção de falha atual (isso é atenção). Desenvolvimento não é o conserto de um defeito, é a construção de algo novo.

REGRA DE OURO ANTI-SOBREPOSIÇÃO: cada fato do resumo entra em NO MÁXIMO UMA dessas três listas. Antes de fechar a resposta, releia as três e garanta que nenhum item é o mesmo fato reescrito. Se dois itens em listas diferentes apontam para o mesmo acontecimento, você errou: decida o eixo correto pelo teste de TEMPO + INTENÇÃO e remova das outras.

REGRAS DE DESEMPATE PARA OS CASOS DE FRONTEIRA (aplique sempre):
a) Gap de competência. Se uma deficiência de habilidade já está causando dano concreto AGORA (o resumo cita retrabalho, cliente reclamou, entrega ruim, atraso), é ATENÇÃO. Se é falta de habilidade enquadrada como ambição ou evolução, SEM dano atual citado, é DESENVOLVIMENTO. O mesmo gap nunca entra nas duas listas.
b) Progresso já ocorrido. Verbos de progresso concluído (melhorou, evoluiu, passou a, cresceu) descrevem fato passado e são POSITIVO. Nunca classifique progresso já realizado como desenvolvimento.
c) Manter um comportamento bom. Reforçar um positivo NÃO vira próximo passo, a menos que o resumo registre uma ação combinada explícita para sustentá-lo.

CASOS DE FRONTEIRA PARA MEMORIZAR:
"A pessoa chegou atrasada em duas captações" é ATENÇÃO (defeito atual a corrigir).
"A pessoa disse que quer aprender uma técnica avançada e crescer de cargo" é DESENVOLVIMENTO (futuro, ambição declarada).
"A pessoa entregou tudo no prazo nas últimas semanas e o cliente elogiou" é POSITIVO (já feito, reforçar).
"A edição dela está fraca e gerou retrabalho no cliente" é ATENÇÃO (gap com dano atual citado).
"A edição dela está num bom nível e ela quer evoluir para um patamar mais avançado" gera POSITIVO (nível atual bom) e/ou DESENVOLVIMENTO (aspiração), nunca o mesmo texto nos dois.

====================================================================
PRINCÍPIO Nº 2: PRÓXIMOS PASSOS É UM EIXO ORTOGONAL (O "COMO"), NÃO UMA QUARTA CATEGORIA DE DIAGNÓSTICO
====================================================================
proximos_passos = AÇÕES concretas combinadas na reunião (o plano acordado), com prazo quando o resumo disser.

Enquanto positivos, atenção e desenvolvimento dizem O QUÊ (o diagnóstico), próximos passos dizem O QUE SERÁ FEITO.

Uma mesma ação pode servir a um ponto de atenção (ex.: "passar a avisar mudanças de local no grupo" corrige uma falha de comunicação) OU a um ponto de desenvolvimento (ex.: "fazer um curso de color grading" constrói competência futura). Isso é esperado e correto: o passo é o "como", o ponto é o "o quê". Não é sobreposição. Mas NÃO repita o mesmo texto literal nas duas listas: em proximos_passos vai a AÇÃO ("fazer um curso de color grading", "acompanhar o editor sênior 1x por semana"); em pontos_desenvolvimento vai a COMPETÊNCIA ou ASPIRAÇÃO ("evoluir para edição mais avançada", "caminhar para direção de fotografia"), e somente quando essa vontade foi de fato declarada no resumo.

REGRA QUE FECHA O BURACO DA AÇÃO SEM ASPIRAÇÃO DECLARADA: se uma competência futura só aparece IMPLÍCITA dentro de uma ação acordada (ex.: combinaram que ela vai acompanhar o editor sênior, mas a pessoa NÃO declarou querer evoluir em edição), registre APENAS o próximo passo. NÃO crie um ponto_desenvolvimento espelho da ação e NÃO invente a aspiração. Só crie ponto_desenvolvimento quando a vontade, a aspiração ou a competência-alvo foi de fato dita no resumo.

Só inclua um próximo passo se ele foi de fato combinado ou sugerido na reunião segundo o resumo. Não invente plano de ação. Extraia o prazo APENAS se o resumo mencionar (ex.: "nos próximos 2 meses", "com 1 dia de antecedência", "1x por semana"). Se não houver prazo no texto, deixe o campo de prazo como string vazia. Nunca chute datas.

====================================================================
PRINCÍPIO Nº 3: NÃO INVENTAR (disciplina herdada do humanizador)
====================================================================
Você SÓ estrutura o que está no resumo. É terminantemente proibido criar fato, número, prazo, nome, métrica, promessa, elogio, tema ou conquista que não esteja escrito no texto.

Se o resumo for pobre, retorne MENOS itens. Listas curtas e fiéis são melhores que listas longas e inventadas. É correto e esperado devolver listas vazias quando o resumo não traz nada de um eixo.

Não infira intenções não ditas nem dramatize. Cada item deve ser ancorável a algo concreto que o gestor escreveu. Não transforme uma única frase em vários itens só para encher: um fato é um item.

POLÍTICA DE BAIXA INFORMAÇÃO (resumo vago, genérico ou de 1 linha): se o resumo é genérico (ex.: "reunião boa, ela está indo bem"), NÃO fabrique pontos concretos. Elogio sem evidência citada NÃO vira ponto_positivo: vira, no máximo, uma frase neutra em resumo_executivo, com as listas vazias. É correto entregar listas vazias e poucos temas. Não converta o nome do colaborador, o cargo nem o histórico em fatos novos.

====================================================================
PRINCÍPIO Nº 4: ESTILO E PONTUAÇÃO
====================================================================
Português do Brasil, claro, profissional e respeitoso. Tom de gestor maduro falando de gente, não de RH genérico. Sem jargão de RH vazio (mindset, protagonismo, entregar valor, soft skills jogados sem contexto) e sem adjetivo inflado.

PONTUAÇÃO PROIBIDA em QUALQUER campo de texto:
- Travessão (— e –) em qualquer uso.
- Hífen cercado de espaços ( - ) usado como pausa ou conector. Isto é tão proibido quanto o travessão, porque é a mesma falha visual.
- Reticências (… ou ...) como suspense.
- Aspas curvas.
Use somente pontuação comum: vírgula, ponto, dois-pontos, ponto e vírgula, parênteses e aspas retas quando necessário. Hífen é permitido SOMENTE dentro de palavras compostas e expressões coladas (ex.: color grading, 1x por semana, médio-prazo). Para pausar uma frase, use vírgula ou ponto, nunca um hífen solto.

titulo: curto e direto, até cerca de 8 palavras, nomeia o ponto.
detalhe: 1 a 3 frases explicando com a evidência do resumo, sem repetir literalmente o título.
resumo_executivo: 1 a 2 frases factuais sobre a reunião. Procure neutralidade descritiva (o que foi tratado), mas não force um tom contraditório com o sentimento: se a reunião foi de alerta, descreva os assuntos sem maquiar nem dramatizar.
Quando o resumo der o nome, use o nome em vez de repetir "o colaborador" de forma robótica.

====================================================================
PRINCÍPIO Nº 5: NOTA, SENTIMENTO E TEMAS (para agregação histórica)
====================================================================
nota_sugerida (inteiro de 1 a 10): avaliação geral coerente com o equilíbrio entre o que está indo bem e o que precisa ajustar, defensável apenas com o que está no texto. Resultados bons com ajustes pontuais costumam ficar na faixa 7 a 8; problemas graves e recorrentes puxam para baixo; excelência sem ressalvas puxa para cima. Quando o resumo NÃO sustenta uma avaliação (vago ou puramente logístico), escolha uma nota central (5 ou 6) e diga na nota_justificativa que a informação foi insuficiente. Nunca invente fatos para defender a nota.

nota_justificativa: 1 frase curta explicando a nota, citando o que pesou para cima e para baixo. Só cite fatos que realmente aparecem no resumo. Se a informação foi insuficiente, diga isso em vez de inventar causalidade.

sentimento: humor geral da reunião, independente da nota numérica. Use "positivo" quando predominam avanços e reconhecimento; "atencao" quando predominam problemas a corrigir ou a conversa foi majoritariamente de alerta; "neutro" quando é equilibrado, informativo ou puramente logístico. Reunião sem carga afetiva (ex.: só férias, escala, alinhamento operacional) é "neutro". Não force "positivo" ou "atencao" sem sinal no texto.

temas: lista curta de competências e assuntos tocados, em substantivos curtos e padronizados (ex.: "pontualidade", "comunicação", "qualidade de imagem", "edição", "direção de fotografia"), para agregar histórico ao longo do tempo. Tire-os do conteúdo REAL: cada tema deve ser rastreável a uma frase do resumo. Não invente tema que não aparece. IMPORTANTE: temas é uma camada transversal de agregação e PODE repetir assuntos já citados nos pontos. A regra de ouro anti-sobreposição vale APENAS entre pontos_positivos, pontos_atencao e pontos_desenvolvimento; temas está livre dela.

====================================================================
PROCESSO MENTAL ANTES DE RESPONDER
====================================================================
1. Liste internamente os fatos do resumo.
2. Classifique cada fato pelo eixo TEMPO + INTENÇÃO em no máximo UMA das três categorias de diagnóstico, aplicando as regras de desempate.
3. Extraia separadamente as AÇÕES acordadas para proximos_passos, com prazo só se citado, e responsável só se atribuído explicitamente.
4. Aplique a regra da ação sem aspiração: não crie ponto_desenvolvimento espelho de uma ação cuja vontade não foi declarada.
5. Releia as três listas de diagnóstico e elimine qualquer repetição entre elas.
6. Defina nota, justificativa, sentimento e temas a partir só do que foi dito.
7. Varra todos os campos e remova qualquer travessão, hífen solto, reticências ou aspas curvas, e qualquer invenção.

CHECKLIST FINAL ANTES DE ENTREGAR (confira mentalmente, item por item):
[ ] Um mesmo ponto aparece em duas das três categorias de diagnóstico? Se sim, mova para a mais adequada pelo teste TEMPO + INTENÇÃO e remova da outra.
[ ] Algum ponto_positivo é potencial ou vontade em vez de fato já ocorrido? Remova ou reclassifique.
[ ] Algum ponto_atencao é ambição de carreira em vez de defeito atual? Mova para desenvolvimento.
[ ] Algum ponto_desenvolvimento é, na verdade, correção de um erro com dano atual citado? Mova para atenção.
[ ] Criei algum ponto_desenvolvimento que só espelha uma ação acordada, sem aspiração declarada no resumo? Remova.
[ ] Inventei algum fato, número, prazo, nome, tema ou elogio que não está no resumo? Remova.
[ ] Preenchi responsavel ou prazo sem o resumo atribuir explicitamente? Deixe string vazia.
[ ] Sobrou algum travessão, hífen com espaços dos dois lados, reticências ou aspas curvas? Troque por pontuação comum.
[ ] resumo_executivo sempre presente; nota_sugerida coerente; sentimento sem sinal forçado.

Emita então o JSON do schema.`;

// Limpeza defensiva de pontuacao (cinto e suspensorio): tira travessao,
// hifen solto como pausa, reticencias e aspas curvas. Preserva hifen
// interno de palavra composta (color-grading, medio-prazo).
function limparPont(s) {
  if (typeof s !== 'string') return s;
  return s
    .replace(/\s*[—–]\s*/g, ', ')        // travessao/en-dash -> virgula
    .replace(/(\S) - (\S)/g, '$1, $2')   // " - " (hifen entre espacos) -> virgula
    .replace(/\s*…\s*/g, '. ')           // reticencia unicode -> ponto
    .replace(/\.{3,}/g, '.')             // ... -> .
    .replace(/[“”]/g, '"')               // aspas curvas duplas -> retas
    .replace(/[‘’]/g, "'")               // aspas curvas simples -> retas
    .replace(/,\s*,/g, ',')
    .replace(/\s+,/g, ',')
    .replace(/,\s*\./g, '.')
    .replace(/[ \t]{2,}/g, ' ')
    .trim();
}

// Aplica limparPont em todos os campos de texto do feedback estruturado.
function limparFeedback(o) {
  if (!o || typeof o !== 'object') return o;
  const limpaPontos = (arr) => Array.isArray(arr) ? arr.map(p => ({ titulo: limparPont(p && p.titulo), detalhe: limparPont(p && p.detalhe) })) : [];
  const limpaPassos = (arr) => Array.isArray(arr) ? arr.map(p => ({ acao: limparPont(p && p.acao), prazo: limparPont((p && p.prazo) || ''), responsavel: limparPont((p && p.responsavel) || '') })) : [];
  return {
    resumo_executivo: limparPont(o.resumo_executivo || ''),
    pontos_positivos: limpaPontos(o.pontos_positivos),
    pontos_atencao: limpaPontos(o.pontos_atencao),
    pontos_desenvolvimento: limpaPontos(o.pontos_desenvolvimento),
    proximos_passos: limpaPassos(o.proximos_passos),
    nota_sugerida: Math.max(1, Math.min(10, Math.round(Number(o.nota_sugerida) || 6))),
    nota_justificativa: limparPont(o.nota_justificativa || ''),
    sentimento: ['positivo', 'neutro', 'atencao'].includes(o.sentimento) ? o.sentimento : 'neutro',
    temas: Array.isArray(o.temas) ? o.temas.map(t => limparPont(String(t || ''))).filter(Boolean) : []
  };
}

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

// Rate limit best-effort em memoria (por instancia da funcao).
const _hits = new Map();
const RL_JANELA_MS = 60 * 1000;
const RL_MAX = 15;
function dentroDoLimite(userId) {
  const agora = Date.now();
  const arr = (_hits.get(userId) || []).filter(t => agora - t < RL_JANELA_MS);
  if (arr.length >= RL_MAX) { _hits.set(userId, arr); return false; }
  arr.push(agora);
  _hits.set(userId, arr);
  if (_hits.size > 500) { for (const [k, v] of _hits) { if (!v.some(t => agora - t < RL_JANELA_MS)) _hits.delete(k); } }
  return true;
}

// Monta a mensagem do usuario (nome/cargo sao so contexto de tom; resumo e a unica fonte de fato).
function montarUserMsg(nome, cargo, resumo, historico) {
  const n = (nome || '').toString().trim() || 'não informado';
  const c = (cargo || '').toString().trim() || 'não informado';
  let msg = 'Estruture o feedback desta reunião 1:1 seguindo as regras do sistema.\n\n';
  msg += 'Colaborador: ' + n + '\nCargo/função: ' + c + '\n\n';
  msg += 'Resumo/ata da reunião (texto cru escrito pelo gestor, entre as marcações abaixo). Esta é a ÚNICA fonte de verdade para os itens:\n<<<RESUMO\n' + resumo + '\nRESUMO>>>\n';
  const h = (historico || '').toString().trim();
  if (h) {
    msg += '\nContexto de reuniões anteriores (somente para coerência de nota e temas, NÃO é fonte de novos fatos): ' + h + '\n';
  }
  msg += '\nDevolva apenas o JSON do schema.';
  return msg;
}

async function chamarIA(API_KEY, userMsg) {
  const r = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: { 'x-api-key': API_KEY, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
    body: JSON.stringify({
      model: MODELO,
      max_tokens: 2000,
      temperature: 0.2,
      system: [{ type: 'text', text: SYSTEM_PROMPT, cache_control: { type: 'ephemeral' } }],
      output_config: { format: { type: 'json_schema', schema: OUTPUT_SCHEMA } },
      messages: [{ role: 'user', content: userMsg }]
    })
  });
  return r;
}

function parseSaida(data) {
  if (data && data.stop_reason === 'refusal') return { refusal: true };
  const bloco = Array.isArray(data && data.content) ? data.content.find(b => b && b.type === 'text') : null;
  let out;
  try { out = JSON.parse(bloco ? bloco.text : '{}'); } catch (e) { out = null; }
  if (!out || typeof out.resumo_executivo !== 'string') return null;
  if (!['positivo', 'neutro', 'atencao'].includes(out.sentimento)) return null;
  return out;
}

module.exports = async (req, res) => {
  if (req.method === 'OPTIONS') { res.status(204).end(); return; }
  if (req.method !== 'POST') { res.status(405).json({ ok: false, erro: 'Use POST.' }); return; }

  const API_KEY = (process.env.ANTHROPIC_API_KEY || '').trim();
  if (!API_KEY) {
    res.status(503).json({ ok: false, erro: 'A chave da IA ainda não foi configurada no servidor (ANTHROPIC_API_KEY na Vercel).' });
    return;
  }
  // A chave vai num header HTTP, que só aceita caracteres Latin1 (<=255). Se a chave foi
  // colada mascarada/truncada (ex.: contém "…"), o fetch quebraria com erro críptico.
  // Detecta e devolve mensagem acionável em vez de 500 genérico.
  if ([...API_KEY].some(c => c.charCodeAt(0) > 255)) {
    res.status(503).json({ ok: false, erro: 'A chave da IA no servidor está malformada (tem caractere inválido, provavelmente foi copiada truncada). Reconfigure a ANTHROPIC_API_KEY na Vercel colando a chave completa.' });
    return;
  }

  let body = req.body;
  if (typeof body === 'string') { try { body = JSON.parse(body); } catch (e) { body = {}; } }
  body = body || {};
  const resumo = (body.resumo || '').toString().trim();
  const nome = (body.nome || '').toString();
  const cargo = (body.cargo || '').toString();
  const historico = (body.historico || '').toString();

  const auth = req.headers['authorization'] || req.headers['Authorization'] || '';
  const token = auth.replace(/^Bearer\s+/i, '').trim();
  const userId = await validarUsuario(token);
  if (!userId) { res.status(401).json({ ok: false, erro: 'Sessão inválida. Faça login novamente.' }); return; }

  if (!resumo) { res.status(400).json({ ok: false, erro: 'Cole o resumo da reunião antes de estruturar.' }); return; }
  if (resumo.length > MAX_CHARS) { res.status(400).json({ ok: false, erro: `Resumo muito longo (${resumo.length} caracteres). Máximo ${MAX_CHARS}.` }); return; }
  if (!dentroDoLimite(userId)) { res.status(429).json({ ok: false, erro: 'Muitas estruturações em pouco tempo. Espere um minutinho e tente de novo.' }); return; }

  const userMsg = montarUserMsg(nome, cargo, resumo, historico);

  try {
    let r = await chamarIA(API_KEY, userMsg);
    if (!r.ok) {
      const detalhe = await r.text().catch(() => '');
      console.error('[feedback] Anthropic', r.status, detalhe.slice(0, 500));
      const msg = r.status === 401 ? 'A chave da IA está inválida no servidor.'
        : r.status === 429 ? 'Muitas requisições agora. Tente de novo em instantes.'
          : 'A IA está indisponível no momento. Tente de novo em instantes.';
      res.status(502).json({ ok: false, erro: msg });
      return;
    }
    let data = await r.json();
    let out = parseSaida(data);

    // Refusal explicito
    if (out && out.refusal) { res.status(422).json({ ok: false, erro: 'A IA não conseguiu processar esse resumo. Revise o conteúdo e tente de novo.' }); return; }

    // Re-tenta UMA vez se a forma veio errada (nota da implementacao).
    if (!out) {
      r = await chamarIA(API_KEY, userMsg);
      if (r.ok) { data = await r.json(); out = parseSaida(data); }
    }
    if (!out || out.refusal) { res.status(502).json({ ok: false, erro: 'Resposta inesperada da IA. Tente de novo.' }); return; }

    const feedback = limparFeedback(out);
    res.status(200).json({ ok: true, feedback });
  } catch (e) {
    console.error('[feedback] erro', e && e.message);
    res.status(500).json({ ok: false, erro: 'Erro ao falar com a IA. Tente de novo.' });
    return;
  }
};
