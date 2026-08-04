-- ============================================================
-- 76 - Aba Relatórios: relatórios de reunião paginados
--   Cola o texto da reunião → o sistema quebra em páginas A4
--   na identidade visual da Impulse (Montserrat 17).
-- Idempotente.
-- ============================================================

create table if not exists public.relatorios (
  id uuid primary key default gen_random_uuid(),
  empresa text not null,              -- nome da empresa (do sistema ou digitado)
  client_id uuid,                     -- clients.id quando veio do sistema (opcional)
  data date default current_date,     -- data do relatório (editável)
  texto text not null,                -- relatório completo colado
  created_at timestamptz default now(),
  created_by_email text
);

create index if not exists idx_relatorios_created on public.relatorios(created_at desc);

alter table public.relatorios enable row level security;
drop policy if exists "rel_all_auth" on public.relatorios;
create policy "rel_all_auth" on public.relatorios for all to authenticated using (true) with check (true);

select 'Tabela relatorios criada' as resultado;
