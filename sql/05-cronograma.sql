insert into cronograma (client_id, year, month, produced, target, has_traffic, status, deadline)
select
  c.id,
  2026,
  m.month,
  case when m.month < 5 then 8 + (m.month * 2)
       when m.month = 5 then 5 + (random()*5)::int
       else 0 end,
  case when c.plan_name = 'Essencial' then 8
       when c.plan_name = 'Crescimento' then 12
       when c.plan_name = 'Premium' then 16
       else 20 end,
  c.plan_name in ('Crescimento','Premium','Enterprise'),
  case when m.month < 5 then 'concluido'
       when m.month = 5 then (array['em-dia','em-andamento','em-andamento','atrasado'])[1 + (random()*3)::int]
       else 'planejado' end,
  make_date(2026, m.month, 5 + (random()*20)::int)
from clients c
cross join generate_series(1, 12) as m(month);
