# Agent Starter Kit v2 — Implementation Plan

> Status: proposed, 2026-07-27. Written by James after a full review of v1 (HEAD `4efb27c`)
> and the Codex port (`MartinPLarsen/agent-starter-kit-codex`, HEAD `7ef8c30`).
> Decision taken 2026-07-27: the two repos merge into this one; the Codex repo is archived.

---

## 1. What changes, in one paragraph

v1 is an onboarding wizard that produces an agent-shaped folder. v2 is a **personal
assistant** that happens to have a setup wizard. The kit stops being an agent factory
(archetypes, orchestration, "coordinate other agents") and becomes one thing done well:
a PA with deep, harvested context about its user's actual work, a real memory contract,
declarative proactivity, and the ability to bootstrap new projects. It runs on Claude
Code, Codex CLI, and any other runtime that reads `AGENTS.md`.

---

## 2. v1 findings (what we are fixing)

| # | Finding | Evidence |
|---|---------|----------|
| 1 | Memory is an empty shell | `MEMORY.md` is 76 bytes, `memory/` holds only `.gitkeep`. No write rules, no recall rules, no fact types. |
| 2 | No context harvest | Wizard asks 4 profile questions and never reads the machine. `CLAUDE.md` Phase 1 has no filesystem step. |
| 3 | Proactivity is one narrow skill | `skills-templates/accountability-heartbeat/SKILL.md` covers stale Linear issues + orphan commitments only. Bills, invites, unanswered questions absent. |
| 4 | Archetypes are the wrong abstraction | `archetypes/{orchestrator,specialist,research,custom}.md`; orchestrator's whole premise is routing to other agents. |
| 5 | No project bootstrap | Nothing in v1 scaffolds a repo. |
| 6 | One shipped skill | `skills-templates/` has exactly one entry. |
| 7 | Codex support is a divergent fork | Separate repo, stale since 2026-04-28, ships a committed Python `.venv`. |
| 8 | Self-rewriting `CLAUDE.md` is fragile | Phase 6.2 backs the wizard up, overwrites it, verifies, and restores on failure. 995 lines loaded every session until it does. |
| 9 | Template ships `bypassPermissions` | `.claude/settings.local.json` sets `defaultMode: bypassPermissions` for every new user. |
| 10 | Vault skip drops the convo log | Phase 5.0 "skip the rest of Phase 5" jumps past Step 5.6, which is the only place `memory/convo_log.md` is created. Phase 6 then tells Session Startup to read it. |

---

## 3. Target repo layout

```
agent-starter-kit/
  README.md
  AGENTS.md                    # CANONICAL agent instructions (all runtimes)
  CLAUDE.md                    # 3-line pointer to AGENTS.md + Claude-only notes
  setup.sh                     # detach git history, symlink skills, print next step
  .setup-state.json

  setup/                       # wizard, one file per phase, loaded on demand
    00-harvest.md
    01-you.md
    02-me.md
    03-channel.md
    04-tools.md
    05-rhythm.md
    06-memory.md
    07-activate.md
    templates/
      AGENTS.agent.md          # post-setup instructions TEMPLATE (no self-rewrite)
      USER.md  SOUL.md  CONTEXT.md  MEMORY.md  convo_log.md  open_commitments.md

  skills/                      # canonical shipped skills
    memory/  watchers/  new-project/  capture-skill/  handoff/  daily-briefing/
  watchers/                    # declarative watcher definitions (data, not prose)
    stale-work.md  unpaid-bills.md  calendar-invites.md  unanswered.md  commitment-drift.md

  codex/
    config.toml.template
    prompts/{help,status,recall}.md
  crons/
    README.md
    examples/morning-briefing.ts

  memory/
    MEMORY.md  facts/.gitkeep  convo_log.md  open_commitments.md  session.log.md
  scripts/
    on-stop.sh
  .claude/
    skills/                    # symlinks into ../../skills, created by setup.sh
    settings.local.json
```

**Deleted:** `archetypes/`, `skills-templates/`, `discord-bridge/` (Codex repo), the
`CLAUDE.md` self-rewrite mechanic, `CLAUDE.md.wizard-backup`.

---

## 4. The four substantive changes

### 4.1 Context Harvest (new Phase 0)

Read-only, no questions, ~2 minutes. The single biggest lever for "deep domain
understanding" and it costs the user nothing.

Collect:
- Git repos under `~/Desktop`, `~/Documents`, `~/Projects`, `~/code`. Per repo: remote,
  last commit date, primary language, first paragraph of README, presence of
  `CLAUDE.md` / `AGENTS.md`.
- `git config --global user.name/user.email` plus per-repo overrides — this is how the
  agent learns the user has separate work and private identities.
- Installed CLIs: `gh node python3 docker supabase vercel trigger codex claude`.
- `~/.claude/settings.json` — enabled plugins and already-configured MCP servers.
- If connectors are live: Linear team names, calendar names, Gmail labels. Names only,
  never contents.

Produces `CONTEXT.md`, then shows the user a summary to correct:
*"Jeg kan se 8 aktive repos, 3 stacks og 2 git-identiteter. Passer det?"*

`CONTEXT.md` is re-harvestable (`/harvest`) and is read at session startup alongside
`USER.md`. This replaces guessing with evidence.

### 4.2 Memory contract

Ported from the James setup and generalised. Four layers, each with explicit write and
read rules. Shipped as `skills/memory/SKILL.md` plus a startup-loaded protocol section.

