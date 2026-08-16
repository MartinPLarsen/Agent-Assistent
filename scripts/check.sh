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

# The wizard gate speaks when setup is unfinished and shuts up when it is done
begin
echo '{"completed": false}' > /tmp/kit-unfinished.$$
echo '{"completed": true}'  > /tmp/kit-finished.$$
scripts/session-start.sh /tmp/kit-unfinished.$$ | grep -q "SETUP IS NOT COMPLETE" \
  || bad "session-start.sh" "silent while setup is unfinished"
[ -z "$(scripts/session-start.sh /tmp/kit-finished.$$)" ] \
  || bad "session-start.sh" "still speaks after completed: true"
rm -f /tmp/kit-unfinished.$$ /tmp/kit-finished.$$
done_ok "wizard gate fires only before setup completes"

# Setup phases form an unbroken chain
python3 - <<'PY' || fail=1
import pathlib, sys
bad = [i for i in range(8)
       if f'"current_phase": {i+1}' not in next(pathlib.Path("setup").glob(f"0{i}-*.md")).read_text()]
if bad:
    print(f"setup phases do not advance: {bad}")
    sys.exit(1)
PY
say "setup phase chain intact" "ok"

# The brain engine's own selftest. It builds a brain in a temp dir, stores, recalls, and
# asserts the parts that are easy to get subtly wrong — a duplicated index line, a recall
# that returns the page title instead of the answer.
begin
if command -v node >/dev/null 2>&1; then
  node scripts/brain.mjs selftest >/dev/null 2>&1 || bad "brain.mjs" "selftest failed"
  done_ok "brain engine selftest"
else
  say "brain engine selftest" "skipped — no node"
fi

# Every script the brain phase tells the user to run must exist and be executable. A phase
# that names a missing script fails in front of the user, mid-setup, which is the worst
# possible moment to discover it.
begin
for s in scripts/brain.mjs scripts/memory-caps.sh scripts/install-capture-hook.sh scripts/capture-session.sh; do
  [ -f "$s" ] || bad "$s" "referenced by setup/07-brain.md but missing"
  [ -x "$s" ] || bad "$s" "not executable"
done
done_ok "brain phase scripts exist and are executable"

# The capture hook is the only thing this kit writes outside its own folder, so the path
# that removes it again matters as much as the one that installs it. Round-trip it against
# a throwaway settings file and confirm nothing of the user's survives or is lost.
begin
sandbox="$(mktemp -d)"
printf '{"model":"x","hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"echo keep-me"}]}]}}' > "$sandbox/settings.json"
CLAUDE_SETTINGS="$sandbox/settings.json" scripts/install-capture-hook.sh "$sandbox" >/dev/null 2>&1 \
  || bad "install-capture-hook.sh" "install failed"
CLAUDE_SETTINGS="$sandbox/settings.json" scripts/install-capture-hook.sh "$sandbox" >/dev/null 2>&1 \
  || bad "install-capture-hook.sh" "second install failed"
python3 -c "
import json,sys
d=json.load(open('$sandbox/settings.json'))
n=len(d.get('hooks',{}).get('SessionEnd',[]))
sys.exit(0 if n==1 else 1)" || bad "install-capture-hook.sh" "not idempotent — stacked duplicate hooks"
CLAUDE_SETTINGS="$sandbox/settings.json" scripts/install-capture-hook.sh --uninstall >/dev/null 2>&1 \
  || bad "install-capture-hook.sh" "uninstall failed"
python3 -c "
import json,sys
d=json.load(open('$sandbox/settings.json'))
ok = 'SessionEnd' not in d.get('hooks',{}) and d.get('model')=='x' \
     and len(d.get('hooks',{}).get('SessionStart',[]))==1
sys.exit(0 if ok else 1)" || bad "install-capture-hook.sh" "uninstall did not restore the file cleanly"
rm -rf "$sandbox"
done_ok "capture hook installs, is idempotent, and uninstalls cleanly"

echo
[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Some checks failed."
exit "$fail"
