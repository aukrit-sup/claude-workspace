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
# Skips per-project runtime: reports/, knowledge/, blueprint.md, README.md, .git
# Root CLAUDE.md is copied only when missing — after that it belongs to the project (its own rules/imports).
# The hook in settings.json uses $CLAUDE_PROJECT_DIR, so it is portable — no path rewrite needed.
#
# Two more modes:
#   ./install.sh --pull   <workspace>          workspace -> this repo (toolkit files only), then review git diff
#   ./install.sh --export <workspace> [x.zip]  toolkit + .claude/knowledge -> zip for teammates (no source code)
#
# --pull refuses to run unless .leak-patterns (gitignored, one ERE per line) exists here, and aborts
# if any pulled file matches — this repo has a public-ish remote, project names must never reach it.

set -euo pipefail

# 1) source = the directory this script lives in (resolved no matter where it's run from)
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OWNED_DIRS="agents commands skills hooks"   # toolkit-owned; everything else in .claude belongs to the workspace

if [ "${1:-}" = "--pull" ]; then
  WS="$(cd "${2:?usage: install.sh --pull <workspace>}" && pwd)"
  [ "$WS" != "$SRC" ] || { echo "Workspace must not be the toolkit repo itself" >&2; exit 1; }
  [ -s "$SRC/.leak-patterns" ] || { echo "Missing $SRC/.leak-patterns — create it (one regex per line) before pulling" >&2; exit 1; }
  PAT="$(mktemp)"; trap 'rm -f "$PAT"' EXIT
  grep -vE '^[[:space:]]*(#|$)' "$SRC/.leak-patterns" > "$PAT" || true   # blank line would match everything
  hits="$(cd "$WS/.claude" && grep -rlEf "$PAT" $OWNED_DIRS settings.json CLAUDE.md || true)"
  if [ -n "$hits" ]; then
    echo "LEAK GUARD: project-specific text found — nothing pulled. Move it to .claude/knowledge/ or root CLAUDE.md:" >&2
    echo "$hits" | sed 's/^/  /' >&2
    exit 1
  fi
  for d in $OWNED_DIRS; do
    rm -rf "$SRC/.claude/$d"
    cp -r "$WS/.claude/$d" "$SRC/.claude/$d"
  done
  cp "$WS/.claude/settings.json" "$WS/.claude/CLAUDE.md" "$SRC/.claude/"
  git -C "$SRC" status --short -- .claude
  echo "Pulled from $WS. Review with: git -C \"$SRC\" diff   — then commit/push yourself."
  exit 0
fi

if [ "${1:-}" = "--export" ]; then
  WS="$(cd "${2:?usage: install.sh --export <workspace> [out.zip]}" && pwd)"
  OUT="${3:-$WS/$(basename "$WS")-claude-kit-$(date +%Y%m%d).zip}"
  OUT="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"
  STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
  # allowlist, never denylist: only these paths can ever end up in the zip
  mkdir -p "$STAGE/.claude"
  for d in $OWNED_DIRS knowledge; do
    if [ -d "$WS/.claude/$d" ]; then cp -r "$WS/.claude/$d" "$STAGE/.claude/$d"; fi
  done
  cp "$WS/.claude/settings.json" "$WS/.claude/CLAUDE.md" "$STAGE/.claude/"
  cp "$WS/CLAUDE.md" "$STAGE/CLAUDE.md"
  # code guard: names/paths are fine (teammates have source access), source code is not
  bad="$(cd "$STAGE" && {
    find . -type f ! -name '*.md' ! -name '*.sh' ! -name '*.json'
    grep -rlE '^[[:space:]]*(package|import)[[:space:]]+[a-z][a-z0-9_]*(\.[A-Za-z0-9_*]+)+[[:space:]]*;|^[[:space:]]*(SELECT|INSERT INTO|DELETE FROM|CREATE TABLE)[[:space:]]|<%@' . || true
  })"
  if [ -n "$bad" ]; then
    echo "CODE GUARD: looks like source code — zip not created:" >&2
    echo "$bad" | sed 's/^/  /' >&2
    exit 1
  fi
  rm -f "$OUT"
  if command -v zip >/dev/null 2>&1; then
    (cd "$STAGE" && zip -qr "$OUT" .claude CLAUDE.md)
  elif [ -n "${SYSTEMROOT:-}" ]; then   # Windows Git Bash: no zip, but the system bsdtar writes zip with -a
    (cd "$STAGE" && "$(cygpath "$SYSTEMROOT")/System32/tar.exe" -a -cf "$(cygpath -w "$OUT")" .claude CLAUDE.md)
  else
    echo "Need 'zip' to export" >&2; exit 1
  fi
  echo "Exported -> $OUT"
  echo "  files: $(cd "$STAGE" && find . -type f | wc -l | tr -d ' ')  (knowledge: $(find "$STAGE/.claude/knowledge" -type f 2>/dev/null | wc -l | tr -d ' '))"
  echo "Teammate: unzip into their workspace root (back up their own CLAUDE.md first)."
  exit 0
