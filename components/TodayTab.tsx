"use client";

import { useState } from "react";
import type { AppState } from "@/lib/types";
import ProgressRing from "./ProgressRing";
import ReminderSwitch from "./ReminderSwitch";
import TaskItem from "./TaskItem";
import type { Toast } from "./App";

type Props = { state: AppState; apply: (s: AppState) => void; toast: (t: Toast) => void };

const DAY_NAMES = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

function formatDate(day: string) {
  return new Date(`${day}T12:00:00Z`).toLocaleDateString("en-GB", { day: "numeric", month: "long", timeZone: "UTC" });
}

export default function TodayTab({ state, apply, toast }: Props) {
  const [pending, setPending] = useState<string | null>(null);
  const [optimistic, setOptimistic] = useState<Record<string, boolean>>({});

  const tasks = state.todayTasks.map((t) => ({ ...t, done: optimistic[t.id] ?? t.done }));
  const done = tasks.filter((t) => t.done).length;
  const total = tasks.length;
  const left = tasks.filter((t) => !t.done).reduce((s, t) => s + t.xp, 0);
  const { level, xpIntoLevel, xpForNext } = state.level;

  async function toggle(id: string, current: boolean) {
    if (pending) return;
    setPending(id);
    setOptimistic((o) => ({ ...o, [id]: !current }));
    try {
      const res = await fetch("/api/toggle", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ taskId: id }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Couldn't save");
      apply(data as AppState);
    } catch (e) {
      toast({ text: (e as Error).message, kind: "bad" });
    } finally {
      setOptimistic((o) => {
        const { [id]: _, ...rest } = o;
        return rest;
      });
      setPending(null);
    }
  }

  return (
    <div className="stack">
      <section className="hero">
        <p className="date">
          {DAY_NAMES[state.weekday]}, {formatDate(state.today)}
        </p>
        <ProgressRing done={done} total={total}>
          {total === 0 ? (
            <>
              <span className="ring-big">Rest</span>
              <span className="ring-small">day</span>
            </>
          ) : (
            <>
              <span className="ring-big">
                {done}/{total}
              </span>
              <span className="ring-small">{done === total ? "Day complete" : `+${left + 20} XP to go`}</span>
            </>
          )}
        </ProgressRing>

        <div className="stats">
          <div className="stat">
            <span className="stat-value">{level}</span>
            <span className="stat-label">Level</span>
          </div>
          <div className="stat">
            <span className="stat-value">
              {state.streak}
              <span className="flame" aria-hidden>
                {state.streak > 0 ? "🔥" : ""}
              </span>
            </span>
            <span className="stat-label">Day streak</span>
          </div>
          <div className="stat">
            <span className="stat-value">{state.xpToday}</span>
            <span className="stat-label">XP today</span>
          </div>
        </div>

        <div className="levelbar" aria-label={`Level ${level}: ${xpIntoLevel} of ${xpForNext} XP`}>
          <div className="levelbar-fill" style={{ width: `${(xpIntoLevel / xpForNext) * 100}%` }} />
        </div>
        <p className="muted small center">
          {xpIntoLevel} / {xpForNext} XP to level {level + 1} · {state.totalXp} XP total
        </p>
      </section>

      <section className="panel">
        <h2>Today&apos;s missions</h2>
        {total === 0 ? (
          <p className="muted">Nothing scheduled today. Your streak is safe. Check the Plan tab to see what's coming.</p>
        ) : (
          <ul className="tasklist">
            {tasks.map((t) => (
              <li key={t.id}>
                <TaskItem
                  title={t.title}
                  xp={t.xp}
                  done={t.done}
                  details={t.details}
                  links={t.links}
                  onToggle={() => toggle(t.id, t.done)}
                  disabled={pending !== null && pending !== t.id}
                />
              </li>
            ))}
          </ul>
        )}
      </section>

      <ReminderSwitch toast={toast} />
    </div>
  );
}
