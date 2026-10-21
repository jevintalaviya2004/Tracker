import { NextResponse } from "next/server";
import { getState } from "@/lib/data";
import { handle } from "@/lib/api";

export const dynamic = "force-dynamic";

export const GET = handle(async () => {
  return NextResponse.json(await getState(), { headers: { "Cache-Control": "no-store" } });
});
