-- ============================================================
-- 59 - Marca de orçamento APROVADO no lead (pipeline Comercial)
-- Usada para somar o "valor total aprovado" na coluna Fechado.
-- ============================================================

alter table public.leads add column if not exists aprovado boolean not null default false;
