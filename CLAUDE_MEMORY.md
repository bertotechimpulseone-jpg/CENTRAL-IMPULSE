# Memória do Claude — IMPULSE ONE

**Última atualização:** v3.47 (2026-05-28)

## ⚠️ REGRA INVIOLÁVEL — INTEGRIDADE DE DADOS

**O sistema está em produção real. Não há margem pra perder dados nem fazer mudanças que o user não pediu.**

Antes de QUALQUER alteração:

1. **Escopo cirúrgico.** Mexer só no que o user pediu. Nada de "já que estou aqui, vou também otimizar X" ou "vou refatorar Y". Se identificar bug paralelo, **avisar e perguntar** — nunca consertar de moto-próprio.

2. **Nunca DELETE / TRUNCATE / DROP automaticamente.** Nem em SQL, nem via Supabase JS. Se precisar limpar dados, gerar o SQL e pedir o user pra rodar manualmente.

3. **UPDATE só nos campos explicitamente solicitados.** Nada de `update({campo1: novo, campo2: '', campo3: null})` pra "limpar de uma vez". Sempre `update({campoEspecifico: valor})`.

4. **Cuidado com array.length = 0 / arr.splice(0)** em arrays globais (`clients`, `team`, etc). Só limpar quando vai recarregar **do mesmo source** logo em seguida. Nunca limpar sem recarregar.

5. **Mock vs real.** Arrays mock antigos foram esvaziados (`#11-#13`). Não repopular com dados de exemplo "pra ficar bonito" — fica vazio até o user cadastrar.

6. **Não auto-criar "registros padrão"** sem o user pedir. Ex: não criar Dashboard, não criar cliente exemplo, não criar pagamento fixo automático.

7. **Antes de salvar/sobrescrever campos grandes** (jsonb tipo `journey_steps`, `antes_impulse`, `services`), confirmar que o array novo contém o conteúdo correto — `[]` vazio salva e apaga o que tinha.

8. **Migrations SQL são append-only.** Nunca alterar SQLs antigos da pasta `sql/`. Criar novo número (50, 51, ...) se precisar.

9. **Decisões de design só com confirmação.** Mudar cor, layout, nome de aba, ordem de itens — perguntar antes. O user tem um modelo mental do sistema.

10. **Se errar, reverter na mesma sessão.** Não acumular "vou consertar depois".

## Padrões recorrentes de bug — SEMPRE checar antes de qualquer mudança

### -1. Cache localStorage chaveado por ÍNDICE POSICIONAL (mistura dados entre clientes)

**Sintoma:** Contrato/plano/dado de um cliente aparece na aba de OUTRO cliente. Some/embaralha quando a lista muda.

**Causa:** `clients.push({id: idx+1, _dbId: cl.id, ...})` — o `id` é índice posicional por ordem alfabética. Cache local `client_overrides_<id>` usava esse índice. Quando entra/sai/renomeia cliente, o índice 9 vira outro cliente e `aplicarCacheLocalClientes` aplica o cache do antigo no novo (quando o campo do banco está vazio). O banco fica intacto (writes vão por `_dbId`), mas a EXIBIÇÃO mistura.

**Fix (v3.94):** cache SEMPRE por `cli._dbId` (estável), nunca por `cli.id`. `_limparCacheClientesPosicional()` removeu chaves `client_overrides_<inteiro>` uma vez (flag `_cli_cache_migrado_v2`).

**ATENÇÃO — mesmo bug latente no cronograma:** `cronograma[cli.id]` e `_cronLocalSet(cli.id,...)` → cache `cron_<índice>_<mês>` também é posicional. Pode misturar designer/tráfego entre clientes. AINDA NÃO corrigido (esperar o user reportar ou pedir). Corrigir = re-chavear por `_dbId` + limpar `cron_<inteiro>_*`.

