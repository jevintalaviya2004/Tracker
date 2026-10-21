"use client";

import { useState } from "react";
import type { AppState, HeatCell } from "@/lib/types";
import type { Toast } from "./App";

type Props = { state: AppState; apply: (s: AppState) => void; toast: (t: Toast) => void };

function heatLevel(c: HeatCell): string {
  if (c.future) return "future";
  if (c.scheduled === 0) return c.done > 0 ? "l4" : "rest";
  const r = c.done / c.scheduled;
  if (r === 0) return "l0";
  if (r < 0.5) return "l1";
  if (r < 1) return "l2";
  return "l4";
}

function shortDate(day: string) {
  return new Date(`${day}T12:00:00Z`).toLocaleDateString("en-GB", { day: "numeric", month: "short", timeZone: "UTC" });
}

export default function MissionControlTab({ state, apply, toast }: Props) {
  const firstOpen = state.phases.find((p) => p.done < p.total)?.phase ?? null;
  const [openPhase, setOpenPhase] = useState<string | null>(firstOpen);
  const [busy, setBusy] = useState<string | null>(null);

  const totalMilestones = state.phases.reduce((s, p) => s + p.total, 0);
  const doneMilestones = state.phases.reduce((s, p) => s + p.done, 0);
  const maxWeek = Math.max(50, ...state.weeklyXp.map((w) => w.xp));
  const unlocked = state.achievements.filter((a) => a.unlocked).length;

  async function toggleMilestone(id: string) {
    setBusy(id);
    try {
      const res = await fetch(`/api/milestones/${encodeURIComponent(id)}`, { method: "POST" });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Couldn't save");
      const wasDone = state.phases.flatMap((p) => p.milestones).find((m) => m.id === id)?.done_at;
      if (!wasDone) toast({ text: "Milestone done. +50 XP", kind: "good" });
      apply(data as AppState);
    } catch (e) {
      toast({ text: (e as Error).message, kind: "bad" });
    } finally {
      setBusy(null);
    }
  }

  // Heatmap: columns are weeks, rows Mon..Sun
  const weeks: HeatCell[][] = [];
  for (let i = 0; i < state.heatmap.length; i += 7) weeks.push(state.heatmap.slice(i, i + 7));

  return (
    <div className="stack">
      <section className="panel">
        <div className="panel-head">
          <h2>Road to Werkstudent</h2>
          <span className="muted small">
            {doneMilestones}/{totalMilestones} milestones
          </span>
        </div>
        <p className="muted small">Target: a Werkstudent role in October 2027.</p>

        <ol className="phases">
          {state.phases.map((p) => {
            const complete = p.total > 0 && p.done === p.total;
            const current = p.phase === firstOpen;
            const isOpen = openPhase === p.phase;
            return (
              <li key={p.phase} className={`phase ${complete ? "complete" : ""} ${current ? "current" : ""}`}>
                <button
                  className="phase-head"
                  aria-expanded={isOpen}
                  onClick={() => setOpenPhase(isOpen ? null : p.phase)}
                >
                  <span className="phase-dot" aria-hidden>
                    {complete ? "✓" : p.phase}
                  </span>
                  <span className="phase-title">{p.title}</span>
                  <span className="phase-count">
                    {p.done}/{p.total}
                  </span>
                </button>
                <div className="phase-bar">
                  <div style={{ width: `${p.total ? (p.done / p.total) * 100 : 0}%` }} />
                </div>
                {isOpen && (
                  <ul className="milestones">
                    {p.milestones.map((m) => (
                      <li key={m.id}>
                        <button
                          className={`milestone ${m.done_at ? "done" : ""}`}
                          onClick={() => toggleMilestone(m.id)}
                          disabled={busy !== null}
                          aria-pressed={!!m.done_at}
                        >
                          <span className="check" aria-hidden>
                            {m.done_at ? "✓" : ""}
                          </span>
                          <span className="task-title">{m.title}</span>
                          <span className="xp">+50</span>
                        </button>
                      </li>
                    ))}
                  </ul>
                )}
              </li>
            );
          })}
        </ol>
      </section>

      <section className="panel">
        <div className="panel-head">
          <h2>Consistency</h2>
          <span className="muted small">Best streak {state.bestStreak} days</span>
        </div>
        <div className="heatmap-wrap">
          <div className="heat-days" aria-hidden>
            <span>Mon</span>
            <span />
            <span>Wed</span>
            <span />
            <span>Fri</span>
            <span />
            <span>Sun</span>
          </div>
          <div className="heatmap" role="img" aria-label="Last 16 weeks of mission completion">
            {weeks.map((w, wi) => (
              <div className="heat-col" key={wi}>
                {w.map((c) => (
                  <span
                    key={c.day}
                    className={`heat ${heatLevel(c)} ${c.day === state.today ? "today" : ""}`}
                    title={
                      c.future
                        ? shortDate(c.day)
                        : c.scheduled === 0
                          ? `${shortDate(c.day)}: rest day`
                          : `${shortDate(c.day)}: ${c.done}/${c.scheduled} done`
                    }
                  />
                ))}
              </div>
            ))}
          </div>
        </div>
        <div className="legend muted small">
          <span>Less</span>
          <span className="heat l0" />
          <span className="heat l1" />
          <span className="heat l2" />
          <span className="heat l4" />
          <span>More</span>
          <span className="legend-gap" />
          <span className="heat rest" />
          <span>Rest day</span>
        </div>
      </section>

      <section className="panel">
        <div className="panel-head">
          <h2>Weekly XP</h2>
          <span className="muted small">Last 8 weeks</span>
        </div>
        <div className="bars">
          {state.weeklyXp.map((w, i) => {
            const current = i === state.weeklyXp.length - 1;
            return (
              <div className="bar-col" key={w.weekStart}>
                <span className="bar-value">{w.xp || ""}</span>
                <div className="bar-track">
                  <div className={`bar ${current ? "current" : ""}`} style={{ height: `${(w.xp / maxWeek) * 100}%` }} />
                </div>
                <span className="bar-label">{current ? "Now" : shortDate(w.weekStart)}</span>
              </div>
            );
          })}
        </div>
      </section>

      <section className="panel">
        <div className="panel-head">
          <h2>Achievements</h2>
          <span className="muted small">
            {unlocked}/{state.achievements.length} unlocked
          </span>
        </div>
        <ul className="achievements">
          {state.achievements.map((a) => (
            <li key={a.id} className={`achievement ${a.unlocked ? "unlocked" : ""}`}>
              <span className="ach-icon" aria-hidden>
                {a.unlocked ? a.icon : "🔒"}
              </span>
              <span className="ach-title">{a.title}</span>
              <span className="ach-desc">{a.description}</span>
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
