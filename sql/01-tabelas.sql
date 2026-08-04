create extension if not exists "uuid-ossp";

create table profiles (
  id uuid primary key default uuid_generate_v4(),
  auth_user_id uuid,
  full_name text not null,
  role text default 'colaborador',
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
  created_at timestamptz default now()
);

create table clients (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  segment text,
  color text default '#1d1d1f',
  initials text,
  mrr numeric(10,2) default 0,
  status text default 'active',
  owner_id uuid,
  phone text,
  email text,
  instagram text,
  website text,
  plan_name text default 'Essencial',
  plan_value numeric(10,2),
  designer_id uuid,
  traffic_manager_id uuid,
  services text[] default array[]::text[],
  created_at timestamptz default now()
);

create table client_accesses (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  category text not null,
  platform text not null,
  login text,
  password_encrypted text,
  created_at timestamptz default now()
);

create table captacoes (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  type text not null,
  responsible_id uuid,
  scheduled_date date not null,
  scheduled_time time not null,
  address text,
  briefing text,
  status text default 'agendada',
  priority text default 'med',
  drive_url text,
  materials text[] default array[]::text[],
  created_at timestamptz default now()
);

create table cronograma (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  year int default 2026,
  month int check (month between 1 and 12),
  produced int default 0,
  target int default 0,
  has_traffic boolean default false,
  traffic_manager_id uuid,
  designer_id uuid,
  status text default 'planejado',
  deadline date,
  observations text,
  created_at timestamptz default now()
);

create table tasks (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  client_id uuid references clients(id) on delete set null,
  assigned_to uuid,
  priority text default 'med',
  status text default 'todo',
  tag text,
  scheduled_time time,
  due_date date,
  is_daily boolean default false,
  done boolean default false,
  created_at timestamptz default now()
);

create table meetings (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  client_id uuid references clients(id) on delete set null,
  scheduled_at timestamptz not null,
  duration_min int default 60,
  type text,
  platform text,
  meet_url text,
  agenda text,
  notes text,
  ata text,
  done boolean default false,
  created_at timestamptz default now()
);

create table feedbacks (
  id uuid primary key default uuid_generate_v4(),
  collaborator_id uuid references profiles(id) on delete cascade,
  author_id uuid,
  type text not null,
  period text,
  score numeric(3,1),
  text text not null,
  created_at timestamptz default now()
);

create table time_clock (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid references profiles(id) on delete cascade,
  work_date date not null,
  entrada timestamptz,
  intervalo_inicio timestamptz,
  intervalo_fim timestamptz,
  saida timestamptz,
  total_hours numeric(4,2),
  created_at timestamptz default now()
);

create table vacations (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid references profiles(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  days int not null,
  status text default 'programada',
  created_at timestamptz default now()
);

create table transactions (
  id uuid primary key default uuid_generate_v4(),
  type text not null,
  category text,
  description text not null,
  amount numeric(10,2) not null,
  date date not null,
  client_id uuid references clients(id) on delete set null,
  supplier text,
  status text default 'paid',
  payment_method text,
  created_at timestamptz default now()
);

create table leads (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  contact_name text,
  phone text,
  email text,
  segment text,
  stage text default 'lead',
  value numeric(10,2),
  responsible_id uuid,
  priority text default 'med',
  created_at timestamptz default now()
);

create table budgets (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete set null,
  lead_id uuid references leads(id) on delete set null,
  services jsonb default '[]'::jsonb,
  total numeric(10,2) not null,
  deadline text default '30 dias',
  conditions text,
  sent_at timestamptz,
  accepted boolean,
  created_at timestamptz default now()
);

create table automations (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  trigger text not null,
  action text not null,
  enabled boolean default true,
  created_at timestamptz default now()
);

create table files (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  storage_path text not null,
  size_bytes bigint,
  client_id uuid references clients(id) on delete cascade,
  category text,
  uploaded_by uuid,
  created_at timestamptz default now()
);

create table notifications (
  id uuid primary key default uuid_generate_v4(),
  recipient_id uuid references profiles(id) on delete cascade,
  type text not null,
  title text not null,
  message text,
  link text,
  priority text default 'med',
  read boolean default false,
  created_at timestamptz default now()
);

create table commemorative_dates (
  id uuid primary key default uuid_generate_v4(),
  date date not null,
  name text not null,
  region text default 'BR',
  category text
);
