import { schedules } from "@trigger.dev/sdk/v3";

/**
 * Posts a morning briefing to Discord at 07:00 user-local time.
 *
 * Adjust `cron` for your timezone. For Europe/Copenhagen 07:00:
 *   summer (CEST): "0 5 * * *" UTC
 *   winter (CET):  "0 6 * * *" UTC
 *
 * Or use a service like https://crontab.guru to translate local time to UTC.
 */
export const morningBriefing = schedules.task({
  id: "morning-briefing",
  cron: "0 5 * * *", // 07:00 Europe/Copenhagen during CEST
  run: async () => {
    const webhookUrl = process.env.DISCORD_WEBHOOK_URL;
    if (!webhookUrl) {
      throw new Error("DISCORD_WEBHOOK_URL not set in Trigger.dev env vars");
    }

    const message = [
      "Good morning. Here's your briefing prompt:",
      "",
      "Reply with: today's top 3 priorities, anything overdue from open commitments,",
      "and one observation from yesterday's vault entries (if any).",
    ].join("\n");

    const res = await fetch(webhookUrl, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ content: message }),
    });

    if (!res.ok) {
      throw new Error(`Discord webhook failed: ${res.status} ${await res.text()}`);
    }
  },
});
