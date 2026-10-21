import { NextResponse } from "next/server";
import { createSessionToken, safeEqual, SESSION_COOKIE, SESSION_DAYS } from "@/lib/auth";

export const dynamic = "force-dynamic";

export async function POST(req: Request) {
  const expected = process.env.APP_PASSCODE;
  if (!expected) {
    return NextResponse.json({ error: "APP_PASSCODE is not set on the server" }, { status: 500 });
  }

  let passcode = "";
  try {
    const body = (await req.json()) as { passcode?: unknown };
    passcode = String(body.passcode ?? "");
  } catch {
    // fall through with empty passcode
  }

  if (!safeEqual(passcode, expected)) {
    // Small delay makes guessing slower
    await new Promise((r) => setTimeout(r, 800));
    return NextResponse.json({ error: "Wrong passcode" }, { status: 401 });
  }

  const res = NextResponse.json({ ok: true });
  res.cookies.set(SESSION_COOKIE, await createSessionToken(), {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: SESSION_DAYS * 24 * 60 * 60,
  });
  return res;
}
