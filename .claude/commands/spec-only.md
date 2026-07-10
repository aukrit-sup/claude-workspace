---
description: ออกแบบ spec อย่างเดียว ไม่เขียนโค้ด — เหมาะเวลาอยากวางแผน/ถกแบบก่อนลงมือ
---

You are the spec-planning orchestrator. The user wants a spec designed for the feature/idea below, WITHOUT any code being written yet. Report in Thai.

Feature/idea to spec out:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้

สร้างโฟลเดอร์ใหม่ต่อการรันหนึ่งครั้งเพื่อไม่ให้ spec เขียนทับของเดิม: `.claude/reports/{feature-slug}-{YYYYMMDD-HHMM}/` (timestamp จาก shell `date +%Y%m%d-%H%M`, slug เป็น kebab-case) แล้วสั่งให้ system-analyst เขียน spec ลงโฟลเดอร์นี้เป็น `01-system-analyst.md` บันทึก `report_dir` ลง `_state.json` — ทำแบบนี้เพื่อให้ `/build-feature` ต่อยอดใช้โฟลเดอร์เดิมได้

## Steps

### Step 1 — brainstorm กับผู้ใช้ (ถ้าจำเป็น)

ก่อน dispatch system-analyst ให้ **คุณเอง (orchestrator) เรียก skill `brainstorming`** เพื่อถกดีไซน์กับผู้ใช้สดๆ — subagent คุยกับผู้ใช้ไม่ได้ จุดนี้จึงต้องทำในลูปหลัก

ทำตามหลัก proportional ของ skill: ถ้าคำขอ**ชัดและเล็กพออยู่แล้ว** ให้ยืนยันสั้นๆ แล้วข้ามไป Step 2 (บอกผู้ใช้ 1 บรรทัดว่าข้าม); ถ้า**คลุมเครือ / ใหญ่ / มีหลายทางเลือก** ให้รัน loop ของ skill (ถามทีละคำถาม, ตีแผ่ assumption, เสนอทางเลือกพร้อมข้อแนะนำ) จนได้ข้อสรุป แล้ว**เขียน design brief ลง `00-brainstorm.md`** ในโฟลเดอร์ report ของ run นี้

### Step 2 — ออกแบบ spec (system-analyst)

Delegate to the `system-analyst` agent to analyze the request and produce a full spec. If a `00-brainstorm.md` was produced in Step 1, **pass its content into the agent prompt** and tell it to build the spec on those settled decisions (don't re-ask what's already resolved). If it involves backend and frontend, tell it to include a detailed API contract.

### เสร็จสิ้น

Present a summary of the spec in Thai and the file path in `.claude/reports/`. Then explicitly offer next steps in Thai:
- ถ้าพร้อมพัฒนาต่อ ใช้ `/build-feature` หรือเรียก feature-developer ตาม spec นี้ได้เลย
- ถ้าอยากปรับ spec บอกจุดที่ต้องแก้ได้

Do NOT proceed to development. This command stops at the spec.

## การบันทึกสถานะ

คำสั่งนี้เป็น step เดียวจบ แต่หลังทำเสร็จให้บันทึกลง `.claude/reports/_state.json` (ตาม convention `pipeline-state`) ว่าทำอะไรไป เพื่อให้ `/resume` เห็นประวัติได้ ถ้ามี workflow อื่นค้างอยู่ก่อนหน้า อย่าเขียนทับ — ให้บันทึกงานนี้แยกหรือถามผู้ใช้ก่อน

## กฎสำคัญ
- brainstorm (Step 1) ทำเองในลูปหลักด้วย skill `brainstorming` — อย่า delegate ให้ subagent (subagent คุยกับผู้ใช้ไม่ได้)
- delegate spec ให้ system-analyst
- หยุดที่ spec เท่านั้น ห้ามเขียนโค้ด
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
- สื่อสารเป็นภาษาไทย
