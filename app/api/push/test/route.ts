import { NextResponse } from "next/server";
import { sendToAll } from "@/lib/push";
import { handle } from "@/lib/api";

export const dynamic = "force-dynamic";

export const POST = handle(async () => {
  const result = await sendToAll({
    title: "Track Record",
    body: "Test notification — reminders are working. 🚀",
    url: "/",
    tag: "test",
  });
  return NextResponse.json(result);
});
