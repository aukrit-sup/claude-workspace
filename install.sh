#!/usr/bin/env bash
# install.sh — install this Claude Code toolkit into a target workspace
#
# Usage:  ./install.sh <target-workspace-dir> [git-remote-url] [branch]
# e.g.:   ./install.sh ~/projects/my-frontend
#         ./install.sh ~/projects/app git@github.com:me/app.git main
#         bash install.sh "D:/work/backend"      # Windows / Git Bash
#         bash install.sh                         # no args -> prompts for path (+ optional remote)
#
# The remote/branch are optional — skip them here and wire them up later with
#   git remote add origin <url> && git branch -M <branch> && git push -u origin <branch>
#
# Copies only the template parts (agents/commands/skills/hooks/settings/CLAUDE.md).
# Skips per-project runtime: reports/, blueprint.md, README.md, .git
# The hook in settings.json uses $CLAUDE_PROJECT_DIR, so it is portable — no path rewrite needed.

set -euo pipefail

# 1) source = the directory this script lives in (resolved no matter where it's run from)
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2) inputs: target (required), remote + branch (optional). Prompt only when run with no args.
TARGET="${1:-}"
REMOTE="${2:-}"
BRANCH="${3:-main}"
INTERACTIVE=0
if [ -z "$TARGET" ]; then
  INTERACTIVE=1
  read -r -p "Enter target workspace path: " TARGET || true   # || true: EOF must not abort under set -e
fi
TARGET="${TARGET/#\~/$HOME}"   # expand a leading ~ (read does not expand it)
if [ -z "$TARGET" ]; then
  echo "No target given — aborting." >&2
  exit 1
fi
# interactive: optionally ask for a remote now (Enter to skip and set it later)
if [ "$INTERACTIVE" = 1 ] && [ -z "$REMOTE" ]; then
  read -r -p "Git remote URL (optional, Enter to skip): " REMOTE || true
  if [ -n "$REMOTE" ]; then
    read -r -p "Branch name [main]: " _b || true
    BRANCH="${_b:-main}"
  fi
fi
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"   # normalize to an absolute path

if [ "$TARGET" = "$SRC" ]; then
  echo "Target must not be the toolkit repo itself ($SRC)" >&2
  exit 1
fi

echo "Installing toolkit"
echo "  from: $SRC"
echo "  to  : $TARGET"

# 3) back up an existing .claude as a whole if present (safety net before overwriting)
# ponytail: back up the whole folder once = simple and rollback-able; if the repo grows large enough
# that this is expensive, switch to backing up only settings.json + CLAUDE.md
if [ -e "$TARGET/.claude" ]; then
  BAK="$TARGET/.claude.bak-$(date +%Y%m%d-%H%M%S)"
  cp -r "$TARGET/.claude" "$BAK"
  echo "  backed up existing -> $BAK"
fi

# 4) copy the toolkit
mkdir -p "$TARGET/.claude"
# directories: remove the old one first so cp -r doesn't nest (a/a) and we get a clean mirror
for d in agents commands skills hooks; do
  rm -rf "$TARGET/.claude/$d"
  cp -r "$SRC/.claude/$d" "$TARGET/.claude/$d"
done
# single files
cp "$SRC/.claude/settings.json" "$TARGET/.claude/settings.json"
cp "$SRC/.claude/CLAUDE.md"     "$TARGET/.claude/CLAUDE.md"
cp "$SRC/CLAUDE.md"             "$TARGET/CLAUDE.md"   # root stub that @imports .claude/CLAUDE.md

# 5) make the hook executable (settings.json runs it via bash + $CLAUDE_PROJECT_DIR)
chmod +x "$TARGET/.claude/hooks/"*.sh 2>/dev/null || true

# 6) ensure the target is a git repo — the blueprint hook, /pause /resume and the
#    workflow commands all rely on git; an initial commit gives HEAD so /blueprint
#    freshness works. Never touch an existing repo.
if [ -e "$TARGET/.git" ]; then
  echo "  git: already a repo — left as-is"
elif ( cd "$TARGET" && { git init -b "$BRANCH" >/dev/null 2>&1 || git init >/dev/null 2>&1; } ); then
  echo "  git: initialized new repo (branch $BRANCH)"
  # stage only the toolkit (not the user's other files) for the first commit
  if ( cd "$TARGET" && git add .claude CLAUDE.md && git commit -q -m "chore: add Claude Code toolkit" >/dev/null 2>&1 ); then
    echo "  git: created initial toolkit commit"
  else
    echo "  git: skipped initial commit — set git user.name/email, then commit"
  fi
else
  echo "  git: init failed (is git installed?)" >&2
fi

# 7) optional: wire up the remote (skip this and add it later if you prefer)
if [ -n "$REMOTE" ]; then
  if ( cd "$TARGET" && git remote get-url origin >/dev/null 2>&1 ); then
    echo "  git: origin already set — leaving remote as-is"
  elif ( cd "$TARGET" && git remote add origin "$REMOTE" >/dev/null 2>&1 ); then
    echo "  git: added remote origin -> $REMOTE"
    echo "       push when ready:  git -C \"$TARGET\" push -u origin $BRANCH"
  else
    echo "  git: could not add remote origin" >&2
  fi
fi

echo "Done."
echo "  agents  : $(find "$TARGET/.claude/agents"   -name '*.md' | wc -l | tr -d ' ')"
echo "  commands: $(find "$TARGET/.claude/commands" -name '*.md' | wc -l | tr -d ' ')"
echo "  skills  : $(find "$TARGET/.claude/skills" -name 'SKILL.md' | wc -l | tr -d ' ')"
echo
echo "Next: open Claude Code in $TARGET and run /blueprint (or just start giving it tasks)."
