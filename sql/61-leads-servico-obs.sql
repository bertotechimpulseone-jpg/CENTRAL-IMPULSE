-- ============================================================
-- 61 - Campos extras no lead (pipeline Comercial)
--   • servico_contratado : qual serviço foi fechado
--   • valido_em          : a partir de quando a alteração vale
--   • observacoes        : anotações livres
-- O serviço contratado também é anexado (append) ao services_list do cliente.
-- ============================================================

alter table public.leads add column if not exists servico_contratado text;
alter table public.leads add column if not exists valido_em date;
alter table public.leads add column if not exists observacoes text;
