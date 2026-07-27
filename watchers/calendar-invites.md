---
id: calendar-invites
source: calendar
model: cheap
cooldown: 24h
---

## Fires when

An invitation is still unanswered and the event starts within 48 hours.

Two days out is when an unanswered invite starts costing someone else something: they are
booking a room, ordering food, or deciding whether to go ahead.

## Gather

Calendar events in the next 7 days where the user's own response status is
`needsAction` — not accepted, not declined, not tentative. Keep title, start time,
organiser, and whether other people have already responded.

## Rule

Skip anything more than 48 hours out; it is not urgent yet and will be caught on a later
fire.

Skip events the user organised themselves. You do not RSVP to your own meeting, and some
calendars mark the organiser as `needsAction` anyway.

If several qualify, take the one starting soonest.

## Nudge

```
{ORGANISER} har inviteret dig til "{TITLE}" {WHEN}, og du har ikke svaret.

Skal jeg svare ja, nej, eller vil du selv?

Sig ja, nej, eller selv.
```

`{WHEN}` in plain language: "i morgen kl. 14", "på torsdag formiddag".

## If the user answers

Accepting or declining on their behalf writes to their calendar and notifies the
organiser, so it is an external action. The one-word reply to this specific nudge is the
approval — you asked, they answered. Do not go further than what they said: "ja" means
accept, not accept and add a note.
