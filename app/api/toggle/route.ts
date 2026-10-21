import { NextResponse } from "next/server";
import { getState, HttpError, toggleToday } from "@/lib/data";
import { handle, readJson } from "@/lib/api";

export const dynamic = "force-dynamic";

export const POST = handle(async (req: Request) => {
  const { taskId } = await readJson<{ taskId?: string }>(req);
  if (!taskId) throw new HttpError(400, "taskId is required");
  await toggleToday(taskId);
  return NextResponse.json(await getState());
});
