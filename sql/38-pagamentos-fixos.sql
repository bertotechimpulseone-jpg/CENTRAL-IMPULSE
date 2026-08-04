-- ============================================================
-- Pagamentos fixos mensais (salários e custos recorrentes)
-- ============================================================

create table if not exists pagamentos_fixos (
  id uuid primary key default uuid_generate_v4(),
  nome text not null,                     -- ex: "Salário Henrique", "Aluguel"
  valor numeric(12,2) not null default 0,
  ativo boolean not null default true,    -- só ativos somam no total
  observacoes text,
  ordem integer default 0,                -- pra ordenar visualmente
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_pf_ativo on pagamentos_fixos(ativo);
create index if not exists idx_pf_ordem on pagamentos_fixos(ordem);

alter table pagamentos_fixos enable row level security;

drop policy if exists "auth all pagfixos" on pagamentos_fixos;
create policy "auth all pagfixos" on pagamentos_fixos
  for all to authenticated using (true) with check (true);
