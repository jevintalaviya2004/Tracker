import { NextResponse } from "next/server";
import { db } from "@/lib/supabase";
import { HttpError, resyncTodayBonus } from "@/lib/data";
import { handle, parseTitle, parseWeekdays, parseXp, readJson } from "@/lib/api";

export const dynamic = "force-dynamic";

type Ctx = { params: { id: string } };

export const PATCH = handle(async (req: Request, { params }: Ctx) => {
  const body = await readJson<{ title?: unknown; xp?: unknown; weekdays?: unknown; archived?: unknown }>(req);

  const update: Record<string, unknown> = {};
  if (body.title !== undefined) update.title = parseTitle(body.title);
  if (body.xp !== undefined) update.xp = parseXp(body.xp);
  if (body.weekdays !== undefined) update.weekdays = parseWeekdays(body.weekdays);
  if (body.archived !== undefined) update.archived_at = body.archived ? new Date().toISOString() : null;
  if (Object.keys(update).length === 0) throw new HttpError(400, "Nothing to update");

  const { data, error } = await db()
    .from("tasks")
    .update(update)
    .eq("id", params.id)
    .select("id,title,xp,weekdays,sort_order,created_at,archived_at")
    .maybeSingle();
  if (error) throw new Error(error.message);
  if (!data) throw new HttpError(404, "Task not found");

  await resyncTodayBonus();
  return NextResponse.json({ task: data });
});
