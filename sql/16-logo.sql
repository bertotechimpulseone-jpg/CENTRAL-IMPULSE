-- Tabela de configuracoes globais do app (logo, nome da agencia, cores etc)
create table if not exists app_settings (
  key text primary key,
  value text,
  updated_at timestamptz default now()
);

alter table app_settings enable row level security;

-- Todos autenticados podem LER configuracoes
drop policy if exists "auth read settings" on app_settings;
create policy "auth read settings" on app_settings
  for select to authenticated using (true);

-- Todos autenticados podem ESCREVER (na pratica voce limita por isAdmin no front)
drop policy if exists "auth write settings" on app_settings;
create policy "auth write settings" on app_settings
  for all to authenticated using (true) with check (true);
