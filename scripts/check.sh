#!/usr/bin/env bash
# Consistency check for the kit itself. Run after editing skills, watchers, or setup
# phases. Catches the class of bug where a file references something that does not
# exist — which reads as working right up until the moment it matters.
#
#   ./scripts/check.sh
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

fail=0
say() { printf '%-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL — $2"; fail=1; }

# Only report a check green if nothing inside it failed. Without this a failing
# check still prints "ok" on the next line, which is worse than no check at all.
mark=0
begin() { mark=$fail; }
done_ok() { [ "$fail" -eq "$mark" ] && say "$1" "ok"; }

# Shell scripts parse
begin
for s in setup.sh scripts/*.sh; do
  bash -n "$s" 2>/dev/null || bad "$s" "syntax error"
done
done_ok "shell scripts parse"

# Shipped JSON parses
begin
for j in .setup-state.json .mcp.json .claude/settings.local.json; do
  python3 -c "import json;json.load(open('$j'))" 2>/dev/null || bad "$j" "invalid JSON"
done
done_ok "shipped JSON parses"

# The template must not ship with the guardrails off
if grep -q bypassPermissions .claude/settings.local.json; then
  bad "settings.local.json" "ships bypassPermissions"
else
  say "permissions are not bypassed" "ok"
fi

# Every skill in the AGENTS.md table exists, and every skill on disk is in the table
grep -oE '^\| `[a-z-]+` ' AGENTS.md | tr -d '|` ' | sort > /tmp/kit-table.$$
find skills -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort > /tmp/kit-disk.$$
if diff -q /tmp/kit-table.$$ /tmp/kit-disk.$$ >/dev/null; then
  say "AGENTS.md skills table matches disk" "ok"
else
  bad "AGENTS.md skills table" "$(diff /tmp/kit-table.$$ /tmp/kit-disk.$$ | tr '\n' ' ')"
fi
rm -f /tmp/kit-table.$$ /tmp/kit-disk.$$

# Every skill has frontmatter with a description — without it, it never loads
begin
for d in skills/*/; do
  head -5 "${d}SKILL.md" | grep -q '^description:' || bad "${d}SKILL.md" "no description in frontmatter"
done
done_ok "skills have descriptions"

# Every watcher declares the fields the runner reads
begin
for w in watchers/*.md; do
  for field in id source model cooldown; do
    head -8 "$w" | grep -q "^$field:" || bad "$w" "missing '$field'"
  done
done
done_ok "watchers declare id/source/model/cooldown"

# Anything the watchers read must be written by someone
begin
grep -q "session.log.md" AGENTS.md || bad "AGENTS.md" "no rule writes session.log.md, which every watcher reads"
done_ok "session.log.md has a writer"

# Setup phases form an unbroken chain
python3 - <<'PY' || fail=1
import pathlib, sys
bad = [i for i in range(7)
       if f'"current_phase": {i+1}' not in next(pathlib.Path("setup").glob(f"0{i}-*.md")).read_text()]
if bad:
    print(f"setup phases do not advance: {bad}")
    sys.exit(1)
PY
say "setup phase chain intact" "ok"

echo
[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Some checks failed."
exit "$fail"
