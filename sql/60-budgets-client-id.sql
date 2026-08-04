-- ============================================================
-- 60 - Vincula orçamentos (budgets) ao cliente do CRM
-- Permite mostrar os orçamentos na aba "Orçamentos" do cliente.
-- client_id = clients.id (UUID = _dbId no app).
-- ============================================================

alter table public.budgets add column if not exists client_id uuid;

create index if not exists idx_budgets_client on public.budgets(client_id);
