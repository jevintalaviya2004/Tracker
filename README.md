# Track Record

Personal daily mission log for the Werkstudent goal (October 2027). Tick off missions, earn XP, levels, streaks and achievements, follow the P0–P4 roadmap, and get an evening push if missions are still open.

## Stack

| Part | Tool |
| --- | --- |
| App | Next.js 14 (App Router, TypeScript) |
| Database | Supabase Postgres (server-only, service_role key) |
| Hosting + cron | Vercel (Hobby plan) |
| Reminders | Web Push with VAPID keys |
| Install | PWA (manifest + service worker) |
| Login | Passcode → signed httpOnly cookie, checked in middleware for every page and API route |

## Game rules

- Each mission has an XP value (5–50) and chosen weekdays.
- +20 XP bonus when every mission scheduled for the day is done.
- +50 XP per roadmap milestone.
- Level 1→2 needs 100 XP, and each level after that needs 50 XP more than the last.
- A day with nothing scheduled doesn't break the streak, and an unfinished today never breaks it.
- "Today" is computed in Europe/Berlin (change it with `APP_TIMEZONE`).

## 60-day plan

`supabase/plan.sql` loads a dated plan from 22 Oct to 20 Dec 2026: 137 tasks, each with written steps, a "Done when" check and verified video or course links. It runs at about 45 min on weekdays and about 2 h on weekends, covering ML foundations, a predictive-maintenance MLOps project, German practice and applications.

- Dated tasks have a `day` and only show up on that date, on the Today tab and in the Plan tab.
- Repeating missions (weekday-based) are managed in the Missions tab.
- The file is safe to re-run. It updates tasks by `plan_key` and keeps your ticks.

## Project layout

```
app/
  page.tsx                 the app (tabs live in components/)
  login/page.tsx           passcode screen
  manifest.ts              PWA manifest
  api/
    login, logout          session cookie
    state                  everything the UI needs (GET)
    toggle                 tick / untick a mission for today
    tasks, tasks/[id]      add, edit, archive, restore missions
    plan                   all dated plan tasks with done status
    milestones/[id]        toggle a roadmap milestone
    push/subscribe, test   reminder switch and test push
    cron/reminder          daily cron (18:00 UTC), protected by CRON_SECRET
components/                Today, Plan, Mission control, Missions tabs
lib/                       game rules, data access, auth, push
middleware.ts              blocks everything unless signed in
public/sw.js               service worker for push
supabase/schema.sql        tables + roadmap milestones
supabase/seed.sql          optional 5 starter missions
supabase/plan.sql          the 60-day plan (run after schema.sql)
vercel.json                cron schedule
```

## Run locally

```bash
npm install
copy .env.example .env.local   # Windows (use cp on macOS/Linux), then fill in the values
npm run dev                    # http://localhost:3000
npm run build                  # production build check
```

Push notifications need HTTPS, so test those on the Vercel URL.

## Deploy

1. **Supabase**: new project (region Frankfurt). SQL Editor → run `supabase/schema.sql`, then `supabase/seed.sql` if you want starter missions. Copy the Project URL and the service_role key (Project Settings → API).
2. **VAPID keys**: `npx web-push generate-vapid-keys`.
3. **GitHub**: push this folder to a private repo `track-record`.
4. **Vercel**: import the repo, add the 8 environment variables from `.env.example`, deploy.
5. **Phone**: open the URL, sign in, Add to Home Screen, open it from the icon, turn on the evening reminder, tap Send test.

The Vercel Hobby cron runs once a day and can fire any time within the scheduled hour.

## Editing the roadmap

Milestones live in the `milestones` table. Edit titles in Supabase → Table Editor, or change the insert in `schema.sql` before the first run.
