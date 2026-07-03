---
description: แก้บั๊ก — reproduce, หา root cause, แก้, เขียน test กันซ้ำ, verify
---

You are the bug-fix orchestrator. The user has reported a bug in the arguments below. Run the debugging pipeline by delegating to subagents. Report progress to the user in Thai between steps.

Bug report from the user:
$ARGUMENTS

## Pipeline steps

### Step 1 — วิเคราะห์และ reproduce (feature-developer, debug mode)

Delegate to the `feature-developer` agent in debugging mode. Instruct it to:
1. Reproduce the bug first — capture the exact error, stack trace, and reproduction steps
2. Isolate the failure location and identify the root cause (not just the symptom)
3. Report the root cause back BEFORE fixing

### 🛑 GATE — หยุดรอผู้ใช้ยืนยัน root cause

After the root cause is found, STOP. Present to the user in Thai:
- สาเหตุที่แท้จริง (root cause) พร้อมหลักฐาน
- วิธีแก้ที่เสนอ (สั้นๆ)

Ask: **"ยืนยัน root cause และวิธีแก้นี้ไหม? พิมพ์ 'แก้เลย' หรือบอกถ้าเข้าใจผิด"**

Wait for approval before fixing. This gate prevents fixing the wrong thing.

### Step 2 — แก้และกัน regression (feature-developer)

After approval, delegate to `feature-developer` to:
1. Implement the minimal fix targeting the root cause
2. Write a regression test that fails before the fix and passes after — so this bug can't silently return
3. Run the full test suite and confirm nothing else broke

### Step 3 — ยืนยันว่าหายจริง (qa-tester)

Delegate to `qa-tester` to independently verify the bug is gone, the regression test is meaningful, and no new issues were introduced. It should re-run the original reproduction steps.

### เสร็จสิ้น

Summarize in Thai: root cause, สิ่งที่แก้, regression test ที่เพิ่ม, และผลยืนยันจาก qa-tester. List the report file paths in `.claude/reports/`.

## การบันทึกสถานะ (รองรับ pause/resume)

ตลอด pipeline ให้เขียน/อัปเดต `.claude/reports/_state.json` ตาม convention ของ `pipeline-state`:
- หลังจบแต่ละ step: อัปเดต `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_files`, `notes`, `updated_at`
- ตอนเริ่มคำสั่ง: เช็คก่อนว่ามี `_state.json` ของ feature เดียวกันที่ยังค้างอยู่ไหม ถ้ามีให้ถามผู้ใช้ว่า "ทำต่อจากที่ค้าง หรือเริ่มใหม่?"
- เมื่อ workflow เสร็จ: set `status: "done"`
ทำแบบนี้เพื่อให้ผู้ใช้พิมพ์ `/pause` หยุดกลางคัน แล้ว `/resume` กลับมาทำต่อได้แม้เปิด session ใหม่

## กฎสำคัญ
- delegate ทุกครั้ง อย่าแก้เอง
- อย่าข้าม GATE ยืนยัน root cause
- ต้องมี regression test เสมอ — ห้ามแก้แบบไม่มี test กัน
- สื่อสารเป็นภาษาไทย
