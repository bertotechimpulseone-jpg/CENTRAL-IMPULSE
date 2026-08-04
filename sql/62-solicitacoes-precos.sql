-- ============================================================
-- 62 - SOLICITAÇÕES: links por cliente, serviços/valores, cota grátis
--   • app_settings: novas chaves 'solicitacoes_formatos' e 'solicitacoes_links'
--     (lidas pelo formulário público anônimo)
--   • solicitacoes: colunas custo / aceito / link_slug
--   • RPC solic_count_cliente: conta solicitações de um cliente numa janela,
--     de forma segura (anon não lê a tabela direto)
-- Tudo "if not exists" / idempotente — seguro pra rodar mais de uma vez.
-- ============================================================

-- ---------- Colunas de custo/aceite na solicitação ----------
alter table public.solicitacoes add column if not exists custo numeric;
alter table public.solicitacoes add column if not exists aceito boolean not null default false;
alter table public.solicitacoes add column if not exists link_slug text;

-- ---------- Libera leitura anônima das novas chaves de config ----------
drop policy if exists app_settings_anon_solic on public.app_settings;
create policy app_settings_anon_solic on public.app_settings
  for select to anon
  using (key in ('solicitacoes_perguntas','logo_url','solicitacoes_formatos','solicitacoes_links'));

-- ---------- Serviços/formatos com preço (default; não sobrescreve) ----------
insert into public.app_settings(key, value) values
('solicitacoes_formatos',
 '[{"nome":"Carrossel","desc":"Vários cards deslizáveis (até 10) — ideal para tutoriais, listas e storytelling.","preco":0},{"nome":"Estático","desc":"Imagem única de feed — direto e objetivo.","preco":0},{"nome":"Reels / Vídeo","desc":"Vídeo curto e dinâmico, ótimo para alcance.","preco":0},{"nome":"Story","desc":"Conteúdo vertical e efêmero (24h) para engajamento rápido.","preco":0},{"nome":"Motion / Animação","desc":"Peça com movimento ou motion graphics.","preco":0},{"nome":"WhatsApp","desc":"Mensagem ou arte para disparo no WhatsApp.","preco":0},{"nome":"Impresso","desc":"Material para impressão (flyer, cartão, banner).","preco":0}]')
on conflict (key) do nothing;

-- ---------- Link exclusivo do cliente Topsport (default; não sobrescreve) ----------
-- client_id fica null e o casamento é por nome; depois você pode vincular o
-- cliente real pelo editor "Links por cliente" no sistema (mais preciso).
insert into public.app_settings(key, value) values
('solicitacoes_links',
 '[{"slug":"topsport","empresa_nome":"Topsport","client_id":null,"solicitantes":["Thomás","Bruno"],"cota_gratis":5,"cota_reset":"mensal"}]')
on conflict (key) do nothing;

-- ---------- Contagem segura de solicitações por cliente ----------
-- Conta por client_id quando informado; senão por nome da empresa.
-- SECURITY DEFINER: roda como dono (ignora RLS) e devolve só o número.
create or replace function public.solic_count_cliente(p_client_id uuid, p_empresa text, p_since timestamptz)
returns integer
language sql
security definer
set search_path = public
as $$
  select count(*)::int
  from public.solicitacoes s
  where s.created_at >= coalesce(p_since, timestamptz '1970-01-01')
    and (
      (p_client_id is not null and s.client_id = p_client_id)
      or (p_client_id is null and p_empresa is not null and lower(s.empresa_nome) = lower(p_empresa))
    );
$$;

grant execute on function public.solic_count_cliente(uuid, text, timestamptz) to anon, authenticated;

select 'Solicitações: links/serviços/cota configurados' as resultado;
