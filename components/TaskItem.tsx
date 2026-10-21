"use client";

import { useState } from "react";
import type { TaskLink } from "@/lib/types";

type Props = {
  title: string;
  xp: number;
  done: boolean;
  details: string | null;
  links: TaskLink[];
  /** null = can't be ticked from here (past or future day) */
  onToggle: (() => void) | null;
  disabled?: boolean;
  status?: "missed" | "upcoming";
  defaultOpen?: boolean;
};

/** Renders the written steps: "- " lines become a list, "Done when:" is highlighted. */
function Details({ text }: { text: string }) {
  const blocks: React.ReactNode[] = [];
  let list: string[] = [];
  const flush = () => {
    if (list.length) {
      blocks.push(
        <ul key={`l${blocks.length}`} className="steps">
          {list.map((l, i) => (
            <li key={i}>{l}</li>
          ))}
        </ul>,
      );
      list = [];
    }
  };
  for (const raw of text.split("\n")) {
    const line = raw.trim();
    if (!line) {
      flush();
      continue;
    }
    if (line.startsWith("- ")) {
      list.push(line.slice(2));
      continue;
    }
    flush();
    if (line.toLowerCase().startsWith("done when:")) {
      blocks.push(
        <p key={`p${blocks.length}`} className="done-when">
          <strong>Done when:</strong> {line.slice(10).trim()}
        </p>,
      );
    } else {
      blocks.push(<p key={`p${blocks.length}`}>{line}</p>);
    }
  }
  flush();
  return <div className="details-text">{blocks}</div>;
}

export default function TaskItem({ title, xp, done, details, links, onToggle, disabled, status, defaultOpen }: Props) {
  const [open, setOpen] = useState(!!defaultOpen);
  const hasMore = !!details || links.length > 0;

  return (
    <div className={`task ${done ? "done" : ""} ${status ?? ""} ${open ? "open" : ""}`}>
      <div className="task-row">
        {onToggle ? (
          <button
            className="check"
            onClick={onToggle}
            disabled={disabled}
            aria-pressed={done}
            aria-label={done ? `Mark "${title}" as not done` : `Mark "${title}" as done`}
          >
            {done ? "✓" : ""}
          </button>
        ) : (
          <span className="check static" aria-label={done ? "Done" : status === "missed" ? "Missed" : "Not done yet"}>
            {done ? "✓" : status === "missed" ? "–" : ""}
          </span>
        )}
        <button
          className="task-main"
          onClick={() => hasMore && setOpen(!open)}
          aria-expanded={hasMore ? open : undefined}
          disabled={!hasMore}
        >
          <span className="task-title">{title}</span>
          {hasMore && <span className="task-more">{open ? "Hide steps" : "Show steps"}</span>}
        </button>
        <span className="xp">+{xp}</span>
      </div>
      {open && hasMore && (
        <div className="task-details">
          {details && <Details text={details} />}
          {links.length > 0 && (
            <ul className="links">
              {links.map((l) => (
                <li key={l.url}>
                  <a href={l.url} target="_blank" rel="noopener noreferrer">
                    {l.label}
                  </a>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  );
}
