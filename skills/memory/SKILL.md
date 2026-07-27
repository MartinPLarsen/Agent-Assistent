---
name: memory
description: Use when writing, reading, pruning, or correcting anything under memory/ — after the user corrects you, after a non-obvious technical discovery, at a natural breakpoint in a session, or when recalling what you know about a topic. Also fires the weekly prune.
---

# Memory

Three layers. Mixing them up is the failure mode that makes memory systems rot.

| Layer | File | Holds | Lifetime |
|-------|------|-------|----------|
| Index | `memory/MEMORY.md` | one line per fact | permanent, always loaded |
| Facts | `memory/facts/*.md` | one fact per file | permanent, loaded on match |
| Session state | `memory/convo_log.md` | where this session got to | overwritten each session |

Plus `memory/session.log.md`, a rolling 48-hour log of inbound messages that the watchers
read to tell "already being discussed" from "gone quiet". It is machine-written; never
hand-edit it.

The rule that separates the layers: **what happened goes in the convo log, what you
learned goes in facts.** "We decided to use Postgres" is a fact. "We spent the afternoon
on the migration" is session state.

## Reading

1. `memory/MEMORY.md` is loaded at startup. That is the whole index.
2. Open a fact file only when its one-line description matches what you are doing. Reading
   the whole folder defeats the point of having an index.
3. **Verify before you rely on it.** A fact records what was true when it was written. If
   it names a file, a flag, an endpoint, or a version, confirm that still exists before
   recommending anything based on it. A confidently stale answer is worse than no memory.

## Writing

Write without being asked. This is the part every memory system gets wrong: it waits for
"remember this", the user never says it, and the folder stays empty.

Four triggers:

| Trigger | Type | Why it matters |
|---------|------|----------------|
| The user corrects you, or confirms an approach | `feedback` | The most valuable thing you can store. Include why. |
| A non-obvious technical discovery, a gotcha, an API quirk | `reference` | Would a future session waste an hour rediscovering it? |
| A goal or constraint you cannot see in the code | `project` | Deadlines, decisions, things deliberately not done. |
| Something durable about the person | `user` | Role, working style, what drains them. |

**Do not write** what the repo already records — file structure, what a function does, git
history, anything in a README. Do not write things that only matter for this conversation;
those go in the convo log.

### Before writing: check

Search `memory/facts/` for the same subject first. If a fact already covers it, update
that file rather than adding a second one. Two files on the same topic will disagree
eventually, and then neither is trustworthy.

### Fact file format

`memory/facts/<short-kebab-name>.md`:

```markdown
---
name: supabase-revoke-from-public
description: REVOKE FROM PUBLIC is a no-op on Supabase — grant is direct to anon/authenticated
metadata:
  type: reference
---

Supabase grants EXECUTE directly to the anon and authenticated roles, not to PUBLIC,
so `REVOKE ... FROM PUBLIC` succeeds and changes nothing. Revoke from both roles by
name instead, then confirm against the security advisors rather than trusting the 201.

Related: [[project-database-hardening]]
```

For `feedback` and `project` types, follow the body with two lines:

```markdown
**Why:** the reason this matters, in one sentence.
**How to apply:** what to do differently next time.
```

`[[links]]` between facts are free. A link to a fact that does not exist yet is fine — it
marks something worth writing later, not an error.

### Then update the index

One line in `memory/MEMORY.md`, newest first:

```markdown
- [Supabase REVOKE FROM PUBLIC is a no-op](facts/supabase-revoke-from-public.md) — grant is direct to anon/authenticated; verify via advisors not the 201
```

Under 200 characters. The line exists so a future session can decide whether to open the
file, nothing more. Detail belongs in the fact.

## Correcting and deleting

When a fact turns out to be wrong, fix it or delete it. Do not leave it with a note saying
it might be outdated — a memory you have to second-guess costs more than it saves.

Deleting a fact file needs the user's approval, like any other deletion. Correcting one
does not.

## Session state

`memory/convo_log.md`, rewritten at natural breakpoints: after a decision, after a task
finishes, when the topic changes. Sessions die without warning, so write early.

Four headings, under 40 lines total, newest session on top, keep only the latest:

```markdown
## <date> (<what this session is about>)

**Active context:** what is in flight right now, and what the next session should do first.
**Completed:** what actually got done.
**Pending:** what is still open, and what unblocks each item.
**Key decisions:** choices made and why, so they do not look arbitrary in a week.
```

## Caps, and the weekly prune

These are not suggestions. v1 of this kit had no caps and its index grew past the point
where it could be loaded at all.

| File | Cap | On exceeding |
|------|-----|--------------|
| `memory/MEMORY.md` | 24KB | Prune. Move detail into fact files, shorten index lines. |
| index line | 200 chars | Shorten it. |
| `memory/convo_log.md` | 40 lines | Cut the oldest session. |
| `memory/session.log.md` | 100KB or 48h | Trim oldest entries until both hold. |

The weekly prune, run from the `self-review` routine:

1. Check each file against its cap. Fix any breach.
2. Find facts whose index line has not matched a task in three months. Ask whether to keep
   or drop them, listing them in one message. Do not delete silently.
3. Find duplicate or contradictory facts and merge them.
4. Check that every index line points at a file that exists, and every file has an index
   line. Orphans in either direction are invisible to recall.

## Recall

When the user asks what you know about something:

1. Match the index by description.
2. Open only the matching facts.
3. Answer citing which fact each claim came from.
4. Verify anything the answer depends on before recommending action on it.
5. If you find nothing, say so. Never fill the gap with a plausible guess.
