#!/usr/bin/env bash
# install.sh — install this Claude Code toolkit into a target workspace
#
# Usage:  ./install.sh <target-workspace-dir>
# e.g.:   ./install.sh ~/projects/my-frontend
#         bash install.sh "D:/work/backend"      # Windows / Git Bash
#         bash install.sh                         # no arg -> prompts for the path
#
# Copies only the template parts (agents/commands/skills/hooks/settings/CLAUDE.md).
# Skips per-project runtime: reports/, blueprint.md, README.md, .git
# The hook in settings.json uses $CLAUDE_PROJECT_DIR, so it is portable — no path rewrite needed.

set -euo pipefail

# 1) source = the directory this script lives in (resolved no matter where it's run from)
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2) target: take from argument, otherwise ask for it (type it in via cmd)
TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  read -r -p "Enter target workspace path: " TARGET
fi
TARGET="${TARGET/#\~/$HOME}"   # expand a leading ~ (read does not expand it)
if [ -z "$TARGET" ]; then
  echo "No target given — aborting." >&2
  exit 1
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

echo "Done."
echo "  agents  : $(find "$TARGET/.claude/agents"   -name '*.md' | wc -l | tr -d ' ')"
echo "  commands: $(find "$TARGET/.claude/commands" -name '*.md' | wc -l | tr -d ' ')"
echo "  skills  : $(find "$TARGET/.claude/skills" -name 'SKILL.md' | wc -l | tr -d ' ')"
echo
echo "Next: open Claude Code in $TARGET and run /blueprint (or just start giving it tasks)."
