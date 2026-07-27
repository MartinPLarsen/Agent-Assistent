---
name: watchers
description: Use when a scheduled proactive check fires, when the user asks why they were or were not nudged, or when adding, editing, or disabling a watcher. Runs the definitions in watchers/ against Linear, mail, calendar, and local memory files, and sends at most one nudge.
---

# Watchers

You are the runner. The watchers themselves are markdown files in `watchers/`, one per
check. Adding a check is a new file, not a code change.

The whole design rests on one number: **at most one nudge per fire.** A proactive
assistant that speaks every time it runs gets muted within a week, and then none of the
checks matter. Silence is the default and the normal outcome.

## Order of operations

1. **Silence rules.** If any match, exit with a one-line terminal log and send nothing.
2. **Load the enabled watchers** from `agent.json` (`watchers` object). Skip any whose
   source is not connected.
3. **Gather** what those watchers need, in parallel, once. Do not let each watcher make
   its own duplicate calls.
4. **Evaluate** in the order the watchers are listed. Stop at the first match.
5. **Send one nudge**, or log "no drift" and exit.
6. **Record the fire** in `watchers/.state.json` so cooldowns work.

## Silence rules

Check these first, every time. Any one of them means exit without sending.

1. Local time is before 08:00 or after 20:00 in the timezone from `agent.json`
2. It is Saturday or Sunday
3. The user has a calendar event running right now (skip if calendar is not connected)
4. The user sent a message in the last 15 minutes — the newest entry in
   `memory/session.log.md` is under 15 minutes old
5. `memory/session.log.md` has no entries at all, only its header comments. No signal to
   work with, so no basis for a nudge.

Timestamps in the session log are UTC with a trailing `Z`. Convert to local before
comparing, and work out the current DST offset rather than hardcoding one.

## Cooldowns

`watchers/.state.json` records the last fire per watcher and per subject:

```json
{ "stale-work": { "LUS-127": "2026-07-27T09:00Z" },
  "commitment-drift": { "bilags-oauth": "2026-07-26T14:00Z" } }
```

A watcher that fired about a given subject does not fire about that same subject again
until its cooldown has passed. Default cooldown is 24 hours; a watcher file can override
it. Nagging twice about the same issue is how an assistant teaches someone to ignore it.

If the file does not exist, create it. If it is unparseable, start fresh rather than
crashing — a corrupt cooldown file must not take the whole check down.

## Watcher file format

```markdown
---
id: stale-work
source: linear
model: cheap
cooldown: 24h
---

## Fires when
<the rule, precisely enough that two runs agree>

## Gather
<what to read, and with which filters>

## Nudge
<the exact message template, ending in a closed choice>
```

**`model`** is `cheap` or `quality`. Scanning, filtering and matching run cheap. Only
composing the final nudge needs quality. This check runs every two hours all day; running
all of it on a premium model is how a background loop quietly becomes the largest line on
the bill.

**`source`** names what must be connected. No source, no fire — and that is not an error,
but it should be visible. See watcher health below.

## Writing a nudge

Three rules, and the third is the one people skip.

1. **One subject.** Name the specific issue, bill, or commitment. Never "you have several
   things drifting".
2. **Say what you saw, not what they should feel.** "LUS-127 has been in progress since
   Thursday and has not come up since" beats "you seem to be falling behind".
3. **End in a closed choice.** The user is on a phone. Every nudge finishes with two or
   three one-word answers:

   > Skal den lukkes, udskydes, eller er det den vi tager nu?

   An open question at the end of a nudge is a nudge that gets left on read.

Keep it under five lines. Plain text, no markdown formatting, no emoji as decoration.

## Watcher health

Every fire, note in `watchers/.state.json` whether each enabled watcher ran cleanly,
errored, or was skipped for a missing source. The `daily-digest` watcher reports this as
one line.

This exists because the alternative is what v1 did: catch the error, log to terminal, exit
silently. A watcher can then be broken for a month and look exactly like a watcher with
nothing to report. If a watcher has errored on every fire for 24 hours, say so in the
digest and name the error.

## On error

Catch it, record it in the state file, and exit without sending. Do not send a Telegram
message reporting that a background check failed — that defeats the point of a quiet
system. The digest is where failures surface.

## Adding a watcher

1. Write `watchers/<id>.md` in the format above.
2. Add `"<id>": true` to the `watchers` object in `agent.json`.
3. Confirm the source is connected. If not, leave it `false` and tell the user what to
   connect.

## Shipped watchers

| File | Fires when |
|------|------------|
| `stale-work.md` | in-progress issue untouched over 4 hours and unmentioned |
| `commitment-drift.md` | an open commitment unmentioned for 24 hours |
| `unpaid-bills.md` | an invoice with a due date and no sign of payment |
| `calendar-invites.md` | an invitation still unanswered close to the event |
| `unanswered.md` | a direct question to the user with no reply in 24 hours |
| `daily-digest.md` | once a day, regardless — this one always speaks |