| Layer | File | Lifetime | Loaded |
|-------|------|----------|--------|
| Index | `memory/MEMORY.md` | permanent | every session |
| Facts | `memory/facts/*.md` | permanent | on demand, by description match |
| Session state | `memory/convo_log.md` | current session | every session |
| Long-term distilled | Obsidian vault (optional) | permanent | on command |

Fact file format — one fact per file, frontmatter `name` / `description` / `type`,
types `user | feedback | project | reference`, `[[links]]` between facts. `feedback` and
`project` bodies carry `**Why:**` and `**How to apply:**`.

Write triggers (missing entirely in v1, and the reason v1 memory stays empty):
- user corrects you → write a `feedback` fact, including the why
- non-obvious technical discovery → `reference`
- a goal or constraint not derivable from the code → `project`
- natural breakpoint → update `convo_log.md`

Read rules:
- index always; open a fact file only when its description matches the task
- before recommending anything a memory names (file, flag, endpoint), verify it still exists
- dedup before writing: search existing facts and update rather than duplicate

Hard caps, enforced by a `memory-prune` cron: `MEMORY.md` under 24KB, one line per fact
under 200 chars, `convo_log.md` under 40 lines. v1 had no caps; the James index blew
past its own limit for exactly this reason.

### 4.3 Watchers (proactivity)

`skills/watchers/SKILL.md` is the runner; `watchers/*.md` are declarative definitions,
each with source, rule, cooldown, and nudge template. The heartbeat cron runs the runner.

Shipped watchers:

| Watcher | Source | Fires when |
|---------|--------|-----------|
| `stale-work` | Linear / issue tracker | in-progress issue untouched >4h and unmentioned in session log |
| `unpaid-bills` | Gmail | invoice/faktura with a due date and no matching payment mail |
| `calendar-invites` | Google Calendar | invitation still pending response |
| `unanswered` | Gmail / Telegram | a direct question to the user with no reply in 24h |
| `commitment-drift` | `open_commitments.md` | item unmentioned in 24h |

Runner rules: silence checks first (outside 08–20, weekend, active calendar event, user
messaged within 15 min), then at most **one** nudge per fire, then a per-watcher cooldown
so nothing nags. Adding a watcher is a new markdown file, not a code change.

### 4.4 Project bootstrap

`skills/new-project/SKILL.md`. Martin's explicit ask: *"nyt projekt → repo, mappestruktur,
shared skills, MCP-adgang, best practice for Claude Code eller Codex."*

Flow: three questions (name, kind, runtime) → scaffold → register.
Scaffold: `git init` + first commit, `README.md`, `AGENTS.md` + `CLAUDE.md` pointer,
`.mcp.json` seeded from the tools the user already has, `docs/decisions/` for ADRs,
stack-appropriate `.gitignore`, symlink to the shared skills library.
Register: append the new project to `CONTEXT.md` so the PA knows about it from day one.

---

## 5. Cross-runtime compatibility

- `AGENTS.md` is canonical. `CLAUDE.md` is three lines pointing at it plus Claude-only
  notes (Skill tool, CronCreate, Telegram plugin). Codex and Kimi read `AGENTS.md`
  natively. One source, no fork.
- Skills are plain markdown in `skills/`. `setup.sh` symlinks them into `.claude/skills/`
  for Claude's Skill tool. Codex has no Skill tool, so `AGENTS.md` carries a skills index
  table (name, when to load, path) that any runtime can follow.
- Codex specifics kept from the merged repo: `codex/config.toml.template`,
  `codex/prompts/{help,status,recall}.md`, `scripts/on-stop.sh` (the `[notify]` hook).
- Channel: Telegram via the Claude plugin. Codex has no plugin, so a Codex user is
  terminal-only in v2.0. A generic Telegram bridge is deferred (see §7).
- Discord bridge from the Codex repo is dropped: it committed a Python `.venv`, and
  Telegram is the channel that is actually used.

---

## 6. Build order

| Phase | Work | Est. |
|-------|------|------|
| A | Repo surgery: merge Codex assets, delete `archetypes/` + `discord-bridge/`, split wizard into `setup/*.md`, `AGENTS.md` canonical + `CLAUDE.md` pointer, remove self-rewrite, fix `bypassPermissions`, fix the vault-skip convo-log bug | 1 h |
| B | Memory contract: skill, templates, index caps, prune cron | 1.5 h |
| C | Context harvest: `setup/00-harvest.md`, `CONTEXT.md` template, `/harvest` command | 1 h |
| D | Watchers: runner + 5 watcher definitions + heartbeat rewrite | 1.5 h |
| E | Skills: `new-project`, `capture-skill`, `handoff`, `daily-briefing` | 1.5 h |
| F | README rewrite + end-to-end wizard run on a throwaway agent | 1 h |

Total ≈ 7.5 h. One evening plus a morning.

Each phase is one commit on `mal/v2`, Conventional Commits, no push until Martin says go.

---

## 7. Explicitly deferred

- **Telegram bridge for Codex** — needed for a Codex agent to be reachable off-terminal.
  Real work (long-poll loop, state dir, allowlist), and no user is blocked on it today.
  Revisit once v2.0 is running.
- **Vector search over memory** — the index-plus-description pattern works at the scale a
  single user generates. Add embeddings only if recall measurably fails.
- **More archetypes** — the whole point of v2 is that there is one.

---

## 8. Open questions for Martin

1. Should the kit stay a public template, or go private? Some of the harvest logic reads
   the user's machine layout; nothing is transmitted, but it changes the README's tone.
2. Keep the Obsidian vault as an optional fourth memory layer, or fold it into
   `memory/facts/` and drop the dependency?
