#!/usr/bin/env bash
# SessionStart hook — wired into .claude/settings.local.json.
#
# Claude Code loads CLAUDE.md automatically but not AGENTS.md, so "read AGENTS.md,
# see setup is unfinished, run the wizard" depended on the model choosing to follow
# a pointer. It often didn't. This makes the gate deterministic: stdout from a
# SessionStart hook is injected into the session as context before the first reply.
#
# Once .setup-state.json says completed, this prints nothing and the wizard never
# fires again.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Optional arg is a state file to read instead of the real one — scripts/check.sh
# uses it to test both branches without touching the shipped state.
STATE="${1:-$KIT_DIR/.setup-state.json}"

# ponytail: grep, not jq — one boolean, and jq is not guaranteed to be installed
if [ -f "$STATE" ] && grep -Eq '"completed"[[:space:]]*:[[:space:]]*true' "$STATE"; then
  exit 0
fi

cat <<'EOF'
SETUP IS NOT COMPLETE — this agent has not been configured yet.

Before answering anything else, read `setup/README.md` and run the setup wizard from
`.setup-state.json`'s `current_phase`. One question at a time, recommend a default for
each. Do not start on any other request until the wizard reaches phase 7 and sets
`completed: true`.

If the user explicitly says they want to skip or postpone setup, respect that and stop
asking for the rest of the session.
EOF
