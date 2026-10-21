import { NextResponse } from "next/server";
import { getState } from "@/lib/data";
import { sendToAll } from "@/lib/push";
import { safeEqual } from "@/lib/auth";

export const dynamic = "force-dynamic";
export const maxDuration = 30;

/**
 * Called by Vercel Cron at 18:00 UTC (see vercel.json).
 * Vercel sends "Authorization: Bearer <CRON_SECRET>" automatically.
 * Only pushes if some of today's missions are still open.
 */
export async function GET(req: Request) {
  const secret = process.env.CRON_SECRET;
  const auth = req.headers.get("authorization") ?? "";
  if (!secret || !safeEqual(auth, `Bearer ${secret}`)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const state = await getState();
    const open = state.todayTasks.filter((t) => !t.done);
    if (open.length === 0) {
      return NextResponse.json({ skipped: true, reason: state.todayTasks.length ? "all done" : "nothing scheduled" });
    }

    const xpLeft = open.reduce((s, t) => s + t.xp, 0) + 20;
    const streakNote = state.streak > 0 ? ` Keep your ${state.streak}-day streak alive.` : "";
    const body =
      open.length === 1
        ? `1 mission left: ${open[0].title}. +${xpLeft} XP waiting.${streakNote}`
        : `${open.length} missions left today. +${xpLeft} XP waiting.${streakNote}`;

    const result = await sendToAll({ title: "Missions still open", body, url: "/", tag: "daily-reminder" });
    return NextResponse.json({ open: open.length, ...result });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ error: (err as Error).message }, { status: 500 });
  }
}
