# Phase 6 — Seed the memory

No questions in this phase. You have spent five phases learning things; this is where they
stop being conversation and become memory.

Read `skills/memory/SKILL.md` first — it is the contract you are about to write against.

## Create the files

```
memory/MEMORY.md              index, one line per fact
memory/facts/                 one file per fact
memory/convo_log.md           session state
memory/open_commitments.md    what is owed
memory/session.log.md         inbound-message log, machine-written
```

Templates for each are in `setup/templates/`. Create all five, even the ones that start
empty — a watcher that reads a missing file errors on its first fire, and v1 shipped
exactly that bug.

## Write the first facts

From what phases 0 and 1 already told you. Do not invent; only write what you actually
learned.

| From | Type | Example |
|------|------|---------|
| Phase 1, role and work | `user` | what they do, where, in what capacity |
| Phase 1, "what drains you" | `feedback` | the work to take over unasked, in their words |
| Phase 0, each active project | `project` | what it is, its stack, whether it is current |
| Phase 0, two git identities | `reference` | which email belongs to which context |
| Phase 4, where keys live | `reference` | where secrets are read from on this machine |

Each is one file in `memory/facts/`, with frontmatter:

```markdown
---
name: two-git-identities
description: work commits use a@b, personal use x@y — check before committing
metadata:
  type: reference
---

Repos under ~/work override user.email to a@b. Everything else inherits x@y.
Getting this wrong attributes work commits to a personal account.

Related: [[active-projects]]
```

Then one line per fact in `memory/MEMORY.md`, under 200 characters, linking to the file.

Five to ten facts is right. The point is not coverage, it is that the first session after
setup opens with real memory instead of an empty index, which is the difference between a
system that gets used and one that stays a folder.

## Seed the commitments

If anything came up during setup that the user still needs to do — connect a mail account,
put a key in the keychain, install something — write it into `memory/open_commitments.md`
now. Those are real open loops and the drift watcher should see them.

## Output

Five files created, five to ten facts written, the index populated. Merge:

```json
{ "current_phase": 7, "steps_completed": [..., "phase_6"] }
```
