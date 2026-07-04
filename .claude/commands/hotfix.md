---
description: แก้ด่วนขึ้น production — เวอร์ชันเร่งรัดของ fix-bug เน้นเร็วและปลอดภัยเฉพาะจุด (ใช้ด้วยความระวัง)
---

You are the hotfix orchestrator. This is an urgent production fix. Speed matters, but a hotfix that breaks something else is worse than a slow fix. Report in Thai.

Production issue:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้ (กัน report เขียนทับกัน)

ก่อนเริ่ม Step 1 ให้กำหนด **run report directory**:
- ถ้า resume → ใช้ `report_dir` เดิมจาก state
- ถ้าเริ่มใหม่ → สร้าง `.claude/reports/{issue-slug}-{YYYYMMDD-HHMM}/` (timestamp จาก shell `date +%Y%m%d-%H%M`)

delegate feature-developer โดยบอก path โฟลเดอร์นี้ และชื่อไฟล์คงที่ (ไม่ใส่ชื่อ feature ในไฟล์):
- Step 1 (วินิจฉัย + เสนอ fix) → `02-feature-developer-diagnosis.md`
- Step 2 (แก้ + smoke test + verify) → `02-feature-developer-fix.md`  ← แยกไฟล์ ไม่ให้ทับ report วินิจฉัย

บันทึก `report_dir` และ path เต็มลง `_state.json`

## Pipeline steps

### Step 1 — วินิจฉัยเร็ว + เสนอ fix แบบเจาะจง (feature-developer, debug mode)

Delegate to `feature-developer` in debug mode. บอกให้ใช้ skill **`debug-mantra`** เป็นกรอบวิเคราะห์แบบเร่งรัด (reproduce → trace → falsify → cross-reference — ทำเร็วแต่ไม่ข้ามขั้น) แล้วทำงานเร็วแต่โฟกัส:
1. Identify the root cause quickly
2. Propose the SMALLEST possible fix that resolves the issue — no refactoring, no unrelated cleanup, minimal blast radius
3. Report the fix plan before applying

### 🛑 GATE — ยืนยันก่อนแตะ production code

STOP. Present in Thai:
- root cause (สั้นๆ)
- fix ที่เสนอ + ไฟล์ที่จะแตะ (ยิ่งน้อยยิ่งดี)
- ความเสี่ยงที่อาจกระทบส่วนอื่น

Ask: **"ยืนยันแก้ hotfix นี้ไหม? พิมพ์ 'แก้เลย' หรือบอกถ้าไม่โอเค"**

Never skip this gate — it's the safety check that separates a hotfix from a disaster.

### Step 2 — แก้ + smoke test + verify แบบ scoped (feature-developer)

After approval, delegate to `feature-developer`. Instruct it to do the fix AND the verification in one pass:
1. Apply the minimal fix
2. Add at least a smoke test / regression test for this specific issue
3. Run the existing test suite to confirm nothing obvious broke
4. Verify the production issue itself is resolved, scoped to the affected area only (NOT a full regression sweep) — and state explicitly that the check was scoped

เหตุผลที่ไม่แยก `qa-tester` ออกมาอีกตัว: hotfix เน้นเร็วและ blast radius เล็ก การ spawn subagent ใหม่ที่ต้องโหลด context ซ้ำหมดไม่คุ้มกับงานด่วน ถ้าต้องการ verify เชิงลึกแบบอิสระ ให้ตามด้วย `/review-pr` ทีหลัง (ดู footer)

### เสร็จสิ้น

Summarize in Thai: สิ่งที่แก้, ไฟล์ที่แตะ, test ที่เพิ่ม, ผล verify. 

Add a reminder in Thai: hotfix ทำแบบเร่งรัด แนะนำให้ตามด้วยการรีวิวเต็ม (`/review-pr`), เขียน post-mortem ด้วย skill **`post-mortem`** เพื่อบันทึก root cause ไว้, และพิจารณา `/build-feature` หรือ `/refactor` สำหรับการแก้ระยะยาวที่สมบูรณ์กว่าภายหลัง

## การบันทึกสถานะ (รองรับ pause/resume)

ตลอด pipeline ให้เขียน/อัปเดต `.claude/reports/_state.json` ตาม convention ของ `pipeline-state`:
- หลังจบแต่ละ step: อัปเดต `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_dir`, `report_files`, `notes`, `updated_at`
- ตอนเริ่มคำสั่ง: เช็คก่อนว่ามี `_state.json` ของ feature เดียวกันที่ยังค้างอยู่ไหม ถ้ามีให้ถามผู้ใช้ว่า "ทำต่อจากที่ค้าง หรือเริ่มใหม่?"
- เมื่อ workflow เสร็จ: set `status: "done"`
ทำแบบนี้เพื่อให้ผู้ใช้พิมพ์ `/pause` หยุดกลางคัน แล้ว `/resume` กลับมาทำต่อได้แม้เปิด session ใหม่

## กฎสำคัญ
- fix ให้เล็กที่สุด blast radius ต่ำสุด
- อย่าข้าม GATE ยืนยันก่อนแตะ production เด็ดขาด
- ต้องมี test กันซ้ำอย่างน้อย smoke test
- ระบุชัดว่า verify แบบ scoped ไม่ใช่ full regression
- delegate ทุกครั้ง สื่อสารเป็นภาษาไทย
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
