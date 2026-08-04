-- ============================================================
-- IMPULSE ONE — Schema completo do Supabase
-- ============================================================
-- Execute este arquivo inteiro no SQL Editor do Supabase
-- Painel Supabase → SQL Editor → New query → cole tudo → RUN
-- ============================================================

-- Extensões necessárias
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ============================================================
-- 1) PERFIS DE USUÁRIO (vinculados ao auth.users do Supabase)
-- ============================================================
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null default 'colaborador', -- 'admin' | 'gestor' | 'colaborador'
  position text,
  avatar_color text default '#1d1d1f',
  initials text,
  phone text,
  cpf text,
  salary numeric(10,2),
  contract_start date,
  vacation_total int default 30,
  vacation_used int default 0,
  productivity int default 85,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- 2) CLIENTES
-- ============================================================
create table if not exists clients (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  segment text,
  color text default '#1d1d1f',
  initials text,
  mrr numeric(10,2) default 0,
  status text default 'active', -- active | onboarding | paused | late
  owner_id uuid references profiles(id),
  phone text,
  email text,
  instagram text,
  website text,
  address text,
  notes text,
  plan_name text default 'Essencial', -- Essencial | Crescimento | Premium | Enterprise
  plan_value numeric(10,2),
  designer_id uuid references profiles(id),
  traffic_manager_id uuid references profiles(id),
  services text[] default array[]::text[], -- gestao_social, design, trafego, branding, etc
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_clients_status on clients(status);
create index idx_clients_owner on clients(owner_id);

-- ============================================================
-- 3) ACESSOS DO CLIENTE (logins de redes sociais, anúncios, etc.)
-- ============================================================
create table if not exists client_accesses (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  category text not null, -- 'redes_sociais' | 'anuncios' | 'ferramentas' | 'hospedagem'
  platform text not null,
  icon text,
  login text,
  password_encrypted text, -- usar pgcrypto: pgp_sym_encrypt(senha, 'chave')
  notes text,
  last_changed_at timestamptz default now(),
  created_at timestamptz default now()
);

create index idx_accesses_client on client_accesses(client_id);

-- ============================================================
-- 4) CAPTAÇÕES (gravações, fotos, vídeos)
-- ============================================================
create table if not exists captacoes (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  type text not null, -- "Vídeo institucional", "Fotos de produtos", etc
  responsible_id uuid references profiles(id),
  scheduled_date date not null,
  scheduled_time time not null,
  address text,
  briefing text,
  status text default 'agendada', -- agendada | confirmada | em_andamento | finalizada | cancelada
  priority text default 'med', -- urgent | high | med | low
  drive_url text,
  materials text[] default array[]::text[],
  checklist jsonb default '[]'::jsonb,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_captacoes_date on captacoes(scheduled_date);
create index idx_captacoes_status on captacoes(status);

-- ============================================================
-- 5) CRONOGRAMA (12 meses por cliente)
-- ============================================================
create table if not exists cronograma (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  year int not null default 2026,
  month int not null check (month between 1 and 12),
  produced int default 0,
  target int default 0,
  has_traffic boolean default false,
  traffic_manager_id uuid references profiles(id),
  designer_id uuid references profiles(id),
  status text default 'planejado', -- em-dia | em-andamento | atrasado | concluido | planejado
  deadline date,
  observations text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(client_id, year, month)
);

create index idx_cron_client_month on cronograma(client_id, year, month);
create index idx_cron_deadline on cronograma(deadline);

-- ============================================================
-- 6) TAREFAS (Checklist diário + Kanban)
-- ============================================================
create table if not exists tasks (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  client_id uuid references clients(id) on delete set null,
  assigned_to uuid references profiles(id),
  priority text default 'med', -- urgent | high | med | low
  status text default 'todo', -- backlog | todo | doing | review | approval | done
  tag text, -- "Conteúdo" | "Vídeo" | "Design" etc
  scheduled_time time,
  due_date date,
  is_daily boolean default false, -- se é tarefa do checklist diário
  done boolean default false,
  done_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_tasks_assigned on tasks(assigned_to, due_date);
create index idx_tasks_status on tasks(status);
create index idx_tasks_client on tasks(client_id);

-- ============================================================
-- 7) REUNIÕES
-- ============================================================
create table if not exists meetings (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  client_id uuid references clients(id) on delete set null,
  scheduled_at timestamptz not null,
  duration_min int default 60,
  type text, -- diagnostico | estrategia | recorrente | criativa | renovacao
  platform text, -- Google Meet | Zoom | Presencial
  meet_url text,
  attendees uuid[] default array[]::uuid[],
  agenda text,
  notes text,
  ata text, -- gerada pela IA
  next_steps jsonb default '[]'::jsonb,
  recording_url text,
  done boolean default false,
  created_at timestamptz default now()
);

