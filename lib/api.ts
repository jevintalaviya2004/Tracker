import "server-only";
import { NextResponse } from "next/server";
import { HttpError } from "./data";

/** Wraps a route handler so thrown errors become JSON responses. */
export function handle<A extends unknown[]>(fn: (...args: A) => Promise<Response>) {
  return async (...args: A): Promise<Response> => {
    try {
      return await fn(...args);
    } catch (err) {
      if (err instanceof HttpError) {
        return NextResponse.json({ error: err.message }, { status: err.status });
      }
      console.error(err);
      return NextResponse.json({ error: (err as Error).message || "Server error" }, { status: 500 });
    }
  };
}

export async function readJson<T = Record<string, unknown>>(req: Request): Promise<T> {
  try {
    return (await req.json()) as T;
  } catch {
    throw new HttpError(400, "Invalid JSON body");
  }
}

export function parseWeekdays(value: unknown): number[] {
  if (!Array.isArray(value)) throw new HttpError(400, "weekdays must be a list");
  const days = [...new Set(value.map(Number))].filter((d) => Number.isInteger(d) && d >= 0 && d <= 6).sort();
  if (days.length === 0) throw new HttpError(400, "Pick at least one weekday");
  return days;
}

export function parseXp(value: unknown): number {
  const xp = Math.round(Number(value));
  if (!Number.isFinite(xp) || xp < 5 || xp > 50) throw new HttpError(400, "XP must be between 5 and 50");
  return xp;
}

export function parseTitle(value: unknown): string {
  const title = String(value ?? "").trim();
  if (!title) throw new HttpError(400, "Title is required");
  if (title.length > 120) throw new HttpError(400, "Title is too long (max 120)");
  return title;
}
