---
description: ปรับปรุงโครงสร้างโค้ดโดยไม่เปลี่ยนพฤติกรรม — มี test กันก่อน แล้ว verify ว่าเหมือนเดิม
---

You are the refactor orchestrator. The user wants to refactor code described in the arguments below. The golden rule of refactoring: behavior must not change. Report in Thai.

Refactor request:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้ (กัน report เขียนทับกัน)

ก่อนเริ่ม ให้กำหนด **run report directory**:
- ถ้า resume → ใช้ `report_dir` เดิม
- ถ้าเริ่มใหม่ → สร้าง `.claude/reports/{slug}-{YYYYMMDD-HHMM}/` (timestamp จาก shell `date +%Y%m%d-%H%M`)

Step 1 baseline รันเองใน orchestrator ไม่มีไฟล์รายงาน — สรุปผล baseline ใส่ใน `notes` ของ state ได้ ส่วน subagent ให้บอก path โฟลเดอร์และชื่อไฟล์คงที่:
- feature-developer (refactor) → `02-feature-developer.md` (ถ้าเขียน characterization test ก่อน ใช้ `02-feature-developer-characterization.md` แยก)
- qa-tester (verify) → `03-qa-tester.md`

บันทึก `report_dir` และ path เต็มลง `_state.json`

## Pipeline steps

### Step 1 — ตรวจ test baseline (orchestrator ทำเอง ไม่ spawn agent)

Before touching anything, establish a behavioral baseline yourself. This is a mechanical step (หา test → รัน → อ่านผล) ที่ไม่คุ้มกับการ spawn subagent เต็มตัวที่ต้องโหลด context ใหม่หมด:
1. Locate and run the existing test suite for the affected area (infer the command from package.json / project config) and record the current passing/failing counts
2. Assess whether the existing tests actually cover the code being refactored — enough to catch a behavior change if one slips in

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
- หลังจบแต่ละ step: อัปเดต `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_dir`, `report_files`, `notes`, `updated_at`
- ตอนเริ่มคำสั่ง: เช็คก่อนว่ามี `_state.json` ของ feature เดียวกันที่ยังค้างอยู่ไหม ถ้ามีให้ถามผู้ใช้ว่า "ทำต่อจากที่ค้าง หรือเริ่มใหม่?"
- เมื่อ workflow เสร็จ: set `status: "done"`
ทำแบบนี้เพื่อให้ผู้ใช้พิมพ์ `/pause` หยุดกลางคัน แล้ว `/resume` กลับมาทำต่อได้แม้เปิด session ใหม่

## กฎสำคัญ
- test ต้องมาก่อนและหลัง refactor เสมอ
- พฤติกรรมห้ามเปลี่ยน — ถ้าจำเป็นต้องเปลี่ยน ให้หยุดถามผู้ใช้
- delegate งานที่ต้องใช้ความเชี่ยวชาญ (refactor → feature-developer, verify → qa-tester) ส่วน baseline test รันเองได้ สื่อสารเป็นภาษาไทย
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
