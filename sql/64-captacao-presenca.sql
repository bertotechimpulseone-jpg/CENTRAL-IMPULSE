-- ============================================================
-- 64 - Captação: confirmação de presença (foto ao vivo + GPS + horário)
-- Cada registro fica em presencas (jsonb array):
--   { foto_url, lat, lng, acc, ts (ISO), por (nome do colaborador) }
-- Idempotente — seguro rodar mais de uma vez.
-- ============================================================

alter table public.captacoes add column if not exists presencas jsonb not null default '[]'::jsonb;

select 'Captação: coluna presencas criada' as resultado;
