"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import type { AppState } from "@/lib/types";
import TodayTab from "./TodayTab";
import MissionControlTab from "./MissionControlTab";
import MissionsTab from "./MissionsTab";
import PlanTab from "./PlanTab";

type Tab = "today" | "plan" | "control" | "missions";

const TABS: { id: Tab; label: string; icon: string }[] = [
  { id: "today", label: "Today", icon: "◎" },
  { id: "plan", label: "Plan", icon: "▦" },
  { id: "control", label: "Control", icon: "◆" },
  { id: "missions", label: "Missions", icon: "☰" },
];

export type Toast = { text: string; kind?: "good" | "bad" };

export default function App() {
  const [tab, setTab] = useState<Tab>("today");
  const [state, setState] = useState<AppState | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [toast, setToast] = useState<Toast | null>(null);
  const toastTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const prev = useRef<AppState | null>(null);

  const showToast = useCallback((t: Toast) => {
    setToast(t);
    if (toastTimer.current) clearTimeout(toastTimer.current);
    toastTimer.current = setTimeout(() => setToast(null), 3200);
  }, []);

  /** Applies new state from the server and celebrates level-ups / perfect days. */
  const apply = useCallback(
    (next: AppState) => {
      const before = prev.current;
      if (before && before.today === next.today) {
        if (next.level.level > before.level.level) showToast({ text: `Level ${next.level.level} reached`, kind: "good" });
        else if (next.dayComplete && !before.dayComplete) showToast({ text: "All missions done. +20 XP bonus", kind: "good" });
      }
      prev.current = next;
      setState(next);
    },
    [showToast],
  );

  const load = useCallback(async () => {
    try {
      const res = await fetch("/api/state", { cache: "no-store" });
      if (res.status === 401) {
        window.location.replace("/login");
        return;
      }
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Couldn't load your missions");
      setError(null);
      apply(data as AppState);
    } catch (e) {
      setError((e as Error).message);
    }
  }, [apply]);

  useEffect(() => {
    load();
    // Refresh when the app comes back to the foreground (e.g. the next morning)
    const onVisible = () => document.visibilityState === "visible" && load();
    document.addEventListener("visibilitychange", onVisible);
    if ("serviceWorker" in navigator) navigator.serviceWorker.register("/sw.js").catch(() => {});
    return () => document.removeEventListener("visibilitychange", onVisible);
  }, [load]);

  useEffect(() => {
    try {
      const saved = localStorage.getItem("tr-tab") as Tab | null;
      if (saved && TABS.some((t) => t.id === saved)) setTab(saved);
    } catch {}
  }, []);

  function pick(t: Tab) {
    setTab(t);
    try {
      localStorage.setItem("tr-tab", t);
    } catch {}
    window.scrollTo({ top: 0 });
  }

  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    window.location.replace("/login");
  }

  return (
    <div className="shell">
      <header className="topbar">
        <span className="brand">Track Record</span>
        <button className="link" onClick={logout}>
          Sign out
        </button>
      </header>

      <main className="content">
        {error && (
          <div className="banner bad" role="alert">
            <span>{error}</span>
            <button className="btn small" onClick={load}>
              Try again
            </button>
          </div>
        )}
        {!state && !error && <div className="loading">Loading missions…</div>}
        {state && tab === "today" && <TodayTab state={state} apply={apply} toast={showToast} />}
        {state && tab === "plan" && <PlanTab apply={apply} toast={showToast} />}
        {state && tab === "control" && <MissionControlTab state={state} apply={apply} toast={showToast} />}
        {state && tab === "missions" && <MissionsTab reload={load} toast={showToast} />}
      </main>

      <nav className="tabbar" aria-label="Sections">
        {TABS.map((t) => (
          <button
            key={t.id}
            className={`tab ${tab === t.id ? "active" : ""}`}
            aria-current={tab === t.id ? "page" : undefined}
            onClick={() => pick(t.id)}
          >
            <span className="tab-icon" aria-hidden>
              {t.icon}
            </span>
            <span>{t.label}</span>
          </button>
        ))}
      </nav>

      {toast && (
        <div className={`toast ${toast.kind ?? ""}`} role="status">
          {toast.text}
        </div>
      )}
    </div>
  );
}
