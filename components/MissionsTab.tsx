"use client";

import { useCallback, useEffect, useState } from "react";
import type { Task } from "@/lib/types";
import type { Toast } from "./App";

type Props = { reload: () => Promise<void>; toast: (t: Toast) => void };

// Display order Mon..Sun, stored as 0 = Sun ... 6 = Sat
const WEEK = [
  { d: 1, label: "Mo" },
  { d: 2, label: "Tu" },
  { d: 3, label: "We" },
  { d: 4, label: "Th" },
  { d: 5, label: "Fr" },
  { d: 6, label: "Sa" },
  { d: 0, label: "Su" },
];

type Draft = { title: string; xp: number; weekdays: number[] };
const EMPTY: Draft = { title: "", xp: 15, weekdays: [1, 2, 3, 4, 5] };

function describeDays(days: number[]) {
  const s = [...days].sort().join(",");
  if (s === "0,1,2,3,4,5,6") return "Every day";
  if (s === "1,2,3,4,5") return "Weekdays";
  if (s === "0,6") return "Weekends";
  return WEEK.filter((w) => days.includes(w.d))
    .map((w) => w.label)
    .join(" ");
}

function TaskForm({
  initial,
  submitLabel,
  onSubmit,
  onCancel,
}: {
  initial: Draft;
  submitLabel: string;
  onSubmit: (d: Draft) => Promise<boolean>;
  onCancel?: () => void;
}) {
  const [draft, setDraft] = useState<Draft>(initial);
  const [busy, setBusy] = useState(false);

  function toggleDay(d: number) {
    setDraft((x) => ({
      ...x,
      weekdays: x.weekdays.includes(d) ? x.weekdays.filter((y) => y !== d) : [...x.weekdays, d],
    }));
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    const ok = await onSubmit(draft);
    setBusy(false);
    if (ok && !onCancel) setDraft(EMPTY);
  }

  const valid = draft.title.trim().length > 0 && draft.weekdays.length > 0;

  return (
    <form className="taskform" onSubmit={submit}>
      <label className="field">
        <span>Mission</span>
        <input
          value={draft.title}
          maxLength={120}
          placeholder="e.g. Solve one LeetCode problem"
          onChange={(e) => setDraft({ ...draft, title: e.target.value })}
        />
      </label>

      <label className="field">
        <span>
          XP value <strong className="xp-inline">{draft.xp}</strong>
        </span>
        <input
          type="range"
          min={5}
          max={50}
          step={5}
          value={draft.xp}
          onChange={(e) => setDraft({ ...draft, xp: Number(e.target.value) })}
        />
      </label>

      <fieldset className="field">
        <legend>Days</legend>
        <div className="days">
          {WEEK.map((w) => (
            <button
              type="button"
              key={w.d}
              className={`day ${draft.weekdays.includes(w.d) ? "on" : ""}`}
              aria-pressed={draft.weekdays.includes(w.d)}
              onClick={() => toggleDay(w.d)}
            >
              {w.label}
            </button>
          ))}
        </div>
      </fieldset>

      <div className="form-actions">
        {onCancel && (
          <button type="button" className="btn ghost" onClick={onCancel}>
            Cancel
          </button>
        )}
        <button type="submit" className="btn primary" disabled={!valid || busy}>
          {busy ? "Saving…" : submitLabel}
        </button>
      </div>
    </form>
  );
}

export default function MissionsTab({ reload, toast }: Props) {
  const [tasks, setTasks] = useState<Task[] | null>(null);
  const [editing, setEditing] = useState<string | null>(null);
  const [showArchived, setShowArchived] = useState(false);

  const load = useCallback(async () => {
    const res = await fetch("/api/tasks", { cache: "no-store" });
    const data = await res.json();
    if (!res.ok) {
      toast({ text: data.error ?? "Couldn't load missions", kind: "bad" });
      return;
    }
    setTasks(data.tasks as Task[]);
  }, [toast]);

  useEffect(() => {
    load();
  }, [load]);

  async function send(url: string, method: string, body: unknown, success: string): Promise<boolean> {
    try {
      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Couldn't save");
      toast({ text: success, kind: "good" });
      await Promise.all([load(), reload()]);
      return true;
    } catch (e) {
      toast({ text: (e as Error).message, kind: "bad" });
      return false;
    }
  }

  // Dated plan tasks live in the Plan tab; this tab manages the repeating missions.
  const recurring = (tasks ?? []).filter((t) => !t.day);
  const active = recurring.filter((t) => !t.archived_at);
  const archived = recurring.filter((t) => t.archived_at);

  return (
    <div className="stack">
      <section className="panel">
        <h2>Add a mission</h2>
        <TaskForm initial={EMPTY} submitLabel="Add mission" onSubmit={(d) => send("/api/tasks", "POST", d, "Mission added")} />
      </section>

      <section className="panel">
        <div className="panel-head">
          <h2>Repeating missions</h2>
          <span className="muted small">{active.length}</span>
        </div>
        {tasks === null && <p className="muted">Loading…</p>}
        {tasks !== null && active.length === 0 && <p className="muted">No repeating missions. Your dated plan tasks are in the Plan tab.</p>}
        <ul className="missionlist">
          {active.map((t) =>
            editing === t.id ? (
              <li key={t.id} className="mission editing">
                <TaskForm
                  initial={{ title: t.title, xp: t.xp, weekdays: t.weekdays }}
                  submitLabel="Save changes"
                  onCancel={() => setEditing(null)}
                  onSubmit={async (d) => {
                    const ok = await send(`/api/tasks/${t.id}`, "PATCH", d, "Changes saved");
                    if (ok) setEditing(null);
                    return ok;
                  }}
                />
              </li>
            ) : (
              <li key={t.id} className="mission">
                <div className="mission-main">
                  <span className="task-title">{t.title}</span>
                  <span className="muted small">
                    {describeDays(t.weekdays)} · +{t.xp} XP
                  </span>
                </div>
                <div className="mission-actions">
                  <button className="btn small ghost" onClick={() => setEditing(t.id)}>
                    Edit
                  </button>
                  <button
                    className="btn small ghost"
                    onClick={() => send(`/api/tasks/${t.id}`, "PATCH", { archived: true }, "Mission archived")}
                  >
                    Archive
                  </button>
                </div>
              </li>
            ),
          )}
        </ul>
      </section>

      {archived.length > 0 && (
        <section className="panel">
          <button className="panel-toggle" aria-expanded={showArchived} onClick={() => setShowArchived(!showArchived)}>
            <h2>Archived</h2>
            <span className="muted small">
              {archived.length} {showArchived ? "▴" : "▾"}
            </span>
          </button>
          {showArchived && (
            <ul className="missionlist">
              {archived.map((t) => (
                <li key={t.id} className="mission archived">
                  <div className="mission-main">
                    <span className="task-title">{t.title}</span>
                    <span className="muted small">
                      {describeDays(t.weekdays)} · +{t.xp} XP
                    </span>
                  </div>
                  <div className="mission-actions">
                    <button
                      className="btn small ghost"
                      onClick={() => send(`/api/tasks/${t.id}`, "PATCH", { archived: false }, "Mission restored")}
                    >
                      Restore
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>
      )}
    </div>
  );
}
