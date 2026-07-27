---
id: unanswered
source: mail
model: quality
cooldown: 48h
---

## Fires when

Someone asked the user a direct question more than 24 hours ago and no reply went out.

`model: quality` because "is this actually waiting on a human answer" is the hard part.
Newsletters ask questions. Automated systems ask questions. Marketing asks questions and
means nothing by it.

## Gather

Threads from the last 14 days where the newest message is **not** from the user. For each,
keep sender, subject, when it arrived, and the last few lines of the body.

## Rule

A thread qualifies when all of these hold:

- The newest message is from a real person. Not a no-reply address, not a mailing list
  (`List-Unsubscribe` header), not an automated notification.
- It asks something or requests something. A question mark helps but is not required —
  "let me know what you think" is a question wearing a coat.
- It is over 24 hours old.
- Nothing went out from the user in that thread since.

Skip anything the user has already flagged, snoozed, or archived. Those are decisions, and
overriding a decision is worse than staying quiet.

If several qualify, take the oldest. It is the one closest to becoming embarrassing.

## Nudge

```
{SENDER} spurgte dig om {SUBJECT_SHORT} for {AGE} siden, og der er ikke svaret.

Skal jeg lave et udkast, minde dig i morgen, eller dropper vi den?

Sig udkast, i morgen, eller drop.
```

`{SUBJECT_SHORT}` is what they actually want, in a handful of words, not the subject line
verbatim. "om han må bruge dit foto" beats "Re: Fwd: FW: quick question".

## If the user says "udkast"

Draft it and show it. Do not send. Sending mail on someone's behalf needs their explicit
go on the actual text, not on the idea of a draft.
