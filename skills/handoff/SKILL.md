---
name: handoff
description: Use when a session is ending, when context is running long, when the user says handoff or compact, or before any risky operation that might lose the session. Writes convo_log.md so the next session picks up where this one stopped.
---

# Handoff

Sessions die without warning. The convo log is the only thing that survives, so write it
before you need it, not when you notice the context filling up.

## When

- After a decision, so the reasoning survives the session that produced it
- After a task finishes
- When the topic changes
- When context is getting long
- Before anything that might kill the session

Little and often beats one careful summary at the end that never gets written.

## Write it

`memory/convo_log.md`. Newest session on top, keep only the latest, under 40 lines.

```markdown
## <date> (<what this session was about>)

**Active context:** What is in flight right now, and the first thing the next session
should do. Be specific enough to act on: which file, which branch, which command.

**Completed:** What actually got done. Commit hashes, file paths, issue ids.

**Pending:** What is still open, and what unblocks each item. If it is waiting on the
user, say so.

**Key decisions:** What was chosen and why. This is the part that looks arbitrary in a
week without the reasoning.
```

## Write it so someone else could use it

The next reader has none of this conversation. Test each line against that:

- "fixed the bug" tells them nothing. "fixed the timezone comparison in the drift rule,
  commit a1b2c3" tells them where to look.
- "waiting for Martin" is incomplete. "waiting for Martin to run the OAuth script; the
  scan window is 11 days so it needs doing before the 3rd" is a handoff.
- A decision without its reason gets overturned by the next session, which then discovers
  the reason the hard way.

## What does not go here

Facts. If the session taught you something durable, that is a `memory/facts/` file — see
the `memory` skill. The convo log is state, and it gets overwritten. Putting a hard-won
finding in it means losing it on the next handoff.

## Then check

If anything was promised and not delivered, it belongs in `memory/open_commitments.md` as
well, or the drift watcher will never see it.
