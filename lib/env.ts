/** Reads a required environment variable and fails with a clear message if it's missing. */
export function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value || !value.trim()) {
    throw new Error(`Missing environment variable ${name}. Add it in Vercel -> Settings -> Environment Variables (or .env.local).`);
  }
  return value.trim();
}
