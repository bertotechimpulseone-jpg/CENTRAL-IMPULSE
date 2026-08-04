-- ============================================================
-- 74 - Recrutamento & Seleção: candidaturas às vagas
--   Página pública (?vaga) insere; só admin logado lê/gerencia.
-- Idempotente.
-- ============================================================

create table if not exists public.candidaturas (
  id uuid primary key default gen_random_uuid(),
  vaga text default 'Estágio · Atendimento & Administrativo',
  nome text,
  cidade text,
  bairro text,
  telefone text,               -- 55 + DDD + numero (pronto pro WhatsApp)
  portfolio_url text,
  respostas jsonb default '{}'::jsonb,
  status text default 'novo',  -- novo | em_analise | favorito | descartado
  created_at timestamptz default now()
);

create index if not exists idx_cand_created on public.candidaturas(created_at desc);

alter table public.candidaturas enable row level security;
-- qualquer um pode se candidatar (insert), mas só quem está logado lê/gerencia (dados pessoais)
drop policy if exists "cand_insert_anon" on public.candidaturas;
create policy "cand_insert_anon" on public.candidaturas for insert to anon, authenticated with check (true);
drop policy if exists "cand_rw_auth" on public.candidaturas;
create policy "cand_rw_auth" on public.candidaturas for all to authenticated using (true) with check (true);

select 'Tabela candidaturas criada' as resultado;
