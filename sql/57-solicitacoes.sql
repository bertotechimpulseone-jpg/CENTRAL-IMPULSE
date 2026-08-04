-- ============================================================
-- 57 - SOLICITAÇÕES (pedidos de conteúdo dos clientes via link público)
--   • Formulário público (sem login): qualquer um com o link envia.
--   • Funil interno: só o time autenticado vê e move as solicitações.
-- ============================================================

create table if not exists public.solicitacoes (
  id               uuid primary key default gen_random_uuid(),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz,
  empresa_nome     text not null,
  client_id        uuid,                       -- = clients.id (quando casou no autocomplete)
  solicitante_nome text not null,
  respostas        jsonb not null default '{}'::jsonb,
  prazo_entrega    date,
  status           text not null default 'nova',   -- nova | andamento | entregue
  priority         text not null default 'med'
);

grant select, insert, update on public.solicitacoes to authenticated;
grant insert on public.solicitacoes to anon;     -- formulário público

alter table public.solicitacoes enable row level security;

-- INSERÇÃO: público (anon) e time (authenticated)
drop policy if exists solic_insert on public.solicitacoes;
create policy solic_insert on public.solicitacoes
  for insert to anon, authenticated with check (true);

-- LEITURA: só o time autenticado
drop policy if exists solic_select on public.solicitacoes;
create policy solic_select on public.solicitacoes
  for select to authenticated using (true);

-- MOVER NO FUNIL / EDITAR: só o time autenticado
drop policy if exists solic_update on public.solicitacoes;
create policy solic_update on public.solicitacoes
  for update to authenticated using (true) with check (true);

-- EXCLUIR: só o time autenticado
grant delete on public.solicitacoes to authenticated;
drop policy if exists solic_delete on public.solicitacoes;
create policy solic_delete on public.solicitacoes
  for delete to authenticated using (true);

-- ---------- View pública só com id + nome das empresas (autocomplete) ----------
-- Não expõe MRR, contratos nem nada sensível — apenas id e nome.
create or replace view public.clientes_publicos as
  select id, name from public.clients;
grant select on public.clientes_publicos to anon, authenticated;

-- ---------- Config das perguntas (app_settings) com leitura anônima da key ----------
create table if not exists public.app_settings (
  key text primary key,
  value text,
  updated_at timestamptz default now()
);
grant all on public.app_settings to authenticated;
grant select on public.app_settings to anon;

alter table public.app_settings enable row level security;

-- garante acesso total do time (não quebra usos existentes, ex.: logo_url)
drop policy if exists app_settings_auth_all on public.app_settings;
create policy app_settings_auth_all on public.app_settings
  for all to authenticated using (true) with check (true);

-- leitura anônima SOMENTE da key das perguntas (para o formulário público)
drop policy if exists app_settings_anon_solic on public.app_settings;
create policy app_settings_anon_solic on public.app_settings
  for select to anon using (key in ('solicitacoes_perguntas','logo_url'));

-- perguntas padrão (não sobrescreve se já existir)
insert into public.app_settings(key, value)
values (
  'solicitacoes_perguntas',
  '["Qual conteúdo?","Qual o formato desse conteúdo?","Qual o título?","Qual o objetivo?","Descrição","Quando deve ser postado?"]'
)
on conflict (key) do nothing;
