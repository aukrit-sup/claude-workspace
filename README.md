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
รัน: วิเคราะห์ → **หยุดให้ตรวจ spec** → พัฒนา (เลือก dev เดี่ยว/คู่ขนานเองตามขนาดงาน) → ทดสอบ → รีวิว

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
- **เปิด agent team สำหรับ dev คู่ขนาน**: ตั้ง `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` ใน `settings.json` (จำเป็นสำหรับ `/build-feature` เมื่อเลือกโหมด backend/frontend คู่ขนาน)
