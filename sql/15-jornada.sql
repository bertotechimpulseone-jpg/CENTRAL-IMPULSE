alter table profiles add column if not exists work_start_time time default '09:00:00';
alter table profiles add column if not exists work_end_time time default '18:00:00';
alter table profiles add column if not exists lunch_duration_min int default 60;
alter table profiles add column if not exists tolerance_min int default 15;
alter table profiles add column if not exists work_days text default '1,2,3,4,5';
