-- ============================================================
-- 63 - Storage: cria o bucket 'uploads' (anexos da jornada, print "Antes", etc.)
-- O código já usa _supa.storage.from('uploads'), mas o bucket não existia.
-- Idempotente — seguro rodar mais de uma vez.
-- ============================================================

-- Bucket público, até 50MB por arquivo
insert into storage.buckets (id, name, public, file_size_limit)
values ('uploads', 'uploads', true, 52428800)
on conflict (id) do update set public = true;

-- Leitura pública dos arquivos (anexos abrem pelo link)
drop policy if exists "uploads_public_read" on storage.objects;
create policy "uploads_public_read" on storage.objects
  for select
  using (bucket_id = 'uploads');

-- Upload por usuários autenticados (equipe logada)
drop policy if exists "uploads_auth_insert" on storage.objects;
create policy "uploads_auth_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'uploads');

-- Substituir arquivo (upsert) por autenticados
drop policy if exists "uploads_auth_update" on storage.objects;
create policy "uploads_auth_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'uploads') with check (bucket_id = 'uploads');

-- Remover arquivo por autenticados
drop policy if exists "uploads_auth_delete" on storage.objects;
create policy "uploads_auth_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'uploads');

select 'Bucket uploads criado e liberado para a equipe' as resultado;
