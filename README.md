# ชุด Subagent + Slash Command สำหรับ Claude Code

ชุดเครื่องมือครบวงจรสำหรับงานพัฒนาซอฟต์แวร์ใน Claude Code ประกอบด้วย **subagent เฉพาะทาง 5 ตัว** และ **slash command 9 คำสั่ง** ที่เรียกใช้ agent เหล่านั้นตามสูตรที่เหมาะกับแต่ละสถานการณ์ ทุกขั้นตอนเขียนสรุปเป็นไฟล์ `.md` และสื่อสารกับคุณเป็นภาษาไทย

---

## Subagent (5 ตัว)

| Agent | หน้าที่ | สิทธิ์ |
|---|---|---|
| `system-analyst` | วิเคราะห์ requirement เขียน spec + API contract | อ่าน + เขียนสรุป |
| `feature-developer` | เขียนโค้ด/แก้บั๊ก/refactor ตาม spec | อ่าน/เขียน/แก้/รันคำสั่ง |
| `qa-tester` | ทดสอบ หา bug (ไม่แก้โค้ดเอง) | อ่าน/รันคำสั่ง/เขียนสรุป |
| `code-reviewer` | รีวิวคุณภาพ + security (ไม่แก้โค้ดเอง) | อ่าน/รันคำสั่ง/เขียนสรุป |
| `code-explainer` | อธิบายว่าโค้ด/ระบบทำงานยังไง | อ่าน/รันคำสั่ง/เขียนสรุป |

---

## Slash Command (9 คำสั่ง)

พิมพ์ชื่อคำสั่งตามด้วยคำอธิบาย แล้วที่เหลือทำงานเอง

| คำสั่ง | ใช้เมื่อ | Agent ที่เกี่ยวข้อง | จุดหยุดตรวจ (GATE) |
|---|---|---|---|
| `/build-feature` | สร้างฟีเจอร์ใหม่ตั้งแต่ต้น | ครบทั้ง 4 ตัว | ตรวจ spec ก่อน dev |
| `/fix-bug` | แก้บั๊ก | dev + qa | ยืนยัน root cause ก่อนแก้ |
| `/hotfix` | แก้ด่วนขึ้น production | dev + qa | ยืนยันก่อนแตะ production |
| `/refactor` | ปรับโครงสร้างโค้ด (พฤติกรรมเดิม) | qa + dev + qa | เช็ค test coverage ก่อน |
| `/write-tests` | เขียน test ให้โค้ดที่ยังไม่มี | qa + dev | ตรวจ test plan ก่อนเขียน |
| `/review-pr` | รีวิวโค้ดที่มีอยู่ (PR/branch/commit) | code-reviewer | — |
| `/security-audit` | ตรวจความปลอดภัยเชิงลึก | code-reviewer (security) | — |
| `/explain` | อธิบายว่าโค้ดส่วนนี้ทำงานยังไง | code-explainer | — |
| `/spec-only` | ออกแบบ spec อย่างเดียว ไม่เขียนโค้ด | system-analyst | — |

---

## วิธีติดตั้ง

คัดลอกไฟล์เข้าโครงสร้างนี้ในโปรเจกต์ (agent กับ command อยู่คนละโฟลเดอร์):

```
.claude/
  agents/
    system-analyst.md
    feature-developer.md
    qa-tester.md
    code-reviewer.md
    code-explainer.md
  commands/
    build-feature.md
    fix-bug.md
    hotfix.md
    refactor.md
    write-tests.md
    review-pr.md
    security-audit.md
    explain.md
    spec-only.md
```

Claude Code จะตรวจพบไฟล์อัตโนมัติภายในไม่กี่วินาที (ถ้าโฟลเดอร์เพิ่งสร้างใหม่ตอน session เปิดอยู่ ให้ปิด-เปิดใหม่หนึ่งครั้ง) โฟลเดอร์ `.claude/reports/` ไม่ต้องสร้างเอง — agent สร้างให้ตอนเขียนไฟล์สรุปครั้งแรก

---

## ตัวอย่างการใช้แต่ละคำสั่ง

### `/build-feature` — สร้างฟีเจอร์ใหม่
```
/build-feature ระบบล็อกอินด้วยอีเมล/รหัสผ่าน รองรับ reset password และจำกัดล็อกอินผิด 5 ครั้ง
```
รัน: วิเคราะห์ → **หยุดให้ตรวจ spec** → พัฒนา (เลือก dev เดี่ยว/คู่ขนานเองตามขนาดงาน — ดูส่วน Agent Team) → ทดสอบ → รีวิว

### `/fix-bug` — แก้บั๊ก
```
/fix-bug กดปุ่ม submit ฟอร์มแล้วขึ้น 500 เฉพาะตอนที่ช่องหมายเหตุมี emoji
```
รัน: reproduce + หา root cause → **หยุดยืนยัน root cause** → แก้ + เขียน regression test → qa ยืนยันหาย

