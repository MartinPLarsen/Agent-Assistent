#!/usr/bin/env bash
set -euo pipefail

# Bootstrap for the agent starter kit.
#
#   ./setup.sh                 check tools, detach template git history, link skills, launch
#   ./setup.sh --link-skills   only refresh the skill symlinks (safe to re-run any time)
#   ./setup.sh --check         run the tool check and stop
#   ./setup.sh --no-launch     do everything except starting the agent

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

have() { command -v "$1" >/dev/null 2>&1; }
ask()  { local r; read -r -p "$1 [y/N] " r; case "$r" in [yY]*) return 0 ;; *) return 1 ;; esac; }

# Which runtime we hand over to at the end. Set by preflight.
RUNTIME=""

# Claude Code installs itself into ~/.local/bin. Its installer does not always put that
# directory on the PATH of *future* shells, so the kit starts fine once and then the next
# terminal answers "zsh: command not found: claude". Fix it where it is fixable: this
# shell now, and the shell profile so tomorrow's terminal agrees.
persist_local_bin() {
  [ -x "$HOME/.local/bin/claude" ] || return 0
  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

  local rc line='export PATH="$HOME/.local/bin:$PATH"'
  case "${SHELL##*/}" in bash) rc="$HOME/.bash_profile" ;; *) rc="$HOME/.zshrc" ;; esac
  grep -qF "$line" "$rc" 2>/dev/null && return 0

  printf '\n# Added by the assistant kit so new terminals can find claude\n%s\n' "$line" >> "$rc"
  echo "     Added ~/.local/bin to your PATH in $rc — new terminals will find claude."
}

# Node is only needed by the brain engine (scripts/brain.mjs). Without it the assistant
# reads wiki/index.md itself — slower, same answers — so a missing Node is a warning,
# never a stop. Claude Code itself ships as a native binary and needs no Node.
node_ok() {
  have node || return 1
  [ "$(node -p 'parseInt(process.versions.node, 10)' 2>/dev/null || echo 0)" -ge 18 ]
}

preflight() {
  local blocked=0
  echo
  echo "  Checking what this machine has:"
  echo

  if have git; then
    printf '  %-22s %s\n' "git" "ok"
  else
    printf '  %-22s %s\n' "git" "MISSING"
    echo "     Run this, let it finish, then run ./setup.sh again:"
    echo "       xcode-select --install"
    blocked=1
  fi

  if have claude; then
    RUNTIME=claude
    printf '  %-22s %s\n' "claude (Claude Code)" "ok"
    persist_local_bin
  elif have codex; then
    RUNTIME=codex
    printf '  %-22s %s\n' "codex (Codex CLI)" "ok"
  else
    printf '  %-22s %s\n' "agent runtime" "MISSING"
    echo "     You need Claude Code or Codex CLI. Claude Code is the one this kit is built for."
    if ask "     Install Claude Code now (downloads from claude.ai)?"; then
      curl -fsSL https://claude.ai/install.sh | bash
      # The installer puts the binary in ~/.local/bin, which this shell and every later
      # one may not know about yet. persist_local_bin fixes both.
      persist_local_bin
      if have claude; then
        RUNTIME=claude
        printf '  %-22s %s\n' "claude (Claude Code)" "installed"
      else
        echo "     Install finished but 'claude' is still not on PATH. Open a new terminal and re-run ./setup.sh."
        blocked=1
      fi
    else
      echo "     Install it yourself with:  curl -fsSL https://claude.ai/install.sh | bash"
      blocked=1
    fi
  fi

  if node_ok; then
    printf '  %-22s %s\n' "node 18+" "ok"
  else
    printf '  %-22s %s\n' "node 18+" "missing — optional"
    echo "     Without it the second brain still works, just slower. To add it:"
    if have brew; then
      echo "       brew install node"
    else
      echo "       Download the LTS installer from https://nodejs.org"
    fi
  fi

  if have python3; then
    printf '  %-22s %s\n' "python3" "ok"
  else
    printf '  %-22s %s\n' "python3" "missing — optional"
    echo "     Only ./scripts/check.sh needs it. 'xcode-select --install' provides it."
  fi

  echo
  if [ "$blocked" -eq 1 ]; then
    echo "  Fix the MISSING lines above, then run ./setup.sh again."
    exit 1
  fi
  echo "  Everything required is in place."
}

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

if [ "${1:-}" = "--check" ]; then
  preflight
  exit 0
fi

preflight

# Detach from the template's history so the user's agent gets its own repo.
# Only fires when the remote still points at the template — never on a repo
# the user has already made theirs.
# Both names are matched on purpose: the repo was renamed from agent-starter-kit to
# Agent-Assistent on 2026-08-16, and clones taken before that still carry the old remote.
if git -C "$KIT_DIR" remote get-url origin 2>/dev/null | grep -qiE "agent-starter-kit|Agent-Assistent"; then
  echo "This repo still points at the template:"
  echo "  $(git -C "$KIT_DIR" remote get-url origin)"
  echo
  read -r -p "Detach and start a fresh git history? [y/N] " reply
  case "$reply" in
    [yY]*)
      mv "$KIT_DIR/.git" "$KIT_DIR/.git-template-backup"
      git -C "$KIT_DIR" init -q
      git -C "$KIT_DIR" add .
      git -C "$KIT_DIR" commit -q -m "chore: initial commit from the assistant template"
      echo "Fresh history created. The old one is in .git-template-backup — delete it when you are happy."
      ;;
    *)
      echo "Left as is."
      ;;
  esac
fi

link_skills

cat <<'EOF'

  Kit is ready. Starting your assistant now.

  It reads AGENTS.md, sees setup is unfinished, and walks you through nine
  short phases. Budget 25-35 minutes. You can stop after any phase and pick
  it back up later. To leave, type /exit — then run ./setup.sh again to return.

EOF

if [ "${1:-}" = "--no-launch" ]; then
  echo "  --no-launch given. Start it yourself with: $RUNTIME"
  echo
  exit 0
fi

cd "$KIT_DIR"
exec "$RUNTIME"
