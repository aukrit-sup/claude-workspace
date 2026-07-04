---
description: รีวิวโค้ดที่มีอยู่แล้ว (PR / branch / commit) โดยไม่ต้องรัน pipeline เต็ม
---

You are the code review orchestrator. The user wants a review of existing code specified in the arguments below (could be a PR number, branch name, commit range, or a set of files). Report in Thai.

What to review:
$ARGUMENTS

## โฟลเดอร์รายงานของ run นี้

สร้างโฟลเดอร์ใหม่ต่อการรันหนึ่งครั้งเพื่อไม่ให้รายงานเขียนทับของเดิม: `.claude/reports/{target-slug}-{YYYYMMDD-HHMM}/` (timestamp จาก shell `date +%Y%m%d-%H%M`, slug เป็น kebab-case ของ branch/PR/target) แล้วสั่งให้ code-reviewer เขียนรีวิวลงโฟลเดอร์นี้เป็น `04-review.md` บันทึก `report_dir` ลง `_state.json`

## Steps

### Step 1 — ระบุขอบเขต

Figure out exactly what to review from the arguments:
- If it's a branch or PR, run `git diff` against the base branch (usually main/master) to get the changeset
- If it's a commit range, diff that range
- If it's files, review those files
- If ambiguous, ask the user in Thai which branch/PR/commit they mean before proceeding

### Step 2 — รีวิว (code-reviewer)

Delegate to the `code-reviewer` agent to review the identified changeset. Since there's no spec/dev/qa report in this flow, tell code-reviewer to review based on the diff and surrounding code context directly, not to expect prior pipeline reports.

### เสร็จสิ้น

Present the review to the user in Thai, organized by priority (🔴 Critical / 🟡 Warning / 🔵 Suggestion). The code-reviewer will also write the full review to `.claude/reports/`. Give the user the file path.

## การบันทึกสถานะ

คำสั่งนี้เป็น step เดียวจบ แต่หลังทำเสร็จให้บันทึกลง `.claude/reports/_state.json` (ตาม convention `pipeline-state`) ว่าทำอะไรไป เพื่อให้ `/resume` เห็นประวัติได้ ถ้ามี workflow อื่นค้างอยู่ก่อนหน้า อย่าเขียนทับ — ให้บันทึกงานนี้แยกหรือถามผู้ใช้ก่อน

## กฎสำคัญ
- delegate ให้ code-reviewer อย่ารีวิวเอง
- ไม่แก้โค้ด แค่รีวิวและรายงาน
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
- สื่อสารเป็นภาษาไทย
