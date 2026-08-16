---
name: daily-harvest
description: Use when the daily harvest routine fires, or when the user asks to capture what happened yesterday into the brain. Reads the session queue, writes one session note for the day, folds it into the pages it touches, and marks the day done. SKIP for reporting to the user about today — that is daily-briefing; this one writes to the brain and speaks only if something went wrong.
---

# Daily harvest

Every Claude Code session on the machine leaves a line in the brain's queue when it ends.
This turns that queue into knowledge, once a day, without being asked.

The distinction that decides everything below: **`daily-briefing` talks to the user about
today; this writes to the brain about yesterday and stays quiet.** A harvest that reports
in every morning is a harvest the user mutes.

## Get the plan

```bash
node scripts/harvest.mjs plan
```

Returns the day, how many sessions ended, and one entry per repo with its session count and
transcript paths. `already_harvested: true` means stop — the day is done, and folding it in
twice is how pages accrete the same paragraph until nobody trusts them.

`sessions: 0` with `already_harvested: false` means a genuinely quiet day. Write nothing,
mark nothing, say nothing.

## Decide what is worth keeping

Work the repos in the order the plan returns them — most sessions first, since that is where
the day actually went.

For each repo, you already know what happened if it is one you worked in; open its
transcript only when you do not. Transcripts are long, and reading all of them to find three
sentences is how a cheap routine becomes an expensive one.

**The bar: would the user want this in a weekly recap?** Concretely, keep

- decisions, and the reason behind them — the reason is the part that is gone in a month
- work that actually completed
- anything learned the hard way: a gotcha, a wrong assumption corrected, a fix that took real effort
- ideas raised and not yet acted on

and skip routine chatter, anything already obvious from the code, and anything the user
keeps in a private journal.

## Write the note

One file per day, at the `note_path` the plan gave you:

```markdown
# <day> — daily harvest

## <repo name>
- what happened, in the user's own framing where you have it
- (inference) anything you concluded rather than observed
```

Mark inferences. The user has to be able to see what they actually decided versus what you
worked out, or the note stops being evidence and becomes an opinion with a date on it.

## Fold it into the pages — this is the actual job

**A session note that never reaches a page is an input nobody digested.** The note is raw
material; the pages are the brain. A growing `session-notes/` folder next to static pages
means the brain is dying, and it dies quietly.

For each thing worth keeping:

```bash
node scripts/brain.mjs recall "<the subject>"
```

If a page already covers it, **update that page** — rewrite the part that is now wrong,
add what is new, keep it readable as one document rather than a changelog. If nothing
covers it, create one:

```bash
node scripts/brain.mjs store "<text>" --name <slug> --title "..." --desc "..."
```

Pages are living documents: no dates in filenames, no "update 2026-08-16" sections. The
history is in git, and a page that has become a diary is a page nobody reads to the end.

## Close the day

```bash
node scripts/harvest.mjs done --day <day>
git -C "<brain path>" add -A
git -C "<brain path>" commit -m "harvest: <day>"
git -C "<brain path>" push        # only if the brain has a remote
```

`done` removes only that day's rows from the queue. A session that ended while you were
working is still there tomorrow, which is the whole reason it does not simply truncate.

## When to speak

Stay silent on a normal run. Message the user only when:

- the queue has grown for several days, which means the routine has not been firing
- the brain has no remote and has never been pushed, so a machine failure would take it
- `check` reports pages the index has lost track of

Each of those is a real fault the user can fix in one action. Nothing else earns an
interruption.

## Verify

```bash
node scripts/brain.mjs check
```

Every page indexed, no orphans, no index line pointing at a missing page. Then confirm the
day's note exists and that at least one page changed. A harvest that wrote a note and
touched no page did the easy half.
