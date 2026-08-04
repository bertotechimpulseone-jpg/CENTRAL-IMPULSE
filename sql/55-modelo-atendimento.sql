-- ============================================================
-- 55-modelo-atendimento.sql
-- Adiciona campo modelo_atendimento nos clientes
-- Tipos: full, design-video, design-sem-video, gabi-propria, a-definir
-- Usado na pagina Fluxo de Clientes & Responsabilidades
-- ============================================================

alter table clients add column if not exists modelo_atendimento text default '';

comment on column clients.modelo_atendimento is 'Modelo de atendimento do cliente: full, design-video, design-sem-video, gabi-propria, a-definir';

select 'Campo modelo_atendimento adicionado em clients' as resultado;
