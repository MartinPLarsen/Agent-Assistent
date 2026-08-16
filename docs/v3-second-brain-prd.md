# PRD: Second brain and cross-machine memory for the starter kit

> Status: settled, 2026-08-16. Produced by a `grill-me` session between Martin and James
> (7 questions, all answered). Every requirement below traces to a decision Martin took
> in that session, or is explicitly marked **ASSUMPTION**.
> Baseline: HEAD `e5b874a`, clone at `~/Desktop/Luna/Agent-Assistent` (the repo was named
> `agent-starter-kit` until 2026-08-16; `docs/v2-plan.md` still uses the old name because it
> records what was true when it was written).

---

## 1. Summary

The kit ships a working memory contract but no knowledge base, and its assistant can only
see the folder it lives in. This adds two things: a **second brain** in its own repo that
the setup wizard provisions, and a **machine-wide capture path** so work done in every
other repo reaches that brain. It also moves the memory caps out of prose and into code.

The concrete target is a Firtal orchestrator on Martin's work Mac, set up from a clone,
filling the same role James fills on the private Mac.

---

## 2. Problem

Measured against the clone on 2026-08-16:

| # | Finding | Evidence |
|---|---------|----------|
| 1 | No knowledge base at all. Memory is a flat fact folder with a 24KB index cap. There is nowhere for synthesis, topic pages, or "what did I do last week" to live. | `memory/` holds `MEMORY.md`, `facts/`, `convo_log.md`, `session.log.md`. Nothing else. |
| 2 | The assistant sees one folder. Everything the user does in other repos is invisible to it. | No `SessionEnd` hook, no cross-project index. `.claude/settings.local.json` wires `SessionStart` only. |
| 3 | Every cap is enforced by asking the model nicely. | `AGENTS.md` "After writing, trim…"; `skills/memory/SKILL.md` caps table. `scripts/check.sh` validates the kit's own structure, never the user's memory files. |
| 4 | v2 dropped the Obsidian vault and nothing replaced it. | `docs/v2-plan.md` §4.2, decision 2026-07-27. |

The reference system this is modelled on is three repos, not one:
`Minions/james` (agent), `second-brain` (knowledge), `luna-second-brain` (engine).
The kit only covers the first.

Finding 3 is the one that decides whether the rest survives. A rule with no owner in code
is a wish; the private-Mac memory index blew past its own cap for exactly this reason.

---

## 3. Goals

- The assistant knows its brain exists from its first message, not after a nudge.
- Setup provisions the brain. It is a wizard phase, not documentation.
- Work done anywhere on the machine reaches the brain without the user doing anything.
- Memory caps hold because code enforces them.
- Martin can clone the kit on the work Mac and stand up a Firtal orchestrator from it.

## 4. Non-Goals

- No bridge between the Firtal brain and Martin's private brain. Not now, not later.
- No vector search. The index-plus-description pattern stays until recall measurably fails
  (carried forward from `docs/v2-plan.md` §7).
- No Obsidian, no GUI dependency. That decision from 2026-07-27 stands.
- No Telegram bridge for Codex. Still deferred.

---

## 5. Target users

Primary: Martin, standing up a Firtal orchestrator on a work Mac.
Secondary: anyone he hands the kit to. The kit stays a template — the brain phase must
survive a user with no GitHub account and must be skippable.

---

## 6. Use cases

- Setup runs on a fresh work Mac and ends with a brain repo that already has content in it.
- The user works all day in five unrelated repos; the next morning the brain has a page
  about what happened.
- The user asks "hvad besluttede vi om X" and gets an answer with citations to pages.
- Three weeks in, the memory index is still under its cap without anyone having pruned it.

---

## 7. Requirements

### Must have

1. **Brain lives in its own repo.** The agent stores the path in config and never assumes
   a sibling folder. *(Q1)*
2. **A wizard phase provisions it.** New phase in `setup/`, run during setup, not optional
   in the flow. It creates the repo, writes the path to config, and seeds the first pages
   from what phases 0 and 1 already learned. *(Q1 addendum)*
