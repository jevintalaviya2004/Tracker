import "server-only";
import { db } from "./supabase";
import { todayStr } from "./dates";
import { computeState, DAY_BONUS_XP, scheduledOn } from "./game";
import type { AppState, Completion, DayBonus, Milestone, Task } from "./types";

function check<T>(res: { data: T | null; error: { message: string } | null }, what: string): T {
  if (res.error) throw new Error(`Database error (${what}): ${res.error.message}`);
  return (res.data ?? ([] as unknown)) as T;
}

/** Supabase returns at most 1000 rows per request — page through everything. */
async function fetchAll<T>(table: string, columns: string, order: string): Promise<T[]> {
  const pageSize = 1000;
  const rows: T[] = [];
  for (let from = 0; ; from += pageSize) {
    const res = await db()
      .from(table)
      .select(columns)
      .order(order, { ascending: true })
      .range(from, from + pageSize - 1);
    const page = check<T[]>(res as never, table);
    rows.push(...page);
    if (page.length < pageSize) break;
  }
  return rows;
}

export async function getAllTasks(): Promise<Task[]> {
  return fetchAll<Task>("tasks", "id,title,xp,weekdays,sort_order,created_at,archived_at", "created_at");
}

export async function getState(): Promise<AppState> {
  const [tasks, completions, bonuses, milestones] = await Promise.all([
    getAllTasks(),
    fetchAll<Completion>("completions", "task_id,day,xp", "day"),
    fetchAll<DayBonus>("day_bonuses", "day,xp", "day"),
    fetchAll<Milestone>("milestones", "id,phase,phase_title,title,sort_order,done_at", "sort_order"),
  ]);
  return computeState({ tasks, completions, bonuses, milestones, today: todayStr() });
}

/** Ticks or unticks a task for today and keeps the +20 day bonus in sync. */
export async function toggleToday(taskId: string): Promise<void> {
  const today = todayStr();
  const tasks = await getAllTasks();
  const task = tasks.find((t) => t.id === taskId);
  if (!task) throw new HttpError(404, "Task not found");
  const scheduled = scheduledOn(tasks, today);
  if (!scheduled.some((t) => t.id === taskId)) throw new HttpError(400, "This task isn't scheduled for today");

  const existing = check<{ id: string }[]>(
    (await db().from("completions").select("id").eq("task_id", taskId).eq("day", today)) as never,
    "completions",
  );

  if (existing.length) {
    check((await db().from("completions").delete().eq("task_id", taskId).eq("day", today)) as never, "uncomplete");
  } else {
    const ins = await db()
      .from("completions")
      .upsert({ task_id: taskId, day: today, xp: task.xp }, { onConflict: "task_id,day", ignoreDuplicates: true });
    check(ins as never, "complete");
  }

  await syncDayBonus(today, scheduled.map((t) => t.id));
}

export async function syncDayBonus(day: string, scheduledIds: string[]): Promise<void> {
  const done = check<{ task_id: string }[]>(
    (await db().from("completions").select("task_id").eq("day", day)) as never,
    "completions",
  );
  const doneSet = new Set(done.map((d) => d.task_id));
  const complete = scheduledIds.length > 0 && scheduledIds.every((id) => doneSet.has(id));
  if (complete) {
    check(
      (await db().from("day_bonuses").upsert({ day, xp: DAY_BONUS_XP }, { onConflict: "day", ignoreDuplicates: true })) as never,
      "bonus",
    );
  } else {
    check((await db().from("day_bonuses").delete().eq("day", day)) as never, "bonus");
  }
}

/** Re-check today's bonus after tasks were added, edited or archived. */
export async function resyncTodayBonus(): Promise<void> {
  const today = todayStr();
  const tasks = await getAllTasks();
  await syncDayBonus(today, scheduledOn(tasks, today).map((t) => t.id));
}

export class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}
