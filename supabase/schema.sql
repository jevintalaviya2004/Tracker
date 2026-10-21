-- Track Record — database schema
-- Run this once in Supabase -> SQL Editor -> New query -> Run.
-- Safe to re-run: it only creates what is missing.

create extension if not exists pgcrypto;

-- Daily missions
create table if not exists public.tasks (
  id          uuid primary key default gen_random_uuid(),
  title       text not null check (char_length(title) between 1 and 120),
  xp          integer not null default 10 check (xp between 5 and 50),
  -- 0 = Sunday, 1 = Monday ... 6 = Saturday
  weekdays    smallint[] not null default '{1,2,3,4,5}',
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now(),
  archived_at timestamptz,
  -- One-off plan tasks: shown only on this date (weekdays is ignored)
  day         date,
  details     text,
  links       jsonb not null default '[]'::jsonb,
  plan_key    text unique
);
-- For databases created before the plan feature existed
alter table public.tasks add column if not exists day date;
alter table public.tasks add column if not exists details text;
alter table public.tasks add column if not exists links jsonb not null default '[]'::jsonb;
alter table public.tasks add column if not exists plan_key text unique;
create index if not exists tasks_day_idx on public.tasks(day);

-- One row per task per day it was ticked off
create table if not exists public.completions (
  id         uuid primary key default gen_random_uuid(),
  task_id    uuid not null references public.tasks(id) on delete cascade,
  day        date not null,
  xp         integer not null,
  created_at timestamptz not null default now(),
  unique (task_id, day)
);
create index if not exists completions_day_idx on public.completions(day);

-- +20 XP bonus for days where every scheduled task was finished
create table if not exists public.day_bonuses (
  day        date primary key,
  xp         integer not null default 20,
  created_at timestamptz not null default now()
);

-- Roadmap milestones (P0–P4), +50 XP each when done
create table if not exists public.milestones (
  id          text primary key,
  phase       text not null,
  phase_title text not null,
  title       text not null,
  sort_order  integer not null default 0,
  done_at     timestamptz
);

-- Web Push subscriptions (one per device/browser)
create table if not exists public.push_subscriptions (
  endpoint   text primary key,
  p256dh     text not null,
  auth       text not null,
  user_agent text,
  created_at timestamptz not null default now()
);

-- Lock everything down: the app only talks to the DB with the service_role key
-- on the server, which bypasses RLS. No policies = no public access.
alter table public.tasks              enable row level security;
alter table public.completions        enable row level security;
alter table public.day_bonuses        enable row level security;
alter table public.milestones         enable row level security;
alter table public.push_subscriptions enable row level security;

-- Roadmap to the Werkstudent goal (October 2027).
-- Edit titles here (or in Table Editor) to match your own plan.
insert into public.milestones (id, phase, phase_title, title, sort_order) values
  ('p0-1', 'P0', 'Launch',          'Tracker live on phone, used 7 days in a row',          1),
  ('p0-2', 'P0', 'Launch',          'GitHub profile cleaned up with a profile README',      2),
  ('p0-3', 'P0', 'Launch',          'CV draft v1 (German + English)',                        3),
  ('p1-1', 'P1', 'Foundations',     'Python fluency: 50 practice problems solved',           4),
  ('p1-2', 'P1', 'Foundations',     'Math for ML refresher (linear algebra, probability)',   5),
  ('p1-3', 'P1', 'Foundations',     'Finish one complete ML course (scikit-learn)',          6),
  ('p1-4', 'P1', 'Foundations',     'Pass winter semester exams',                            7),
  ('p2-1', 'P2', 'Build',           'Project 1: end-to-end ML project, deployed',            8),
  ('p2-2', 'P2', 'Build',           'Project 2: deep learning project in PyTorch',           9),
  ('p2-3', 'P2', 'Build',           'Project 3: LLM / RAG application',                     10),
  ('p2-4', 'P2', 'Build',           'Write-up or blog post for one project',                11),
  ('p3-1', 'P3', 'Prepare',         'Final CV + LinkedIn and Xing profiles',                12),
  ('p3-2', 'P3', 'Prepare',         'Target list of 30 companies',                          13),
  ('p3-3', 'P3', 'Prepare',         'Interview practice: 50 coding problems',               14),
  ('p3-4', 'P3', 'Prepare',         'German Anschreiben template ready',                    15),
  ('p4-1', 'P4', 'Apply',           '20 applications sent',                                 16),
  ('p4-2', 'P4', 'Apply',           'First interview done',                                 17),
  ('p4-3', 'P4', 'Apply',           'Werkstudent contract signed (Oct 2027)',               18)
on conflict (id) do nothing;