3. **The phase is skippable for other users** and must not assume GitHub. *(Q2)*
4. **The kit ships its own retrieval engine, written from scratch.** Three commands —
   `recall`, `store`, `ask` — against the index-and-pages layout. No third-party code,
   nothing to attribute. Martin's existing `brain.js` is the behavioural reference, not a
   source to copy from. *(Q4, then Q9: he chose to write our own rather than carry a
   NOTICE file for CC BY 4.0 code.)*
5. **MIT is removed from the kit's README.** The kit carries no licence. *(Q5)*
6. **A `SessionEnd` hook captures every Claude Code session on the machine**, queueing
   `cwd` and transcript path. It lives in `~/.claude/settings.json`, outside the repo, so
   the wizard installs it and asks permission first. *(Q3)*
7. **A daily harvest distils the queue into the brain** — session notes, then the pages
   they touch, then the index and log. *(Q3)*
8. **Caps are enforced by a script, not by prose.** `session.log.md` at 48h/100KB,
   `MEMORY.md` at 24KB, `convo_log.md` at 40 lines. The script runs on a hook, not on the
   model remembering. *(Q6)*
9. **The kit hardcodes no storage location.** The brain phase asks where the brain should
   live: local-only, or a GitHub repo. If GitHub, it asks for the account, verifies it has
   access to that account, then creates the repo. Nothing about any specific employer,
   account, or path is baked into the kit. *(Q8)*
10. **No bridge between brains.** Where a user runs more than one assistant, each has its
    own brain and nothing crosses. Martin's instance of this rule was decided 2026-08-12
    for Jenna: never employer-internal material or customer data in the private brain,
    one-way only.

### Should have

11. An uninstall path for the user-level hook. It is the one thing the kit installs outside
    its own folder, so removing the kit must be able to remove it.
12. A watcher-health line so a harvest that has been failing silently becomes visible.
    *(carried from `docs/v2-plan.md` §4.5)*
13. `scripts/check.sh` gains a check that fails when a cap is documented but not enforced —
    the same trick that caught `session.log.md` having no writer.

### Could have

14. A `/harvest` command to re-read the machine on demand.
15. Recap queries over the brain ("hvad lavede jeg i sidste uge").

---

## 8. Workflow

**Setup, once:** wizard phase asks where the brain should live — local-only or GitHub. On
GitHub it asks which account, checks that the runtime can actually reach that account, and
creates the repo; on local-only it inits a repo with no remote and says plainly that the
brain will not survive the machine. Either way it writes the path into config → asks
permission for the machine-wide hook → installs it → seeds 5-10 pages from the harvest and
profile phases → commits.

**Every day, unattended:** each Claude session on the machine ends → hook appends `cwd` +
transcript path to a queue → the daily harvest reads the queue, writes a session note per
day, updates the pages those notes touch, updates index and log, commits and pushes.

**On demand:** the user asks a question → `brain.js recall` scores the index without
opening files → the assistant answers from the returned evidence, citing pages.

**Continuously:** the cap script trims and warns. Nothing depends on the model choosing to.

---

## 9. Dependencies and constraints

- **Node.** The engine needs a runtime. Measured on the private Mac: `v24.15.0`.
  Unverified on the work Mac. The kit's README promises "nothing is installed for you", so
  the brain phase must detect a missing runtime and degrade to plain markdown recall — the
  assistant reading the index itself — rather than fail. Node with no dependencies is the
  default; a stdlib-only Python fallback is the alternative if the work Mac lacks Node.
- **Licence.** The kit carries no licence, by Martin's decision, and now ships no
  third-party code either. `~/Desktop/Luna/luna-second-brain` (CC BY 4.0, Jay E |
  RoboNuggets) stays where it is and is referenced as prior art, never copied.
- **Hook placement.** Per-project hooks in `.claude/settings.local.json` only fire for
  sessions in that project. Machine-wide capture requires `~/.claude/settings.json`.
- **Git is the only sync layer.** Nothing under `~/.claude/` crosses machines.
- **`memory/` is not gitignored** in the kit, so the agent's own memory already travels
  with the repo. The brain is the layer that does not.

---