-- ============================================================
-- 8) FEEDBACKS (avaliações dos colaboradores)
-- ============================================================
create table if not exists feedbacks (
  id uuid primary key default uuid_generate_v4(),
  collaborator_id uuid references profiles(id) on delete cascade,
  author_id uuid references profiles(id),
  type text not null, -- positive | concern | development
  period text, -- "Q1 2026"
  score numeric(3,1) check (score >= 1 and score <= 10),
  text text not null,
  ai_sentiment text, -- analisado pelo client
  ai_topics text[],
  ai_recommendations text[],
  created_at timestamptz default now()
);

create index idx_feedbacks_collab on feedbacks(collaborator_id);

-- ============================================================
-- 9) PONTO ELETRÔNICO
-- ============================================================
create table if not exists time_clock (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid references profiles(id) on delete cascade,
  work_date date not null,
  entrada timestamptz,
  intervalo_inicio timestamptz,
  intervalo_fim timestamptz,
  saida timestamptz,
  total_hours numeric(4,2),
  notes text,
  created_at timestamptz default now(),
  unique(profile_id, work_date)
);

create index idx_clock_profile_date on time_clock(profile_id, work_date);

-- ============================================================
-- 10) FÉRIAS
-- ============================================================
create table if not exists vacations (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid references profiles(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  days int not null,
  status text default 'programada', -- programada | em_andamento | concluida | cancelada
  notes text,
  approved_by uuid references profiles(id),
  created_at timestamptz default now()
);

-- ============================================================
-- 11) FINANCEIRO — TRANSAÇÕES
-- ============================================================
create table if not exists transactions (
  id uuid primary key default uuid_generate_v4(),
  type text not null, -- in | out
  category text, -- recorrente | projeto | equipe | trafego | ferramentas | impostos | aluguel
  description text not null,
  amount numeric(10,2) not null,
  date date not null,
  client_id uuid references clients(id) on delete set null,
  supplier text,
  status text default 'paid', -- paid | pending | late
  payment_method text, -- pix | boleto | cartao | transferencia
  created_at timestamptz default now()
);

create index idx_trans_date on transactions(date);
create index idx_trans_type on transactions(type, date);

-- ============================================================
-- 12) COMERCIAL — LEADS E PIPELINE
-- ============================================================
create table if not exists leads (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  contact_name text,
  phone text,
  email text,
  segment text,
  stage text default 'lead', -- lead | contato | diagnostico | proposta | fechamento | fechado | perdido
  value numeric(10,2),
  responsible_id uuid references profiles(id),
  priority text default 'med',
  notes text,
  created_at timestamptz default now()
);

-- ============================================================
-- 13) ORÇAMENTOS
-- ============================================================
create table if not exists budgets (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete set null,
  lead_id uuid references leads(id) on delete set null,
  services jsonb not null default '[]'::jsonb, -- [{name, value}]
  total numeric(10,2) not null,
  deadline text default '30 dias',
  conditions text default 'PIX à vista ou 2x no cartão',
  notes text,
  pdf_url text,
  sent_at timestamptz,
  accepted boolean,
  created_at timestamptz default now()
);

-- ============================================================
-- 14) AUTOMAÇÕES
-- ============================================================
create table if not exists automations (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  trigger text not null,
  action text not null,
  enabled boolean default true,
  runs_count int default 0,
  last_run_at timestamptz,
  created_at timestamptz default now()
);

-- ============================================================
-- 15) ARQUIVOS (metadados, conteúdo no Storage)
-- ============================================================
create table if not exists files (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  storage_path text not null, -- caminho no bucket
  size_bytes bigint,
  mime_type text,
  client_id uuid references clients(id) on delete cascade,
  category text, -- criativos | contrato | video | relatorio | briefing
  uploaded_by uuid references profiles(id),
  created_at timestamptz default now()
);

