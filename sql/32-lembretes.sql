-- ============================================================
-- LEMBRETES pessoais por usuário
-- ============================================================
create table if not exists lembretes (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  texto text not null,
  data_hora timestamptz,        -- quando notificar
  client_id uuid references clients(id) on delete set null,
  done boolean default false,   -- foi resolvido?
  notificado boolean default false,  -- já avisou no dia?
  created_at timestamptz default now()
);

create index if not exists idx_lemb_profile on lembretes(profile_id);
create index if not exists idx_lemb_datahora on lembretes(data_hora);

alter table lembretes enable row level security;

drop policy if exists "auth all lembretes" on lembretes;
create policy "auth all lembretes" on lembretes
  for all to authenticated using (true) with check (true);
