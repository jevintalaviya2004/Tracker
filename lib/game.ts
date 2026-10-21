import { addDays, isoToDay, mondayOf, weekdayOf } from "./dates";
import type {
  Achievement,
  AppState,
  Completion,
  DayBonus,
  HeatCell,
  LevelInfo,
  Milestone,
  PhaseView,
  Task,
  WeekXp,
} from "./types";

export const DAY_BONUS_XP = 20;
export const MILESTONE_XP = 50;
export const FIRST_LEVEL_XP = 100; // level 1 -> 2
export const LEVEL_STEP_XP = 50; // each level needs 50 XP more than the last
export const HEATMAP_WEEKS = 16;
export const WEEKLY_BARS = 8;

/** Level from total XP. Level 1→2 needs 100 XP, 2→3 needs 150, 3→4 needs 200, … */
export function levelFromXp(totalXp: number): LevelInfo {
  let level = 1;
  let need = FIRST_LEVEL_XP;
  let rest = Math.max(0, totalXp);
  while (rest >= need) {
    rest -= need;
    level += 1;
    need += LEVEL_STEP_XP;
  }
  return { level, xpIntoLevel: rest, xpForNext: need };
}

/** Was this task on the schedule for `day`? Respects when it was created and archived. */
export function isScheduledOn(task: Task, day: string): boolean {
  if (task.archived_at && isoToDay(task.archived_at) <= day) return false;
  // One-off plan task: only on its own date
  if (task.day) return task.day === day;
  if (isoToDay(task.created_at) > day) return false;
  return task.weekdays.includes(weekdayOf(day));
}

export function scheduledOn(tasks: Task[], day: string): Task[] {
  return tasks.filter((t) => isScheduledOn(t, day));
}

type Ctx = {
  tasks: Task[];
  completions: Completion[];
  bonuses: DayBonus[];
  milestones: Milestone[];
  today: string;
};

