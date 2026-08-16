# Phase 5 — Routines

Two kinds, and the difference matters more than the schedule:

- **Session routines** run inside an open session and die with it. They are recreated at
  startup and expire on their own after a week. Fine for anything that only matters while
  someone is at the machine.
- **Cloud routines** run on a server and fire whether or not the machine is on. Anything
  the user would be annoyed to miss belongs here.

Say that plainly before asking anything. Most people put their morning briefing in a
session cron, close the laptop, and then wonder why it never arrives.

## What to offer

> "Jeg foreslår tre til at starte med:
>
> Daglig briefing, hver morgen: hvad der skete i går, hvad der venter i dag, med links.
> Daglig høst, sidst på dagen: jeg samler dagens arbejde ind i din second brain. Du
> hører ikke fra mig, medmindre noget er gået galt.
> Watchers, hver anden time i arbejdstiden: siger kun noget hvis noget driver.
> Ugentlig self-review: jeg bedømmer min egen uge og foreslår justeringer.
>
> Lyder det rigtigt, eller vil du skrue på det?"

Recommend the briefing as a cloud routine and the rest as session routines. The briefing is
the one that hurts to miss.

Offer the harvest only if phase 7 set up a brain. Without one it has nowhere to write, and
a routine that cannot do its job is worse than a missing one — it looks like coverage.

Ask for times only after they have said yes to the set. Default to something early enough
to be useful and late enough to have news: a briefing around 09:00, the harvest in the
evening once the day's work is done, watchers every two hours between 08:00 and 20:00 on
weekdays, the review on a Monday morning.

## Only enable what has a source

Phase 4 noted which watchers have their source connected. Enable those. For the rest, say
so in one line rather than turning on a check that can never fire:

> "Regnings-watcheren venter på at du forbinder mail. Sig til, så tænder jeg den."

## agent.json

This is what the assistant reads at startup. Write it now.

```json
{
  "name": "<agent name>",
  "timezone": "<IANA timezone>",
  "channel": "telegram",
  "chat_id": "<numeric id, or null>",
  "language": "da",
  "routines": [
    { "id": "daily-briefing", "where": "cloud",   "cron": "12 9 * * 1-5", "enabled": true },
    { "id": "daily-harvest",  "where": "session", "cron": "23 18 * * *", "enabled": true },
    { "id": "watchers",       "where": "session", "cron": "7 8-20/2 * * 1-5", "enabled": true },
    { "id": "self-review",    "where": "session", "cron": "5 9 * * 1", "enabled": true }
  ],
  "watchers": {
    "stale-work": true,
    "commitment-drift": true,
    "unpaid-bills": false,
    "calendar-invites": false,
    "unanswered": false,
    "daily-digest": true
  }
}
```

`where: session` routines are recreated at startup by the runtime's own scheduler.
`where: cloud` routines need step 2.

## Cloud routines

Only if the user wants them. `crons/README.md` has the details; the short version:

1. The user runs `npx trigger.dev@latest login` and `init` in their own terminal. Both are
   interactive and open a browser, so they cannot be driven from a tool call. Wait for
   them to say it is done.
2. Adapt `crons/examples/morning-briefing.ts` to what they actually want.
3. Environment variables go in the Trigger.dev dashboard under Production, never in this
   repo. A cloud routine that messages them needs the bot token and chat ID there.
4. The user runs `npx trigger.dev@latest deploy`, then fires it once from the dashboard to
   confirm it works end to end.

If they would rather not, everything becomes a session routine. Say the consequence once:
nothing fires while the machine is off.

## Output

`agent.json`, written. Merge:

```json
{ "current_phase": 6, "steps_completed": [..., "phase_5"] }
```
