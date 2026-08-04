-- ============================================================
-- Planilha de pagamentos dos colaboradores
-- ============================================================
create table if not exists colaborador_pagamentos (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  mes_ref text,                -- formato 'YYYY-MM' (ex: 2026-05) ou texto livre
  descricao text not null,
  valor numeric(10,2) not null default 0,
  status_pago boolean not null default false,
  data_pagamento date,
  observacoes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_pag_profile on colaborador_pagamentos(profile_id);
create index if not exists idx_pag_mes on colaborador_pagamentos(mes_ref);
create index if not exists idx_pag_status on colaborador_pagamentos(status_pago);

alter table colaborador_pagamentos enable row level security;

-- Usuário autenticado pode ver/criar/editar (UI restringe por isGestor)
drop policy if exists "auth all pagamentos" on colaborador_pagamentos;
create policy "auth all pagamentos" on colaborador_pagamentos
  for all to authenticated using (true) with check (true);
