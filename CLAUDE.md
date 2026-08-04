# IMPULSE-ONE — contexto do projeto (ler antes de editar)

Sistema interno de gestão da agência **Impulse One** (Porto Alegre/RS, dono: Vinícius/"Vini").
Este arquivo viaja com o código (OneDrive) pra o Claude Code entender o projeto em QUALQUER PC.

## O que é / estrutura
- **Um único arquivo:** `index.html` (~26k linhas, ~1,6MB) — SPA com **3 blocos `<script>` inline**.
- Backend: **Supabase** (projeto `pzqxceqtnsmpsiaejhjw`). Frontend: **Vercel**.
- Funções serverless de IA em `api/` (humanizar, gerar-conteudo, feedback) — exigem `ANTHROPIC_API_KEY` na Vercel.

## SEMPRE antes de salvar/deployar
1. Validar o JS: rode no diretório do projeto → deve imprimir **`blocos 3 erros 0`**:
   ```
   node _checkjs.cjs
   ```
   (Ele NÃO pega funções duplicadas — antes de criar `renderX`, `grep -n "function renderX"`.)
2. Deploy só com autorização do Vini. Comando (conta nova **central-impulse**, precisa do token vcp_ que o Vini fornece — NÃO guardar o token):
   ```
   vercel --prod --yes --scope central-impulse --token <TOKEN_vcp_DO_VINI>
   ```
   Conta antiga (`viniciusimpulseone`) foi migrada em ago/2026 — não usar mais.

## Supabase
- **Anon key** já embutida no `index.html` (pública, ok).
- **DDL/SQL** via Management API: `POST https://api.supabase.com/v1/projects/pzqxceqtnsmpsiaejhjw/database/query` com `Authorization: Bearer <PAT sbp_ do Vini>` — o PAT é **segredo de sessão, NUNCA salvar em arquivo/memória**; pedir ao Vini quando precisar.

## Regras de arquitetura que NÃO podem ser quebradas (aprendidas na marra)
- **UM único supabase client** (`_supa`); no `checkAuth` faz `setSession(...)` pra sessão valer nas queries. Nunca criar um 2º `createClient`.
- **Escritas que não podem falhar por sessão instável** (captação, credenciais) gravam com a **chave pública** via `_gravarAnon(tabela,tipo,payload,id)` (fetch no PostgREST) + RLS liberada pra `public` no INSERT/UPDATE (DELETE segue autenticado). Ver bloco "BLINDAGEM".
- **Blindagem:** todo write novo passa por `gravarSeguro`/fila (`impulse_gravacoes_pendentes` no localStorage → reenvia sozinho, nunca perde). Erro global → `mostrarManutencao()` ("⚙️ em manutenção"). Leitura de lista que a UI mostra síncrono deve ser **pré-carregada** (ex: `loadAllCredentials`).
- **`vercel.json`** manda `Cache-Control: no-cache` em `/` e `/index.html` — senão o navegador segura o HTML antigo e "corrige mas não aparece".
- **Nunca chavear storage por índice posicional** — usar `cli._dbId` (UUID). Regra do `_dbId`.
- **Logo/foto que aparece em LISTA vem no load principal** (`select *`); só blob que abre sob clique (briefing base64) é lazy.
- **Página pública** (`?cap`, `?check`, `?solicitar`, etc.) NÃO pode depender de arrays em memória (`clients`/`captacoes`/`team`) nem de id posicional — usar o objeto lido direto do banco (ex: `window._publicCap`).
- Modais no mobile: altura em **dvh** (não vh); scroll no `.modal-body`.
- Nome de exibição do cliente = helper `_nomeCli(cli)` (usa `nome_social||name`).

## Memória detalhada
As anotações finas ficam na auto-memória do Claude Code (`~/.claude/projects/.../memory/`), que é **local por PC** e NÃO sincroniza. Este `CLAUDE.md` é o resumo que viaja junto. Ao aprender algo novo importante, atualizar aqui também.
