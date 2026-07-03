---
description: เขียน test ให้โค้ดที่ยังไม่มี test เพื่อเพิ่ม coverage
---

You are the test-writing orchestrator. The user wants tests written for code described in the arguments below. Report in Thai.

Target for testing:
$ARGUMENTS

## Pipeline steps

### Step 1 — วิเคราะห์ว่าควร test อะไร (qa-tester)

Delegate to `qa-tester` to analyze the target code and produce a test plan:
- What behaviors, branches, and edge cases need coverage
- Which cases are highest-risk / most important
- Current coverage gaps

qa-tester writes this plan to `.claude/reports/`.

### 🛑 GATE — ตรวจ test plan

STOP and present the test plan to the user in Thai (สรุปว่าจะเขียน test ครอบคลุมอะไรบ้าง). Ask: **"test plan โอเคไหม? พิมพ์ 'เขียนเลย' หรือบอกจุดที่อยากเพิ่ม/ตัด"**

Wait for approval.

### Step 2 — เขียน test (feature-developer)

After approval, delegate to `feature-developer` to write the tests according to the plan. Instruct it:
- Write tests that verify behavior, not just implementation details
- Cover the edge cases from the plan
- Run the tests and confirm they pass (or reveal genuine bugs — report those, don't silently make tests pass)

### Step 3 — ตรวจคุณภาพ test (qa-tester)

Delegate to `qa-tester` to verify the tests are meaningful (would actually catch regressions), not just padding coverage numbers.

### เสร็จสิ้น

Summarize in Thai: test ที่เขียน, coverage ที่เพิ่มขึ้น, และบั๊กที่เจอระหว่างเขียน test (ถ้ามี). List report paths.

## การบันทึกสถานะ (รองรับ pause/resume)

ตลอด pipeline ให้เขียน/อัปเดต `.claude/reports/_state.json` ตาม convention ของ `pipeline-state`:
- หลังจบแต่ละ step: อัปเดต `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_files`, `notes`, `updated_at`
- ตอนเริ่มคำสั่ง: เช็คก่อนว่ามี `_state.json` ของ feature เดียวกันที่ยังค้างอยู่ไหม ถ้ามีให้ถามผู้ใช้ว่า "ทำต่อจากที่ค้าง หรือเริ่มใหม่?"
- เมื่อ workflow เสร็จ: set `status: "done"`
ทำแบบนี้เพื่อให้ผู้ใช้พิมพ์ `/pause` หยุดกลางคัน แล้ว `/resume` กลับมาทำต่อได้แม้เปิด session ใหม่

## กฎสำคัญ
- test ต้องมีความหมายจริง ไม่ใช่แค่เพิ่มตัวเลข coverage
- ถ้าเจอบั๊กตอนเขียน test ให้รายงาน อย่าดัด test ให้ผ่าน
- delegate ทุกครั้ง สื่อสารเป็นภาษาไทย
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
