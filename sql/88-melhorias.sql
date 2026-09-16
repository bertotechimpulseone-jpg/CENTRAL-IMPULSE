-- ============================================================
-- Solicitacoes de melhoria e bugs do sistema.
-- Quem abre: administracao e a Francielle, dentro do IMPULSE-ONE.
-- Quem responde: a Bertotech, pelo painel dela (service role, no servidor).
-- ============================================================

create table if not exists public.melhorias (
  id             uuid primary key default gen_random_uuid(),
  criado_em      timestamptz not null default now(),

  tipo           text not null,            -- bug | melhoria
  titulo         text not null,
  descricao      text not null,
  area           text,                     -- aba/tela do sistema
  prioridade     text not null default 'media',

  autor_nome     text,
  autor_email    text,

  status         text not null default 'recebida',
  resposta       text,                     -- o que a Bertotech respondeu
  atualizado_em  timestamptz not null default now(),
  atualizado_por text,
  historico      jsonb not null default '[]'::jsonb,

  constraint melhorias_tipo       check (tipo in ('bug','melhoria')),
  constraint melhorias_prioridade check (prioridade in ('baixa','media','alta')),
  constraint melhorias_status     check (status in ('recebida','em_analise','em_andamento','concluida','recusada'))
);
create index if not exists melhorias_status_idx on public.melhorias (status, criado_em desc);
create index if not exists melhorias_tipo_idx   on public.melhorias (tipo);

-- Quem pode ver e abrir solicitacao. Um lugar so pra editar a lista.
create or replace function public.melhorias_permitido()
returns boolean
language sql
stable
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'vini@impulseone.com.br',
    'vinicius@impulseone.com.br',
    'haisa@impulseone.com.br',
    'heidy@impulseone.com.br',
    'edersonoliveira.eder@gmail.com',
    'fran@impulseone.com.br'
  );
$$;

alter table public.melhorias enable row level security;

drop policy if exists melhorias_ler on public.melhorias;
create policy melhorias_ler on public.melhorias
  for select to authenticated using (public.melhorias_permitido());

-- So insere em nome proprio: o autor_email tem que ser o do login.
drop policy if exists melhorias_abrir on public.melhorias;
create policy melhorias_abrir on public.melhorias
  for insert to authenticated
  with check (public.melhorias_permitido()
              and lower(coalesce(autor_email,'')) = lower(coalesce(auth.jwt() ->> 'email','')));

-- Sem update/delete pelo app: status e resposta so mudam pela Bertotech.