## 9b. Martin's own configuration (not a kit requirement)

Kept separate on purpose. These are answers Martin will give the wizard on his work Mac,
not values the kit knows about. *(Q7, corrected by Q8)*

- Brain stored on GitHub, on the **`ml-firtal`** account. Not his personal account, so the
  repo never becomes his to clean up after he leaves.
- Fully separate from his private brain. No bridge, in either direction.

---

## 10. Success metrics

- A clone on the work Mac reaches a first useful reply with brain configured, in one
  wizard run, with no manual file editing.
- The morning after a normal workday, the brain contains a page about work done in repos
  the assistant was never opened in.
- After three weeks, all three caps still hold without anyone having pruned by hand.
- Zero Firtal-internal content in the private brain. Checked, not assumed.

---

## 11. Risks and open questions

- **Node on the work Mac is unverified.** Requirement 4 and the fallback in §9 both hinge
  on it. First thing to measure there.
- **No licence conflicts with "template for others."** Martin was shown that standard
  copyright means nobody may legally use it, and chose it anyway. Recorded, not reopened.
- **A machine-wide hook is the kit's largest blast radius.** It fires for every Claude
  session on the machine, including work unrelated to the assistant. Requirement 11 is
  the mitigation.
- **Hosting work knowledge on a named GitHub account** still needs Firtal's blessing, even
  on the `ml-firtal` account. Worth one email before the first push.
- **SETTLED 2026-08-16.** Martin asked to drop the attribution to Jay E. That is not
  available — CC BY 4.0 grants everything and asks one thing back, and removing it while
  distributing is infringement whether the kit is public or handed over privately. He was
  offered a NOTICE line or a clean-room engine and chose the engine. Requirement 4 is now
  our own code, and the constraint disappears with it. Care still needed while building:
  `brain.js` is the behavioural spec, not a file to copy lines out of.
- **ASSUMPTION:** the brain phase offers "create new" or "point at an existing brain". The
  config field holding the path is needed either way, so this costs one extra question.
- **ASSUMPTION:** harvest runs daily, mirroring the private-Mac cadence.

---

## 12. Recommended next action

Run the wizard end to end on a throwaway agent, then do the same on the work Mac. Nothing
below has been exercised by a real setup run yet, and phase 7 is where a template usually
breaks first.

---

## 13. Built 2026-08-16

Requirements 1-9, 11 and 13 are in. Requirement 10 is a rule, not code. Requirements 12,
14 and 15 are not started.

| Piece | File |
|-------|------|
| Wizard phase | `setup/07-brain.md` — asks local vs GitHub, checks account access before creating anything, creates the repo private, writes `agent.json` → `brain`. Activate moved to `08-activate.md`. |
| Engine | `scripts/brain.mjs` — `recall`, `store`, `ask`, `check`, `selftest`. Node, no dependencies, no network. Written from scratch. |
| Caps | `scripts/memory-caps.sh` — trims the session log by age and size, keeps one session in the convo log, reports index breaches without deleting index lines. |
| Capture | `scripts/capture-session.sh` + `scripts/install-capture-hook.sh` — opt-in `SessionEnd` hook in `~/.claude/settings.json`, idempotent, with a working uninstall. |
| Instructions | `AGENTS.md` gains a **Second brain** section; the trim-it-yourself instruction is replaced by a pointer to the script. |
| Guards | `scripts/check.sh` gains three checks: the engine's selftest, the brain-phase scripts existing and being executable, and a full install → idempotent reinstall → uninstall round trip of the capture hook. |

Two bugs found while building, both in code written this session:

1. `recall` returned the page's own H1 instead of the section that answered. The H1 repeats
   the title, so it ties on the query's title words and wins by being first.
2. The capture hook interpolated the hook's JSON payload into a shell heredoc. A `cwd`
   containing a quote would have broken out of the program. It reads the payload as a
   stream now and never through the shell.

The first assertion written for bug 1 passed with the bug reintroduced — the query it used
scored the right section higher outright, so it never created the tie the bug needed. Both
new guards were then tested in the failing direction as well as the passing one. Green on a
check that cannot go red proves nothing.
