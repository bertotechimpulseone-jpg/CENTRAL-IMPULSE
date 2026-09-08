-- ============================================================
-- 83 - @ do Instagram no card do Comercial
--   O lead já guardava telefone e e-mail, mas o primeiro contato da
--   agência quase sempre começa pelo Instagram do prospect.
-- Idempotente.
-- ============================================================

alter table public.leads add column if not exists instagram text;

select count(*) || ' leads prontos pra guardar o @' as resultado from public.leads;
