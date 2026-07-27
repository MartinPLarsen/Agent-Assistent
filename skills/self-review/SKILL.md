---
name: self-review
description: Use when the weekly self-review routine fires, or when the user asks whether the assistant is working well, why it keeps nudging about something, or asks it to tune itself. Grades the week against a rubric and proposes changes to its own rules. Also runs the memory prune.
---

# Self review

Once a week, grade your own week and propose changes to yourself. An assistant whose rules
never change is one whose mistakes never stop.

**Propose, never self-edit.** You are allowed to change your own configuration only with
the user saying yes. Anything else is a system that drifts somewhere nobody chose.

## Gather

- `watchers/.state.json` — what fired, about what, and how it went
- `memory/session.log.md` for the last 7 days — what the user actually replied
- `memory/MEMORY.md` and `memory/facts/` — sizes, dates, orphans
- `memory/open_commitments.md` — what moved and what did not
- `memory/convo_log.md` — what was in flight and whether it landed

## The rubric

Five questions. Answer each with evidence, not impression.

**1. Did the nudges land?**
For each nudge sent this week, find the user's reply in the session log. Acted on, put
off, or ignored? A watcher whose nudges are ignored three times running is wrong: either
its rule is too loose or its subject does not matter. Say which.

**2. Did anything fire that should not have?**
A nudge about something already handled, already parked, or already discussed an hour
earlier. Each one is a rule bug, and each one costs more trust than the nudge was worth.

**3. Did anything not fire that should have?**
Look for things in the convo log or commitments that went quiet for days without a nudge.
Usually a disconnected source or a threshold set too high.

**4. Is memory being used?**
Facts written this week, facts actually read, facts written months ago and never read
since. A fact nobody reads is either badly described in the index or was not worth
keeping. Check the file sizes against their caps too.

**5. Did the briefing's recommendation get taken?**
If the same thing was recommended four mornings running and never done, recommending it a
fifth time is not going to work. Say so and suggest a different angle: break it down, park
it, or drop it.

## Prune the memory

Run the prune from the `memory` skill as part of this:

- every file against its cap
- facts unread for three months, listed for the user to keep or drop
- duplicate or contradictory facts, merged
- orphans in both directions: index lines pointing at nothing, facts with no index line

Deletions get proposed in one message, never done silently.

## Propose

Under 15 lines. Concrete changes, each with the evidence behind it.

```
Ugens selvgennemgang.

Virkede: {what demonstrably worked, one line}

Foreslår:
- {watcher}: {specific change} — {evidence}
- {rule}: {specific change} — {evidence}

Memory: {n} facts, index {size}. {n} ulæste siden {date}.

Sig ja til alle, eller nævn dem du vil have.
```

Two or three proposals. Ten means you are listing observations rather than deciding what
matters, and the user will approve none of them.

If the week was genuinely fine, say that in one line and skip the proposals. A review that
invents changes to justify itself is worse than no review.

## After approval

Make exactly the approved changes: edit the watcher file, adjust `agent.json`, prune the
memory. Then write a `feedback` fact recording what changed and why, so the next review
has the history and does not propose reverting it.
