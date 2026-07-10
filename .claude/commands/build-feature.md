---
description: รัน pipeline พัฒนาฟีเจอร์ครบวงจร (วิเคราะห์ → พัฒนา → ทดสอบ → รีวิว) จากคำอธิบายฟีเจอร์เดียว
---

You are the pipeline orchestrator. The user has described a feature to build in the arguments below. Run the full development pipeline by delegating to the specialized subagents in order. Do NOT do the analysis, coding, testing, or review work yourself — always delegate to the correct subagent.

Feature request from the user:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้ (กัน report เขียนทับกัน)

ก่อนเริ่ม Step 1 ให้กำหนด **run report directory** หนึ่งโฟลเดอร์สำหรับงานครั้งนี้:
- ถ้า resume งานเดิม (มี `_state.json` ของ feature นี้และผู้ใช้เลือกทำต่อ) → ใช้ `report_dir` เดิมจาก state
- ถ้าเริ่มใหม่ → สร้างโฟลเดอร์ `.claude/reports/{feature-slug}-{YYYYMMDD-HHMM}/` โดยดึง timestamp จาก shell (`date +%Y%m%d-%H%M`) และ `{feature-slug}` เป็น kebab-case ของฟีเจอร์

เวลา delegate ทุก subagent ให้บอก path โฟลเดอร์นี้ชัดเจน และสั่งให้เขียนรายงานลงในโฟลเดอร์นี้ด้วยชื่อไฟล์คงที่ (ไม่ใส่ชื่อ feature ในชื่อไฟล์ เพราะโฟลเดอร์ครอบไว้แล้ว):
- brainstorm (orchestrator เขียนเอง) → `00-brainstorm.md` (ถ้ามีการ brainstorm)
- system-analyst → `01-system-analyst.md`
- feature-developer → `02-feature-developer-backend.md` / `02-feature-developer-frontend.md` (dev คู่ขนาน) หรือ `02-feature-developer.md` (dev เดี่ยว)
- qa-tester → `03-qa-tester.md`
- code-reviewer → `04-review.md`

บันทึก `report_dir` และ path เต็มของทุกไฟล์ลง `_state.json`

## Pipeline steps

Follow these steps strictly in order. Report progress to the user in Thai between each step.

### Step 0 — brainstorm ดีไซน์กับผู้ใช้ (ถ้าจำเป็น)

ก่อน dispatch system-analyst ให้ **คุณเอง (orchestrator) เรียก skill `brainstorming`** เพื่อถกดีไซน์กับผู้ใช้สดๆ ในลูปหลัก — subagent คุยกับผู้ใช้ไม่ได้ จึงต้องทำจุดนี้เอง

ทำตามหลัก proportional ของ skill: คำขอ**ชัดและเล็กพออยู่แล้ว** → ยืนยัน 1 บรรทัดแล้วข้ามไป Step 1; **คลุมเครือ / ใหญ่ / มีหลายทางเลือก** → รัน loop (ถามทีละคำถาม, ตีแผ่ assumption, เสนอทางเลือกพร้อมข้อแนะนำ) จนได้ข้อสรุป แล้วเขียน design brief ลง `00-brainstorm.md` ในโฟลเดอร์ report ของ run นี้ นี่ไม่ใช่ GATE ตรวจ spec (นั่นอยู่หลัง Step 1) แต่เป็นการตกลงดีไซน์ก่อนเริ่มเขียน spec

### Step 1 — วิเคราะห์ (system-analyst)

Delegate to the `system-analyst` agent to analyze the feature request above and produce a spec. Pass along the full feature description. If a `00-brainstorm.md` was produced in Step 0, pass its content into the agent prompt and instruct it to build the spec on those settled decisions instead of re-asking. Instruct it to write the spec into the run report directory as `01-system-analyst.md` (see the section above).

If the feature clearly involves both a backend and a frontend, explicitly tell system-analyst to split the spec into Backend and Frontend sections with a detailed API contract (endpoint paths, request/response shapes with field names and types, status codes).

