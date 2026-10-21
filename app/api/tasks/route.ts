import { NextResponse } from "next/server";
import { db } from "@/lib/supabase";
import { getAllTasks, resyncTodayBonus } from "@/lib/data";
import { handle, parseTitle, parseWeekdays, parseXp, readJson } from "@/lib/api";

export const dynamic = "force-dynamic";

export const GET = handle(async () => {
  const tasks = await getAllTasks();
  tasks.sort((a, b) => a.sort_order - b.sort_order || a.created_at.localeCompare(b.created_at));
  return NextResponse.json({ tasks }, { headers: { "Cache-Control": "no-store" } });
});

export const POST = handle(async (req: Request) => {
  const body = await readJson<{ title?: unknown; xp?: unknown; weekdays?: unknown }>(req);
  const title = parseTitle(body.title);
  const xp = parseXp(body.xp);
  const weekdays = parseWeekdays(body.weekdays);

  const tasks = await getAllTasks();
  const sort_order = tasks.reduce((m, t) => Math.max(m, t.sort_order), 0) + 1;

  const { data, error } = await db()
    .from("tasks")
    .insert({ title, xp, weekdays, sort_order })
    .select("id,title,xp,weekdays,sort_order,created_at,archived_at")
    .single();
  if (error) throw new Error(error.message);

  await resyncTodayBonus();
  return NextResponse.json({ task: data }, { status: 201 });
});
