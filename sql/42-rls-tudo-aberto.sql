-- ============================================================
-- 42-rls-tudo-aberto.sql
-- RLS aberta pra todas as tabelas — autenticado pode tudo
-- Rode esse SQL no Supabase se DELETEs/UPDATEs estiverem falhando
-- com erro "policy" ou "permission denied"
-- ============================================================

-- Garante RLS ligada e cria policy de acesso total pra authenticated
do $$
declare
  tbl text;
begin
  for tbl in
    select tablename from pg_tables
    where schemaname = 'public'
      and tablename in (
        'profiles','clients','cronograma','captacoes','tasks',
        'colaborador_pagamentos','pagamentos_fixos','client_briefings',
        'client_accesses','client_relationships','lembretes',
        'eventos_calendario','ferias_programadas','trafego_campanhas',
        'app_settings','automacoes','custom_links','link_groups','orcamentos'
      )
  loop
    execute format('alter table %I enable row level security', tbl);
    execute format('drop policy if exists "auth_all_%s" on %I', tbl, tbl);
    execute format('create policy "auth_all_%s" on %I for all to authenticated using (true) with check (true)', tbl, tbl);
  end loop;
end;
$$;

-- Tambem libera leitura anon na public.captacoes (pra paginas publicas com token)
do $$
begin
  if exists (select 1 from pg_tables where schemaname='public' and tablename='captacoes') then
    drop policy if exists "anon_read_captacoes_token" on captacoes;
    create policy "anon_read_captacoes_token" on captacoes
      for select to anon using (share_token is not null);
  end if;
end;
$$;

-- Tambem libera leitura anon na public.client_briefings (pra responder briefing publico)
do $$
begin
  if exists (select 1 from pg_tables where schemaname='public' and tablename='client_briefings') then
    drop policy if exists "anon_read_briefings_token" on client_briefings;
    create policy "anon_read_briefings_token" on client_briefings
      for all to anon using (share_token is not null) with check (share_token is not null);
  end if;
end;
$$;

select 'RLS aberta com sucesso. Teste DELETE/UPDATE agora.' as resultado;
