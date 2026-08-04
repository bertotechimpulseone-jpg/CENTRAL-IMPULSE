-- ============================================================
-- Cronograma — garante colunas necessárias pra edição completa
-- ============================================================
alter table cronograma add column if not exists has_traffic boolean default false;
alter table cronograma add column if not exists traffic_manager text;
alter table cronograma add column if not exists designer text;
alter table cronograma add column if not exists deadline date;
alter table cronograma add column if not exists observations text;

-- Habilita upsert pela combinação (client_id, year, month)
create unique index if not exists ux_cron_client_year_month
  on cronograma(client_id, year, month);
