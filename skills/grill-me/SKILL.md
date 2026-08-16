---
name: grill-me
description: Interview the user relentlessly about a plan, design, architecture, product idea or decision — mapped as a design tree and worked in rounds — until every branch is visited and the output is a written PRD. Use when a plan should be stress-tested, challenged, or have its holes found. Triggers — "grill me", "stress-test this plan", "find the holes", "what am I missing", "challenge this", "tear this apart", "interview me about this". SKIP when the user wants the thing built rather than questioned, and for a single factual lookup.
---

# Grill me

Stress-test a plan, design, architecture, product idea or decision until both sides hold
the same picture of it. Expose ambiguity, missing constraints, hidden dependencies, weak
assumptions and premature conclusions.

Be direct, specific and decision-forcing. Agreeableness is the thing this skill exists to
remove: an assistant that nods costs its user a rewrite in three weeks.

The frontier-round method below is Matt Pocock's (github.com/mattpocock/skills,
productivity/grilling, MIT).

## The design tree

Map the subject as a **design tree**: every decision branches into the decisions that hang
off it. A decision that cannot be put to the user until an earlier one lands is a *later*
branch, not a question to guess at now.

The **frontier** is every decision whose prerequisites are already settled — the questions
answerable *now*. Work the tree in **rounds**: ask the frontier, wait, then recompute it
from the answers.

Each answer reshapes the tree. Settled decisions push the frontier outward. The session
ends when the frontier is empty: every branch visited, nothing silently assumed.

## Rounds

Ask the frontier as a numbered round, **highest-leverage first, capped at five questions**.
A sixth goes in the next round — a wall of questions is a wall whether or not each one is
independently answerable. Where the user is on a phone, or reads short, ask fewer; one
question is a legitimate round and is the normal shape early in a tree.

Every question carries a recommended answer, so the user can settle a whole round in one
line ("1 and 3 yes, rest as you say"). That is what makes a round cheaper than five
sequential exchanges rather than five times the work.

Format each question like this:

```
Q1 — <question title>: <the question, with the real tradeoff and the consequence of each
way. Multiple choice is fine.>

→ <your recommended answer, stated as a position, not a menu>
```

Then wait. Do not answer your own questions, and do not move to the next round on partial
answers — an unanswered question is an unsettled prerequisite.

## Facts are your job

Finding *facts* is yours; making *decisions* is the user's. When a frontier question needs a
fact from the environment — a file, a config, a row count, what an API actually returns,
what the code already does — go and get it. Dispatch a subagent for anything that takes
real reading.

A running exploration is an unsettled prerequisite: only the questions downstream of it
wait. Ask the rest of the frontier while it runs.

**A question the repo can answer, asked of the user anyway, is the single most common way
this skill wastes a session.** It also costs trust: it reads as not having looked.

## Question quality

A question earns its place when it is specific, decision-forcing, tied to a consequence,
scoped to one issue, and carries your recommended answer. Uncomfortable is fine;
uncomfortable is often the point.

When an answer comes back vague, treat the vagueness as the finding and put the sharper
version in the next round.

## Stop criterion

Stop when the frontier is empty **and** the PRD would be materially actionable: core goal,
problem and desired outcome, constraints, named tradeoffs, surfaced assumptions, success
metrics, the boundary between must-have and later, risks stated rather than hidden, and an
obvious next action.

An empty frontier with a thin PRD means branches were skipped. A full PRD with questions
still open means you stopped early.

Say in one line that the grilling is complete and why the clarity is sufficient, then draft
the PRD.

## Output: a PRD

```markdown
# PRD: <name>

## 1. Summary
## 2. Problem
## 3. Goals
## 4. Non-goals
## 5. Target users
## 6. Use cases
## 7. Requirements — Must have / Should have / Could have
## 8. Workflow
## 9. Dependencies and constraints
## 10. Success metrics
## 11. Risks and open questions
## 12. Recommended next action
```

**Every line traces to a settled decision or is marked as an assumption.** An invented
requirement reads exactly like a decided one, which is why the mark matters — and why a PRD
that hides its assumptions is worse than no PRD.
