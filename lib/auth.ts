// Passcode session. Uses only Web Crypto so it runs in both the Edge middleware
// and Node.js route handlers.

export const SESSION_COOKIE = "tr_session";
export const SESSION_DAYS = 90;

const enc = new TextEncoder();

function b64url(bytes: ArrayBuffer): string {
  let s = "";
  const arr = new Uint8Array(bytes);
  for (let i = 0; i < arr.length; i++) s += String.fromCharCode(arr[i]);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function hmac(secret: string, data: string): Promise<string> {
  const key = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, [
    "sign",
  ]);
  return b64url(await crypto.subtle.sign("HMAC", key, enc.encode(data)));
}

/** Constant-time string comparison */
export function safeEqual(a: string, b: string): boolean {
  const ab = enc.encode(a);
  const bb = enc.encode(b);
  let diff = ab.length ^ bb.length;
  const len = Math.max(ab.length, bb.length);
  for (let i = 0; i < len; i++) diff |= (ab[i] ?? 0) ^ (bb[i] ?? 0);
  return diff === 0;
}

function secret(): string {
  const s = process.env.AUTH_SECRET;
  if (!s || s.length < 16) throw new Error("AUTH_SECRET is missing or shorter than 16 characters");
  return s;
}

export async function createSessionToken(): Promise<string> {
  const exp = Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000;
  const payload = `v1.${exp}`;
  return `${payload}.${await hmac(secret(), payload)}`;
}

export async function verifySessionToken(token: string | undefined | null): Promise<boolean> {
  if (!token) return false;
  const parts = token.split(".");
  if (parts.length !== 3 || parts[0] !== "v1") return false;
  const exp = Number(parts[1]);
  if (!Number.isFinite(exp) || exp < Date.now()) return false;
  try {
    const expected = await hmac(secret(), `${parts[0]}.${parts[1]}`);
    return safeEqual(expected, parts[2]);
  } catch {
    return false;
  }
}
