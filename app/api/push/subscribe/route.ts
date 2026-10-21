import { NextResponse } from "next/server";
import { db } from "@/lib/supabase";
import { HttpError } from "@/lib/data";
import { handle, readJson } from "@/lib/api";

export const dynamic = "force-dynamic";

type Body = { endpoint?: string; keys?: { p256dh?: string; auth?: string } };

/** Saves this device's push subscription (reminder switch on). */
export const POST = handle(async (req: Request) => {
  const sub = await readJson<Body>(req);
  if (!sub.endpoint || !sub.keys?.p256dh || !sub.keys?.auth) throw new HttpError(400, "Invalid subscription");
  if (!sub.endpoint.startsWith("https://")) throw new HttpError(400, "Invalid endpoint");

  const { error } = await db()
    .from("push_subscriptions")
    .upsert(
      {
        endpoint: sub.endpoint,
        p256dh: sub.keys.p256dh,
        auth: sub.keys.auth,
        user_agent: req.headers.get("user-agent")?.slice(0, 300) ?? null,
      },
      { onConflict: "endpoint" },
    );
  if (error) throw new Error(error.message);
  return NextResponse.json({ ok: true });
});

/** Removes this device's subscription (reminder switch off). */
export const DELETE = handle(async (req: Request) => {
  const { endpoint } = await readJson<{ endpoint?: string }>(req);
  if (!endpoint) throw new HttpError(400, "endpoint is required");
  const { error } = await db().from("push_subscriptions").delete().eq("endpoint", endpoint);
  if (error) throw new Error(error.message);
  return NextResponse.json({ ok: true });
});
