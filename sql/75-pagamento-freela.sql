-- ============================================================
-- 75 - Pagamentos: permitir FREELA / avulso (nao cadastrado)
--   O lancamento variavel exigia profile_id (colaborador do cadastro).
--   Agora aceita profile_id NULL + nome digitado manualmente + Pix de destino.
--   FK continua valida pra profile_id != null (nao quebra os existentes).
-- Idempotente.
-- ============================================================

alter table public.colaborador_pagamentos alter column profile_id drop not null;
alter table public.colaborador_pagamentos add column if not exists nome_manual text;  -- nome do freela quando nao ha profile
alter table public.colaborador_pagamentos add column if not exists pix text;          -- chave Pix de destino (freela)

select 'Pagamentos: profile_id agora nullable + nome_manual + pix (freela) OK' as resultado;
