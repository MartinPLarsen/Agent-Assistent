---
name: new-project
description: Use when the user is starting something new — a new project, app, site, repo, or experiment — or says they have an idea they want to get moving. Scaffolds the repo with instructions files, MCP config, ADR folder and a linked skill library, then records the project in CONTEXT.md.
---

# New project

The point is not the folder structure. It is that ten minutes of setup decides whether an
agent can work in this repo for the next year, and nobody does it properly when they are
excited about the idea.

## Ask three things

One at a time. You should be able to guess two of them from `CONTEXT.md` — offer your
guess rather than asking cold.

1. **What is it, in one sentence?** This becomes the README's first line and the project's
   entry in `CONTEXT.md`. If they cannot say it in one sentence, that is worth noticing
   out loud before any code exists.
2. **What kind?** Web app, script, API, library, content pipeline. Determines the
   `.gitignore` and the layout.
3. **Where?** Default to a sibling of their other projects, from `CONTEXT.md`. Do not
   invent a new location.

Do not ask which language or which framework unless it is genuinely open. `CONTEXT.md`
says what they use. Offer that and let them correct you.

## Scaffold

```
<project>/
  README.md              what it is, how to run it, how to deploy it
  AGENTS.md              instructions for any agent working here
  CLAUDE.md              three lines pointing at AGENTS.md
  .gitignore             for the actual stack
  .mcp.json              only servers this project needs
  docs/decisions/        ADRs, with 0001 already written
  .claude/skills/        symlinks to the shared library
```

### AGENTS.md for the new project

Not a copy of the assistant's own. A project's `AGENTS.md` answers what an agent landing
in this repo cold needs to know:

- what the project is, in two lines
- how to run it, how to test it, how to deploy it — actual commands
- the shape of the codebase: where things live and why
- what not to touch, and what needs asking first
- which conventions are real here as opposed to habit

Write it from what you know now and mark the gaps `TBD` rather than guessing. A confident
wrong instruction is worse than a blank.

### The first ADR

`docs/decisions/0001-<slug>.md`, recording the stack choice made in the last five minutes:

```markdown
# 1. <the decision>

Date: <date>
Status: accepted

## Context
What made this a decision rather than a default.

## Decision
What was chosen.

## Consequences
What this makes easy, what it makes hard, and what would have to change to undo it.
```

One ADR at the start is what makes the second one get written. A `docs/decisions/` folder
that is empty at month three stays empty.

### Skills

Symlink the shared library so the new project's agent has the same capabilities:

```bash
mkdir -p <project>/.claude/skills
for s in <kit>/skills/*/; do
  ln -sfn "$s" "<project>/.claude/skills/$(basename "$s")"
done
```

Skills stay in one place and every project sees the same set. Copying them means five
divergent versions within a month.

## Git

```bash
git init
git add -A
git commit -m "chore: initial scaffold"
```

Creating a GitHub repo, adding a remote, and pushing are external actions. Ask first, and
ask which identity — `CONTEXT.md` knows they have more than one, and getting it wrong
attributes work to a personal account or the reverse.

## Record it

Add the project to `CONTEXT.md` under active projects: name, path, stack, what it is. Then
write a `project` fact in `memory/facts/` covering why it exists and any constraint agreed
during this conversation. Six months from now, that is the part nobody remembers and the
code does not say.

## Hand back

End with what to do next, concretely. Not "you can now start building" — the first actual
file, the first actual command.