**MESMO BUG nos CONTRATOS (custom_links) — JÁ CORRIGIDO (v3.95):** o botão "Contrato" usava `openLinksManager('client-'+cli.id+'-contrato')` (posicional). Como clientes novos (Club NEX 28/05, Delta 12/06...) deslocaram a ordem alfabética, 12 contratos apareciam no cliente errado (Eucassel↔iGet, Qualific↔Steel Desk, etc). Corrigido: (1) código agora usa `client-${cli._dbId}-contrato`; (2) remapeei as 20 linhas de `custom_links` no banco para o `_dbId` do dono real — reconstruído pela data de criação do contrato vs ordem alfabética dos clientes existentes naquela data. Backup reversível em `localStorage['_backup_contratos_remap_v1']` (id→chave antiga). O link de compartilhar (`/c/${cli.id}` linha ~5926) ainda usa posicional mas é cosmético.

**Regra geral:** qualquer cache/estado/chave persistente de cliente DEVE usar `_dbId`, nunca o `id` posicional.

### 0. Campo novo no Supabase mas não mapeado no load

**Sintoma:** Toggle persiste no banco mas ao recarregar volta pro estado anterior. Tipicamente checkbox/flag (oculto, ativo, arquivado).

**Causa:** Adiciona-se um `cl.campo` no `update()` mas esquece de incluir `campo: cl.campo` dentro do `clients.push({...})` no `loadDataFromSupabase`.

**Já regrediu:** campo `oculto` em `clients` (cronograma → ocultar cliente).

**Fix preventivo ao criar campo persistente:**
1. SQL migration adiciona coluna
2. Função `toggleXxx`/`updateXxx` faz UPDATE
3. **Adicionar `campo: cl.campo || valorPadrao` no push do load** ← essa etapa esquece sempre
4. Renderizadores leem `cli.campo`

### 1. Funções `loadXxx()` órfãs (não chamadas no boot)

**Sintoma:** Aba abre mas mostra dados zerados/vazios. Console mostra todos os logs verdes ([LOGIN], [MAIN], [HEALTH] OK) e nenhum erro vermelho.

**Causa:** Função `async function loadXxx()` está definida, lê do Supabase, mas nunca é invocada no boot. A variável global associada fica `[]`.

**Lugar correto pra chamar:** dentro de `async function startApp(user)` (~linha 3440), no array `_loaders` E no objeto `_loaderMap` do bloco "CARREGA TODAS AS TABELAS DO SUPABASE".

**Já regrediu antes:** loadColaboradorPagamentos, loadPagamentosFixos, loadFerias, loadRelacionamentos, loadParcerias, loadCampanhas, loadLembretes, loadEventosCalendario, loadCustomLinks, loadTransactions, loadBudgetServices, loadBudgetClients, loadOrcamentosSalvos, loadPontoLogs.

**Diagnóstico rápido:**
```bash
grep -c "loadXxx\s*(" index.html
```
Se der `1` → órfã (só a definição). Se der `2+` → checar se alguma chamada está no boot.

**Ao criar uma feature nova:** adicionar a função no `_loaderMap` e no array `_loaders` do startApp — sempre.

---

### 2. Null bytes (`\x00`) no fim do arquivo

**Sintoma:** Tela completamente branca depois de deploy. Chrome para de parsar HTML no primeiro null byte. Sidebar carrega parcial, conteúdo vazio.

**Causa:** Edit tool ou sincronização do OneDrive às vezes pad o arquivo com null bytes no fim.

**Fix preventivo após qualquer edição grande:**
```python
with open('index.html','rb') as f: raw = f.read()
clean = raw.replace(b'\x00', b'')
with open('index.html','wb') as f: f.write(clean)
```

**Já mordeu 4+ vezes.** Vale rodar SEMPRE no fim das edições.

---

### 3. Truncamento do fim do arquivo

**Sintoma:** Função `excluirTarefa` (última do arquivo) sai cortada no meio, sem `</script></body></html>`.

**Fix:** Adicionar manualmente:
```html
));
};
</script>
</body>
</html>
```

---

### 4. Regex com combining marks literais

