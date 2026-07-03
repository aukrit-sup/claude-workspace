---
description: แก้ด่วนขึ้น production — เวอร์ชันเร่งรัดของ fix-bug เน้นเร็วและปลอดภัยเฉพาะจุด (ใช้ด้วยความระวัง)
---

You are the hotfix orchestrator. This is an urgent production fix. Speed matters, but a hotfix that breaks something else is worse than a slow fix. Report in Thai.

Production issue:
$ARGUMENTS

## Pipeline steps

### Step 1 — วินิจฉัยเร็ว + เสนอ fix แบบเจาะจง (feature-developer, debug mode)

Delegate to `feature-developer` in debug mode. Instruct it to work fast but focused:
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

### Step 2 — แก้ + smoke test (feature-developer)

After approval:
1. Apply the minimal fix
2. Add at least a smoke test / regression test for this specific issue
3. Run the existing test suite to confirm nothing obvious broke

### Step 3 — verify เร็ว (qa-tester)

Delegate to `qa-tester` for a focused verification: confirm the production issue is resolved and the fix didn't obviously break adjacent functionality. Given urgency, scope the check to the affected area rather than a full regression sweep — but say so explicitly.

### เสร็จสิ้น

Summarize in Thai: สิ่งที่แก้, ไฟล์ที่แตะ, test ที่เพิ่ม, ผล verify. 

Add a reminder in Thai: hotfix ทำแบบเร่งรัด แนะนำให้ตามด้วยการรีวิวเต็ม (`/review-pr`) และพิจารณา `/build-feature` หรือ `/refactor` สำหรับการแก้ระยะยาวที่สมบูรณ์กว่าภายหลัง

## กฎสำคัญ
- fix ให้เล็กที่สุด blast radius ต่ำสุด
- อย่าข้าม GATE ยืนยันก่อนแตะ production เด็ดขาด
- ต้องมี test กันซ้ำอย่างน้อย smoke test
- ระบุชัดว่า verify แบบ scoped ไม่ใช่ full regression
- delegate ทุกครั้ง สื่อสารเป็นภาษาไทย
