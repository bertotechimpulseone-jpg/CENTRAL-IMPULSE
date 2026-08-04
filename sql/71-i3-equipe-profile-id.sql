-- ============================================================
-- 71 - I3: vincular o Painel da Equipe ao cadastro (profiles) via profile_id
--   Usado pelo botao "Sincronizar com a Equipe": cria/vincula os colaboradores
--   ATIVOS do cadastro (array team / tabela profiles) e permite marcar no painel
--   quem tem vinculo mas nao esta mais ativo. Linhas manuais/externas ficam com
--   profile_id NULL e nunca sao marcadas como "fora".
-- Idempotente.
-- ============================================================

alter table public.i3_equipe add column if not exists profile_id uuid;
create index if not exists idx_i3_equipe_profile on public.i3_equipe(profile_id);

select 'I3 OK: coluna i3_equipe.profile_id criada' as resultado;
