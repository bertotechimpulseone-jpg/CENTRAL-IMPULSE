-- ============================================================
-- 75 - Checklist público simplificado (link por colaborador)
--   Página pública ?check=<profile_id> pra abrir no celular:
--   ver tarefas diárias, marcar feito e ADICIONAR demandas que
--   caem direto no checklist principal (mesma tabela tasks).
--   Seguro: funções security definer escopadas pelo id da pessoa
--   (não abre a tabela tasks pro anon).
-- Idempotente.
-- ============================================================

create or replace function public.check_get(p_id uuid)
returns json language sql security definer set search_path = public as $func$
  select json_build_object(
    'ok', exists(select 1 from profiles where id = p_id),
    'nome', (select coalesce(nullif(trim(full_name),''),'Colaborador') from profiles where id = p_id),
    'tasks', coalesce((
      select json_agg(x) from (
        select t.id, t.title, t.done, t.priority, t.created_at, t.done_at
        from tasks t
        where t.assigned_to = p_id and t.is_daily = true
        order by t.done asc, t.created_at desc
      ) x
    ), '[]'::json)
  );
$func$;

-- excluir uma demanda AINDA PENDENTE (só pendente, pra não apagar histórico de concluídas)
create or replace function public.check_del(p_id uuid, p_task uuid)
returns void language sql security definer set search_path = public as $func$
  delete from tasks where id = p_task and assigned_to = p_id and is_daily = true and done = false;
$func$;
grant execute on function public.check_del(uuid, uuid) to anon, authenticated;

create or replace function public.check_toggle(p_id uuid, p_task uuid, p_done boolean)
returns void language sql security definer set search_path = public as $func$
  update tasks set done = p_done, done_at = case when p_done then now() else null end
  where id = p_task and assigned_to = p_id and is_daily = true;
$func$;

create or replace function public.check_add(p_id uuid, p_title text)
returns json language plpgsql security definer set search_path = public as $func$
declare v_id uuid;
begin
  if p_title is null or length(trim(p_title)) = 0 then return json_build_object('ok', false); end if;
  if not exists(select 1 from profiles where id = p_id) then return json_build_object('ok', false); end if;
  insert into tasks (title, assigned_to, is_daily, done, priority, status)
  values (trim(p_title), p_id, true, false, 'med', 'pendente')
  returning id into v_id;
  return json_build_object('ok', true, 'id', v_id);
end;
$func$;

grant execute on function public.check_get(uuid) to anon, authenticated;
grant execute on function public.check_toggle(uuid, uuid, boolean) to anon, authenticated;
grant execute on function public.check_add(uuid, text) to anon, authenticated;

select 'RPCs de checklist público criadas' as resultado;
