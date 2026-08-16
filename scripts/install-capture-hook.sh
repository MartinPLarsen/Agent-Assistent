#!/usr/bin/env bash
# Wire the machine-wide session capture into ~/.claude/settings.json.
#
#   scripts/install-capture-hook.sh <brain-path>
#   scripts/install-capture-hook.sh --uninstall
#   scripts/install-capture-hook.sh --status
#
# This is the only thing the kit writes outside its own folder, and the only reason it has
# to: a hook in .claude/settings.local.json fires only for sessions opened in THIS project,
# so it would capture the assistant talking about work and never the work itself.
#
# Idempotent. Backs the file up before touching it. Prints exactly what it changed.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"
CAPTURE="$KIT_DIR/scripts/capture-session.sh"

mode="install"
case "${1:-}" in
  --uninstall) mode="uninstall" ;;
  --status)    mode="status" ;;
  "")          echo "usage: install-capture-hook.sh <brain-path> | --uninstall | --status" >&2; exit 2 ;;
  *)           BRAIN="$(cd "$1" && pwd)" ;;
esac

if [ "$mode" = "install" ]; then
  [ -x "$CAPTURE" ] || chmod +x "$CAPTURE"
  QUEUE="$BRAIN/.harvest-queue.jsonl"
  # The queue is runtime, not knowledge. Keep it out of the brain's history.
  if [ -d "$BRAIN/.git" ] && ! grep -qxF '.harvest-queue.jsonl' "$BRAIN/.gitignore" 2>/dev/null; then
    echo '.harvest-queue.jsonl' >> "$BRAIN/.gitignore"
    echo "added .harvest-queue.jsonl to $BRAIN/.gitignore"
  fi
fi

mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak"

python3 - "$SETTINGS" "$mode" "$CAPTURE" "${QUEUE:-}" <<'PY'
import json, sys

settings_path, mode, capture, queue = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.setdefault("hooks", {})
session_end = hooks.setdefault("SessionEnd", [])

def is_ours(entry):
    return any(capture in (h.get("command") or "") for h in entry.get("hooks", []))

existing = [e for e in session_end if is_ours(e)]

if mode == "status":
    print(f"installed: {bool(existing)}")
    for e in existing:
        for h in e.get("hooks", []):
            print(f"  {h.get('command')}")
    sys.exit(0)

if mode == "uninstall":
    if not existing:
        print("not installed — nothing to remove")
        sys.exit(0)
    hooks["SessionEnd"] = [e for e in session_end if not is_ours(e)]
    # Leave no empty scaffolding behind; an empty SessionEnd array reads as configuration
    # someone chose, which is a lie once the hook is gone.
    if not hooks["SessionEnd"]:
        del hooks["SessionEnd"]
    if not hooks:
        del settings["hooks"]
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    print(f"removed {len(existing)} capture hook(s) from {settings_path}")
    sys.exit(0)

command = f'"{capture}" "{queue}"'
if existing:
    # Re-running after the brain moved should repoint, not stack up a second hook.
    for e in existing:
        for h in e.get("hooks", []):
            if capture in (h.get("command") or ""):
                h["command"] = command
    action = "updated"
else:
    session_end.append({"hooks": [{"type": "command", "command": command}]})
    action = "installed"

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
print(f"{action} SessionEnd capture hook in {settings_path}")
print(f"  command: {command}")
PY

if [ "$mode" = "install" ]; then
  echo "backup: $SETTINGS.bak"
  echo "remove it again with: scripts/install-capture-hook.sh --uninstall"
fi
