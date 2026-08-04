-- ============================================================
-- 73 - Aprovação de desconto (fluxo com link + senha de gestor)
--   O comercial solicita aprovação quando o desconto passa de 10%;
--   um admin abre o link (?aprovar-desconto=TOKEN), vê o resumo e
--   confirma com a senha de gestor. Uso único, com trilha de auditoria.
-- Idempotente. RLS aberta (padrão dos links públicos); a segurança é o
-- token não-adivinhável + a senha de gestor na confirmação (client-side).
-- ============================================================

create table if not exists public.desconto_aprovacoes (
  id uuid primary key default gen_random_uuid(),
  token text unique not null,
  cliente text,
  resumo text,
  desconto_pct numeric default 0,
  subtotal numeric default 0,
  total numeric default 0,
  solicitante text,
  status text default 'pendente',   -- pendente | aprovado | rejeitado
  aprovado_por text,
  usado boolean default false,
  created_at timestamptz default now(),
  decided_at timestamptz
);

create index if not exists idx_desc_aprov_token on public.desconto_aprovacoes(token);
create index if not exists idx_desc_aprov_status on public.desconto_aprovacoes(status);

alter table public.desconto_aprovacoes enable row level security;
drop policy if exists "desc_aprov_all" on public.desconto_aprovacoes;
create policy "desc_aprov_all" on public.desconto_aprovacoes
  for all to anon, authenticated using (true) with check (true);

select 'Tabela desconto_aprovacoes criada' as resultado;
