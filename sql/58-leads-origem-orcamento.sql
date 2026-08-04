-- ============================================================
-- 58 - Vínculo Orçamento (budgets) -> Lead (pipeline Comercial)
-- Cada orçamento salvo vira um lead editável no pipeline.
-- A coluna origem_orcamento_id liga o lead ao orçamento de origem,
-- evitando duplicar na sincronização.
-- ============================================================

alter table public.leads add column if not exists origem_orcamento_id uuid;

create index if not exists idx_leads_origem_orcamento
  on public.leads(origem_orcamento_id);
