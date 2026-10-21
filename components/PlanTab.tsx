"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import type { AppState, PlanItem, PlanResponse } from "@/lib/types";
import TaskItem from "./TaskItem";
import type { Toast } from "./App";

type Props = { apply: (s: AppState) => void; toast: (t: Toast) => void };

function addDays(day: string, n: number) {
  const d = new Date(`${day}T12:00:00Z`);
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}
function mondayOf(day: string) {
  const wd = new Date(`${day}T12:00:00Z`).getUTCDay();
  return addDays(day, -((wd + 6) % 7));
}
function fmt(day: string, opts: Intl.DateTimeFormatOptions) {
  return new Date(`${day}T12:00:00Z`).toLocaleDateString("en-GB", { ...opts, timeZone: "UTC" });
}

export default function PlanTab({ apply, toast }: Props) {
  const [plan, setPlan] = useState<PlanResponse | null>(null);
  const [week, setWeek] = useState<string | null>(null);
  const [pending, setPending] = useState<string | null>(null);

  const load = useCallback(async () => {
    const res = await fetch("/api/plan", { cache: "no-store" });
    const data = await res.json();
    if (!res.ok) {
      toast({ text: data.error ?? "Couldn't load the plan", kind: "bad" });
      return;
    }
    setPlan(data as PlanResponse);
  }, [toast]);

  useEffect(() => {
    load();
  }, [load]);

  const weeks = useMemo(() => {
    const map = new Map<string, PlanItem[]>();
    for (const item of plan?.items ?? []) {
      const w = mondayOf(item.day);
      if (!map.has(w)) map.set(w, []);
      map.get(w)!.push(item);
    }
    return [...map.entries()].sort((a, b) => a[0].localeCompare(b[0]));
  }, [plan]);

  // Default to the current week (or the nearest one in the plan)
  useEffect(() => {
    if (!plan || week || weeks.length === 0) return;
    const current = mondayOf(plan.today);
    const match = weeks.find(([w]) => w === current) ?? weeks.find(([w]) => w > current) ?? weeks[weeks.length - 1];
    setWeek(match[0]);
  }, [plan, weeks, week]);

  async function toggle(item: PlanItem) {
    setPending(item.id);
    setPlan((p) => p && { ...p, items: p.items.map((i) => (i.id === item.id ? { ...i, done: !i.done } : i)) });
    try {
      const res = await fetch("/api/toggle", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ taskId: item.id }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Couldn't save");
      apply(data as AppState);
    } catch (e) {
      toast({ text: (e as Error).message, kind: "bad" });
    } finally {
      setPending(null);
      load();
    }
  }

  if (!plan) return <div className="loading">Loading plan…</div>;
  if (plan.items.length === 0) {
    return (
      <section className="panel">
        <h2>No plan loaded yet</h2>
        <p className="muted">Run supabase/plan.sql in the Supabase SQL Editor to load the 60-day plan.</p>
      </section>
    );
  }

  const total = plan.items.length;
  const done = plan.items.filter((i) => i.done).length;
  const idx = Math.max(0, weeks.findIndex(([w]) => w === week));
  const [weekStart, items] = weeks[idx] ?? weeks[0];

  const days: string[] = [];
  for (let i = 0; i < 7; i++) days.push(addDays(weekStart, i));

  const first = plan.items[0].day;
  const last = plan.items[plan.items.length - 1].day;

  return (
    <div className="stack">
      <section className="panel">
        <div className="panel-head">
          <h2>60-day plan</h2>
          <span className="muted small">
            {done}/{total} tasks done
          </span>
        </div>
        <p className="muted small">
          {fmt(first, { day: "numeric", month: "short" })} to {fmt(last, { day: "numeric", month: "short", year: "numeric" })}
          . ML foundations, then a predictive-maintenance project with MLflow, FastAPI, Docker, CI and monitoring, plus German
          practice and applications.
        </p>
        <div className="levelbar">
          <div className="levelbar-fill" style={{ width: `${(done / total) * 100}%` }} />
        </div>
      </section>

      <div className="weeknav">
        <button className="btn small ghost" onClick={() => setWeek(weeks[idx - 1][0])} disabled={idx === 0}>
          Previous
        </button>
        <span className="weeknav-label">
          Week {idx + 1} of {weeks.length}
          <span className="muted small">
            {fmt(weekStart, { day: "numeric", month: "short" })} – {fmt(addDays(weekStart, 6), { day: "numeric", month: "short" })}
          </span>
        </span>
        <button
          className="btn small ghost"
          onClick={() => setWeek(weeks[idx + 1][0])}
          disabled={idx === weeks.length - 1}
        >
          Next
        </button>
      </div>

      {days.map((day) => {
        const dayItems = items.filter((i) => i.day === day);
        if (dayItems.length === 0) return null;
        const isToday = day === plan.today;
        const isPast = day < plan.today;
        return (
          <section key={day} className={`panel day-card ${isToday ? "is-today" : ""}`}>
            <div className="panel-head">
              <h3>{fmt(day, { weekday: "long", day: "numeric", month: "short" })}</h3>
              <span className="muted small">
                {isToday ? "Today" : `${dayItems.filter((i) => i.done).length}/${dayItems.length}`}
              </span>
            </div>
            <ul className="tasklist">
              {dayItems.map((item) => (
                <li key={item.id}>
                  <TaskItem
                    title={item.title}
                    xp={item.xp}
                    done={item.done}
                    details={item.details}
                    links={item.links}
                    onToggle={isToday ? () => toggle(item) : null}
                    disabled={pending !== null}
                    status={!item.done && isPast ? "missed" : !isToday && !isPast ? "upcoming" : undefined}
                  />
                </li>
              ))}
            </ul>
          </section>
        );
      })}
    </div>
  );
}
