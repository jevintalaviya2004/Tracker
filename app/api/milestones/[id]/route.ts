import { NextResponse } from "next/server";
import { db } from "@/lib/supabase";
import { getState, HttpError } from "@/lib/data";
import { handle } from "@/lib/api";

export const dynamic = "force-dynamic";

/** Toggles a roadmap milestone done / not done. */
export const POST = handle(async (_req: Request, { params }: { params: { id: string } }) => {
  const { data, error } = await db().from("milestones").select("id,done_at").eq("id", params.id).maybeSingle();
  if (error) throw new Error(error.message);
  if (!data) throw new HttpError(404, "Milestone not found");

  const done_at = data.done_at ? null : new Date().toISOString();
  const upd = await db().from("milestones").update({ done_at }).eq("id", params.id);
  if (upd.error) throw new Error(upd.error.message);

  return NextResponse.json(await getState());
});
