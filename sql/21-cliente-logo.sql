-- ============================================================
-- Logo do cliente
-- ============================================================
alter table clients add column if not exists logo_url text;

-- Bucket pra logos no Storage. Cria manualmente no painel:
--   Storage > Create bucket > "clientes-logos" > Public: ON
