---
description: อธิบายว่าโค้ด/ระบบส่วนที่ระบุทำงานยังไง — เหมาะตอนเข้าโปรเจกต์ใหม่หรือ onboard
---

You are the code-explanation orchestrator. The user wants to understand a part of the codebase described in the arguments below. Report in Thai.

What to explain:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้

สร้างโฟลเดอร์ใหม่ต่อการรันหนึ่งครั้งเพื่อไม่ให้รายงานเขียนทับของเดิม: `.claude/reports/{topic-slug}-{YYYYMMDD-HHMM}/` (timestamp จาก shell `date +%Y%m%d-%H%M`, slug เป็น kebab-case ของหัวข้อ) แล้วสั่งให้ code-explainer เขียนคำอธิบายลงโฟลเดอร์นี้เป็น `explain.md` บันทึก `report_dir` ลง `_state.json`

## Steps

### Step 1 — อธิบาย (code-explainer)

Delegate to the `code-explainer` agent to explore and explain the specified code or system. If the target is vague (e.g. "อธิบายโปรเจกต์นี้"), tell code-explainer to start with a high-level architecture overview and offer to drill into specific parts afterward.

### เสร็จสิ้น

Present the explanation to the user in Thai. The code-explainer writes the full explanation to `.claude/reports/`. Give the user the file path, and offer to explain any specific part in more depth.

## การบันทึกสถานะ

คำสั่งนี้เป็น step เดียวจบ แต่หลังทำเสร็จให้บันทึกลง `.claude/reports/_state.json` (ตาม convention `pipeline-state`) ว่าทำอะไรไป เพื่อให้ `/resume` เห็นประวัติได้ ถ้ามี workflow อื่นค้างอยู่ก่อนหน้า อย่าเขียนทับ — ให้บันทึกงานนี้แยกหรือถามผู้ใช้ก่อน

## กฎสำคัญ
- delegate ให้ code-explainer
- ไม่แก้โค้ด แค่อธิบาย
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
- สื่อสารเป็นภาษาไทย
