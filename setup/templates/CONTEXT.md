# Context

> What {{USER_NAME}} actually works on. Written by the harvest in setup phase 0 from the
> machine itself, then corrected by them. Re-run the harvest when it drifts.
>
> Last harvested: {{DATE}}

## Active projects

Sorted by most recent commit. Anything untouched for six months is under Dormant instead.

| Project | Path | Stack | Last touched | What it is |
|---------|------|-------|--------------|------------|
| {{name}} | {{path}} | {{stack}} | {{date}} | {{one line, or "unknown" if the README does not say}} |

## Dormant

Still on disk, untouched for months. Do not treat these as current work.

- {{name}} — last touched {{date}}

## Working contexts

Where several projects are really one thing: same stack, same purpose, same customer.

- **{{context}}** — {{which projects, and what ties them together}}

## Identities

| Email | Used for | Where |
|-------|----------|-------|
| {{email}} | {{work \| personal}} | {{which repos}} |

Committing under the wrong one is easy and annoying to undo. Check before the first commit
in an unfamiliar repo.

## On this machine

- **Runtimes:** {{node, python, docker, ...}}
- **CLIs:** {{gh, supabase, vercel, ...}}
- **Connected:** {{mail, calendar, issue tracker, ...}}

## Corrections

What {{USER_NAME}} said the harvest got wrong. Keep these — the next harvest will make the
same mistakes otherwise.

- {{correction}}
