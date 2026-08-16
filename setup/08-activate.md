# Phase 8 — Activate

Nothing gets rewritten here. `AGENTS.md` was already correct before the wizard started;
all this phase does is verify that the generated pieces exist and then hand over.

## Verify

Check each. Any failure is fixable by re-running that phase, not by starting over.

| File | Passes when |
|------|-------------|
| `CONTEXT.md` | lists at least one real project, no `{{PLACEHOLDER}}` left |
| `USER.md` | has a name, a timezone, and the "what drains you" answer |
| `SOUL.md` | has the agent name and the anti-slop rules |
| `agent.json` | valid JSON, has `timezone` and `channel` |
| `memory/MEMORY.md` | at least five index lines |
| `memory/facts/` | one file per index line, each with frontmatter |
| `memory/convo_log.md`, `open_commitments.md`, `session.log.md` | exist, even if empty |
| `agent.json` → `brain.path` | resolves to a real directory with `knowledge-base/wiki/index.md` in it |

```bash
grep -rl '{{[A-Z_]*}}' *.md 2>/dev/null && echo "unsubstituted placeholders above"
python3 -c "import json; json.load(open('agent.json'))" && echo "agent.json ok"
```

## Link the skills

```bash
./setup.sh --link-skills
```

This symlinks each `skills/<name>/` into `.claude/skills/` so Claude Code's Skill tool
finds them. Other runtimes read from `skills/` directly and need no linking. Confirm the
links resolve:

```bash
ls -l .claude/skills/
```

## Close the wizard

Set `.setup-state.json` to:

```json
{ "completed": true, "current_phase": 8,
  "steps_completed": ["phase_0","phase_1","phase_2","phase_3","phase_4","phase_5","phase_6","phase_7","phase_8"] }
```

From the next session, `AGENTS.md` sends you straight past the wizard.

## Say hello

Short, and as the assistant rather than as the wizard. Something like:

> "[Navn] er klar. Jeg ved hvad du arbejder med, jeg holder øje med [de watchers der
> faktisk er tændt], og du får en briefing [tidspunkt].
>
> Det første jeg vil foreslå: [den ene ting fra open_commitments der blokerer mest]."

Send it on the configured channel. If Telegram is set up, this is also the real smoke test
— an assistant that answers in the terminal is invisible.

Then write the first `memory/convo_log.md` entry: setup finished, what was configured,
what is still open. The next session starts by reading it.
