-- ============================================================
-- "Antes da Impulse" — snapshot do cliente antes de entrar
-- ============================================================

-- JSONB pra suportar qualquer estrutura de dados
alter table clients add column if not exists antes_impulse jsonb default '{}'::jsonb;

-- Exemplo de estrutura armazenada:
-- {
--   "print_url": "data:image/...",
--   "data_referencia": "2025-01-15",
--   "seguidores": {
--     "instagram": 1500,
--     "facebook": 800,
--     "tiktok": 0,
--     "youtube": 0,
--     "linkedin": 0
--   },
--   "engajamento": "1.2%",
--   "faturamento": "R$ 5k/mês",
--   "alcance_medio": "500/post",
--   "observacoes": "Cliente nunca rodou tráfego pago"
-- }