### `/hotfix` — แก้ด่วน production
```
/hotfix production ล่ม หน้า checkout error ตั้งแต่ deploy รอบล่าสุด สงสัยที่ payment service
```
รัน: วินิจฉัยเร็ว เสนอ fix เล็กสุด → **หยุดยืนยันก่อนแตะ production** → แก้ + smoke test → verify แบบ scoped

### `/refactor` — ปรับโครงสร้าง
```
/refactor แยกฟังก์ชัน processOrder ที่ยาว 300 บรรทัดใน orderService.js ให้เป็นฟังก์ชันย่อยที่อ่านง่าย
```
รัน: เช็ค test baseline → **หยุดเช็ค coverage** → refactor (พฤติกรรมห้ามเปลี่ยน) → qa ยืนยันเหมือนเดิม

### `/write-tests` — เพิ่ม test
```
/write-tests เขียน unit test ให้ utils/dateFormatter.js ที่ตอนนี้ยังไม่มี test เลย
```
รัน: qa วางแผนว่าควรทดสอบอะไร → **หยุดตรวจ test plan** → dev เขียน test → qa ตรวจว่า test มีความหมาย

### `/review-pr` — รีวิวโค้ดที่มีอยู่
```
/review-pr รีวิว branch feature/payment-refund เทียบกับ main
```
รัน: หา diff → code-reviewer รีวิวจัดลำดับความสำคัญ (Critical/Warning/Suggestion)

### `/security-audit` — ตรวจความปลอดภัย
```
/security-audit ตรวจส่วน authentication และ API endpoints ทั้งหมด
```
รัน: code-reviewer โหมด security ไล่ injection, auth flaw, secrets, ฯลฯ จัดลำดับตาม severity

### `/explain` — อธิบายโค้ด
```
/explain อธิบายว่าระบบ authentication ในโปรเจกต์นี้ทำงานยังไงตั้งแต่ login จน session หมดอายุ
```
รัน: code-explainer สำรวจ + อธิบายสถาปัตยกรรม, data flow, จุดสำคัญ เป็นภาษาไทย

### `/spec-only` — ออกแบบอย่างเดียว
```
/spec-only ออกแบบระบบ notification แบบ real-time แต่ยังไม่ต้องเขียนโค้ด อยากดู spec ก่อน
```
รัน: system-analyst เขียน spec เต็ม แล้วหยุด (ต่อด้วย `/build-feature` ทีหลังได้)

---

## Agent Team: ให้ dev ทำ backend + frontend คู่ขนาน

โดยปกติ `feature-developer` จะทำงานทีละอย่าง (sequential) แต่ถ้างานมีทั้ง backend และ frontend เป็นชิ้นใหญ่พอๆ กัน สามารถให้ dev สองตัวทำ**พร้อมกัน**และ**คุยกันเองระหว่างทาง**ได้ ด้วยฟีเจอร์ Agent Team ของ Claude Code

### ต่างจาก subagent ปกติยังไง

| | Subagent ปกติ | Agent Team |
|---|---|---|
| การทำงาน | ทีละตัว ส่งผลกลับ | หลายตัวพร้อมกัน |
| การสื่อสาร | รายงานกลับตัวสั่งเท่านั้น | teammate คุยกันเองได้ |
| เหมาะกับ | งาน sequential (bug, review, spec) | backend/frontend คู่ขนานที่ต้อง sync API contract |
| ค่าใช้จ่าย | ต่ำ | สูงกว่า (แต่ละตัวมี context แยกเต็ม) |

### ขั้นตอนที่ 0: เปิดใช้งานก่อน (จำเป็น)

Agent Team เป็น experimental feature ปิดไว้เป็น default ต้องเปิดใน `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

> ถ้าไม่เปิดตัวนี้ `/build-feature` จะ fallback ไปทำ backend ก่อนแล้วค่อย frontend แบบ sequential แทน (ยังทำงานได้ แค่ไม่ขนาน)

### วิธีที่ 1: ผ่าน `/build-feature` (อัตโนมัติ)

เมื่อเปิด Agent Team แล้ว `/build-feature` จะ**ตัดสินใจเองใน Step 2** ว่าจะใช้ agent team หรือไม่:
- งานเล็ก / มีแค่ backend หรือ frontend อย่างเดียว → dev คนเดียว (sequential)
- งานใหญ่มีทั้ง backend + frontend + มี API contract ชัด → สร้าง team `dev-backend` + `dev-frontend` ให้เอง

คุณไม่ต้องทำอะไรเพิ่ม แค่เปิด flag ไว้ Claude จะเลือกโหมดที่เหมาะเอง และแจ้งให้ทราบว่าเลือกโหมดไหนเพราะอะไร

### วิธีที่ 2: เรียก dev คู่ขนานแบบ manual

ถ้าอยากคุมเอง ไม่ผ่าน `/build-feature` ทำตามนี้ (สมมติมี spec จาก system-analyst แล้ว):

```
สร้าง agent team 2 คนโดยใช้ definition ของ feature-developer agent:

