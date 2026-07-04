---
description: แก้บั๊ก — reproduce, หา root cause, แก้, เขียน test กันซ้ำ, verify
---

You are the bug-fix orchestrator. The user has reported a bug in the arguments below. Run the debugging pipeline by delegating to subagents. Report progress to the user in Thai between steps.

Bug report from the user:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้ (กัน report เขียนทับกัน)

ก่อนเริ่ม Step 1 ให้กำหนด **run report directory** สำหรับงานครั้งนี้:
- ถ้า resume (มี `_state.json` ของบั๊กนี้ที่ผู้ใช้เลือกทำต่อ) → ใช้ `report_dir` เดิม
- ถ้าเริ่มใหม่ → สร้าง `.claude/reports/{bug-slug}-{YYYYMMDD-HHMM}/` (timestamp จาก shell `date +%Y%m%d-%H%M`, slug เป็น kebab-case)

delegate แต่ละ subagent โดยบอก path โฟลเดอร์นี้ และชื่อไฟล์คงที่ในโฟลเดอร์ (ไม่ใส่ชื่อ feature ในไฟล์):
- feature-developer Step 1 (วินิจฉัย) → `02-feature-developer-diagnosis.md`
- feature-developer Step 2 (แก้) → `02-feature-developer-fix.md`  ← แยกจาก diagnosis เพื่อไม่ให้เขียนทับ report วินิจฉัย
- qa-tester → `03-qa-tester.md`

บันทึก `report_dir` และ path เต็มของทุกไฟล์ลง `_state.json`

## Pipeline steps

### Step 1 — วิเคราะห์และ reproduce (feature-developer, debug mode)

Delegate to the `feature-developer` agent in debugging mode. บอกให้มันใช้ skill **`debug-mantra`** เป็นวินัยการวิเคราะห์ (reproduce → trace → falsify → cross-reference) แล้ว:
1. Reproduce the bug first — capture the exact error, stack trace, and reproduction steps
2. Isolate the failure location and identify the root cause (not just the symptom)
3. Report the root cause back BEFORE fixing
4. บันทึก root cause + fix plan + ไฟล์และบรรทัดที่จะแก้ ลง report ให้ละเอียดพอที่ dev ใน Step 2 จะแก้ได้เลยโดยไม่ต้องสำรวจโค้ดซ้ำจากศูนย์ — เพราะ subagent หลัง GATE เริ่ม context ใหม่ ไม่ได้รับความเข้าใจจากตัวแรกมา การเขียน plan ให้ครบตรงนี้คือการประหยัด token ของ Step 2

### 🛑 GATE — หยุดรอผู้ใช้ยืนยัน root cause

After the root cause is found, STOP. Present to the user in Thai:
- สาเหตุที่แท้จริง (root cause) พร้อมหลักฐาน
- วิธีแก้ที่เสนอ (สั้นๆ)

Ask: **"ยืนยัน root cause และวิธีแก้นี้ไหม? พิมพ์ 'แก้เลย' หรือบอกถ้าเข้าใจผิด"**

Wait for approval before fixing. This gate prevents fixing the wrong thing.

### Step 2 — แก้และกัน regression (feature-developer)

After approval, delegate to `feature-developer`. Tell it to read the Step 1 report first (root cause + fix plan + exact file/line locations) and go straight to the fix without re-exploring the codebase. Then:
1. Implement the minimal fix targeting the root cause
2. Write a regression test that fails before the fix and passes after — so this bug can't silently return
3. Run the full test suite and confirm nothing else broke

### Step 3 — ยืนยันว่าหายจริง (qa-tester)

Delegate to `qa-tester` to independently verify the bug is gone, the regression test is meaningful, and no new issues were introduced. It should re-run the original reproduction steps.

### Step 4 — เขียน post-mortem

หลัง qa-tester ยืนยันว่าบั๊กหายจริง ให้เรียก skill **`post-mortem`** เขียนบันทึกทางวิศวกรรมของบั๊กนี้ (root cause, กลไกที่เกิด, สิ่งที่แก้, การ validate, และมันหลุดมาได้ยังไง) ลงใน run report directory เป็น `05-post-mortem.md`

### เสร็จสิ้น

Summarize in Thai: root cause, สิ่งที่แก้, regression test ที่เพิ่ม, ผลยืนยันจาก qa-tester, และ path ของ post-mortem. List the report file paths in `.claude/reports/`.

## การบันทึกสถานะ (รองรับ pause/resume)

ตลอด pipeline ให้เขียน/อัปเดต `.claude/reports/_state.json` ตาม convention ของ `pipeline-state`:
- หลังจบแต่ละ step: อัปเดต `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_dir`, `report_files`, `notes`, `updated_at`
- ตอนเริ่มคำสั่ง: เช็คก่อนว่ามี `_state.json` ของ feature เดียวกันที่ยังค้างอยู่ไหม ถ้ามีให้ถามผู้ใช้ว่า "ทำต่อจากที่ค้าง หรือเริ่มใหม่?"
- เมื่อ workflow เสร็จ: set `status: "done"`
ทำแบบนี้เพื่อให้ผู้ใช้พิมพ์ `/pause` หยุดกลางคัน แล้ว `/resume` กลับมาทำต่อได้แม้เปิด session ใหม่

## กฎสำคัญ
- delegate ทุกครั้ง อย่าแก้เอง
- อย่าข้าม GATE ยืนยัน root cause
- ต้องมี regression test เสมอ — ห้ามแก้แบบไม่มี test กัน
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
- สื่อสารเป็นภาษาไทย
