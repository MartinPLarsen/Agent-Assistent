---
id: commitment-drift
source: none
model: cheap
cooldown: 48h
---

## Fires when

An item under `## Active` in `memory/open_commitments.md` has not been mentioned anywhere
in the last 24 hours.

Needs no connector, so this one works from day one. It is also the watcher most likely to
be right, because the user put those items there themselves.

## Gather

From `memory/open_commitments.md`, every bullet under `## Active` that starts with `- **`.
Ignore the `## Parked` section entirely — parked means deliberately not now, and nudging
about it is exactly the noise that gets an assistant muted.

From `memory/session.log.md`, every entry in the last 24 hours.

## Rule

Normalise both sides the same way before comparing, or nothing will ever match: strip
leading `- **` and trailing `**`, collapse whitespace, lowercase.

Take the first 40 characters of the normalised commitment as a search key and look for it
in the normalised 24-hour log. Not found means it has drifted.

If several have drifted, take the first one listed — the user ordered that list, so trust
the order.

## Nudge

```
"{COMMITMENT}" har ligget i open_commitments uden at blive rørt det sidste døgn.

Skal den ud, udskydes, eller er det den vi tager nu?
```

`{COMMITMENT}` is the bullet's own summary text, around 40 characters, in the user's own
words. Do not paraphrase it into something tidier; they will not recognise it.