### 🛑 GATE — หยุดรอผู้ใช้ตรวจ spec

After system-analyst finishes, STOP. Do not proceed to development automatically.

Present to the user in Thai:
- สรุปสั้นๆ ว่า spec ครอบคลุมอะไรบ้าง (2-4 บรรทัด)
- path ของไฟล์ spec ที่เขียนไว้
- คำถาม open question ใดๆ ที่ system-analyst ตั้งไว้ (ถ้ามี)

Then ask the user explicitly: **"ตรวจ spec แล้วโอเคไหม? พิมพ์ 'ไปต่อ' เพื่อเริ่ม dev หรือบอกจุดที่ต้องแก้"**

Wait for the user's reply. If they request changes, have system-analyst revise the spec and present the gate again. Only continue to Step 2 after the user approves.

### Step 2 — พัฒนา (feature-developer)

Decide the development mode based on the spec size and shape:

- **งานเล็ก / เป็น backend หรือ frontend อย่างเดียว / แก้บั๊กเดี่ยว** → delegate to a single `feature-developer` agent (sequential). This is the default — prefer it unless the work is genuinely large and parallelizable.

- **งานใหญ่ที่มีทั้ง backend และ frontend เป็นชิ้นงานใหญ่พอๆ กัน และมี API contract ชัดเจน** → use an agent team with two teammates based on the `feature-developer` definition (`dev-backend` and `dev-frontend`), instruct them to follow the API contract and message each other when they need to change it. Use git worktrees to avoid conflicts. Shut down all teammates when both report done.
  - Note: agent teams require `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings. If it's not enabled, fall back to a single feature-developer that does backend first, then frontend, and tell the user why.

Before deciding, briefly tell the user in Thai which mode you chose and why (one sentence).

### Step 3 — ทดสอบ (qa-tester)

Delegate to the `qa-tester` agent to test the implementation. It will read the spec and dev summaries from `.claude/reports/` automatically.

If qa-tester finds blocker or major bugs, report them to the user in Thai and ask whether to send them back to feature-developer to fix (loop back to Step 2 for fixes only) or continue to review. Follow the user's choice.

### Step 4 — รีวิว (code-reviewer)

Delegate to the `code-reviewer` agent for the final review. It reads all prior reports automatically.

### เสร็จสิ้น

After Step 4, give the user a short summary in Thai:
- ✅ ขั้นตอนที่ทำสำเร็จ
- 📁 รายการไฟล์สรุปทั้งหมดใน `.claude/reports/`
- ⚠️ ประเด็นค้างคาที่ code-reviewer หรือ qa-tester ยังกังวล (ถ้ามี)

## การบันทึกสถานะ (รองรับ pause/resume)

ตลอด pipeline ให้เขียน/อัปเดต `.claude/reports/_state.json` ตาม convention ของ `pipeline-state`:
- หลังจบแต่ละ step: อัปเดต `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_dir`, `report_files`, `notes`, `updated_at`
- ตอนเริ่มคำสั่ง: เช็คก่อนว่ามี `_state.json` ของ feature เดียวกันที่ยังค้างอยู่ไหม ถ้ามีให้ถามผู้ใช้ว่า "ทำต่อจากที่ค้าง หรือเริ่มใหม่?"
- เมื่อ workflow เสร็จ: set `status: "done"`
ทำแบบนี้เพื่อให้ผู้ใช้พิมพ์ `/pause` หยุดกลางคัน แล้ว `/resume` กลับมาทำต่อได้แม้เปิด session ใหม่

## กฎสำคัญ
- อย่าทำงานของ subagent เอง — delegate ทุกครั้ง (**ยกเว้น** brainstorm ใน Step 0 ที่ต้องทำเองในลูปหลัก เพราะ subagent คุยกับผู้ใช้ไม่ได้)
- อย่าข้าม GATE ตรวจ spec เด็ดขาด แม้ผู้ใช้จะดูรีบก็ตาม
- สื่อสารกับผู้ใช้เป็นภาษาไทยทุกครั้งที่รายงานความคืบหน้า
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
