-- ============================================================
-- Gestor responsável por cada cliente (atualização semanal)
-- ============================================================

alter table clients add column if not exists gestor_nome text;
alter table clients add column if not exists gestor_id uuid references profiles(id) on delete set null;

create index if not exists idx_clients_gestor on clients(gestor_id);
