alter table custom_links add column if not exists group_key text;
alter table custom_links add column if not exists position int default 0;
create index if not exists idx_clinks_group on custom_links(group_key);

drop index if exists custom_links_link_key_key;
alter table custom_links drop constraint if exists custom_links_link_key_key;
