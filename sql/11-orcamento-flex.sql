create table if not exists budget_services (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  value numeric(10,2) not null default 0,
  description text,
  position int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists budget_clients (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  cnpj text,
  email text,
  phone text,
  address text,
  notes text,
  created_at timestamptz default now()
);

alter table budget_services enable row level security;
alter table budget_clients enable row level security;
create policy "auth all" on budget_services for all to authenticated using (true) with check (true);
create policy "auth all" on budget_clients for all to authenticated using (true) with check (true);

-- Popular com servicos padrao (so se vazio)
insert into budget_services (name, value, position)
select * from (values
  ('Gestão de rede social', 1800::numeric, 1),
  ('Design fixo', 1200::numeric, 2),
  ('Tráfego pago', 2200::numeric, 3),
  ('Vídeos', 1800::numeric, 4),
  ('Captação', 2500::numeric, 5),
  ('Branding', 4500::numeric, 6),
  ('Campanhas', 3200::numeric, 7),
  ('Consultoria', 1500::numeric, 8)
) as v(name, value, position)
where not exists (select 1 from budget_services);
