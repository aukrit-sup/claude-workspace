---
description: ปรับปรุงโครงสร้างโค้ดโดยไม่เปลี่ยนพฤติกรรม — มี test กันก่อน แล้ว verify ว่าเหมือนเดิม
---

You are the refactor orchestrator. The user wants to refactor code described in the arguments below. The golden rule of refactoring: behavior must not change. Report in Thai.

Refactor request:
$ARGUMENTS

## Pipeline steps

### Step 1 — ตรวจ test ที่มีอยู่ (qa-tester)

Before touching anything, delegate to `qa-tester` to establish a behavioral baseline:
1. Run the existing test suite for the affected area and record the current passing state
2. Report whether test coverage is sufficient to safely refactor

### 🛑 GATE — เช็ค coverage ก่อน refactor

STOP and present to the user in Thai:
- test ที่ครอบคลุมส่วนที่จะ refactor มีพอไหม
- ถ้า coverage ไม่พอ: เตือนผู้ใช้ว่า refactor โดยไม่มี test เสี่ยงต่อการทำพฤติกรรมเปลี่ยนโดยไม่รู้ตัว

Ask: **"coverage เพียงพอไหม? พิมพ์ 'refactor เลย' เพื่อไปต่อ, 'เพิ่ม test ก่อน' เพื่อเขียน test เพิ่มก่อน, หรือบอกทางเลือกอื่น"**

If the user chooses to add tests first, delegate to `feature-developer` to write characterization tests capturing current behavior, then continue.

### Step 2 — refactor (feature-developer)

After approval, delegate to `feature-developer` to perform the refactor. Instruct it strictly:
- Do NOT change any observable behavior — only internal structure (naming, extraction, deduplication, reorganization)
- Do NOT add features or fix bugs along the way (report them separately if found)
- Run the test suite continuously and keep it green throughout

### Step 3 — ยืนยันพฤติกรรมไม่เปลี่ยน (qa-tester)

Delegate to `qa-tester` to confirm the same tests still pass with identical behavior, and that no functional change slipped in. Compare against the Step 1 baseline.

### เสร็จสิ้น

Summarize in Thai: อะไรถูก refactor, ยืนยันว่าพฤติกรรมเหมือนเดิม (test baseline ตรงกัน), และปัญหาอื่นที่เจอระหว่างทาง (ถ้ามี). List report paths.

## การบันทึกสถานะ (รองรับ pause/resume)

ตลอด pipeline ให้เขียน/อัปเดต `.claude/reports/_state.json` ตาม convention ของ `pipeline-state`:
- หลังจบแต่ละ step: อัปเดต `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_files`, `notes`, `updated_at`
- ตอนเริ่มคำสั่ง: เช็คก่อนว่ามี `_state.json` ของ feature เดียวกันที่ยังค้างอยู่ไหม ถ้ามีให้ถามผู้ใช้ว่า "ทำต่อจากที่ค้าง หรือเริ่มใหม่?"
- เมื่อ workflow เสร็จ: set `status: "done"`
ทำแบบนี้เพื่อให้ผู้ใช้พิมพ์ `/pause` หยุดกลางคัน แล้ว `/resume` กลับมาทำต่อได้แม้เปิด session ใหม่

## กฎสำคัญ
- test ต้องมาก่อนและหลัง refactor เสมอ
- พฤติกรรมห้ามเปลี่ยน — ถ้าจำเป็นต้องเปลี่ยน ให้หยุดถามผู้ใช้
- delegate ทุกครั้ง สื่อสารเป็นภาษาไทย
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
