import { schedules, logger } from "@trigger.dev/sdk/v3";

/**
 * Morning briefing, sent to Telegram.
 *
 * This is a cloud routine: it fires whether or not the machine is on, which is
 * the whole reason a briefing belongs here rather than in a session cron.
 *
 * Give `cron` a timezone and write the time you actually mean. Converting to
 * UTC by hand works until the clocks change, and then it is wrong twice a year
 * in a way nobody notices for a week.
 */
export const morningBriefing = schedules.task({
  id: "morning-briefing",
  cron: {
    pattern: "12 9 * * 1-5",
    timezone: "Europe/Copenhagen",
  },
  run: async (payload) => {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const chatId = process.env.TELEGRAM_CHAT_ID;

    // Fail loudly. A briefing that quietly stops arriving is worse than one
    // that errors in the dashboard, because nobody goes looking for the first.
    if (!token || !chatId) {
      throw new Error(
        "TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID missing. Set both in the " +
          "Trigger.dev dashboard: Settings, Environment Variables, Production.",
      );
    }

    logger.info("Briefing firing", { at: payload.timestamp });

    // Replace this with what the briefing should actually contain: call an API,
    // read a database, ask a model. The skeleton exists to prove the delivery
    // path works end to end before anything is built on top of it.
    const text = [
      "Godmorgen.",
      "",
      "Cloud-briefingen kører. Erstat indholdet her med det du faktisk vil vide.",
    ].join("\n");

    const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ chat_id: chatId, text }),
    });

    if (!res.ok) {
      throw new Error(`Telegram send failed: ${res.status} ${await res.text()}`);
    }
  },
});
