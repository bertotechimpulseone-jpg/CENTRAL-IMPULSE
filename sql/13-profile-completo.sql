alter table profiles add column if not exists vacation_period_end date;
alter table profiles add column if not exists vacation_legal_deadline date;
alter table profiles add column if not exists last_vacation text;
alter table profiles add column if not exists weekly_tasks int default 0;
alter table profiles add column if not exists promotion_eval text;
alter table profiles add column if not exists raise_eval text;
alter table profiles add column if not exists areas_develop text;
alter table profiles add column if not exists strengths text;
alter table profiles add column if not exists next_review date;
