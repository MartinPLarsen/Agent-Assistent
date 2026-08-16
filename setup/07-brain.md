# Phase 7 — The second brain

Phase 6 gave you memory: facts about the user, one file each, loaded by description match.
This phase gives you somewhere for knowledge to *accumulate* — pages that get rewritten as
you learn more, a log of what happened, and a capture path that runs whether or not anyone
opens a session with you.

Memory is what you know about the user. The brain is what the two of you have worked out
together. Keeping them in separate repos is deliberate: the brain outlives any single
clone of this kit.

Ask one question at a time, as everywhere else in the wizard.

---

## Q1 — Where should it live

> "Din second brain får sit eget repo, så den overlever at du klonner mig forfra.
> To muligheder:
>
> Lokalt: ligger kun på denne maskine. Ingen konto, intet at sætte op. Men den dør med
> maskinen, og du kan ikke læse den fra telefonen.
>
> GitHub: privat repo. Overlever maskinen, læsbar overalt. Kræver at jeg kan nå din konto.
>
> Jeg foreslår GitHub, hvis du har en konto. Sig til hvis lokalt er nok."

Default the path to a sibling of this repo — `../<agent-name>-brain` — and say the path
out loud before creating anything.

### If they choose local

```bash
mkdir -p "$BRAIN/knowledge-base/raw/pages" "$BRAIN/knowledge-base/raw/session-notes" \
         "$BRAIN/knowledge-base/wiki" "$BRAIN/knowledge-base/outputs"
git -C "$BRAIN" init -q
```

Say plainly, once: without a remote, the brain does not survive the machine. Do not repeat
it later.

### If they choose GitHub

Ask **which account** — not just "do you have GitHub". People have more than one, and the
right one is often not the one they are logged in as. This matters most when the assistant
is for work: knowledge produced on an employer's time is easier to hand over if it never
lived on a personal account in the first place.

Then check you can actually reach it, before creating anything:

```bash
gh auth status
gh api user --jq .login          # who am I right now
gh api "users/$ACCOUNT" --jq .login   # does the named account exist
```

If the authenticated login is not the account they named, stop and say so. Offer
`gh auth login` and wait — logins open a browser and cannot be done from a tool call.

Create it private, and never anything else:

```bash
gh repo create "$ACCOUNT/$REPO" --private --description "Second brain" --clone=false
git -C "$BRAIN" remote add origin "git@github.com:$ACCOUNT/$REPO.git"
```

---

## Q2 — Machine-wide capture

The brain is only worth having if it fills up on its own. Left to session conversations
alone it becomes a diary of talking, not a record of working.

> "Vil du have at jeg fanger alt arbejde på maskinen, ikke kun vores samtaler?
>
> Det kræver en lille krog i ~/.claude/settings.json, altså uden for min egen mappe.
> Den skriver kun hvor en session kørte og hvornår. Ikke indholdet.
>
> Jeg foreslår ja. Uden den ser jeg kun det du siger til mig direkte."

This is the only thing the kit installs outside its own folder, so it is the only thing
that needs saying out loud. If they say yes:

```bash
scripts/install-capture-hook.sh "$BRAIN"
```

The script is idempotent and prints what it changed. `scripts/install-capture-hook.sh
--uninstall` removes it again; mention that once, so the door is visibly unlocked.

If they say no, the brain still works — it just only sees this assistant's own sessions.
Note it in `agent.json` and move on.

---

## Write the config

Everything else in the kit reads this block. Merge it into `agent.json`:

```json
"brain": {
  "path": "/absolute/path/to/the/brain",
  "remote": "github",
  "account": "<github account, or null>",
  "capture_hook": true,
  "engine": "node"
}
```

`engine` is `node` when `node --version` succeeds, `markdown` when it does not. On
`markdown` the assistant reads `wiki/index.md` itself and opens matching pages by hand —
slower and it costs tokens, but nothing breaks. Check now rather than at first use:

```bash
node --version || echo "no node — set engine to markdown"
```

---

## Seed it

An empty brain is one nobody goes back to. Write three to five real pages from what
phases 0 and 1 already told you — not invented ones:

| Page | From |
|------|------|
| one per active project | phase 0's repo scan: what it is, its stack, its current state |
| how the user works | phase 1: hours, what drains them, how they want to be pushed |
| the tooling in play | phase 0: languages, CLIs, accounts, where secrets live |

Pages go in `knowledge-base/raw/pages/<kebab-name>.md`, no dates in the filename — pages
are living documents. Each gets one line in `knowledge-base/wiki/index.md`:

```markdown
- [Title](../raw/pages/kebab-name.md) — one line, under 200 characters
```

Markdown links, not wikilinks: the engine parses these as its index hops. Then append the
first entry to `knowledge-base/wiki/log.md`:

```markdown
## [YYYY-MM-DD] setup — brain created
Seeded from the setup wizard: <n> pages.
```

Commit, and push if there is a remote:

```bash
git -C "$BRAIN" add -A && git -C "$BRAIN" commit -qm "setup: seed the brain"
git -C "$BRAIN" push -u origin HEAD    # only if a remote exists
```

---

## Verify before moving on

```bash
node scripts/brain.mjs check      # layout, index/page agreement, config path resolves
```

The one failure worth catching here: an index line pointing at a page that does not exist,
or a page with no index line. Either way it is invisible to recall, which reads as "the
brain forgot" rather than as a broken link.

## Output

Brain repo created, config written, capture hook installed or declined, three to five
pages seeded and committed. Merge:

```json
{ "current_phase": 8, "steps_completed": [..., "phase_7"] }
```