export function computeState({ tasks, completions, bonuses, milestones, today }: Ctx): AppState {
  // ---- indexes -------------------------------------------------------------
  const doneByDay = new Map<string, Set<string>>();
  const xpByDay = new Map<string, number>();
  for (const c of completions) {
    if (!doneByDay.has(c.day)) doneByDay.set(c.day, new Set());
    doneByDay.get(c.day)!.add(c.task_id);
    xpByDay.set(c.day, (xpByDay.get(c.day) ?? 0) + c.xp);
  }
  const bonusDays = new Set(bonuses.map((b) => b.day));
  for (const b of bonuses) xpByDay.set(b.day, (xpByDay.get(b.day) ?? 0) + b.xp);
  for (const m of milestones) {
    if (!m.done_at) continue;
    const d = isoToDay(m.done_at);
    xpByDay.set(d, (xpByDay.get(d) ?? 0) + MILESTONE_XP);
  }

  const scheduledCount = (day: string) => scheduledOn(tasks, day).length;

  // ---- today ---------------------------------------------------------------
  const todaysDone = doneByDay.get(today) ?? new Set<string>();
  const todayTasks = scheduledOn(tasks, today)
    .sort(
      (a, b) =>
        (a.day ? 0 : 1) - (b.day ? 0 : 1) ||
        a.sort_order - b.sort_order ||
        a.created_at.localeCompare(b.created_at),
    )
    .map((t) => ({
      id: t.id,
      title: t.title,
      xp: t.xp,
      done: todaysDone.has(t.id),
      details: t.details ?? null,
      links: Array.isArray(t.links) ? t.links : [],
      planned: !!t.day,
    }));
  const dayComplete = todayTasks.length > 0 && todayTasks.every((t) => t.done);
  if (dayComplete) bonusDays.add(today);

  // ---- XP / level ----------------------------------------------------------
  const taskXp = completions.reduce((s, c) => s + c.xp, 0);
  const bonusXp = bonuses.reduce((s, b) => s + b.xp, 0);
  const milestonesDone = milestones.filter((m) => m.done_at).length;
  const totalXp = taskXp + bonusXp + milestonesDone * MILESTONE_XP;
  const level = levelFromXp(totalXp);
  const xpToday = xpByDay.get(today) ?? 0;

  // ---- streaks -------------------------------------------------------------
  // A day counts if every scheduled task was done. A day with nothing scheduled
  // is skipped (doesn't add, doesn't break). Today only counts once it is done,
  // and an unfinished today never breaks the streak.
  const firstDay = tasks.length
    ? tasks.map((t) => isoToDay(t.created_at)).sort()[0]
    : today;

  let streak = 0;
  {
    let d = bonusDays.has(today) ? today : addDays(today, -1);
    let guard = 0;
    while (d >= firstDay && guard++ < 2000) {
      if (bonusDays.has(d)) streak += 1;
      else if (scheduledCount(d) > 0) break;
      d = addDays(d, -1);
    }
  }

  let bestStreak = 0;
  {
    let run = 0;
    let d = firstDay;
    let guard = 0;
    while (d <= today && guard++ < 2000) {
      if (bonusDays.has(d)) {
        run += 1;
        bestStreak = Math.max(bestStreak, run);
      } else if (scheduledCount(d) > 0 && d !== today) {
        run = 0;
      }
      d = addDays(d, 1);
    }
    bestStreak = Math.max(bestStreak, streak);
  }

  // ---- heatmap (16 weeks, Monday-first columns) ----------------------------
  const heatStart = addDays(mondayOf(today), -7 * (HEATMAP_WEEKS - 1));
  const heatmap: HeatCell[] = [];
  for (let i = 0; i < HEATMAP_WEEKS * 7; i++) {
    const day = addDays(heatStart, i);
    const future = day > today;
    const scheduled = future ? 0 : scheduledCount(day);
    const done = future ? 0 : (doneByDay.get(day)?.size ?? 0);
    heatmap.push({ day, scheduled, done: Math.min(done, scheduled || done), future });
  }

  // ---- weekly XP bars ------------------------------------------------------
  const weeklyXp: WeekXp[] = [];
  const thisMonday = mondayOf(today);
  for (let w = WEEKLY_BARS - 1; w >= 0; w--) {
    const weekStart = addDays(thisMonday, -7 * w);
    let xp = 0;
    for (let i = 0; i < 7; i++) xp += xpByDay.get(addDays(weekStart, i)) ?? 0;
    weeklyXp.push({ weekStart, xp });
  }

  // ---- roadmap phases ------------------------------------------------------
  const phaseMap = new Map<string, PhaseView>();
  for (const m of [...milestones].sort((a, b) => a.sort_order - b.sort_order)) {
    if (!phaseMap.has(m.phase)) {
      phaseMap.set(m.phase, { phase: m.phase, title: m.phase_title, done: 0, total: 0, milestones: [] });
    }
    const p = phaseMap.get(m.phase)!;
    p.total += 1;
    if (m.done_at) p.done += 1;
    p.milestones.push(m);
  }
  const phases = [...phaseMap.values()].sort((a, b) => a.phase.localeCompare(b.phase));

  // ---- achievements --------------------------------------------------------
  const perfectDays = bonusDays.size;
  const phaseCleared = phases.some((p) => p.total > 0 && p.done === p.total);
  const allPhasesCleared = phases.length > 0 && phases.every((p) => p.done === p.total);
  const a = (id: string, icon: string, title: string, description: string, unlocked: boolean): Achievement => ({
    id, icon, title, description, unlocked,
  });
  const achievements: Achievement[] = [
    a("first-step", "🚀", "Liftoff", "Complete your first mission", completions.length >= 1),
    a("perfect-day", "⭐", "Perfect day", "Finish every mission in a day", perfectDays >= 1),
    a("streak-3", "🔥", "On fire", "Reach a 3-day streak", bestStreak >= 3),
    a("streak-7", "📅", "Full week", "Reach a 7-day streak", bestStreak >= 7),
    a("streak-30", "🏔️", "Unbreakable", "Reach a 30-day streak", bestStreak >= 30),
    a("perfect-25", "💎", "Consistent", "25 perfect days", perfectDays >= 25),
    a("missions-100", "💯", "Centurion", "Complete 100 missions", completions.length >= 100),
    a("xp-1000", "⚡", "Charged", "Earn 1,000 XP", totalXp >= 1000),
    a("level-5", "🎖️", "Level 5", "Reach level 5", level.level >= 5),
    a("level-10", "👑", "Level 10", "Reach level 10", level.level >= 10),
    a("milestone-1", "🗺️", "On the map", "Finish your first roadmap milestone", milestonesDone >= 1),
    a(
      allPhasesCleared ? "roadmap" : "phase-clear",
      allPhasesCleared ? "🏆" : "🧭",
      allPhasesCleared ? "Mission complete" : "Phase cleared",
      allPhasesCleared ? "Every roadmap milestone done" : "Finish every milestone in one phase",
      phaseCleared,
    ),
  ];

  return {
    today,
    weekday: weekdayOf(today),
    todayTasks,
    totalXp,
    xpToday,
    level,
    streak,
    bestStreak,
    dayComplete,
    phases,
    heatmap,
    weeklyXp,
    achievements,
  };
}
