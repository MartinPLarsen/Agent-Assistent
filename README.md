# Agent Starter Template

A copy-and-configure template that bootstraps a fully functional AI agent through an interactive wizard in Claude Code. The agent "wakes up" and guides you through its own setup — from personality to tools to daily routines.

## Quick Start

1. **Clone the kit:**
   ```bash
   git clone https://github.com/MartinPLarsen/agent-starter-kit.git my-new-agent
   ```
   Replace `my-new-agent` with whatever you want your agent's folder to be called.

2. **Open in Claude Code:**
   ```bash
   cd my-new-agent && claude
   ```

3. **Follow the wizard.** On first run the kit detaches from the template's git history (`rm -rf .git && git init`) so your agent has its own clean repo. Then it asks you questions and sets itself up.

## What the Wizard Does

| Phase | What happens |
|-------|-------------|
| 1. Who Are You? | Learns about you (name, role, timezone, preferences) |
| 2. Who Am I? | Picks a name, archetype, and personality |
| 3. Capabilities | Maps tools, MCP connections, workflows, and skills |
| 4. Daily Rhythm | Sets up scheduled routines (morning briefing, nudges, etc.) |
| 5. Knowledge Vault | Sets up an Obsidian-based knowledge base (raw → wiki → output) |
| 6. Activation | Generates final config and goes live |

## Archetypes

- **Orchestrator** — Coordinator + personal assistant that routes work between other agents and manages daily rhythms
- **Specialist** — Domain expert with a production pipeline (e.g., video production, website building, data processing)
- **Research** — Lightweight search and analysis agent that reports findings
- **Custom** — Blank slate, you define everything

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- The `telegram` plugin from the `claude-plugins-official` marketplace (enables the Telegram reply tool and `/telegram:configure` / `/telegram:access` setup skills). Optional but strongly recommended — most agent experiences rely on Telegram.
- A Telegram bot token from @BotFather (free — the wizard walks you through creating one)
- [Obsidian](https://obsidian.md) (free) — for the knowledge vault that your agent maintains. The wizard sets up the vault folder structure (`raw/`, `wiki/`, `output/`) for you.

## Session Resilience

The wizard tracks progress in `.setup-state.json`. If your session crashes mid-setup, just reopen Claude Code — it resumes where you left off.

## After Setup

The wizard rewrites `CLAUDE.md` into proper agent instructions. Your agent works just like any other Claude Code agent — with session memory, crons, Telegram, and an external Obsidian knowledge vault you can compile / query / audit with plain commands.

## Two memory layers

- **Session memory** (`memory/*.md` in this folder) — short-term session state, recent work, open commitments.
- **Knowledge vault** (external Obsidian folder) — distilled, cross-session knowledge. "Compile" new raw material, "audit" for gaps, query by natural language.

The separation keeps recent work and long-term insights in different places — the first decays (gets trimmed), the second accumulates.
