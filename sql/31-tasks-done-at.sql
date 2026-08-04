-- ============================================================
-- Hora de conclusão da tarefa
-- ============================================================
alter table tasks add column if not exists done_at timestamptz;
