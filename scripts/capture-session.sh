#!/usr/bin/env bash
# SessionEnd hook body. Installed by scripts/install-capture-hook.sh, which passes the
# queue path as $1 so this script needs no config of its own.
#
# Records that a session ended, where, and where its transcript is. Not the contents.
# The daily harvest reads the queue and decides what is worth writing into the brain.
#
# Runs on every Claude Code session on the machine, including ones that have nothing to do
# with the assistant. So: never fail loudly, never block the exit, never write anything but
# one line.

set -uo pipefail

QUEUE="${1:?install-capture-hook.sh passes the queue path}"

mkdir -p "$(dirname "$QUEUE")" 2>/dev/null || exit 0

# The hook payload is JSON on stdin. It is passed to python as a stream and never through
# the shell — interpolating it into a heredoc would let a path containing a quote break out
# of the program, and the payload includes a cwd we do not control.
python3 -c '
import json, sys, os, datetime
queue = sys.argv[1]
try:
    data = json.load(sys.stdin)
except Exception:
    data = {}
row = {
    "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
    "cwd": data.get("cwd") or os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd(),
    "transcript_path": data.get("transcript_path"),
    "reason": data.get("reason"),
}
with open(queue, "a") as f:
    f.write(json.dumps(row, ensure_ascii=False) + "\n")
' "$QUEUE" 2>/dev/null

exit 0
