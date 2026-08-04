-- ============================================================
-- Adiciona campo pra marcar quais meses um pagamento fixo foi pago
-- Armazena como JSON array de strings YYYY-MM
-- ============================================================
alter table pagamentos_fixos add column if not exists pagos_meses text default '[]';

comment on column pagamentos_fixos.pagos_meses is 'JSON array com meses pagos (formato YYYY-MM). Ex: ["2026-04","2026-05"]';