**Sintoma:** Site em branco mesmo com JS validado por `node --check`.

**Causa:** Regex tipo `/[̀-ͯ]/g` com chars Unicode literais (U+0300-U+036F) às vezes não é parseado corretamente pelo Chrome dependendo do encoding do response.

**Fix:** Sempre usar escape Unicode: `/[̀-ͯ]/g`.

---

## Checklist obrigatório ANTES de mandar deploy

1. ✅ `python3 -c "...replace(b'\x00', b'')..."` — tira null bytes
2. ✅ `tail -c 100 index.html` — confirma que termina com `</html>`
3. ✅ Conta `<script` e `</script>` — devem bater (6/6 atualmente)
4. ✅ `node --check /tmp/check.js` no script principal embrulhado em `(async function(){...})();`
5. ✅ Se adicionou função `loadXxx()` → verificar se está no `_loaderMap` do startApp
6. ✅ Atualizar versão no rodapé da sidebar (linha ~1780)

## Validação rápida do JS

```python
import re
with open('index.html','r',encoding='utf-8') as f: txt = f.read()
last_open = txt.rfind('<script>')
last_close = txt.rfind('</script>')
main = txt[last_open+8:last_close]
op, cl = main.count('{'), main.count('}')
print(f'Main script: {op}={cl} diff={op-cl}')
wrapped = '(async function(){\n' + main + '\n})();'
with open('/tmp/check.js','w') as f: f.write(wrapped)
# subprocess.run(['node','--check','/tmp/check.js'])
```

## Estrutura conhecida do arquivo

- 3 scripts inline:
  - Script 0 (~330 chars): config IMPULSE_CONFIG
  - Script 1 (~4735 chars): auth helpers (doLogin, etc)
  - Script 2 (~878000 chars): código principal (DataLayer, render*, modais)
- 3 scripts com `src=`: Chart.js, jsPDF, Supabase
- Total: ~975KB

## Tabela de apelidos da equipe

Definida em `_APELIDOS_EQUIPE` (índice ~linha 11774). Usada por `_primeirosNomesEquivalentes(a, b)` pra comparar nomes em filtros de "isso é meu?".

Grupos atuais:
- yas, yasmin, yasmim, yasmine, yasmyn
- vini, vinicius, vinícius
- gabi, gabriela, gabriella
- gabriel, gael
- heidi, heidy, heydi, heydy
- haisa, haysa, haísa
- andre, andré
- leticia, letícia, leti
- ederson, éderson, eder

**Cuidado:** "gabriel" NÃO inclui "gabi" porque Gabi é uma sócia diferente do Gael (Gabriel). Decisões de equivalência são por pessoa, não por similaridade textual.

Pra adicionar pessoa nova com apelido, edita só o array `_APELIDOS_EQUIPE` — todos os filtros que usam `capEhMinha` ou `_primeirosNomesEquivalentes` herdam automaticamente.

## Pasta projeto

`C:\Users\conta\OneDrive\Área de Trabalho\IMPULSE-ONE\`
- `index.html` — arquivo único (SPA inteiro)
- `sql/` — migrations Supabase numeradas
- `CLAUDE_MEMORY.md` — este arquivo

## Decisões de design (visual / UX)

### Tráfego Pago
- Detalhe do cliente: gráfico Gasto×Resultados **separado por plataforma** (1 chart por plataforma com 2+ campanhas).
- Cores das plataformas:
  - Meta/Facebook/Instagram: `#1877f2` (azul Meta)
  - Google/YouTube: `#ea4335` (vermelho Google)
  - TikTok: `#000000` (preto)
  - LinkedIn: `#0a66c2` (azul corporativo)
  - Outros: `#0ea5e9` (azul padrão)
- Linha de resultados sempre verde `#22c55e`.
- Detecção da plataforma é case-insensitive e por substring (`pn.includes('meta')` etc) — tolera variações como "Meta Ads", "Facebook Ads", "Instagram Ads" todas como família Meta.
