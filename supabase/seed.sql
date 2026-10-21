-- Optional: 5 starter missions. Run after schema.sql. Run it only once
-- (running it again adds the tasks a second time).
-- weekdays: 0 = Sun, 1 = Mon, 2 = Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat

insert into public.tasks (title, xp, weekdays, sort_order) values
  ('Study / lecture review (45 min)',          20, '{1,2,3,4,5}',     1),
  ('Python or ML practice (1 problem)',        15, '{1,2,3,4,5,6}',   2),
  ('Work on portfolio project (30 min)',       25, '{1,3,5,6}',       3),
  ('Read one ML article or paper section',     10, '{2,4,0}',         4),
  ('Plan tomorrow (5 min)',                     5, '{0,1,2,3,4,5,6}', 5);
