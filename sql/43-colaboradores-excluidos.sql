-- ============================================================
-- 43-colaboradores-excluidos.sql
-- Tabela para guardar colaboradores excluidos do mock inicial
-- Persiste a exclusao globalmente (em todos os navegadores)
-- ============================================================

create table if not exists colaboradores_excluidos (
  id uuid primary key default uuid_generate_v4(),
  nome_normalizado text unique not null,  -- nome em lowercase (ou _dbId se houver)
  nome_original text,                      -- nome como aparecia na tela
  profile_dbid text,                       -- _dbId se tinha
  excluido_em timestamptz default now(),
  excluido_por uuid references profiles(id) on delete set null
);

create index if not exists idx_colab_excl_nome on colaboradores_excluidos(nome_normalizado);

alter table colaboradores_excluidos enable row level security;

drop policy if exists "auth all colab_exc" on colaboradores_excluidos;
create policy "auth all colab_exc" on colaboradores_excluidos
  for all to authenticated using (true) with check (true);

select 'Tabela colaboradores_excluidos criada com sucesso' as resultado;