create index idx_files_client on files(client_id);

-- ============================================================
-- 16) NOTIFICAÇÕES
-- ============================================================
create table if not exists notifications (
  id uuid primary key default uuid_generate_v4(),
  recipient_id uuid references profiles(id) on delete cascade,
  type text not null, -- prazo | aprovacao | pagamento | reuniao | sistema
  title text not null,
  message text,
  link text, -- ex: /captacao/123
  priority text default 'med',
  read boolean default false,
  created_at timestamptz default now()
);

create index idx_notif_recipient on notifications(recipient_id, read);

-- ============================================================
-- 17) LOG DE ATIVIDADE
-- ============================================================
create table if not exists activity_log (
  id uuid primary key default uuid_generate_v4(),
  actor_id uuid references profiles(id),
  action text not null,
  entity_type text, -- client | task | feedback | etc
  entity_id uuid,
  metadata jsonb,
  created_at timestamptz default now()
);

-- ============================================================
-- 18) DATAS COMEMORATIVAS
-- ============================================================
create table if not exists commemorative_dates (
  id uuid primary key default uuid_generate_v4(),
  date date not null,
  name text not null,
  region text default 'BR', -- BR | RS
  category text, -- nacional | regional | comercial
  notes text
);

-- ============================================================
-- TRIGGERS — atualizar updated_at automaticamente
-- ============================================================
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

do $$ declare t text;
begin
  for t in select unnest(array['profiles','clients','captacoes','cronograma','tasks']) loop
    execute format('drop trigger if exists trg_%s_upd on %s; create trigger trg_%s_upd before update on %s for each row execute function set_updated_at();', t, t, t, t);
  end loop;
end $$;

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
-- Política: qualquer usuário autenticado da Impulse One acessa tudo
-- (simplificado para 1 organização — multi-tenant pode vir depois)

alter table profiles enable row level security;
alter table clients enable row level security;
alter table client_accesses enable row level security;
alter table captacoes enable row level security;
alter table cronograma enable row level security;
alter table tasks enable row level security;
alter table meetings enable row level security;
alter table feedbacks enable row level security;
alter table time_clock enable row level security;
alter table vacations enable row level security;
alter table transactions enable row level security;
alter table leads enable row level security;
alter table budgets enable row level security;
alter table automations enable row level security;
alter table files enable row level security;
alter table notifications enable row level security;
alter table activity_log enable row level security;
alter table commemorative_dates enable row level security;

-- Policy genérica: autenticados podem tudo
do $$ declare t text;
begin
  for t in select unnest(array['profiles','clients','client_accesses','captacoes','cronograma','tasks','meetings','feedbacks','time_clock','vacations','transactions','leads','budgets','automations','files','notifications','activity_log','commemorative_dates']) loop
    execute format('drop policy if exists "team can all" on %s; create policy "team can all" on %s for all to authenticated using (true) with check (true);', t, t);
  end loop;
end $$;

-- Acessos de cliente: senhas só admin/gestor podem ler descriptografadas
-- (esta política básica permite leitura para todos autenticados; refine depois)

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
-- Execute manualmente no Supabase → Storage:
-- 1. Crie bucket 'avatars' (public)
-- 2. Crie bucket 'client-files' (private)
-- 3. Crie bucket 'captacoes' (private)
-- 4. Crie bucket 'orcamentos' (private)

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

-- Criptografar senha de acesso (usa pgcrypto)
create or replace function encrypt_access_password(password text, key text)
returns text as $$
  select pgp_sym_encrypt(password, key);
$$ language sql immutable;

create or replace function decrypt_access_password(encrypted text, key text)
returns text as $$
  select pgp_sym_decrypt(encrypted::bytea, key);
$$ language sql immutable;

-- ============================================================
-- DONE!
-- Próximos passos:
-- 1. Rode supabase-seed.sql para popular os dados iniciais
-- 2. Configure Auth: Authentication → Providers → Email habilitado
-- 3. Crie os 9 usuários: Authentication → Users → Add user
-- 4. Crie os buckets em Storage
-- 5. Pegue Project URL + anon key em Settings → API
-- 6. Atualize config.js do frontend
-- ============================================================
