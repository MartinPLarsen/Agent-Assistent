# CLAUDE — {{AGENT_NAME}}, vault conventions

> Lives in the root of the second brain. Any Claude Code session opened on this folder
> reads it. Written during setup phase 7; fix it when something stops being true.

## About {{USER_NAME}}

{{ROLE_AND_WORK}}

This is {{USER_NAME}}'s private knowledge system — where thinking happens before it becomes
action. Strategic notes, reflections, learning logs, project context, reference material.
If it matters enough to remember but does not belong in a codebase, a ticket, or an agent's
memory, it lives here.

## Vault structure

- `knowledge-base/raw/` — inbox. Incoming material: research, brain dumps, notes.
  - `raw/pages/` — the living pages themselves, one topic per file.
  - `raw/session-notes/` — what happened, dated, append-only.
- `knowledge-base/wiki/` — the filing cabinet you maintain.
  - `wiki/index.md` — the entry point. Every page has exactly one line here.
  - `wiki/log.md` — one entry per change to the brain.
- `knowledge-base/outputs/` — generated deliverables.

Stuff comes in messy through `raw/`, you organise it.

## The index is load-bearing

`wiki/index.md` is how recall finds anything. One line per page, markdown link, never a
wikilink — the engine (`scripts/brain.mjs`) parses these links to know where to look:

```markdown
- [Title](../raw/pages/kebab-name.md) — one line, under 200 characters
```

Wikilinks are fine *inside* a page body, where Obsidian resolves them and the engine never
reads them. In `index.md` they are invisible to recall, which reads as "the brain forgot".

A page with no index line, or an index line pointing at a missing page, is the one failure
worth catching. `node scripts/brain.mjs check` finds both.

## Compiling

When {{USER_NAME}} says "compile", or drops new material in `raw/`:

1. Read each new raw file.
2. Decide which existing page it belongs to, or start a new one.
3. Rewrite the page — pages are living documents, not an append log.
4. Add or update its line in `wiki/index.md`.
5. Cross-link related pages with `[[wikilinks]]` in the body.
6. Append what changed to `wiki/log.md`.

## Querying

1. Read `wiki/index.md` to find the right pages.
2. Read those pages.
3. Answer from them, and say when the brain has nothing.

## Auditing

When {{USER_NAME}} says "audit" or "lint", review for contradictions, missing cross-links,
topics mentioned but never written up, and index/page disagreement. Suggest; do not
rewrite without confirmation.

## Conventions

- File names: lowercase with hyphens, no dates — pages are living documents.
- Every page starts with `name:` and `description:` frontmatter. The description is what
  recall matches on, so write it for a stranger.
- Every content page has a `## Key Takeaways` section. Index files do not.
- Notes in `raw/` include date, source, and key findings.

## Preferences

- Concise. Bullets over paragraphs.
- {{COMMUNICATION_PREFERENCES}}
