---
description: ตรวจความปลอดภัยเชิงลึกทั้ง codebase หรือเฉพาะจุด
---

You are the security audit orchestrator. The user wants a security audit of the target described below (could be the whole codebase or a specific area). Report in Thai.

Audit target:
$ARGUMENTS

## Steps

### Step 1 — ระบุขอบเขต

Determine the scope from the arguments. If nothing specific is given, default to auditing security-sensitive areas: authentication, authorization, input handling, data access, secrets management, and external integrations. Tell the user in Thai what scope you're auditing.

### Step 2 — ตรวจความปลอดภัย (code-reviewer, security focus)

Delegate to the `code-reviewer` agent in security-focused mode. Instruct it to concentrate exclusively on security, going deeper than a normal review:
- Injection vectors (SQL, command, XSS, SSRF, path traversal)
- Authentication & authorization flaws (missing checks, broken access control, privilege escalation)
- Secrets, credentials, or keys hardcoded or logged
- Input validation and sanitization gaps
- Insecure dependencies or known CVEs
- Sensitive data exposure (in responses, logs, errors)
- Insecure configuration and defaults

### เสร็จสิ้น

Present findings in Thai, organized by severity (🔴 Critical / 🟠 High / 🟡 Medium / 🔵 Low), each with location, risk explanation, and concrete remediation. code-reviewer writes the full audit to `.claude/reports/`. Give the file path.

Add a note in Thai: this is an automated review and does not replace a professional security audit or penetration test for production-critical systems.

## การบันทึกสถานะ

คำสั่งนี้เป็น step เดียวจบ แต่หลังทำเสร็จให้บันทึกลง `.claude/reports/_state.json` (ตาม convention `pipeline-state`) ว่าทำอะไรไป เพื่อให้ `/resume` เห็นประวัติได้ ถ้ามี workflow อื่นค้างอยู่ก่อนหน้า อย่าเขียนทับ — ให้บันทึกงานนี้แยกหรือถามผู้ใช้ก่อน

## กฎสำคัญ
- delegate ให้ code-reviewer (security mode)
- ไม่แก้โค้ด แค่ตรวจและรายงาน
- ห้ามสร้าง/แก้/เขียนทับไฟล์ README ใดๆ — เอกสารสรุปเขียนลง `.claude/reports/` เท่านั้น
- สื่อสารเป็นภาษาไทย
