-- ============================================================
-- Férias programadas + Aniversário no perfil
-- ============================================================

-- 1) Tabela de períodos de férias programados
create table if not exists ferias_programadas (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  data_inicio date not null,
  data_fim date not null,
  dias integer,                -- preenchido automaticamente, mas editável
  observacoes text,
  status text default 'programada',  -- programada | em_andamento | concluida | cancelada
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_ferias_profile on ferias_programadas(profile_id);
create index if not exists idx_ferias_inicio on ferias_programadas(data_inicio);
create index if not exists idx_ferias_status on ferias_programadas(status);

alter table ferias_programadas enable row level security;

drop policy if exists "auth all ferias" on ferias_programadas;
create policy "auth all ferias" on ferias_programadas
  for all to authenticated using (true) with check (true);

-- 2) Adiciona campo de aniversário no perfil (data de nascimento)
alter table profiles add column if not exists birthday date;

-- 3) View útil pra próximos eventos (férias + aniversários + admissões)
-- (opcional, mas deixa documentado)
