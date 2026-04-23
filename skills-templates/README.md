# Skills Templates

Skills shipped with Agent Starter Kit. The wizard (Phase 3.5) copies selected templates into the new agent's `.claude/skills/` folder and substitutes placeholder tokens with values collected during Phase 1–4.

## Placeholder tokens

| Token | Source | Example |
|-------|--------|---------|
| `{{AGENT_NAME}}` | Phase 2 | `James` |
| `{{USER_NAME}}` | Phase 1 | `Martin` |
| `{{TIMEZONE}}` | Phase 1 | `Europe/Copenhagen` |
| `{{CHAT_ID}}` | Phase 3.2b | `8380764254` |
| `{{MEMORY_PATH}}` | Derived | `memory` (relative to agent root) |

## Templates

| Template | Archetypes | Purpose |
|----------|------------|---------|
| `accountability-heartbeat/` | Orchestrator | Drift detection + gentle nudge on stale Linear issues and orphan commitments. Fires every 2 hours on weekdays. Requires `session.log.md` to be written on every inbound Telegram message (embedded by wizard in Phase 6 CLAUDE.md rewrite). |

## Add a new template

1. Create `skills-templates/<skill-name>/SKILL.md` with placeholders from the table above.
2. Add a row to the template table.
3. Update `archetypes/<relevant>.md` to list it under Recommended Skills.
4. Update `CLAUDE.md` Phase 3.5 recommended-list for the matching archetype.
