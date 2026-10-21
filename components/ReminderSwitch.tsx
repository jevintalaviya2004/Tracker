"use client";

import { useEffect, useState } from "react";
import type { Toast } from "./App";

type Status = "checking" | "unsupported" | "needs-install" | "blocked" | "off" | "on";

function urlBase64ToUint8Array(base64: string): Uint8Array {
  const padding = "=".repeat((4 - (base64.length % 4)) % 4);
  const b64 = (base64 + padding).replace(/-/g, "+").replace(/_/g, "/");
  const raw = atob(b64);
  const out = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
  return out;
}

function isIos() {
  return /iphone|ipad|ipod/i.test(navigator.userAgent) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
}

function isStandalone() {
  return (
    window.matchMedia("(display-mode: standalone)").matches ||
    (navigator as Navigator & { standalone?: boolean }).standalone === true
  );
}

async function getRegistration() {
  await navigator.serviceWorker.register("/sw.js");
  return navigator.serviceWorker.ready;
}

export default function ReminderSwitch({ toast }: { toast: (t: Toast) => void }) {
  const [status, setStatus] = useState<Status>("checking");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    (async () => {
      const supported = "serviceWorker" in navigator && "PushManager" in window && "Notification" in window;
      if (!supported) {
        setStatus(isIos() && !isStandalone() ? "needs-install" : "unsupported");
        return;
      }
      if (Notification.permission === "denied") {
        setStatus("blocked");
        return;
      }
      try {
        const reg = await getRegistration();
        const sub = await reg.pushManager.getSubscription();
        setStatus(sub ? "on" : "off");
      } catch {
        setStatus("off");
      }
    })();
  }, []);

  async function turnOn() {
    const key = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
    if (!key) {
      toast({ text: "NEXT_PUBLIC_VAPID_PUBLIC_KEY is missing on the server", kind: "bad" });
      return;
    }
    setBusy(true);
    try {
      const permission = await Notification.requestPermission();
      if (permission !== "granted") {
        setStatus(permission === "denied" ? "blocked" : "off");
        return;
      }
      const reg = await getRegistration();
      const sub =
        (await reg.pushManager.getSubscription()) ??
        (await reg.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(key).buffer as ArrayBuffer,
        }));
      const res = await fetch("/api/push/subscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(sub.toJSON()),
      });
      if (!res.ok) throw new Error((await res.json().catch(() => ({}))).error ?? "Couldn't save this device");
      setStatus("on");
      toast({ text: "Reminders on for this device", kind: "good" });
    } catch (e) {
      toast({ text: (e as Error).message || "Couldn't turn on reminders", kind: "bad" });
    } finally {
      setBusy(false);
    }
  }

  async function turnOff() {
    setBusy(true);
    try {
      const reg = await getRegistration();
      const sub = await reg.pushManager.getSubscription();
      if (sub) {
        await fetch("/api/push/subscribe", {
          method: "DELETE",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ endpoint: sub.endpoint }),
        });
        await sub.unsubscribe();
      }
      setStatus("off");
      toast({ text: "Reminders off for this device" });
    } catch (e) {
      toast({ text: (e as Error).message, kind: "bad" });
    } finally {
      setBusy(false);
    }
  }

  async function sendTest() {
    setBusy(true);
    try {
      const res = await fetch("/api/push/test", { method: "POST" });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Test failed");
      if (data.sent > 0) toast({ text: `Test sent to ${data.sent} device${data.sent > 1 ? "s" : ""}`, kind: "good" });
      else toast({ text: "No devices are signed up for reminders yet", kind: "bad" });
    } catch (e) {
      toast({ text: (e as Error).message, kind: "bad" });
    } finally {
      setBusy(false);
    }
  }

  const on = status === "on";
  const hint =
    status === "needs-install"
      ? "On iPhone: tap Share → Add to Home Screen, then open Track Record from the home-screen icon to turn on reminders."
      : status === "unsupported"
        ? "This browser can't receive push notifications."
        : status === "blocked"
          ? "Notifications are blocked for this site. Allow them in your browser or phone settings, then reload."
          : "If missions are still open in the evening, you get one push around 20:00 (19:00 in winter).";

  return (
    <section className="panel reminder">
      <div className="reminder-row">
        <div>
          <h3>Evening reminder</h3>
          <p className="muted small">{hint}</p>
        </div>
        <button
          role="switch"
          aria-checked={on}
          aria-label="Evening reminder"
          className={`switch ${on ? "on" : ""}`}
          disabled={busy || !(status === "on" || status === "off")}
          onClick={on ? turnOff : turnOn}
        >
          <span className="knob" />
        </button>
      </div>
      {on && (
        <button className="btn small ghost" onClick={sendTest} disabled={busy}>
          Send test
        </button>
      )}
    </section>
  );
}
