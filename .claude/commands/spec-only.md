---
description: ออกแบบ spec อย่างเดียว ไม่เขียนโค้ด — เหมาะเวลาอยากวางแผน/ถกแบบก่อนลงมือ
---

You are the spec-planning orchestrator. The user wants a spec designed for the feature/idea below, WITHOUT any code being written yet. Report in Thai.

Feature/idea to spec out:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้

สร้างโฟลเดอร์ใหม่ต่อการรันหนึ่งครั้งเพื่อไม่ให้ spec เขียนทับของเดิม: `.claude/reports/{feature-slug}-{YYYYMMDD-HHMM}/` (timestamp จาก shell `date +%Y%m%d-%H%M`, slug เป็น kebab-case) แล้วสั่งให้ system-analyst เขียน spec ลงโฟลเดอร์นี้เป็น `01-system-analyst.md` บันทึก `report_dir` ลง `_state.json` — ทำแบบนี้เพื่อให้ `/build-feature` ต่อยอดใช้โฟลเดอร์เดิมได้

## Steps

### Step 1 — ออกแบบ spec (system-analyst)

Delegate to the `system-analyst` agent to analyze the request and produce a full spec. If it involves backend and frontend, tell it to include a detailed API contract.

### เสร็จสิ้น

Present a summary of the spec in Thai and the file path in `.claude/reports/`. Then explicitly offer next steps in Thai:
- ถ้าพร้อมพัฒนาต่อ ใช้ `/build-feature` หรือเรียก feature-developer ตาม spec นี้ได้เลย
- ถ้าอยากปรับ spec บอกจุดที่ต้องแก้ได้

Do NOT proceed to development. This command stops at the spec.

## การบันทึกสถานะ

คำสั่งนี้เป็น step เดียวจบ แต่หลังทำเสร็จให้บันทึกลง `.claude/reports/_state.json` (ตาม convention `pipeline-state`) ว่าทำอะไรไป เพื่อให้ `/resume` เห็นประวัติได้ ถ้ามี workflow อื่นค้างอยู่ก่อนหน้า อย่าเขียนทับ — ให้บันทึกงานนี้แยกหรือถามผู้ใช้ก่อน

## กฎสำคัญ
- delegate ให้ system-analyst
- หยุดที่ spec เท่านั้น ห้ามเขียนโค้ด
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
- สื่อสารเป็นภาษาไทย
