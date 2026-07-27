#!/usr/bin/env bash
# Codex [notify] hook — runs when an agent session ends.
# Wired into ~/.codex/config.toml as: [notify] command = "<KIT>/scripts/on-stop.sh"
#
# What it does: appends a one-line stop marker to memory/session.log.md so the
# next session can see when the previous one ended.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$KIT_DIR/memory/session.log.md"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%MZ)"

if [ ! -f "$LOG" ]; then
  echo "session.log.md missing at $LOG — skipping notify" >&2
  exit 0
fi

# Insert the stop marker after the header comments (line 5) so it appears at the top of the log
TMPFILE="$(mktemp)"
{
  head -n 5 "$LOG"
  echo ""
  echo "## $TIMESTAMP"
  echo "Session ended."
  tail -n +6 "$LOG"
} > "$TMPFILE"
mv "$TMPFILE" "$LOG"
