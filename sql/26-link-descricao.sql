-- ============================================================
-- Descrição dos links customizados
-- ============================================================
alter table custom_links add column if not exists description text;
