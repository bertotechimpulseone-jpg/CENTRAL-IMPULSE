-- ============================================================
-- 66 - PESQUISA NR-1 PSICOSSOCIAL (anônima)
--   • Resposta: link público anônimo (anon) — NÃO guarda autor/nome/setor.
--   • Leitura dos resultados: só gestores, admins e liderança.
-- Idempotente — seguro rodar mais de uma vez.
-- ============================================================

create table if not exists public.pesquisa_nr1 (
  id          uuid primary key default gen_random_uuid(),
  respostas   jsonb not null default '{}'::jsonb,  -- { chave_indice: nota(1-5) } — sem identificação
  created_at  timestamptz not null default now()
);

grant insert on public.pesquisa_nr1 to anon, authenticated;
grant select on public.pesquisa_nr1 to authenticated;
alter table public.pesquisa_nr1 enable row level security;

-- Função: usuário logado é gestor/admin/liderança? (para liberar a LEITURA dos resultados)
create or replace function public.is_gestor_app()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    lower(auth.jwt() ->> 'email') in (
      'vini@impulseone.com.br','vinicius@impulseone.com.br',
      'heidy@impulseone.com.br','heidi@impulseone.com.br','haisa@impulseone.com.br'
    )
    or exists (
      select 1 from public.profiles p
      where lower(p.email) = lower(auth.jwt() ->> 'email')
        and (
          lower(coalesce(p.role,'')) in ('admin','gestor')
          or lower(split_part(coalesce(p.full_name,''),' ',1)) in (
            'vinicius','vinícius','vini','heidy','heidi','heydi','haisa','haísa','haysa'
          )
        )
    );
$$;

-- INSERÇÃO: qualquer um (público anônimo) — sem dados de autor
drop policy if exists pesquisa_nr1_insert on public.pesquisa_nr1;
create policy pesquisa_nr1_insert on public.pesquisa_nr1
  for insert to anon, authenticated with check (true);

-- LEITURA: só gestores/admins/liderança
drop policy if exists pesquisa_nr1_select on public.pesquisa_nr1;
create policy pesquisa_nr1_select on public.pesquisa_nr1
  for select to authenticated using (public.is_gestor_app());

select 'Pesquisa NR-1: tabela criada (resposta anônima, leitura só gestão)' as resultado;
