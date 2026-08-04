-- ============================================================
-- 67 - Alinha as listas de nomes da liderança no RLS com o front
--   O front aceita a grafia "Heydy" (entre os apelidos), mas o RLS
--   (is_lideranca / is_gestor_app) não listava — então quem tem
--   profile "Heydy..." via a aba mas o SELECT voltava vazio.
--   Adiciona 'heydy' às duas funções. Idempotente (create or replace).
-- ============================================================

create or replace function public.is_lideranca()
returns boolean language sql stable security definer set search_path = public as $$
  select
    lower(auth.jwt() ->> 'email') in (
      'vini@impulseone.com.br','vinicius@impulseone.com.br',
      'heidy@impulseone.com.br','heidi@impulseone.com.br','haisa@impulseone.com.br'
    )
    or exists (
      select 1 from public.profiles p
      where lower(p.email) = lower(auth.jwt() ->> 'email')
        and lower(split_part(coalesce(p.full_name,''),' ',1)) in (
          'vinicius','vinícius','vini','heidy','heidi','heydi','heydy','haisa','haísa','haysa'
        )
    );
$$;

create or replace function public.is_gestor_app()
returns boolean language sql stable security definer set search_path = public as $$
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
            'vinicius','vinícius','vini','heidy','heidi','heydi','heydy','haisa','haísa','haysa'
          )
        )
    );
$$;

select 'Listas de nomes do RLS alinhadas com o front (heydy incluído)' as resultado;
