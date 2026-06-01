# Agent Starter Template

A copy-and-configure template that bootstraps a fully functional AI agent through an interactive wizard in Claude Code. The agent "wakes up" and guides you through its own setup — from personality to tools to daily routines.

## Quick Start

1. **Get your own copy.** Easiest: click **"Use this template" → Create a new repository** on GitHub — you get a fresh repo with clean history, no detach step needed. Then clone *your* new repo:
   ```bash
   git clone https://github.com/<you>/<your-new-repo>.git my-new-agent
   ```
   Replace `my-new-agent` with whatever you want your agent's folder to be called.

   *Alternative:* `git clone https://github.com/MartinPLarsen/agent-starter-kit.git my-new-agent` — but then the wizard asks you to detach from the template's git history on first run.

2. **Open in Claude Code:**
   ```bash
   cd my-new-agent && claude
   ```

3. **Wake the agent.** At the Claude Code prompt, type `hej` (or `hi`) — that kicks off the wizard. It then asks you questions and sets itself up. (If you cloned the template directly instead of using "Use this template", it first asks you to run `rm -rf .git && git init` in a terminal so your agent gets a clean repo — the agent's own safety rules stop it from doing that for you.)

## What the Wizard Does

| Phase | What happens |
|-------|-------------|
| 1. Who Are You? | Learns about you (name, role, timezone, preferences) |
| 2. Who Am I? | Picks a name, archetype, and personality |
| 3. Capabilities | Maps tools, MCP connections, workflows, and skills |
| 4. Daily Rhythm | Sets up scheduled routines (morning briefing, nudges, etc.) |
| 5. Knowledge Vault | Sets up an Obsidian-based knowledge base (raw → wiki → output) |
| 6. Activation | Generates final config and goes live |

Before Phase 1, a quick **Preflight** checks your machine (git, Node.js, Obsidian, the Telegram plugin) and hands you one consolidated list of anything to install — so all the terminal/download work happens up front instead of interrupting you mid-setup. It never installs anything for you; it just tells you what's missing and how to get it.

## Archetypes

- **Orchestrator** — Coordinator + personal assistant that routes work between other agents and manages daily rhythms
- **Specialist** — Domain expert with a production pipeline (e.g., video production, website building, data processing)
- **Research** — Lightweight search and analysis agent that reports findings
- **Custom** — Blank slate, you define everything

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- The `telegram` plugin from the `claude-plugins-official` marketplace (enables the Telegram reply tool and `/telegram:configure` / `/telegram:access` setup skills). Optional but strongly recommended — most agent experiences rely on Telegram.
- A Telegram bot token from @BotFather (free — the wizard walks you through creating one)
- Your Telegram numeric chat ID — message `@userinfobot` once to get it. Required so the bot only listens to you, not to random Telegram users.
- The ability to launch Claude Code with the `--channels plugin:telegram@claude-plugins-official` flag (the wizard generates a launcher script for you during Telegram setup). Without this flag the Telegram plugin never boots.
- [Node.js](https://nodejs.org) 18+ — only if you want cloud crons via Trigger.dev. The wizard's `npx trigger.dev` steps need it; skip it for a terminal-only or session-cron-only agent.
- [Obsidian](https://obsidian.md) (free) — for the knowledge vault that your agent maintains. The wizard sets up the vault folder structure (`raw/`, `wiki/`, `output/`) for you. Optional — Phase 5 now lets you skip the vault and add it later.

## Session Resilience

The wizard tracks progress in `.setup-state.json`. If your session crashes mid-setup, just reopen Claude Code — it resumes where you left off.

## After Setup

The wizard rewrites `CLAUDE.md` into proper agent instructions. Your agent works just like any other Claude Code agent — with session memory, crons, Telegram, and an external Obsidian knowledge vault you can compile / query / audit with plain commands.

## Two memory layers

- **Session memory** (`memory/*.md` in this folder) — short-term session state, recent work, open commitments.
- **Knowledge vault** (external Obsidian folder) — distilled, cross-session knowledge. "Compile" new raw material, "audit" for gaps, query by natural language.

The separation keeps recent work and long-term insights in different places — the first decays (gets trimmed), the second accumulates.
