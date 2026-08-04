# HANDOFF — IMPULSE-ONE (continuar em nova sessão)

Gerado no fim de uma sessão longa (03/07/2026, Brasília). Contexto chegou ao limite. Este doc + os arquivos de memória (`~/.claude/projects/.../memory/`) permitem retomar de onde parou.

## Projeto
- SPA single-file: `C:\Users\conta\OneDrive\Área de Trabalho\IMPULSE-ONE\index.html` (~1.5MB, JS inline em 3 blocos `<script>`).
- Backend Supabase (projeto **pzqxceqtnsmpsiaejhjw**, org **"impulso"**, NÃO "Organiza ai"). Prod Vercel: **impulse-one.vercel.app** (org viniciusimpulseone, projeto "impulse").
- **Validar antes de deploy:** `node "C:/Users/conta/OneDrive/Área de Trabalho/IMPULSE-ONE/_checkjs.cjs"` → tem que dar `blocos 3 erros 0`.
- **Deploy:** `cd "IMPULSE-ONE" && vercel --prod --yes` (Vercel já autenticado; se pedir login use `npx.cmd vercel login` no PowerShell — `vercel`/`npx` puros falham lá). **Deploy exige autorização explícita do Vini a cada vez** (regra da sessão: perguntar via AskUserQuestion, esperar "Sim", só então rodar).

## ⏳ EM ANDAMENTO — Feature I3 (falta 2 passos: rodar SQL + deploy)
O Vini pediu completar a aba **I3 ("Combinados dos Sócios")** espelhando a planilha "Operações e RH", com 3 partes (todas escolhidas): Painel da Equipe, expandir as atas, e alimentar com o histórico. **Frontend BUILDADO + validado, mas NÃO deployado. SQL pronto mas NÃO rodado.**

### Já feito (local, no index.html + sql/):
- **`sql/69-i3-equipe-atas.sql`** — PRONTO E COMPLETO (schema + seed). Cria tabela `i3_equipe` (roster: colaborador, cargo, inicio, contrato, vcto_contrato, manual_conduta bool, valores, aniversario, ultimo_feedback, ultima_bonif, farol, clientes jsonb, ativo, ordem) + RLS `for all to authenticated using(true)` (mesmo padrão frontend-gated do I3) + trigger updated_at; faz `alter table i3_reunioes add column if not exists` de **pontos_positivos / financeiro / pontos_para_ver**; e **SEED idempotente** de 21 colaboradores (roster de mai/2025) + 16 atas históricas (jan/25→mai/26). Idempotente (`if not exists`, `where not exists`).
- **Frontend Painel da Equipe** (index.html, funções inseridas ANTES de `renderI3`): `loadI3Equipe`, `renderI3EquipePainel` (tabela: Farol clicável colorido, contrato+vcto, valores, aniversário, carteira de clientes em chips, editar/excluir), `openI3EquipeModal`/`salvarI3Equipe`/`excluirI3Equipe`/`ciclarI3Farol`, `_I3_FAROIS`/`_i3FarolInfo`/`_i3EquipeClientes`, state `_i3Equipe`/`_i3EquipeCarregado`/`_i3EquipeErro`. `renderI3` agora faz `await loadI3Equipe()` e injeta `renderI3EquipePainel()` logo após o cabeçalho.
- **Atas expandidas:** 3 campos novos no modal (`i3rPos`/`i3rFin`/`i3rVer`), no payload do `salvarI3Reuniao`, e 3 `_i3SecaoCard` no card da ata (pontos_positivos amarelo, financeiro verde, pontos_para_ver laranja).
- JSONs-fonte copiados pra `IMPULSE-ONE/sql/_i3_seed/` (i3_equipe.json, i3_atas.json) — caso precise regenerar o seed.

### FALTA (próxima sessão):
1. **Rodar o `sql/69-i3-equipe-atas.sql`** no Supabase (SQL Editor). ⚠️ **DESATIVAR o Chrome Translate em supabase.com antes** (ele quebra o dashboard com erro React removeChild). Estar logado na org **"impulso"** (não "Organiza ai"). Se rodar pelo navegador: injetar via base64→`atob`→`TextDecoder`→`monaco.editor.getEditors()[0].setValue(sql)`, conferir `getValue()` (o Translate só traduz a exibição), clicar Run, confirmar "operações destrutivas" (é só DDL, seguro). OU pedir o Vini colar e dar Run.
2. **Deploy** do frontend (`vercel --prod --yes`) **DEPOIS** de rodar o SQL (as colunas novas de i3_reunioes precisam existir antes de editar ata). Frontend degrada com elegância se rodar antes (painel mostra "rode o sql/69").
3. Verificar: abrir I3 logado como sócio → Painel da Equipe com 21 pessoas + Farol; atas com as seções novas.
- Observação: o seed veio de planilha bagunçada — alguns valores têm ruído (ex.: cliente "R$ 225.00" na Sabrina, "Antonio (planilha separada)"). Tudo editável na UI. NÃO reconstruir férias/freelas (já existem no sistema — foram ignorados de propósito).

