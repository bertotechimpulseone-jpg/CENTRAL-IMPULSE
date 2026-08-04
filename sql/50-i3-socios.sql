-- ============================================================
-- 50-i3-socios.sql
-- Aba I3 — combinados dos sócios (reuniões mensais + Impulse Learning semanal)
-- ============================================================

-- Tabela 1: reuniões mensais dos sócios (uma ata por mês)
create table if not exists i3_reunioes (
  id uuid primary key default gen_random_uuid(),
  data_reuniao date not null,
  titulo text,
  -- Encontro presencial mensal definido nessa reunião
  encontro_data date,
  encontro_local text,
  encontro_evento_id uuid references eventos_calendario(id) on delete set null,
  -- Seções da ata
  obs_rh text default '',
  conclusoes text default '',
  pontos_atencao text default '',
  pontos_analisar text default '',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_i3_reunioes_data on i3_reunioes(data_reuniao desc);

-- Tabela 2: reuniões semanais Impulse Learning
create table if not exists i3_learning (
  id uuid primary key default gen_random_uuid(),
  data date not null,
  responsavel text,
  tema text,
  observacoes text default '',
  evento_calendario_id uuid references eventos_calendario(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_i3_learning_data on i3_learning(data desc);

-- Trigger pra updated_at automatico
create or replace function set_updated_at_i3()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_i3_reunioes_updated on i3_reunioes;
create trigger trg_i3_reunioes_updated before update on i3_reunioes
  for each row execute function set_updated_at_i3();

drop trigger if exists trg_i3_learning_updated on i3_learning;
create trigger trg_i3_learning_updated before update on i3_learning
  for each row execute function set_updated_at_i3();

-- RLS: liberar leitura/escrita pra qualquer authenticated (controle de acesso fica no frontend)
alter table i3_reunioes enable row level security;
alter table i3_learning enable row level security;

drop policy if exists "i3_reunioes_authenticated" on i3_reunioes;
create policy "i3_reunioes_authenticated" on i3_reunioes
  for all to authenticated using (true) with check (true);

drop policy if exists "i3_learning_authenticated" on i3_learning;
create policy "i3_learning_authenticated" on i3_learning
  for all to authenticated using (true) with check (true);

comment on table i3_reunioes is 'I3 — atas das reuniões mensais dos sócios (uma por mês)';
comment on table i3_learning is 'I3 — agendamento e tema das reuniões semanais Impulse Learning';

select 'Tabelas i3_reunioes e i3_learning criadas com sucesso' as resultado;
