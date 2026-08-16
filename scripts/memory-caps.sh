#!/usr/bin/env bash
# Enforce the memory caps. Runs from a hook, not from the assistant remembering to.
#
#   scripts/memory-caps.sh          trim what is over, report what it did
#   scripts/memory-caps.sh --check  report only, exit 1 if anything is over
#
# AGENTS.md and skills/memory/SKILL.md both document these caps. Documenting a cap is not
# enforcing one: the previous version asked the model to trim on every write, which works
# right up until a session is busy, and then the index quietly grows until it stops being
# loadable at all. This script is the owner of those numbers.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEM="$KIT_DIR/memory"

SESSION_LOG="$MEM/session.log.md"
INDEX="$MEM/MEMORY.md"
CONVO="$MEM/convo_log.md"

SESSION_MAX_BYTES=$((100 * 1024))
SESSION_MAX_HOURS=48
INDEX_MAX_BYTES=$((24 * 1024))
CONVO_MAX_LINES=40

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

over=0
note() { printf '%s\n' "$1"; }
breach() { note "OVER — $1"; over=1; }

size_of() { [ -f "$1" ] && wc -c < "$1" | tr -d ' ' || echo 0; }

# --- session.log.md: 48 hours, and 100KB as a backstop ------------------------
#
# Entries are `## YYYY-MM-DDTHH:MMZ` newest-first, so the cut point is the first entry
# older than the window and everything below it goes. Trimming by age rather than by count
# is what lets a quiet week and a busy one both behave.
trim_session_log() {
  [ -f "$SESSION_LOG" ] || return 0
  local bytes cutoff
  bytes="$(size_of "$SESSION_LOG")"
  cutoff="$(date -u -v-${SESSION_MAX_HOURS}H +%Y-%m-%dT%H:%MZ 2>/dev/null \
            || date -u -d "-${SESSION_MAX_HOURS} hours" +%Y-%m-%dT%H:%MZ)"

  local oldest
  oldest="$(grep -m1 -oE '^## [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}Z' "$SESSION_LOG" | tail -1 | cut -d' ' -f2 || true)"

  if [ "$bytes" -le "$SESSION_MAX_BYTES" ] && [ -z "$(find_old_entries "$cutoff")" ]; then
    note "session.log.md ok (${bytes} bytes)"
    return 0
  fi

  breach "session.log.md: ${bytes} bytes, entries older than ${SESSION_MAX_HOURS}h present"
  [ "$CHECK_ONLY" -eq 1 ] && return 0

  # Keep the header (everything before the first entry) plus every entry newer than cutoff.
  python3 - "$SESSION_LOG" "$cutoff" "$SESSION_MAX_BYTES" <<'PY'
import re, sys
path, cutoff, max_bytes = sys.argv[1], sys.argv[2], int(sys.argv[3])
text = open(path).read()
parts = re.split(r'(?m)^(## \d{4}-\d{2}-\d{2}T\d{2}:\d{2}Z)$', text)
header, kept = parts[0], []
for stamp, body in zip(parts[1::2], parts[2::2]):
    if stamp[3:] >= cutoff:          # ISO stamps compare correctly as strings
        kept.append(stamp + body)
out = header + ''.join(kept)
while len(out.encode()) > max_bytes and kept:   # backstop: drop oldest until under cap
    kept.pop()
    out = header + ''.join(kept)
open(path, 'w').write(out)
print(f"  trimmed to {len(kept)} entries, {len(out.encode())} bytes")
PY
}

find_old_entries() {
  [ -f "$SESSION_LOG" ] || return 0
  awk -v cutoff="$1" '/^## [0-9]{4}-/ { stamp = substr($0, 4); if (stamp < cutoff) print stamp }' "$SESSION_LOG"
}

# --- MEMORY.md: 24KB ---------------------------------------------------------
#
# Never trimmed automatically. The index is one line per fact, so cutting it silently
# deletes the only pointer to a fact file — the fact survives and becomes unreachable,
# which is worse than a big index. This one reports and stops.
check_index() {
  [ -f "$INDEX" ] || { note "MEMORY.md missing"; return 0; }
  local bytes; bytes="$(size_of "$INDEX")"
  if [ "$bytes" -gt "$INDEX_MAX_BYTES" ]; then
    breach "MEMORY.md: ${bytes} bytes, cap ${INDEX_MAX_BYTES}. Shorten index lines or merge facts — do NOT delete lines without merging the fact files first."
  else
    note "MEMORY.md ok (${bytes} bytes)"
  fi

  # Orphans in either direction are invisible to recall.
  local missing=0
  while IFS= read -r target; do
    [ -f "$MEM/$target" ] || { breach "MEMORY.md points at a missing fact: $target"; missing=1; }
  done < <(grep -oE '\]\(facts/[^)]+\)' "$INDEX" 2>/dev/null | sed 's/^](//;s/)$//' || true)

  if [ -d "$MEM/facts" ]; then
    for f in "$MEM"/facts/*.md; do
      [ -e "$f" ] || continue
      grep -q "facts/$(basename "$f")" "$INDEX" || breach "fact has no index line: $(basename "$f")"
    done
  fi
  [ "$missing" -eq 0 ] || true
}

# --- convo_log.md: 40 lines --------------------------------------------------
#
# Only the latest session is kept, so the cut is at the second `## ` heading rather than
# at line 40 — cutting mid-session leaves a log that reads as if work was abandoned.
trim_convo_log() {
  [ -f "$CONVO" ] || { note "convo_log.md missing"; return 0; }
  local lines; lines="$(wc -l < "$CONVO" | tr -d ' ')"
  if [ "$lines" -le "$CONVO_MAX_LINES" ]; then
    note "convo_log.md ok (${lines} lines)"
    return 0
  fi
  breach "convo_log.md: ${lines} lines, cap ${CONVO_MAX_LINES}"
  [ "$CHECK_ONLY" -eq 1 ] && return 0

  python3 - "$CONVO" "$CONVO_MAX_LINES" <<'PY'
import re, sys
path, cap = sys.argv[1], int(sys.argv[2])
lines = open(path).read().split('\n')
starts = [i for i, l in enumerate(lines) if re.match(r'^## ', l)]
if len(starts) > 1:
    kept = lines[:starts[1]]                 # header + newest session only
    open(path, 'w').write('\n'.join(kept).rstrip() + '\n')
    print(f"  dropped {len(starts)-1} older session(s), now {len(kept)} lines")
else:
    print(f"  one session and still over cap ({len(lines)} lines) — shorten it by hand, "
          f"cutting mid-session would lose the end of it")
PY
}

trim_session_log
check_index
trim_convo_log

echo
if [ "$over" -eq 0 ]; then
  echo "All caps hold."
else
  [ "$CHECK_ONLY" -eq 1 ] && echo "Caps breached (check only, nothing changed)." || echo "Caps enforced."
fi
exit "$over"
