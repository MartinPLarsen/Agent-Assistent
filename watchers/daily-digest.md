---
id: daily-digest
source: whatever is connected
model: quality
cooldown: 20h
---

## Fires when

Once a day, at the time set in `agent.json`. Unlike every other watcher, this one always
speaks, even when nothing is wrong.

That is the point. The others only appear when something has gone bad, which trains
someone to read a message from their assistant as bad news. This one is the routine report
they scan on the way to the coffee machine.

## What makes it useful

**The links, not the summary.** Every line points at the thing it describes: the issue,
the mail thread, the commit, the calendar entry. The user is not reading for
comprehension, they are scanning for the one line that looks wrong, and then clicking
straight through to it. A digest without links is a digest nobody acts on.

Humans are very good at spotting that something is off and very bad at reading a wall of
status. Build for the first.

## Gather

Only from what is actually connected. Skip a section entirely rather than printing an
empty heading.

- **Work:** issues that changed state yesterday, and what is in progress now
- **Code:** commits and merged pull requests across the repos in `CONTEXT.md`
- **Mail:** what arrived that appears to need an answer, count plus the two most notable
- **Today:** calendar for the next 12 hours
- **Owed:** the count under `## Active` in `memory/open_commitments.md`
- **Watcher health:** from `watchers/.state.json`

## Format

```
Godmorgen. I går:

{n} issues flyttede sig. {IDENTIFIER} gik til Done. {link}
{n} PRs merged i {repo}. {link}
{n} mails venter svar, ældste fra {sender}. {link}

I dag: {first event} kl. {time}, og {n} mere. {link}

Åbent: {n} commitments, ældste er "{oldest}".

{watcher health line, only when something is wrong}
```

Under 12 lines. Numbers rather than adjectives — "3 issues" not "some movement". If a
section has nothing, leave it out rather than writing "ingenting i dag".

## Watcher health

One line, and only when there is something to say:

```
NB: unpaid-bills har fejlet ved hver kørsel siden i går. Fejl: {error}.
```

A watcher that has errored on every fire for 24 hours goes here. So does one that is
enabled but has no source connected, though only once a week — repeating it daily is
nagging about a thing the user already decided.

Without this line a broken watcher looks exactly like a quiet one, and stays broken for
however long it takes someone to notice by accident.

## What not to do

Do not editorialise about how the day looks. Do not congratulate. Do not end with a
motivational line. Report what happened, link to it, stop.
