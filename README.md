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
claude          # or: codex
```

The assistant reads `AGENTS.md`, sees it is not configured, and runs the wizard. Eight
short phases, 20 to 30 minutes. You can stop after any of them and resume later.

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
| 7 | Verifies, links the skills, says hello. |

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

Nothing is installed for you. The wizard detects what is missing and tells you how to get
it.

## Memory layers

- `memory/facts/` — what it knows. Permanent, one fact per file.
- `memory/convo_log.md` — where the last session left off. Overwritten each session.
- `memory/session.log.md` — a rolling 48-hour log of inbound messages, so the watchers can
  tell "already being discussed" from "gone quiet".

## License

MIT.
