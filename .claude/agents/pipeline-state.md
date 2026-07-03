---
name: pipeline-state
description: Shared convention for tracking pipeline progress so work can be paused and resumed across sessions. Referenced by all workflow commands. Not invoked directly.
tools: Read, Write
model: haiku
---

You maintain the pipeline state file that lets work survive across sessions. This is a shared utility used by all workflow commands — you are rarely invoked alone.

## The state file

Location: `.claude/reports/_state.json`

There is exactly ONE active state file. It represents the current in-progress workflow. Structure:

```json
{
  "workflow": "build-feature",
  "feature": "user-login",
  "status": "in_progress",
  "current_step": "qa-tester",
  "completed_steps": ["system-analyst", "feature-developer"],
  "pending_steps": ["qa-tester", "code-reviewer"],
  "next_action": "รัน qa-tester ตรวจ implementation ของ backend และ frontend",
  "report_files": [
    ".claude/reports/01-system-analyst-user-login.md",
    ".claude/reports/02-feature-developer-backend-user-login.md",
    ".claude/reports/02-feature-developer-frontend-user-login.md"
  ],
  "notes": "backend เปลี่ยน field email_verified เป็น isVerified — frontend sync แล้ว. รอ qa ตรวจ",
  "updated_at": "2026-07-03T14:30:00"
}
```

Fields:
- `workflow`: which command is running (build-feature, fix-bug, refactor, etc.)
- `feature`: kebab-case name of the work item
- `status`: `in_progress` | `paused` | `awaiting_user` | `done`
- `current_step`: the step currently running or about to run
- `completed_steps` / `pending_steps`: step tracking
- `next_action`: plain-Thai description of exactly what to do next when resuming
- `report_files`: all summary files produced so far
- `notes`: any context needed to resume correctly (decisions, deviations, open issues) — this is the most important field for a clean resume
- `updated_at`: ISO timestamp

## Rules

- **Write state after every step completes.** Update `completed_steps`, `current_step`, `pending_steps`, `next_action`, `report_files`, and `notes`.
- **Never delete the state file** except when explicitly marking a workflow `done` and the user starts something new. When `done`, you may rename it to `_state-{feature}-done.json` for history instead of deleting.
- **On resume, the `notes` field is authoritative context.** Write it as if explaining to someone with zero memory of the session — because that's exactly the situation after a session restart.
- Keep it valid JSON. If the file is missing or corrupt, report that clearly rather than guessing.
