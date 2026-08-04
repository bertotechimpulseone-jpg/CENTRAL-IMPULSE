-- ============================================================
-- 79 - Calendário editorial do cliente + aprovação com notificação
--   calendarios        : o calendário de um cliente (posts em jsonb) + token do link público
--   calendario_eventos : tudo que o cliente faz (aprovar, pedir ajuste, editar texto)
--                        vira um evento -> vira notificação no sistema.
-- Idempotente.
-- ============================================================

create table if not exists public.calendarios (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid,                     -- clients.id (regra do _dbId: nunca índice posicional)
  cliente_nome text,                   -- snapshot do nome de exibição (some join na página pública)
  titulo text not null,                -- ex: "Agosto e Setembro 2026"
  token text unique not null,          -- segredo do link público ?aprovar=<token>
  posts jsonb not null default '[]'::jsonb,
  -- cada post: { ref, data, dia, formato, eixo, chamada, slides[], legenda,
  --              status:'pendente|aprovado|ajustar', comentario,
  --              chamada_original, legenda_original, editado, decidido_em }
  status text not null default 'rascunho',   -- rascunho | enviado | concluido
  enviado_em timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  created_by_email text
);

create index if not exists idx_calendarios_token on public.calendarios(token);
create index if not exists idx_calendarios_cliente on public.calendarios(cliente_id);

alter table public.calendarios enable row level security;
drop policy if exists "cal_all" on public.calendarios;
create policy "cal_all" on public.calendarios
  for all to anon, authenticated using (true) with check (true);

-- ------------------------------------------------------------
-- Eventos = trilha de auditoria + fonte das notificações
-- ------------------------------------------------------------
create table if not exists public.calendario_eventos (
  id uuid primary key default gen_random_uuid(),
  calendario_id uuid,
  cliente_nome text,
  post_ref text,        -- ex: "Ago 01"
  post_titulo text,     -- chamada do post na hora do evento
  tipo text not null,   -- aprovado | ajuste | editou_chamada | editou_legenda | comentario | finalizou
  detalhe text,         -- comentário do cliente, ou o texto novo que ele escreveu
  lido boolean not null default false,
  created_at timestamptz default now()
);

create index if not exists idx_cal_ev_lido on public.calendario_eventos(lido, created_at desc);
create index if not exists idx_cal_ev_cal on public.calendario_eventos(calendario_id);

alter table public.calendario_eventos enable row level security;
drop policy if exists "cal_ev_all" on public.calendario_eventos;
create policy "cal_ev_all" on public.calendario_eventos
  for all to anon, authenticated using (true) with check (true);

select 'Tabelas calendarios + calendario_eventos criadas' as resultado;