fi

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
# normalize a Windows-style path (backslashes and/or a C:\ / C:/ drive prefix) into the
# POSIX form the rest of the script needs. Without this, Git Bash treats "C:\..." as a
# relative name and installs into a bogus ./C:/... tree under the current dir.
# cygpath ships with Git Bash; fall back to a manual rewrite if it is missing. No-op on
# real Unix paths (no backslash, no drive letter).
case "$TARGET" in
  *\\* | [A-Za-z]:[\\/]*)
    if command -v cygpath >/dev/null 2>&1; then
      TARGET="$(cygpath -u "$TARGET")"
    else
      TARGET="${TARGET//\\//}"                       # backslashes -> forward slashes
      case "$TARGET" in                              # C:/... -> /c/...
        [A-Za-z]:/*) _drv="$(printf '%s' "${TARGET%%:*}" | tr 'A-Z' 'a-z')"; TARGET="/$_drv${TARGET#?:}" ;;
      esac
    fi
    ;;
esac
# interactive: optionally ask for a remote now (Enter to skip and set it later).
# Skip the whole prompt if the target is already a git repo — its remote is left
# as-is later (step 7), so asking would only be a blind, no-op question.
if [ "$INTERACTIVE" = 1 ] && [ -z "$REMOTE" ] && [ ! -e "$TARGET/.git" ]; then
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

# 3) back up only what we are about to overwrite (not reports/ — those hold project code and grow)
if [ -e "$TARGET/.claude" ]; then
  BAK="$TARGET/.claude.bak-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BAK"
  for p in $OWNED_DIRS settings.json CLAUDE.md; do
    if [ -e "$TARGET/.claude/$p" ]; then cp -r "$TARGET/.claude/$p" "$BAK/"; fi
  done
  echo "  backed up toolkit files -> $BAK"
fi

# 4) copy the toolkit
mkdir -p "$TARGET/.claude"
# directories: remove the old one first so cp -r doesn't nest (a/a) and we get a clean mirror
for d in $OWNED_DIRS; do
  rm -rf "$TARGET/.claude/$d"
  cp -r "$SRC/.claude/$d" "$TARGET/.claude/$d"
done
# single files
cp "$SRC/.claude/settings.json" "$TARGET/.claude/settings.json"
cp "$SRC/.claude/CLAUDE.md"     "$TARGET/.claude/CLAUDE.md"
# root stub that @imports .claude/CLAUDE.md — only on first install; afterwards the project owns it
if [ -e "$TARGET/CLAUDE.md" ]; then
  echo "  CLAUDE.md (root): exists — kept (project-owned)"
else
  cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
fi

# 4b) one-click wrappers for --export / --pull, pointing back at this toolkit repo
#     (regenerated every install so a moved toolkit path heals itself; env CLAUDE_WORKSPACE overrides)
write_wrapper() {   # $1 = file name, $2 = mode, $3 = comment, $4 = extra lines run on success
  cat > "$TARGET/$1" <<EOF
#!/usr/bin/env bash
# $1 — $3
# generated by install.sh — รัน: bash $1  หรือดับเบิลคลิก (ถูกเขียนทับทุกครั้งที่ install)
MAIN="\${CLAUDE_WORKSPACE:-$SRC}"
cd "\$(dirname "\$0")" || exit 1
bash "\$MAIN/install.sh" $2 "\$PWD"
st=\$?
if [ \$st -eq 0 ]; then :
$4
fi
[ -t 0 ] && read -rp "กด Enter เพื่อปิด"
exit \$st
EOF
  chmod +x "$TARGET/$1"
}
write_wrapper kit-export.sh --export "สร้าง zip (toolkit + .claude/knowledge ไม่มีโค้ดจริง) ไว้ส่งเพื่อน" ""
write_wrapper kit-pull.sh --pull "ส่ง agents/commands/skills/hooks ที่ปรับในนี้กลับ main (มี leak guard) ไม่ commit/push ให้" \
'  echo; git -C "$MAIN" diff --stat -- .claude
  echo "ดูรายละเอียด: git -C \"$MAIN\" diff"'
echo "  wrappers: kit-export.sh, kit-pull.sh"

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
  if ( cd "$TARGET" && git add .claude CLAUDE.md kit-export.sh kit-pull.sh && git commit -q -m "chore: add Claude Code toolkit" >/dev/null 2>&1 ); then
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
