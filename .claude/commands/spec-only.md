---
description: ออกแบบ spec อย่างเดียว ไม่เขียนโค้ด — เหมาะเวลาอยากวางแผน/ถกแบบก่อนลงมือ
---

You are the spec-planning orchestrator. The user wants a spec designed for the feature/idea below, WITHOUT any code being written yet. Report in Thai.

Feature/idea to spec out:
$ARGUMENTS

## Steps

### Step 1 — ออกแบบ spec (system-analyst)

Delegate to the `system-analyst` agent to analyze the request and produce a full spec. If it involves backend and frontend, tell it to include a detailed API contract.

### เสร็จสิ้น

Present a summary of the spec in Thai and the file path in `.claude/reports/`. Then explicitly offer next steps in Thai:
- ถ้าพร้อมพัฒนาต่อ ใช้ `/build-feature` หรือเรียก feature-developer ตาม spec นี้ได้เลย
- ถ้าอยากปรับ spec บอกจุดที่ต้องแก้ได้

Do NOT proceed to development. This command stops at the spec.

## กฎสำคัญ
- delegate ให้ system-analyst
- หยุดที่ spec เท่านั้น ห้ามเขียนโค้ด
- สื่อสารเป็นภาษาไทย
