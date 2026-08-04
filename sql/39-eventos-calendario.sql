-- ============================================================
-- Eventos personalizados do calendário
-- ============================================================

create table if not exists eventos_calendario (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid references profiles(id) on delete set null,
  titulo text not null,
  descricao text,
  data_inicio date not null,
  hora text,                              -- HH:MM (texto pra simplificar)
  data_fim date,                          -- pra eventos de múltiplos dias
  tipo text default 'evento',             -- evento | reuniao | treinamento | prazo | tarefa | outro
  cor text default '#0ea5e9',             -- cor do evento no calendário
  client_id uuid references clients(id) on delete set null,
  local text,
  link text,                              -- link da reunião, mapa, etc
  notificar boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_evcal_data on eventos_calendario(data_inicio);
create index if not exists idx_evcal_tipo on eventos_calendario(tipo);
create index if not exists idx_evcal_profile on eventos_calendario(profile_id);

alter table eventos_calendario enable row level security;

drop policy if exists "auth all eventos" on eventos_calendario;
create policy "auth all eventos" on eventos_calendario
  for all to authenticated using (true) with check (true);
