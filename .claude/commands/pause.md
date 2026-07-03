---
description: หยุดงานที่กำลังทำอยู่ชั่วคราว บันทึกสถานะไว้เพื่อกลับมาทำต่อภายหลัง (ข้าม session ได้)
---

You are pausing the current in-progress workflow so it can be resumed later, possibly in a completely new session after the machine is closed. Report in Thai.

Optional note from the user about why/what they're pausing:
$ARGUMENTS

## Steps

### Step 1 — รวบรวมสถานะปัจจุบัน

Determine where the current workflow stands:
1. Read `.claude/reports/_state.json` if it exists (it holds the running workflow's progress).
2. Read the most recent report files in `.claude/reports/` to understand what's been done.
3. If an agent team is currently running, note that teammates will be lost on session close — instruct the user to let the lead shut them down first, and record what each teammate had completed.

### Step 2 — เขียนสถานะให้ครบเพื่อ resume ได้

Update `.claude/reports/_state.json` (following the `pipeline-state` convention):
- set `status` to `"paused"`
- fill `next_action` with a precise, plain-Thai description of exactly what to do next
- fill `notes` with ALL context needed to resume cleanly: decisions made, deviations from spec, half-finished work, anything in-flight. Write it for someone with zero memory of this session.
- add the user's pause note (from arguments) into `notes` if provided
- update `updated_at`

If no `_state.json` exists yet (e.g. work was done manually without a pipeline command), create one now capturing the current situation as best you can from the report files and conversation.

### เสร็จสิ้น

Confirm to the user in Thai:
- ✅ บันทึกสถานะแล้ว งานค้างที่ขั้นไหน
- 📌 กลับมาทำต่อได้ด้วยคำสั่ง `/resume`
- ⚠️ ถ้ามี agent team ทำงานอยู่ เตือนให้ปิด teammate ก่อนปิด session (ไม่งั้น team จะหาย)

## กฎสำคัญ
- เขียน `notes` ให้ละเอียดพอที่จะ resume ได้แม้เปิด session ใหม่ในอีกหลายวัน
- อย่าลบไฟล์สรุปหรือ state เดิม
- สื่อสารเป็นภาษาไทย
