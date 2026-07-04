---
description: กลับมาทำงานที่ pause ไว้ต่อจากจุดเดิม (อ่านสถานะจากไฟล์ ทำงานต่อได้แม้เปิด session ใหม่)
---

You are resuming a previously paused workflow. This may be a brand-new session with zero memory of the earlier work, so you must rebuild context entirely from files. Report in Thai.

Optional hint from the user (e.g. which feature to resume if multiple):
$ARGUMENTS

## Steps

### Step 1 — อ่านสถานะที่บันทึกไว้

1. Read `.claude/reports/_state.json`. This is the source of truth for where the workflow stopped.
   - If it doesn't exist, tell the user in Thai there's no paused workflow found, and list what's in `.claude/reports/` so they can decide what to do.
   - If multiple done-state files exist, use the active `_state.json`; use the user's hint to disambiguate if needed.
2. Read ALL files listed in the state's `report_files` to rebuild full context — especially the spec (`01-system-analyst-*`) and any dev/qa/review reports.
3. Pay close attention to the `notes` field — it contains decisions and in-flight context from before the pause.

### Step 2 — ยืนยันกับผู้ใช้ก่อนทำต่อ

Present a short recap in Thai:
- งานอะไร (feature) และ workflow ไหน
- ทำถึงขั้นไหนแล้ว (completed steps)
- ขั้นถัดไปคืออะไร (next_action)
- context สำคัญจาก notes (decisions, จุดค้าง)

Ask: **"ทำต่อจากขั้นนี้เลยไหม? พิมพ์ 'ต่อเลย' หรือบอกถ้าอยากปรับ"**

Wait for confirmation. This guards against resuming stale work the user has since changed their mind about.

### Step 3 — ทำงานต่อ

After confirmation, continue the workflow from `next_action`, delegating to the appropriate subagents exactly as the original command would. Honor any GATEs that still lie ahead (e.g. if resuming before the spec-review gate, still stop for it).

Any new reports produced after resuming go into the existing `report_dir` from the state — do NOT create a new run folder. Tell each delegated subagent that exact directory path and the fixed in-folder filename it should use.

Update `.claude/reports/_state.json` to `status: "in_progress"` and keep updating it after each step (per the `pipeline-state` convention), so the work can be paused again later.

### เสร็จสิ้น

When the workflow completes, mark the state `done` and give the user the standard end-of-workflow summary in Thai.

## กฎสำคัญ
- สร้าง context ใหม่จากไฟล์ทั้งหมด อย่าเดาจากความจำ (session อาจใหม่หมด)
- ยืนยันกับผู้ใช้ก่อนทำต่อเสมอ
- GATE ที่ยังไม่ผ่านต้องหยุดตามเดิม
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
- สื่อสารเป็นภาษาไทย
