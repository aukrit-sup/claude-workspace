# คำแนะนำโปรเจกต์ (CLAUDE.md)

Repo นี้เป็น **ชุดเครื่องมือ Claude Code** — subagent 6 ตัว, slash command 12 คำสั่ง และ skill 10 ตัว
อยู่ใน `.claude/` (คัดลอกไปใช้ในโปรเจกต์อื่นได้) รายละเอียดเต็มดู [`README.md`](../README.md) และ
[`.claude/skills/README.md`](skills/README.md)

## กฎที่มีผลทุกครั้ง

- **ภาษา** — สื่อสารกับผู้ใช้เป็น **ภาษาไทย**
- **README** — ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ เอง เว้นแต่ผู้ใช้สั่งตรงๆ; เอกสารสรุปงานให้เขียนลง `.claude/reports/` เท่านั้น
- **รายงาน** — ทุก pipeline เขียนไฟล์สรุปลง `.claude/reports/<run-dir>/` และอัปเดต `_state.json` เพื่อรองรับ `/pause` และ `/resume`
- **Delegate + GATE** — งานที่มี command/agent รองรับให้ delegate ตามสูตร อย่าลุยเอง และอย่าข้ามจุดยืนยัน (GATE) ก่อนแก้ของจริง

## Project blueprint (แผนที่โปรเจกต์ — ลด context)

โปรเจกต์ที่ copy template นี้ไปใช้ ใช้ `.claude/blueprint.md` เป็นแผนที่เพื่อ **ไม่ต้องสแกนทั้งโปรเจกต์ทุก session**:

- **เริ่มงาน** — อ่าน `.claude/blueprint.md` เป็นจุดตั้งต้นก่อน ค่อยค้นไฟล์เสริมเฉพาะจุดที่ blueprint ไม่ครอบคลุม
- **SessionStart hook** (`blueprint-check.sh`) จะ inject สถานะความสดให้ทุก session: "สดใหม่" = เชื่อ blueprint ได้; "เก่ากว่า HEAD N commit" = ยึดโค้ดจริงเหนือ blueprint เฉพาะไฟล์ที่ hook ระบุ
- **ไม่มี blueprint** (เพิ่ง copy template มา) → สร้างด้วย `/blueprint` เป็นส่วนหนึ่งของงานแรก **โดยไม่ต้องถาม**
- **หลังเปลี่ยนโครงสร้าง** (เพิ่ม/ย้าย/ลบไฟล์-โมดูลสำคัญ) → refresh ด้วย `/blueprint` แล้ว commit เฉพาะไฟล์นั้น
- blueprint ต้อง **lean** (ดัชนี/แผนที่ ไม่ใช่ dump โค้ด) และต้องมี stamp `blueprint-sha:` เสมอ มิฉะนั้น hook เช็คความสดไม่ได้

## Skill ที่ผูกตายตัวกับ agent (สรุปสั้น)

- `code-reviewer` → `scrutinize` (ทุกรีวิว) + UI skills เมื่อ diff แตะ UI
- `feature-developer` → `debug-mantra` (โหมดวินิจฉัย) / UI skills (เมื่อแตะ UI)
- `qa-tester` → `fixing-accessibility` (เมื่อทดสอบ UI)
- `/fix-bug`, `/hotfix` → `debug-mantra`, `post-mortem`
- `/spec-only` (Step 1), `/build-feature` (Step 0) → `brainstorming` — **orchestrator เรียกเองในลูปหลัก** ก่อน dispatch `system-analyst` เมื่อโจทย์คลุมเครือ (subagent คุยกับผู้ใช้ไม่ได้ จึงไม่ผูกกับ sa)
- ที่เหลือ (เช่น `management-talk`) auto-trigger จาก `description` หรือเรียก `/skill-name`

## เมื่อแก้การผูก skill ↔ agent — ต้อง sync 3 ที่ให้ตรงกัน

1. ตัว prompt ของ agent/command ใน `.claude/agents/` หรือ `.claude/commands/` (ถ้าเป็น subagent ต้องมี `Skill` ในช่อง `tools:` ด้วย มิฉะนั้นเรียก skill ไม่ได้)
2. ตารางใน `.claude/skills/README.md`
3. ตารางใน `README.md` (root)
