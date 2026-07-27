---
id: stale-work
source: issue-tracker
model: cheap
cooldown: 24h
---

## Fires when

An issue assigned to the user is in progress, was last updated more than 4 hours ago, and
has not been mentioned in the session log in the last 2 hours.

Four hours is deliberate. Shorter and it fires while someone is actually working on
something; longer and a whole day slips past unnoticed.

## Gather

Issues assigned to the user, state "In Progress", sorted by `updatedAt` descending, limit
10. Keep identifier, title, and `updatedAt`.

Then read `memory/session.log.md` and concatenate every entry from the last 2 hours into
one lowercase string.

## Rule

For each issue: if hours since `updatedAt` is under 4, skip it. Lowercase the identifier
and the title, and check whether either appears in the 2-hour string. Appearing means it
is being discussed right now, so skip it.

If several survive, take the one with the oldest `updatedAt`. One nudge.

## Nudge

```
{IDENTIFIER} har været i gang siden {HUMAN_TIME} og er ikke nævnt siden.

Er du stadig på den, eller skal den lukkes eller skubbes?

Sig luk, skub, eller kører.
```

`{HUMAN_TIME}` reads like a person wrote it: "torsdag morgen", "2 dage siden", "i går
eftermiddag". Not an ISO timestamp.
