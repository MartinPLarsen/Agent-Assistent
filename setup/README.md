# Setup wizard

You are reading this because `.setup-state.json` says setup is not finished. Run the
phases below in order. Each one is a separate file — read it when you reach it, not before.

## How to run it

1. Read `.setup-state.json`. If it is missing, create it:
   ```json
   { "completed": false, "current_phase": 0, "steps_completed": [] }
   ```
2. Start at `current_phase`. Read that phase's file and follow it.
3. At the end of each phase, **merge** into `.setup-state.json`: read the current file,
   change only the keys the phase names, write the whole object back. Overwriting with
   just the new keys wipes earlier answers and breaks resume.
4. After the last phase, set `completed: true`.

| Phase | File | What it does |
|-------|------|--------------|
| 0 | `00-harvest.md` | Reads the machine. No questions. Produces `CONTEXT.md`. |
| 1 | `01-you.md` | Who the user is. Produces `USER.md`. |
| 2 | `02-me.md` | Name and voice. Produces `SOUL.md`. |
| 3 | `03-channel.md` | How the user reaches you. Telegram or terminal. |
| 4 | `04-tools.md` | Which systems you can touch. Produces `TOOLS.md`, `.mcp.json`. |
| 5 | `05-rhythm.md` | Scheduled routines. Produces `agent.json`. |
| 6 | `06-memory.md` | Seeds the memory files from what phases 0–1 learned. |
| 7 | `07-activate.md` | Verifies, links skills, says hello. |

## Rules for the whole wizard

**One question at a time.** Wait for the answer before asking the next. A message with
four questions in it gets one answer and three gaps.

**Recommend, don't survey.** When you ask something with an obvious default, say which one
you would pick and why, in one line. The user can disagree in one word.

**Resume by looking, not by trusting.** Before running a phase, check whether its output
already has real content instead of placeholders. If `USER.md` is filled in, phase 1 is
done no matter what the state file says.

**Never install anything.** Detect what is missing and tell the user how to get it. Logins
open browsers and installs need passwords; neither works from a tool call.

**Skippable is fine.** Phases 3, 4 and 5 can all be answered with "skip". Note it in
`agent.json` and move on. The assistant works without a channel, without connectors, and
without routines — it is just quieter.

## If setup breaks halfway

Nothing here overwrites `AGENTS.md`, so a crash mid-wizard is not destructive. Reopen the
session; the state file plus the resume check above will pick it back up.
