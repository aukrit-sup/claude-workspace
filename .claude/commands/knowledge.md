---
description: สร้าง/อัปเดต knowledge ของทีม (.claude/knowledge/) จากงานที่ทำไป — กฎ/gotcha, แผนที่ระบบ, การ์ดส่งต่องานรายฟีเจอร์ (ไม่มีโค้ดจริง)
---

You maintain the **team knowledge base** at `.claude/knowledge/` — สิ่งที่คนอื่นต้องรู้เพื่อ **รับงานต่อได้ทันที**
โดยไม่ต้องอ่าน report ทั้งหมดหรือถามซ้ำ ต่างจาก blueprint (แผนที่ไฟล์) ตรงที่ knowledge เก็บ **ความรู้/การตัดสินใจ/สถานะ**

Optional focus (feature slug หรือหัวข้อ): $ARGUMENTS

## โครงที่ต้องมี

```
.claude/knowledge/
  index.md              ← บรรทัดแรก: <!-- knowledge-sha: <FULL_HEAD_SHA> generated: <YYYY-MM-DD HH:MM> -->
  rules.md              ← กฎ/gotcha ที่ "เจ็บมาแล้ว" ใช้ข้ามฟีเจอร์ (root CLAUDE.md ควร @import ไฟล์นี้)
  systems.md            ← แผนที่ระบบ/โปรเจกต์ปลายทาง: อะไรอยู่โปรเจกต์/package/โมดูลไหน
  features/<slug>.md    ← การ์ดส่งต่องาน 1 ไฟล์ต่อ 1 ฟีเจอร์
```

## โหมดการทำงาน

1. **ไม่มี `.claude/knowledge/` → CREATE:** อ่านแหล่งข้อมูลทั้งหมดด้านล่างแล้วสร้างครบทุกไฟล์
   ถ้า root `CLAUDE.md` ยังไม่ import `rules.md` ให้เพิ่มบรรทัด `@.claude/knowledge/rules.md` ต่อท้าย
2. **มีแล้ว → REFRESH (ประหยัด ไม่อ่านใหม่ทั้งก้อน):**
   - อ่าน SHA จากบรรทัดแรกของ `index.md` → `git log --oneline <sha>..HEAD` + `git diff --name-only <sha>..HEAD`
   - ฟีเจอร์ที่มี commit/report/`_state*.json` เปลี่ยน → อัปเดตการ์ดของฟีเจอร์นั้น (ไม่มีการ์ด = สร้างใหม่)
   - ฟีเจอร์ที่ไม่ถูกแตะ → คงเดิม
3. ถ้า `$ARGUMENTS` ระบุฟีเจอร์ → ทำเฉพาะการ์ดนั้น (+ rules/systems ถ้าเจอของใหม่)

## แหล่งข้อมูล (เรียงตามความน่าเชื่อถือ — ขัดกันให้ยึดตัวบนสุด)

1. **git** (`git log`, `git show --stat`) — ความจริงว่าอะไร commit แล้ว
2. คำยืนยันของผู้ใช้ในบทสนทนานี้
3. `.claude/reports/_state*.json` (`notes`, `decided`, `pending_steps`) และ `.claude/reports/<run-dir>/*.md` (brainstorm, spec, review — ส่วนท้ายไฟล์/rev ล่าสุดมักแก้ส่วนต้น)
4. memory ส่วนตัว (`~/.claude/projects/.../memory/`) — ถ้าเจอความรู้ที่ทีมควรรู้แต่อยู่แค่ใน memory ให้ย้ายมา knowledge แล้วบอกผู้ใช้

ถ้าแหล่งข้อมูลขัดกันในเรื่องที่ทำให้การ์ดผิดได้ (สถานะ, ค่าที่ยืนยันแล้วหรือยัง) → **ถามผู้ใช้** อย่าเดา
ถ้าเยอะ (หลายฟีเจอร์) ให้ dispatch subagent ทีละฟีเจอร์แบบขนานได้ — ส่งโครงการ์ด + กฎเหล็กด้านล่างไปครบ

## โครงการ์ด `features/<slug>.md` (≤ ~120 บรรทัด)

```
# <ชื่อฟีเจอร์>
- สถานะ: in_progress | paused | done — ค้างที่ไหน · อัปเดตล่าสุด YYYY-MM-DD · commit ที่เกี่ยว
## เป้าหมาย            (2–4 บรรทัด)
## การตัดสินใจที่ยุติแล้ว (ข้อละบรรทัด + เหตุผลสั้น — ห้ามรื้อถามซ้ำ)
## ไฟล์/คลาสที่แตะ       (pointer: โปรเจกต์ปลายทาง › FQN/path #method — ห้ามแปะ body)
## ตาราง/config/สคริปต์ที่เกี่ยว
## งานค้าง + คำถามที่รอคำตอบ (เรียงตามลำดับที่ควรทำ; ที่ปิดแล้วขีดฆ่า + วันที่)
## วิธี verify          (บรรยายเป็นขั้นตอน)
## gotcha ที่เจอในงานนี้   (ตัวที่ใช้ข้ามฟีเจอร์ได้ → ย้ายขึ้น rules.md ด้วย)
```

## กฎเหล็ก — knowledge ถูก zip ส่งต่อ (`kit-export.sh`) ห้ามมีโค้ดจริงหลุด

- **ห้ามแปะโค้ด** Java/JSP/SQL/XML/shell — ไม่มี code block ของโค้ดจริง ไม่มีบรรทัดขึ้นต้น `package ` / `import `
- อ้างได้แค่ **ชื่อ**: path, FQN class, เมธอด, ตาราง/คอลัมน์, config key, batch/report code, ชื่อ host
- **ห้าม** credential, password, IP, connection string, ข้อมูลจริง/PII
- **Lean** — ความรู้ ไม่ใช่บันทึกประจำวัน · ไม่ซ้ำกับ blueprint (blueprint = ไฟล์อยู่ไหน, knowledge = ทำไม/สถานะ/ห้ามอะไร)
- ห้ามแตะ README ใดๆ

## ปิดงาน

1. อัปเดต `index.md` (ตารางไฟล์ + รายการการ์ด) และ stamp บรรทัดแรกด้วย `git rev-parse HEAD` + `date '+%Y-%m-%d %H:%M'`
2. ตรวจเอง: `grep -rnE '^[[:space:]]*(package|import)[[:space:]]+[a-z].*;|^[[:space:]]*(SELECT|INSERT INTO|DELETE FROM|CREATE TABLE)[[:space:]]|([0-9]{1,3}\.){3}[0-9]{1,3}' .claude/knowledge` ต้องว่าง
3. Commit เฉพาะ knowledge (+ root `CLAUDE.md` ถ้าเพิ่ง import): `git commit .claude/knowledge -m "docs: update team knowledge"` — repo อยู่กลาง merge/ห้าม commit ให้ข้ามแล้วแจ้ง
4. รายงานสั้นๆ ภาษาไทย: สร้างใหม่/refresh, การ์ดที่สร้าง/อัปเดต, กฎใหม่, ข้อมูลที่ขัดกันที่ต้องให้ผู้ใช้ยืนยัน
