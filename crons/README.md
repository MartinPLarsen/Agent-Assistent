# Cloud routines

Setup phase 5 decides which routines belong here. The rule: **anything the user would be
annoyed to miss goes in the cloud.** Session routines die when the terminal closes and
expire after a week on their own, so a morning briefing in a session cron arrives only on
the mornings someone happened to leave Claude Code running.

## Setup

The user runs these themselves. Both are interactive and `login` opens a browser, so
neither works from a tool call.

```bash
npx trigger.dev@latest login
npx trigger.dev@latest init
```

`init` writes `trigger.config.ts` and creates a `src/trigger/` folder. Answer TypeScript
when it asks.

Then copy an example across and adapt it:

```bash
cp crons/examples/morning-briefing.ts src/trigger/
npx trigger.dev@latest deploy
```

## Environment variables

Set in the Trigger.dev dashboard under Settings, Environment Variables, Production. Never
in this repo — cloud routines run on someone else's machine, and a token committed here is
a token in the git history forever.

| Variable | Needed for |
|----------|-----------|
| `TELEGRAM_BOT_TOKEN` | sending anything to the user |
| `TELEGRAM_CHAT_ID` | knowing who to send it to |
| service keys | whatever the routine reads |

## How a cloud routine reaches the user

Directly. The task calls the Telegram API itself and the message arrives on the user's
phone. There is no local process to run and nothing that has to be awake.

What it cannot do is reach the *assistant*. A cloud routine has no access to `memory/`,
`CONTEXT.md`, or anything else in this folder — it runs on a server that has never seen
them. So a cloud routine either carries everything it needs in its own code, or it fetches
it from somewhere the cloud can also read.

That is the real split, more than the schedule:

- **Cloud** for anything that must arrive: a briefing, a reminder, a deadline.
- **Session** for anything that needs the assistant's memory and context: the watchers, the
  self-review.

## Timezones

Use the object form of `cron` with an explicit IANA timezone, as the example does. Writing
a UTC pattern by hand and adding an offset is correct for about five months, and then the
clocks move.

## When it does not fire

Check the dashboard's run list first. A routine that never ran and one that ran and failed
look identical from the outside, and they have completely different causes.
