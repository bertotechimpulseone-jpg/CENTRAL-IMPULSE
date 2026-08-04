-- ============================================================
-- 65 - MATERIAIS (repositório restrito)
--   Aba "Materiais" disponível SOMENTE para Vini, Haisa e Heidy.
--   Privacidade real: RLS restringe leitura E escrita a esses 3.
-- Idempotente — seguro rodar mais de uma vez.
-- ============================================================

create table if not exists public.materiais (
  id               uuid primary key default gen_random_uuid(),
  titulo           text not null,
  descricao        text,
  url              text,
  tipo             text,            -- 'link' | 'arquivo'
  arquivo_nome     text,
  created_by_email text,
  created_at       timestamptz not null default now()
);

grant select, insert, update, delete on public.materiais to authenticated;
alter table public.materiais enable row level security;

-- Função: o usuário logado é Vini, Haisa ou Heidy?
-- (mesmo critério do Desabafo: e-mail autorizado OU primeiro nome no profile)
create or replace function public.is_lideranca()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    lower(auth.jwt() ->> 'email') in (
      'vini@impulseone.com.br','vinicius@impulseone.com.br',
      'heidy@impulseone.com.br','heidi@impulseone.com.br',
      'haisa@impulseone.com.br'
    )
    or exists (
      select 1 from public.profiles p
      where lower(p.email) = lower(auth.jwt() ->> 'email')
        and lower(split_part(coalesce(p.full_name,''),' ',1)) in (
          'vinicius','vinícius','vini','heidy','heidi','heydi','haisa','haísa','haysa'
        )
    );
$$;

drop policy if exists materiais_select on public.materiais;
create policy materiais_select on public.materiais
  for select to authenticated using (public.is_lideranca());

drop policy if exists materiais_insert on public.materiais;
create policy materiais_insert on public.materiais
  for insert to authenticated with check (public.is_lideranca());

drop policy if exists materiais_update on public.materiais;
create policy materiais_update on public.materiais
  for update to authenticated using (public.is_lideranca()) with check (public.is_lideranca());

drop policy if exists materiais_delete on public.materiais;
create policy materiais_delete on public.materiais
  for delete to authenticated using (public.is_lideranca());

select 'Materiais: tabela criada e restrita a Vini/Haisa/Heidy' as resultado;
