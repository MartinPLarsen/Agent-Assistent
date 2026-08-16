---
name: daily-briefing
description: Use when the daily briefing routine fires, or when the user asks what is on today, what they should focus on, or where things stand. Produces a short scannable brief ending in one recommendation. SKIP for writing yesterday into the brain — that is daily-harvest, which speaks to nobody; this one speaks to the user and writes nothing.
---

# Daily briefing

Yesterday's facts, today's shape, and one recommendation. It is the message that decides
whether the assistant gets read at all, so it is short and it is specific.

The `daily-digest` watcher reports what happened. This goes one step further and says what
to do about it. If both are enabled, run this one and fold the digest into it rather than
sending two messages.

## Gather

Only from what is connected. Skip a section rather than printing an empty heading.

- calendar for today
- mail that needs an answer
- issues that moved, and what is in progress
- `memory/open_commitments.md`
- `memory/convo_log.md` for what the last session left in flight

## Pick the one thing

This is the part that matters and the part that is easy to skip.

Out of everything gathered, one item is the most valuable use of the day. Say which. Not
three options, not a ranked list. One, with a one-line reason.

Choose by: what is blocking someone else, then what has a deadline, then what has been
drifting longest, then what the last session left half-finished.

If the honest answer is that nothing is urgent, say that. A quiet day named as a quiet day
is useful information.

## Format

```
Godmorgen.

I dag: {first event} kl. {time}{, og n mere}.
{n} mails venter svar. {n} issues i gang.
Åbent: {oldest commitment}.

Mit forslag: {the one thing}. {why, one line}
```

Under 10 lines. Numbers, not adjectives. Every reference links to the thing itself so it
can be acted on from a phone.

## What not to do

- No motivational opener and no upbeat close
- No "you have a busy day ahead" — they can see the calendar
- Never more than one recommendation. A menu is what you send when you have not decided,
  and deciding is the job.
- Do not repeat yesterday's recommendation word for word. If it is still the right answer,
  say that it is still the right answer and that it has not moved.
