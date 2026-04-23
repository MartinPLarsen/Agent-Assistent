# Orchestrator

## Description
A central coordinator that routes tasks to the right agent or handles them inline. Manages daily rhythms, memory systems, and multi-agent workflows. Think: personal assistant + router + accountability partner.

## Example Use Cases
- **Personal daily-ops assistant** — Routes tasks to specialist agents (video production, web work, research), manages morning briefings, midday check-ins, evening reflections, and memory consolidation.
- **Team coordinator** — Central entry point for a small AI team; decides inline vs. delegate based on task complexity and handles cross-agent handoffs.

## Suggested Personality Traits
- **Structured** — Keeps things organized, tracks commitments, follows up
- **Proactive** — Initiates check-ins, suggests priorities, anticipates needs
- **Warm** — Supportive tone, celebrates wins, doesn't guilt-trip
- **Context-aware** — Remembers past conversations, builds on previous decisions
- **Decisive** — When asked "what should I do?", gives ONE clear recommendation

## Recommended Services
| Service | Why | Priority |
|---------|-----|----------|
| Telegram | Direct communication with user | Must-have |
| Gmail | Morning briefing email scan, evening reflection | Nice-to-have |
| Google Calendar | Daily schedule awareness, event reminders | Nice-to-have |
| Linear | Task/issue tracking for daily rocks | Nice-to-have |
| Notion | Knowledge base access | Optional |
| n8n | Workflow monitoring and triggering | Optional |

## Default Crons

### Cloud Crons (Trigger.dev) — run regardless of terminal
| Name | Schedule | Purpose |
|------|----------|---------|
| morning-briefing | 12 9 * * * | Calendar + email + tasks + one recommendation |
| midday-nudge | 33 12 * * * | Gentle check-in on top priority |
| evening-reflection | 57 17 * * * | Day review + carry-forward to tomorrow |

### Local Crons (session-only) — require active terminal
| Name | Schedule | Purpose |
|------|----------|---------|
| keepalive | */20 * * * * | Maintain Telegram connection |
| heartbeat-every-2h | 7 8-20/2 * * 1-5 | Accountability drift check (Linear + commitments + session log), sends nudge only if drift detected |
| calendar-reminder | */10 * * * * | 15-min heads-up for upcoming events |
| dream-sync | 3 12,15,20 * * * | Memory consolidation + sync |

### Why the split?
Cloud crons (briefings, nudge, reflection) are the agent's most important daily routines — they MUST fire even if the user's computer is off. Local crons (keepalive, dream-sync) need filesystem access or only matter in active sessions.

## Recommended Skills
- **accountability-heartbeat** — Drift-aware nudges when in-progress Linear issues or open commitments go silent (ships as a template with the kit — wizard installs it)
- **daily-rocks** — Daily priority management (top 3 rocks)
- **nudge** — Gentle midday check-in
- **humanizer** — Make AI text sound human
- **contrarian-view** — Challenge assumptions and ideas
- **limiting-factor** — Identify what's blocking progress
- **decide** — Priority recommendation when overwhelmed
- **youtube-summarize** — Quick video summaries

## CLAUDE.md Template Sections
Key sections an orchestrator CLAUDE.md needs:
1. **Session Startup** — Read order, cron recreation, catch-up protocol, Telegram confirmation
2. **Cron Management** — Startup verification, proxy commands (/crons, /status, /agents)
3. **Orchestrator Protocol** — Decision tree for inline vs. delegate, task-brief format
4. **Context Recovery** — Handoff format (Active Context, Completed, Pending, Key Decisions)
5. **Memory System** — Index file, topic files, convo log, accountability, open commitments
6. **Approval Required** — What needs user approval vs. safe operations
7. **Agent Team** — List of all agents with Telegram bots and roles
