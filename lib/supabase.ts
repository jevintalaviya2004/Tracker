import "server-only";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { requireEnv } from "./env";

let client: SupabaseClient | null = null;

/** Server-only Supabase client using the service_role key (bypasses RLS). */
export function db(): SupabaseClient {
  if (client) return client;
  client = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: { persistSession: false, autoRefreshToken: false },
    global: {
      // Next.js 14 caches fetch() by default — always hit the database fresh.
      fetch: (input: RequestInfo | URL, init?: RequestInit) => fetch(input, { ...init, cache: "no-store" }),
    },
  });
  return client;
}
