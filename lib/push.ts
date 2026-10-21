import "server-only";
import webpush from "web-push";
import { db } from "./supabase";
import { requireEnv } from "./env";

type Sub = { endpoint: string; p256dh: string; auth: string };

let configured = false;
function configure() {
  if (configured) return;
  webpush.setVapidDetails(
    requireEnv("VAPID_SUBJECT"),
    requireEnv("NEXT_PUBLIC_VAPID_PUBLIC_KEY"),
    requireEnv("VAPID_PRIVATE_KEY"),
  );
  configured = true;
}

export type PushPayload = { title: string; body: string; url?: string; tag?: string };

/** Sends to every saved device. Removes subscriptions the push service says are gone. */
export async function sendToAll(payload: PushPayload): Promise<{ sent: number; removed: number; failed: number }> {
  configure();
  const { data, error } = await db().from("push_subscriptions").select("endpoint,p256dh,auth");
  if (error) throw new Error(`Database error (push_subscriptions): ${error.message}`);
  const subs = (data ?? []) as Sub[];

  let sent = 0;
  let removed = 0;
  let failed = 0;
  await Promise.all(
    subs.map(async (s) => {
      try {
        await webpush.sendNotification(
          { endpoint: s.endpoint, keys: { p256dh: s.p256dh, auth: s.auth } },
          JSON.stringify(payload),
          { TTL: 60 * 60 * 4, urgency: "normal" },
        );
        sent += 1;
      } catch (err) {
        const code = (err as { statusCode?: number }).statusCode;
        if (code === 404 || code === 410) {
          await db().from("push_subscriptions").delete().eq("endpoint", s.endpoint);
          removed += 1;
        } else {
          failed += 1;
          console.error("Push failed", code, (err as Error).message);
        }
      }
    }),
  );
  return { sent, removed, failed };
}
