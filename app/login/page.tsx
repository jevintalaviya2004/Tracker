"use client";

import { useState } from "react";

export default function LoginPage() {
  const [passcode, setPasscode] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    if (!passcode || busy) return;
    setBusy(true);
    setError(null);
    try {
      const res = await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ passcode }),
      });
      if (res.ok) {
        window.location.replace("/");
        return;
      }
      const data = (await res.json().catch(() => ({}))) as { error?: string };
      setError(data.error ?? "Sign-in failed. Try again.");
      setPasscode("");
    } catch {
      setError("No connection. Check your internet and try again.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="login">
      <form className="login-card" onSubmit={submit}>
        <img src="/icons/icon-192.png" alt="" width={72} height={72} className="login-logo" />
        <h1>Track Record</h1>
        <p className="muted">Enter your passcode to open today&apos;s missions.</p>
        <input
          type="password"
          inputMode="text"
          autoComplete="current-password"
          autoFocus
          aria-label="Passcode"
          placeholder="Passcode"
          value={passcode}
          onChange={(e) => setPasscode(e.target.value)}
        />
        {error && (
          <p className="error" role="alert">
            {error}
          </p>
        )}
        <button className="btn primary" type="submit" disabled={busy || !passcode}>
          {busy ? "Signing in…" : "Sign in"}
        </button>
      </form>
    </main>
  );
}
