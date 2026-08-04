-- ============================================================
-- Campos extras pra Plano & Serviços do cliente
-- ============================================================
alter table clients add column if not exists plan_name text;          -- ja existia? garante
alter table clients add column if not exists plan_value numeric(10,2); -- ja existia? garante
alter table clients add column if not exists plan_designer text;
alter table clients add column if not exists contract_start date;
alter table clients add column if not exists renovation_date date;
alter table clients add column if not exists services_list jsonb default '[]'::jsonb;
