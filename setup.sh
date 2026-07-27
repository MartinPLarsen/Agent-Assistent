#!/usr/bin/env bash
set -euo pipefail

# Bootstrap for the agent starter kit.
#
#   ./setup.sh                 detach template git history, link skills, print next step
#   ./setup.sh --link-skills   only refresh the skill symlinks (safe to re-run any time)

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_skills() {
  # Claude Code discovers skills in .claude/skills/. The canonical copies live in
  # skills/, so each one gets a symlink. Other runtimes read skills/ directly.
  mkdir -p "$KIT_DIR/.claude/skills"

  # Drop links whose skill is gone, otherwise a deleted skill stays discoverable
  # and the agent loads instructions for something that no longer exists.
  for link in "$KIT_DIR"/.claude/skills/*; do
    [ -L "$link" ] || continue
    [ -e "$link" ] || { rm "$link"; echo "Removed dead link: $(basename "$link")"; }
  done

  local n=0
  for dir in "$KIT_DIR"/skills/*/; do
    [ -f "${dir}SKILL.md" ] || continue
    local name
    name="$(basename "$dir")"
    # ponytail: ln -sfn replaces atomically, no unlink-then-link race
    ln -sfn "../../skills/$name" "$KIT_DIR/.claude/skills/$name"
    n=$((n + 1))
  done
  echo "Linked $n skill(s) into .claude/skills/"
}

if [ "${1:-}" = "--link-skills" ]; then
  link_skills
  exit 0
fi

# Detach from the template's history so the user's agent gets its own repo.
# Only fires when the remote still points at the template — never on a repo
# the user has already made theirs.
if git -C "$KIT_DIR" remote get-url origin 2>/dev/null | grep -q "agent-starter-kit"; then
  echo "This repo still points at the template:"
  echo "  $(git -C "$KIT_DIR" remote get-url origin)"
  echo
  read -r -p "Detach and start a fresh git history? [y/N] " reply
  case "$reply" in
    [yY]*)
      mv "$KIT_DIR/.git" "$KIT_DIR/.git-template-backup"
      git -C "$KIT_DIR" init -q
      git -C "$KIT_DIR" add .
      git -C "$KIT_DIR" commit -q -m "chore: initial commit from agent starter kit"
      echo "Fresh history created. The old one is in .git-template-backup — delete it when you are happy."
      ;;
    *)
      echo "Left as is."
      ;;
  esac
fi

link_skills

cat <<'EOF'

  Kit is ready. Next step: open it in your agent runtime.

      claude          (Claude Code)
      codex           (Codex CLI)

  It reads AGENTS.md, sees setup is unfinished, and walks you through eight
  short phases. Budget 20-30 minutes. You can stop after any phase and pick
  it back up later.

EOF
