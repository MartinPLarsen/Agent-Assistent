# Personal assistant starter kit

A template that turns into your personal assistant. Open it in Claude Code or Codex CLI,
answer some questions, and you end up with an assistant that knows what you work on,
remembers what you told it, and speaks up when something is drifting.

One assistant. Not a framework for building teams of them.

> Private while it is being tested. Public later.

## Quick start

```bash
git clone <this repo> my-assistant
cd my-assistant
./setup.sh
```

That one command is the whole install. It checks what your machine has, offers to install
Claude Code if it is missing, links the skills, and then starts the assistant for you.

The assistant reads `AGENTS.md`, sees it is not configured, and runs the wizard. Nine
short phases, 25 to 35 minutes. You can stop after any of them and resume later — type
`/exit` and run `./setup.sh` again when you want to continue.

`./setup.sh --check` runs only the tool check. `./setup.sh --no-launch` does everything
except starting the assistant.

## What the wizard does

| Phase | What happens |
|-------|--------------|
| 0 | Reads your machine — repos, stacks, git identities, installed tools. No questions. |
| 1 | Who you are and how you want to be worked with. |
| 2 | Names the assistant and sets its voice. |
| 3 | Telegram, or terminal only. |
| 4 | Which systems it may touch. |
| 5 | Scheduled routines: daily briefing, watchers, weekly self-review. |
| 6 | Seeds memory from everything the earlier phases learned. |
| 7 | Creates the second brain, in its own repo, and wires machine-wide capture. |
| 8 | Verifies, links the skills, says hello. |

Phase 0 is the one that matters. Twenty minutes of interview cannot tell an assistant what
two minutes of looking at your actual repos can.

## What it does once it is running

**Remembers.** One file per fact under `memory/facts/`, an index that is always loaded, and
rules for when to write. Corrections, non-obvious technical findings, and constraints that
are not visible in the code all get written down without being asked.

**Watches.** Work that has gone quiet, bills coming due, invitations still unanswered,
questions nobody replied to. At most one nudge per check, always answerable with one word
from a phone.

**Reports.** A daily digest of what actually happened, where every line links to the thing
itself, so you find problems by scanning rather than by being told.

**Reviews itself.** Once a week it grades its own week and proposes changes to its own
rules. You approve or you do not.

**Starts projects.** Ask it for a new project and it scaffolds the repo, the instructions
files, the MCP config, and an ADR folder, then adds the project to what it knows about you.

## Runtimes

`AGENTS.md` is the single source of instructions. Claude Code reads it via a three-line
`CLAUDE.md`; Codex CLI and anything else that follows the `AGENTS.md` convention read it
directly. Skills are plain markdown in `skills/`, symlinked into `.claude/skills/` for
Claude's Skill tool.

Telegram currently needs Claude Code. On Codex the assistant is terminal-only.

## Requirements

- Claude Code or Codex CLI
- git
- Optional: the Telegram plugin, if you want it to reach your phone
- Optional: Node 18+ and a free Trigger.dev account, for routines that fire while your
  machine is off

`./setup.sh` checks all of these before it does anything else. The only thing it offers to
install for you is Claude Code, and it asks first. Everything else it names, with the exact
command, and stops so you can decide.

## Memory layers

- `memory/facts/` — what it knows about *you*. Permanent, one fact per file.
- `memory/convo_log.md` — where the last session left off. Overwritten each session.
- `memory/session.log.md` — a rolling 48-hour log of inbound messages, so the watchers can
  tell "already being discussed" from "gone quiet".

Caps on all three are enforced by `scripts/memory-caps.sh`, not by the assistant
remembering to prune. A rule with no owner in code is a wish.

## The second brain

A separate repo, created by phase 7, holding what you and the assistant have worked out
together: living pages, an index, and a dated log. Memory is what it knows about you; the
brain is the knowledge itself, and it outlives any single clone of this kit.

```
knowledge-base/
  raw/pages/          living pages, rewritten as you learn more
  raw/session-notes/  daily capture, the input to those pages
  wiki/index.md       one line per page — the whole retrieval index
  wiki/log.md         dated, append-only history
  outputs/            finished briefings and reports
```

`scripts/brain.mjs` is the retrieval engine: `recall`, `store`, `ask`, `check`. Node, no
dependencies. Without Node the assistant reads `wiki/index.md` itself — slower, same
answers.

A capture hook in `~/.claude/settings.json` records every Claude Code session on the
machine, so work done in other repos reaches the brain too. It is the only thing this kit
installs outside its own folder, it is opt-in, and
`scripts/install-capture-hook.sh --uninstall` removes it.
