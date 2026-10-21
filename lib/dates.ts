// All "days" are plain YYYY-MM-DD strings in the app timezone (Europe/Berlin by default).
// Arithmetic is done at UTC noon so DST changes can never shift a date.

export const APP_TIMEZONE = process.env.APP_TIMEZONE || "Europe/Berlin";

export function dayInTz(date: Date = new Date(), timeZone: string = APP_TIMEZONE): string {
  // en-CA formats as YYYY-MM-DD
  return new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

export function todayStr(): string {
  return dayInTz(new Date());
}

function toUtcNoon(day: string): Date {
  return new Date(`${day}T12:00:00Z`);
}

export function addDays(day: string, n: number): string {
  const d = toUtcNoon(day);
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

/** 0 = Sunday ... 6 = Saturday */
export function weekdayOf(day: string): number {
  return toUtcNoon(day).getUTCDay();
}

/** Monday of the week that contains `day` */
export function mondayOf(day: string): string {
  const wd = weekdayOf(day);
  const offset = (wd + 6) % 7; // Mon -> 0, Sun -> 6
  return addDays(day, -offset);
}

/** Converts an ISO timestamp to the app-timezone day it falls on */
export function isoToDay(iso: string): string {
  return dayInTz(new Date(iso));
}
