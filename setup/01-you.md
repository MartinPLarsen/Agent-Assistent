# Phase 1 — Who the user is

Phase 0 told you what they work on. This phase is about how they want to be worked with.
Keep it short: four questions, and you already know enough to make three of them
confirmations rather than open asks.

## Open

> "Nu ved jeg nogenlunde hvad du arbejder med. Lad mig lære hvordan du vil arbejde."

## Questions

One at a time. Wait for each answer.

1. **Name and role.** "Hvad hedder du, og hvad laver du?" You may already be able to guess
   the role from the harvest — if so, offer it: *"Ud fra dine repos ser det ud til du
   bygger web og automation. Passer det?"*

2. **Timezone.** Offer the machine's own setting rather than asking cold:
   ```bash
   readlink /etc/localtime | sed 's|.*zoneinfo/||'
   ```
   *"Din maskine står på Europe/Copenhagen. Er det din tidszone?"*

3. **Languages.** Conversation language and code language are separate questions with one
   answer for most people. *"Dansk i samtale, engelsk i kode og docs?"*

4. **How they want to be talked to.** "Kort og direkte, eller mere uddybende?" Listen for
   more than the literal answer — someone who writes long, exploratory messages and asks
   for "kort" wants short *replies*, not short thinking.

## One more, worth asking

5. **What drains them.** "Hvad er den slags arbejde du helst vil slippe for?"

This is the single most useful answer in the whole wizard. It tells you what to take over
without being asked, which is most of what separates an assistant from a chatbot. Write it
down verbatim.

## Infer, don't interrogate

Work these out rather than asking:

- **Technical level** — from the harvest and how they describe their work. Someone with
  Docker and a Supabase CLI does not need Postgres explained. Someone with three no-code
  exports does.
- **Whether they work alone** — repos with one committer versus many.
- **Whether work and personal are separate** — the git identities from phase 0.

Asking someone to rate their own technical level gets you their self-image, not their
level.

## Output

`USER.md` from `setup/templates/USER.md`, fully filled in — no placeholders left. Include
what they said drains them, in their own words.

Merge into `.setup-state.json`:

```json
{ "current_phase": 2, "steps_completed": ["phase_0", "phase_1"] }
```

Then: *"Nu kender jeg dig. Hvem skal jeg være?"*