teammate "dev-backend": อ่าน spec จาก .claude/reports/01-system-analyst-*.md
แล้ว implement เฉพาะส่วน backend ตาม Backend section และ API contract
ทำงานในโฟลเดอร์ src/backend/ พร้อมเขียน unit test ของแต่ละ endpoint

teammate "dev-frontend": อ่าน spec ไฟล์เดียวกัน
แล้ว implement เฉพาะส่วน frontend ตาม Frontend section
เริ่มด้วย mock data ที่ตรงกับ API contract ไปก่อน แล้วค่อยเชื่อมของจริงเมื่อ backend พร้อม
ทำงานในโฟลเดอร์ src/frontend/

ทั้งสองคนต้องส่งข้อความหากันโดยตรงเมื่อ:
- ฝ่ายใดฝ่ายหนึ่งจะเปลี่ยนหรือขอความชัดเจนเรื่อง API contract
- backend ทำ endpoint เสร็จ (แจ้ง frontend ให้เลิกใช้ mock)
- frontend เจอ edge case ที่ contract ไม่ครอบคลุม

ห้ามเปลี่ยน API contract ฝ่ายเดียว ต้องตกลงกันก่อน
แต่ละคนเขียนไฟล์สรุปของตัวเองตามที่ระบุใน agent definition
ใช้ git worktree แยกกันเพื่อกัน conflict
```

จากนั้นปิดทีมก่อนไปขั้น qa:
```
ปิด teammate ทั้งหมด แล้วสรุปว่า backend กับ frontend ทำอะไรไปบ้าง และมีจุดไหนเบี่ยงจาก API contract หรือไม่
```
แล้วต่อด้วย qa-tester และ code-reviewer ตามปกติ

### ข้อควรรู้ / ข้อจำกัด

- **teammate ไม่ได้รับ conversation history มา** — ต้องบอก context ที่จำเป็นตอน spawn (สั่งให้อ่าน spec จากไฟล์คือวิธีที่ดีที่สุด)
- **ปิด session แล้วทีมหาย** — `/resume` กู้ teammate ไม่ได้ ต้องสร้างทีมใหม่ (เก็บ spec เป็นไฟล์ช่วยได้มาก)
- **1 session มีได้ 1 ทีม** — ต้องปิดทีมเก่าก่อนสร้างทีมใหม่
- **ใช้ token มากกว่า sequential** — เหมาะเฉพาะงานที่ backend/frontend ใหญ่พอจะคุ้ม ถ้างานเล็กใช้ dev คนเดียวประหยัดกว่า
- **split-pane (เห็นทุก teammate แยกช่อง)** ต้องใช้ terminal ที่รองรับ tmux หรือ iTerm2 (VS Code integrated terminal / Windows Terminal ใช้ split-pane ไม่ได้ แต่ in-process mode ยังใช้ได้ทุก terminal)

---

## ไฟล์สรุปใน `.claude/reports/`

แต่ละ agent เขียนสรุปงานเป็นไฟล์ ทำให้ agent ตัวถัดไปอ่านต่อได้ และคุณตรวจย้อนหลังได้:

```
01-system-analyst-{ฟีเจอร์}.md
02-feature-developer-{scope}-{ฟีเจอร์}.md
03-qa-tester-{ฟีเจอร์}.md
04-review-{ฟีเจอร์}.md
explain-{หัวข้อ}.md
```

---

## แนวคิดการออกแบบ

- **agent = ความเชี่ยวชาญ, command = สูตรการเรียกใช้** — 9 command ใช้ agent 5 ตัวเดิมซ้ำ แต่เรียงลำดับและตั้งโหมดต่างกันตามสถานการณ์
- **แต่ละ agent ทำเฉพาะหน้าที่ตัวเอง** — qa/reviewer/explainer ไม่แก้โค้ด แค่รายงาน เพื่อให้ผลแต่ละขั้นชัดเจน
- **GATE หยุดตรวจในจุดเสี่ยง** — spec, root cause, การแตะ production คือจุดที่ผิดแล้วแพง จึงบังคับให้หยุดถามก่อนเสมอ
- **สื่อสารภาษาไทย เขียนโค้ด/สรุปตามมาตรฐานสากล**

---

## ปรับแต่งเพิ่มเติม

- **เปลี่ยนที่เก็บ report**: find-replace `.claude/reports/` ในทุกไฟล์ agent
- **แจ้งเตือนอัตโนมัติ**: ตั้ง `SubagentStart`/`SubagentStop` hook ใน `settings.json`
- **เปลี่ยนโมเดล**: แก้ `model:` ในแต่ละ agent (เช่น `haiku` งานเบา, `opus` งานหนัก)
- **เปิด agent team สำหรับ dev คู่ขนาน**: ดูรายละเอียดเต็มในส่วน "Agent Team" ด้านบน (ตั้ง `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` ใน `settings.json`)