## 🔴 PENDÊNCIAS DO VINI (ação dele)
1. **ANTHROPIC_API_KEY na Vercel está MALFORMADA** — foi colada truncada/mascarada (tem um "…" na posição 15). Quebra **Feedback** (`api/feedback.js`) e **Humanizar Texto** (`api/humanizar.js`). Ele precisa re-colar a chave COMPLETA em Vercel → Settings → Environment Variables → ANTHROPIC_API_KEY (gerar nova em console.anthropic.com se não tiver a inteira), e aí um **redeploy**. Guards já detectam e mostram msg clara. Teste: `vercel whoami --token X` numa chave boa retorna o usuário.
2. Rodar **`sql/67-rls-nomes-sync.sql`** (Heidy ler Materiais) — não confirmado.
3. Marcar **Eduarda como Videomaker** no cadastro (Equipe → cargo).
4. Re-subir **materiais** perdidos.
5. **Vazamento:** tabela `profiles` legível por anônimo (dados da equipe/salário). Falta SQL restringindo SELECT a `authenticated` — aguardando OK do Vini.

## ✅ FEITO E NO AR nesta sessão (impulse-one.vercel.app)
- **Solicitações:** preços só aparecem depois da cota grátis acabar (`_mostraPrecos`).
- **Feedback (aba):** refeita — cola resumo da reunião → IA estrutura em positivos/atenção/desenvolvimento/próximos passos + histórico. `api/feedback.js` (2ª serverless, Opus 4.8). **Só funciona quando a chave for corrigida.**
- **Pagamentos:** gravação confirmada (`.select()` + reverte em erro), sem pulo de scroll, **bug do André** (checkbox auto-desmarcava — `atualizarTotalAndre` re-renderizava e apagava a marcação; agora `_andreSyncValorInput` via DOM sem re-render), **observações visíveis** ao lado da descrição.
- **Pesquisa NR-1:** obrigatória a partir de 03/07/2026 pra todos; **Eduarda e Gabrielly isentas até 01/08/2026** (`NR1_EXCECOES`, lê `_currentProfile.full_name`); flag gravada em QUALQUER envio; mês em fuso Brasília. **Bug "não passa pro lado" RESOLVIDO** — causa raiz: botão `id="pesqProximo"` IGUAL ao nome da função → em handler inline o id do form sombreia a global → TypeError. Renomeado pra `pesqBtnProx`/`pesqBtnVoltar`. Feedback de pergunta faltante virou destaque visual (sem `alert()`, que some no celular). Testado no navegador (7 partes avançam).
- **Checklist:** colisão Gabrielly→Gabriel resolvida (`getMeuChecklistNome` resolve por `_dbId`; `_membroPorPrimeiroNome` = 1º nome EXATO, nunca `startsWith`).
- **Desligamento (aba nova, grupo Interno, restrita à gestão):** `sql/68` JÁ RODADO (tabela existe + 6 entrevistas seed). 10 perguntas, RLS `is_gestor_app`. + **Painel de Insights** (toggle): motivos de saída (gráfico), temas recorrentes, central de melhorias — client-side, não precisa de IA.

## GOTCHAS / LIÇÕES
- **Nunca** dar a um elemento `id`/`name` igual ao nome de uma função chamada por handler inline no mesmo `<form>` (named-access do form sombreia a global → TypeError). Foi a raiz do bug do wizard NR-1.
- **Chrome Translate quebra o dashboard do Supabase** (removeChild). Desativar em supabase.com.
- Identidade sempre por **`_dbId`** (UUID), nunca índice posicional nem `startsWith` de nome (ver memória `impulse-one-positional-id-rule`).
- Supabase: DDL só via SQL Editor (a anon key não cria tabela). Padrão anti-"materiais sumiram": frontend detecta tabela faltando e mostra "rode o sql/NN".
- Escrita honesta em pagamentos/CRUD: `.update(...).select()` e checar `data.length===0` (RLS bloqueia sem erro).

## Memórias atualizadas (~/.claude/projects/.../memory/)
impulse-one-desligamento, impulse-one-pesquisa-nr1, impulse-one-positional-id-rule, impulse-one-feedback-estruturado, impulse-one-storage-e-uploads, MEMORY.md (índice).
