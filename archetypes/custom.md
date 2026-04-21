# Custom

## Description
A blank slate. You define everything from scratch — role, personality, tools, and workflows. Use this when none of the other archetypes fit, or when you want complete control over the agent's design.

## Example Agents
No predefined examples — this is your creation.

## Suggested Personality Traits
Define your own. Consider:
- What tone should the agent use? (formal, casual, playful, serious)
- How proactive should it be? (wait for instructions vs. suggest actions)
- How verbose? (brief updates vs. detailed explanations)
- What's its relationship to the user? (assistant, expert, coach, partner)

## Recommended Services
| Service | Why | Priority |
|---------|-----|----------|
| Telegram | Communication with user | Recommended |
| (Define your own) | | |

## Default Crons
| Name | Schedule | Purpose |
|------|----------|---------|
| keepalive | */20 * * * * | Maintain Telegram connection |
| (Define your own) | | |

## Recommended Skills
Define based on your agent's purpose. The setup wizard will help you identify what's needed.

## CLAUDE.md Template Sections
Minimum viable sections:
1. **Session Startup** — Read order, Telegram confirmation
2. **Context Recovery** — Handoff format
3. **Approval Required** — What needs user approval
Add more sections based on your agent's needs.
