-- ============================================================
-- Jornada customizável do cliente (checklist de etapas)
-- ============================================================
alter table clients add column if not exists journey_steps jsonb default '[]'::jsonb;

-- Estrutura esperada de cada item:
-- {
--   "id": "step_xxx",
--   "name": "Reunião de briefing",
--   "description": "...",
--   "done": false,
--   "completed_at": "2026-05-22T10:00:00Z"
-- }
