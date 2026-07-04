# คำแนะนำโปรเจกต์ (CLAUDE.md)

Repo นี้เป็น **ชุดเครื่องมือ Claude Code** — subagent 6 ตัว, slash command 11 คำสั่ง และ skill 8 ตัว
อยู่ใน `.claude/` (คัดลอกไปใช้ในโปรเจกต์อื่นได้) รายละเอียดเต็มดู [`README.md`](../README.md) และ
[`.claude/skills/README.md`](skills/README.md)

## กฎที่มีผลทุกครั้ง

- **ภาษา** — สื่อสารกับผู้ใช้เป็น **ภาษาไทย**
- **README** — ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ เอง เว้นแต่ผู้ใช้สั่งตรงๆ; เอกสารสรุปงานให้เขียนลง `.claude/reports/` เท่านั้น
- **รายงาน** — ทุก pipeline เขียนไฟล์สรุปลง `.claude/reports/<run-dir>/` และอัปเดต `_state.json` เพื่อรองรับ `/pause` และ `/resume`
- **Delegate + GATE** — งานที่มี command/agent รองรับให้ delegate ตามสูตร อย่าลุยเอง และอย่าข้ามจุดยืนยัน (GATE) ก่อนแก้ของจริง

## Skill ที่ผูกตายตัวกับ agent (สรุปสั้น)

- `code-reviewer` → `scrutinize` (ทุกรีวิว) + UI skills เมื่อ diff แตะ UI
- `feature-developer` → `debug-mantra` (โหมดวินิจฉัย) / UI skills (เมื่อแตะ UI)
- `qa-tester` → `fixing-accessibility` (เมื่อทดสอบ UI)
- `/fix-bug`, `/hotfix` → `debug-mantra`, `post-mortem`
- ที่เหลือ (เช่น `management-talk`) auto-trigger จาก `description` หรือเรียก `/skill-name`

## เมื่อแก้การผูก skill ↔ agent — ต้อง sync 3 ที่ให้ตรงกัน

1. ตัว prompt ของ agent/command ใน `.claude/agents/` หรือ `.claude/commands/` (ถ้าเป็น subagent ต้องมี `Skill` ในช่อง `tools:` ด้วย มิฉะนั้นเรียก skill ไม่ได้)
2. ตารางใน `.claude/skills/README.md`
3. ตารางใน `README.md` (root)
