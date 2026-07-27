# Phase 0 — Harvest

Read the machine before asking the user anything. Two minutes of looking beats twenty
minutes of interview, and it is the difference between an assistant that knows the user's
work and one that only knows their answers about it.

Everything here is read-only. Nothing leaves the machine.

## Step 0 — Language

One bilingual line, because you do not know yet:

> "Hi! Before we start — **Dansk eller English?** 👋"

Store the answer as `language` in `.setup-state.json`. Everything after this, including
the files you generate, is in that language. Code and technical docs stay English.

## Step 1 — Look

Run these. They are all read-only and fast.

```bash
# Where the user's work lives
for d in ~/Desktop ~/Documents ~/Projects ~/code ~/src; do
  [ -d "$d" ] && find "$d" -maxdepth 3 -name .git -type d 2>/dev/null | sed 's|/.git$||'
done

# Who they are to git, globally
git config --global user.name; git config --global user.email

# What is installed
for c in gh node python3 docker supabase vercel trigger codex claude ffmpeg; do
  command -v "$c" >/dev/null && echo "$c: yes" || echo "$c: no"
done
```

For each repo found, gather cheaply: the origin remote, the date of the last commit, the
dominant language, the first paragraph of the README, whether it has a `CLAUDE.md` or
`AGENTS.md`, and its local `user.email` if it overrides the global one.

```bash
cd "<repo>" && git log -1 --format=%cs && git remote get-url origin 2>/dev/null
git config user.email   # empty means it inherits the global identity
```

A repo with its own `user.email` means the user has separate work and personal identities.
That is worth knowing and they will rarely think to tell you.

Then, only if the runtime already has them connected, list the *names* of things — never
their contents: Linear teams, calendar names, mail labels. If nothing is connected, skip
it; phase 4 handles connectors.

## Step 2 — Sort

Sort the repos by last commit date. Anything untouched for six months is dormant; say so
rather than listing it as current work. Group by stack where it is obvious — three
Next.js repos with a Supabase dependency are one working context, not three facts.

## Step 3 — Show it and be corrected

Write `CONTEXT.md` from the template, then show a short summary and ask one question:

> "Jeg har kigget på maskinen. Sådan her ser dit arbejde ud:
>
> Aktive projekter: [3–6 navne med én linje hver]
> Stacks: [det du faktisk fandt]
> To git-identiteter: [x@y] privat, [a@b] arbejde
>
> Passer det, eller mangler der noget vigtigt?"

Their correction is the valuable part. Fold it into `CONTEXT.md` before moving on.

## What not to do

- Do not read source files. Repo names, READMEs, and git metadata are enough.
- Do not read mail, calendar entries, or issue contents. Names only.
- Do not touch anything outside the user's home directory.
- Do not guess a project's purpose from its folder name. If the README does not say, write
  "unknown" and let the user fill it in.

## Output

`CONTEXT.md` from `setup/templates/CONTEXT.md`. Then merge into `.setup-state.json`:

```json
{ "current_phase": 1, "language": "<da|en>", "steps_completed": ["phase_0"] }
```

`CONTEXT.md` is re-runnable later: when the user says "harvest" or "opdater kontekst",
run this phase again and rewrite the file.
