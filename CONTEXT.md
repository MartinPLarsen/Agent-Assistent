# Kontekst

> Hvad Martin faktisk arbejder på. Skrevet af harvesten i setup fase 0 ud fra maskinen selv,
> derefter rettet af ham. Kør harvesten igen når den er drevet fra virkeligheden.
>
> Sidst harvestet: 2026-08-17

## Aktive projekter

Sorteret efter seneste commit. Luna Studios produkter ligger også på maskinen, men holdes
bevidst ude af denne fil — se Rettelser.

| Projekt | Sti | Stack | Sidst rørt | Hvad det er |
|---------|-----|-------|------------|-------------|
| Agent-Assistent | `~/Desktop/Firtal/Agent-Assistent` | Markdown + shell, Claude Code | 2026-08-16 | Dette repo — personlig assistent med hukommelse, skills og second brain |
| second-brain | `~/Desktop/Luna/second-brain` | Markdown | 2026-08-16 | Selvforbedrende videnbase (LLM Wiki-mønster). Skrives af agenten, læses deterministisk |
| Minions | `~/Desktop/Luna/Minions` | Shell + Claude Code | 2026-08-16 | Privat monorepo. James er eneste agent — én Claude Code-session med egen Telegram-bot |
| luna-skills | `~/Desktop/Luna/luna-skills` | Markdown | 2026-08-14 | Martins Claude Code skill-bibliotek, 93 skills, single source symlinket til `~/.claude/skills` |
| luna-claude-config | `~/Desktop/Luna/luna-claude-config` | Markdown | 2026-08-14 | Global Claude Code-config delt mellem de to Macs, symlinket ind i `~/.claude/` |
| customer-service-upstream | `~/Desktop/Firtal/customer-service-upstream` | Node/TypeScript monorepo, Postgres/SQLite | 2026-08-12 | Firtal kundeservice-agent (upstream `firtal-group/customer-service`): Dixa-mails, klassificering, Selveo-ordreopslag, AI-svar, GEPA-loop |
| customer-service-main | `~/Desktop/Firtal/customer-service-main` | Node/TypeScript monorepo | 2026-08-11 | Martins fork `ml-firtal/customer-service-kategorisering` af samme system |
| luna-second-brain | `~/Desktop/Luna/luna-second-brain` | Node | 2026-08-11 | brain.js — zero-token retrieval/storage-engine bag second-brain |

## Dvale

Ingen. Alt herover er rørt inden for den seneste uge.

## Arbejdskontekster

- **Firtal (arbejde)** — `customer-service-upstream` + `customer-service-main`, samme system:
  upstream er firtal-group, main er Martins fork. Kundevendt, så ingen data herfra i noter
  eller brain.
- **Agent-infrastruktur (personlig)** — Minions (James), luna-skills, luna-claude-config,
  second-brain, luna-second-brain og dette repo. Alle under `MartinPLarsen`, symlinket ind
  i `~/.claude/`. Ligger fysisk under `~/Desktop/Luna/` af historiske grunde — det er ikke
  Luna Studio-arbejde.

## Stacks

- Node/TypeScript monorepos (pnpm workspaces) — kundeservice-agenten
- Postgres i produktion, SQLite lokalt — backend vælges ud fra `DATABASE_URL`
- Python — enkelte agent-værktøjer
- Markdown + shell — hele agent-infrastrukturen
- Vercel + Supabase hvor der deployes

## Identiteter

| Konto | Email | Bruges til |
|-------|-------|------------|
| MartinPLarsen | Martin.pa.larsen@gmail.com | privat — agent-infrastruktur, egne repoer |
| ml-firtal | ml@firtal.com | arbejde — alt Firtal, inkl. forken `ml-firtal/customer-service-kategorisering` |

`Martin.pa.larsen@gmail.com` er den globale git-identitet, og **ingen af Firtal-repoerne
sætter en lokal override**. Firtal-commits lander derfor under den private adresse indtil
`git config user.email ml@firtal.com` køres i hvert af dem. Tjek før første commit i et
kundevendt repo.

## På denne maskine

- **Runtimes:** node, python3, docker
- **CLIs:** gh, vercel, codex, claude
- **Mangler:** supabase CLI, trigger CLI, ffmpeg
- **Forbundet:** Gmail, Google Calendar, Google Drive, Slack, Supabase, Vercel, Playwright
  (MCP). Kræver login endnu: Linear, Stripe, ElevenLabs, n8n.

## Rettelser

Hvad Martin sagde harvesten tog fejl i. Behold dem — næste harvest laver de samme fejl ellers.

- **Luna Studios produkter hører ikke til her.** Luna-Production, luna-studio/RENDER Studio,
  multica og cmo-agent-team ligger på maskinen, men denne assistent er til Firtal,
  agent-infrastrukturen og stacken. Tag dem ikke med ved næste harvest.
- **To identiteter, ikke én.** Harvesten så kun den globale git-config. Martin har både
  MartinPLarsen (privat) og ml-firtal (arbejde).
