---
name: capture-skill
description: Use at the end of any task where something non-obvious was learned — a gotcha, an API quirk, a workflow that took real effort to get right, a sequence worth repeating. Drafts a new skill or updates an existing one, then asks before saving. This is how the library grows.
---

# Capture a skill

An assistant that ends every month knowing exactly what it knew at the start is a tool. An
assistant whose library grows from its own work compounds. This skill is the mechanism.

Fire it yourself. Nobody is going to say "please write that down".

## The bar

One question: **would a future session waste real time rediscovering this?**

Yes:

- an API that behaves differently from its documentation
- a sequence that only works in one order, and the order is not obvious
- a fix that took more than a few attempts to find
- a workflow with a step that is easy to skip and expensive to skip

No:

- anything the README, the code, or `--help` already says
- a one-off fix for a one-off situation
- something you already had to look up and got right first time

When in doubt, ask whether you would have wanted this file an hour ago.

## Skill or fact?

Both persist. They are for different things.

| | Fact (`memory/facts/`) | Skill (`skills/`) |
|---|---|---|
| Shape | something that is true | something to do |
| Length | a paragraph | a procedure |
| Read | when the description matches | when the task matches |

"Supabase revokes do not apply to PUBLIC" is a fact. "How to harden a Supabase project"
is a skill. If it has steps and an order, it is a skill. If it is a thing you need to know
before acting, it is a fact. Write the fact first — it is cheaper, and most learnings stop
there.

## Check for an existing one

Before writing anything new, look through `skills/` for one that already covers the
territory. Extending an existing skill beats adding a neighbour that competes with it for
the same trigger. Two skills whose descriptions overlap means whichever gets loaded is
effectively random.

## Draft it

`skills/<name>/SKILL.md`:

```markdown
---
name: <kebab-case>
description: Use when <the situation, in the words someone would actually use>. <What it does.>
---

# <Title>

<Why this exists — the failure it prevents, in two lines.>

## <The procedure>

<Steps, in order, with the non-obvious parts called out.>

## What goes wrong

<The specific failure modes and how to recognise them.>
```

The `description` is the only part the runtime reads when deciding whether to load it. It
must name the *situation*, not the capability. "Use when the Telegram bot stops receiving
messages" gets loaded; "Telegram troubleshooting utilities" does not.

Write the failure modes down. That is the part nobody remembers and the part that saves the
hour.

## Then ask

**Never save without asking.** Show the draft and ask whether to keep it, in one message.

> "Jeg har skrevet [navn] ud fra det her. Skal den gemmes?"

The library is the user's, not yours. A folder that fills up with skills nobody approved is
one nobody trusts, and an untrusted library gets ignored wholesale.

## After saving

```bash
./setup.sh --link-skills
```

Then add it to the skills table in `AGENTS.md`, and check that its description does not
collide with an existing one. A new description can quietly steal a neighbour's triggers,
and the symptom is the wrong skill loading for a month before anyone works out why.
