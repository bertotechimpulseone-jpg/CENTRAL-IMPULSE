-- ============================================================
-- 52-controle-almoco.sql
-- Aba Almoço — controle mensal de quantos almoços aconteceram
-- ============================================================

create table if not exists controle_almoco (
  id uuid primary key default gen_random_uuid(),
  -- tipo: 'interno' (colaborador da equipe) OU 'convidado' (cliente/parceiro/etc)
  tipo text not null default 'interno',
  nome text not null,
  -- profile_id só preenchido quando tipo='interno'
  profile_id uuid references profiles(id) on delete set null,
  data date not null,
  hora text,                  -- HH:MM
  custo numeric,              -- opcional, R$ gasto
  observacoes text default '',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_almoco_data on controle_almoco(data desc);
create index if not exists idx_almoco_tipo on controle_almoco(tipo);
create index if not exists idx_almoco_profile on controle_almoco(profile_id);

-- Trigger updated_at
create or replace function set_updated_at_almoco()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_almoco_updated on controle_almoco;
create trigger trg_almoco_updated before update on controle_almoco
  for each row execute function set_updated_at_almoco();

-- RLS: leitura/escrita pra authenticated. Controle de acesso (whitelist por nome) no front
alter table controle_almoco enable row level security;

drop policy if exists "almoco_authenticated" on controle_almoco;
create policy "almoco_authenticated" on controle_almoco
  for all to authenticated using (true) with check (true);

comment on table controle_almoco is 'Controle mensal de almoços da equipe e convidados';

select 'Tabela controle_almoco criada com sucesso' as resultado;
