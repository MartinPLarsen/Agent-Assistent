# Phase 4 — What you can touch

The harvest in phase 0 already told you what the user has installed and what the runtime
has connected. Start from that instead of from a blank list.

## Open with what you found

> "Du har allerede [gh, docker, supabase] installeret, og [Gmail, Linear] er forbundet i
> Claude. Skal jeg bruge dem alle, eller er der noget jeg skal holde mig fra?"

Then, one question:

> "Er der andet jeg skal kunne nå?"

Offer a short menu only if they hesitate:

> Mail og kalender · Issues (Linear, Jira, GitHub) · Databaser (Supabase, Postgres) ·
> Noter (Notion, Obsidian) · Automation (n8n, Trigger.dev) · Andet

## Connectors

Most connectors are enabled by the user at `claude.ai/settings/connectors`, not by you.
For each one they want and do not have, give one line on what it unlocks and let them
enable it. Do not walk them through six connectors they will never use — the ones that
matter for an assistant are mail, calendar, and whatever tracks their work.

`.mcp.json` in this folder is for servers this project runs itself. Leave it as
`{"mcpServers": {}}` unless there is a genuine one to add. Notably, **no telegram entry**
— the channel flag handles that, and an entry here breaks it.

## Which ones the watchers need

Phase 5 sets up watchers, and each needs a source. Tell the user plainly:

| Watcher | Needs |
|---------|-------|
| stale work | an issue tracker |
| bills coming due | mail |
| unanswered invitations | calendar |
| questions nobody replied to | mail |
| commitment drift | nothing, it reads a local file |

A watcher without its source is not an error; it just never fires. Note which ones will be
inert so phase 5 does not enable them silently.

## Keys

If a service needs an API key, the key does not go in this repo. It goes wherever the
runtime reads secrets from — the OS keychain, a `.env` outside the repo, or the cloud
dashboard for scheduled routines. Tell the user where, and have them confirm when it is
in place. Never echo a key back into the conversation.

## Output

`TOOLS.md` from `setup/templates/TOOLS.md`: one row per service with how it is reached and
whether it is live. Update `.mcp.json` only if something genuinely belongs there.

Merge:

```json
{ "current_phase": 5, "steps_completed": [..., "phase_4"] }
```
