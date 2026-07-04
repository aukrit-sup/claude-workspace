#!/usr/bin/env bash
# SessionStart hook — รายงานสถานะความสดของ .claude/blueprint.md
# เพื่อให้ Claude ใช้ blueprint เป็นแผนที่โปรเจกต์แทนการสแกนทั้ง tree
# และรู้ว่าส่วนไหน stale จนต้องยึดโค้ดจริงแทน
#
# SessionStart hook: stdout ของสคริปต์นี้จะถูก inject เข้า context ของ session
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
BP="$ROOT/.claude/blueprint.md"

# ยังไม่มี blueprint — เช่นเพิ่ง copy template มาใช้ในโปรเจกต์ใหม่
if [ ! -f "$BP" ]; then
  echo "[blueprint] โปรเจกต์นี้ยังไม่มี .claude/blueprint.md (ครั้งแรก). เมื่อเริ่มงานจริง ให้สร้างด้วยคำสั่ง /blueprint — สแกนโครงสร้างโปรเจกต์ เขียนแผนที่ พร้อม stamp git SHA เพื่อให้ session ถัดไปอ่านแทนการสแกนทั้งโปรเจกต์."
  exit 0
fi

# ไม่ใช่ git repo — ตรวจความสดไม่ได้
if ! git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  echo "[blueprint] มี .claude/blueprint.md แต่โฟลเดอร์นี้ไม่ใช่ git repo — ตรวจความสดอัตโนมัติไม่ได้ ใช้ด้วยความระวัง."
  exit 0
fi

# ดึง SHA ที่ stamp ไว้: บรรทัดรูปแบบ  <!-- blueprint-sha: <sha> generated: <date> -->
SHA="$(sed -n 's/.*blueprint-sha:[[:space:]]*\([0-9a-f]\{7,40\}\).*/\1/p' "$BP" | head -n1)"

if [ -z "$SHA" ] || ! git -C "$ROOT" cat-file -e "$SHA" 2>/dev/null; then
  echo "[blueprint] มี .claude/blueprint.md แต่หา git SHA ที่ stamp ไม่เจอ (หรือ SHA ไม่อยู่ในประวัติ) — refresh ด้วย /blueprint เพื่อให้ตรวจความสดได้."
  exit 0
fi

COUNT="$(git -C "$ROOT" rev-list --count "$SHA"..HEAD 2>/dev/null || echo 0)"
if [ "${COUNT:-0}" -eq 0 ]; then
  echo "[blueprint] .claude/blueprint.md สดใหม่ (ตรงกับ HEAD). ใช้เป็นแผนที่โปรเจกต์ได้เลย — เริ่มจาก blueprint ก่อน แทนการสแกนทั้งโปรเจกต์."
else
  echo "[blueprint] .claude/blueprint.md เก่ากว่า HEAD $COUNT commit. ใช้เป็นแผนที่ตั้งต้นได้ แต่ไฟล์ต่อไปนี้เปลี่ยนหลัง blueprint — งานที่แตะส่วนเหล่านี้ให้ยึดโค้ดจริงเหนือ blueprint แล้ว refresh ด้วย /blueprint เมื่อสะดวก:"
  git -C "$ROOT" diff --name-only "$SHA"..HEAD 2>/dev/null | head -n 40 | sed 's/^/  - /'
fi
exit 0
