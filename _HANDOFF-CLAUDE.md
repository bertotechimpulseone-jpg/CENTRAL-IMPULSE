# Handoff — Impulse One (leia antes de mexer)

Escrito em 04/08/2026. São **dois projetos diferentes**, não confunda.

---

## 1. O SISTEMA (este repositório)

**Central Impulse One** — o sistema interno da agência.

- No ar: https://sistema.iimpulseone.com.br
- Repositório: `bertotechimpulseone-jpg/CENTRAL-IMPULSE`, branch `main`
- Vercel: time `central-impulse`, projeto `impulse-one`
- **Deploy é automático**: todo push na `main` publica sozinho. Não use `vercel deploy`.
- Estrutura: um `index.html` de ~1,7 MB com 35 abas, mais `api/`, `sql/`, `documentos/`.
- Banco: Supabase projeto `Central Impulse` (ref `pzqxceqtnsmpsiaejhjw`).

### Como o menu funciona
- A lista de abas é um array de `{id,label,icon}` agrupado por `group:` (Principal, Estratégia, Interno).
- `renderPage(page)` mapeia `id -> renderXxx`.
- `canAccess(page)` controla permissão por perfil.

### Aba "Site" (adicionada em 04/08)
35ª aba, no grupo Estratégia depois do I3. Abre `iimpulseone.com.br/?editor=1`
num iframe e passa a sessão do usuário por `postMessage`. São 58 linhas, nada removido.

### REGRA DE OURO
O dono edita de **dois computadores**. Sempre `git pull` antes de mexer e
`git push` assim que terminar. Nunca publicar por fora do Git.

---

## 2. O SITE (outro repositório)

**Site institucional** — não fica aqui.

- No ar: https://iimpulseone.com.br
- Repositório: `bertotechimpulseone-jpg/site-impulse-one`, branch `main`
- Vercel: mesmo time, projeto `site-impulse-one`. Push publica sozinho.
- Um `index.html` só, mais `logos/` (32 clientes), `equipe/` (fotos), `antigo/` (site velho arquivado).

### Textos editáveis
Todo texto tem `data-cms="chave"` (287 no total). O site lê a tabela
`site_conteudo` do Supabase e aplica por cima do HTML. Se o Supabase cair, o
site mostra o texto padrão. A equipe edita pela aba **Site** do sistema.

### Formulário do diagnóstico
Edge function `diagnostico` (verify_jwt off) grava em `public.leads` usando
service role, porque a tabela só aceita usuário autenticado. Aparece na aba
**Comercial** do sistema. O WhatsApp abre em seguida, com corte de 2,5s.

---

## Contas (todas de bertotech.impulseone@gmail.com)

- GitHub: `bertotechimpulseone-jpg`
- Vercel: time `central-impulse`
- Supabase: projeto `Central Impulse`
- Hostinger: só o domínio e o DNS. O site NÃO está mais hospedado lá.

**Os tokens não estão neste arquivo de propósito — este repositório é público.**
Peça ao dono.

---

## Armadilhas descobertas (não repita)

1. **CLI da Vercel devolve BLOCKED** com token de API nesta conta (plano Hobby).
   Publicação é por Git. Se precisar forçar, a API REST `POST /v13/deployments` passa.
2. **`overflow-x:hidden` esconde overflow real.** Meça `document.documentElement.scrollWidth`
   contra `clientWidth`, não confie no olho.
3. **Atributo `width`/`height` em `<img>` anula o `aspect-ratio` do CSS** se não houver `height:auto`.
4. **`requestAnimationFrame` congela em aba oculta.** Nunca gate conteúdo em animação
   disparada por rAF; sempre deixe uma rede de segurança.
5. **DNS do domínio fica na Hostinger**, mas aponta para a Vercel (A `@` -> 76.76.21.21).
   Não existe registro AAAA de propósito.
6. **"Impulse One" usa espaço rígido** no site para nunca quebrar entre linhas.

---

## Pendências

- **Depoimentos reais no site.** Os do PDF de orçamento são texto de exemplo repetido, não servem.
- **Converter imagens do site para WebP** (hoje ~1,1 MB entre logos e fotos).
- **Marcar origem do lead** como "Site" num campo próprio, hoje só aparece nas observações.
