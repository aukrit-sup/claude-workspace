# Claude Skills

Skills คือชุดคำสั่ง/วิธีทำงานเฉพาะทางที่ Claude Code หยิบมาใช้ระหว่างทำงาน แต่ละ
skill อยู่ในโฟลเดอร์ของตัวเองพร้อมไฟล์ `SKILL.md` ที่มี frontmatter (`name`,
`description`) และเนื้อหาแนวทางการทำงาน

Skill ในโฟลเดอร์นี้ถูก **vendor (คัดลอก)** มาจากสองรีโปต้นทาง เพื่อให้ agent ในโปรเจกต์นี้
อ้างอิงได้ทั้งแบบเรียกเอง (`/skill-name`), แบบ auto-trigger จาก `description`, และแบบ
ผูกตายตัวกับ subagent บางตัว

---

## สารบัญ

- [Skill ทำงานยังไงใน Claude Code](#skill-ทำงานยังไงใน-claude-code)
- [แหล่งที่มา](#แหล่งที่มา)
- [แคตตาล็อก Skill (รายละเอียดแต่ละตัว)](#แคตตาล็อก-skill-รายละเอียดแต่ละตัว)
  - [debug-mantra](#1-debug-mantra)
  - [post-mortem](#2-post-mortem)
  - [scrutinize](#3-scrutinize)
  - [management-talk](#4-management-talk)
  - [baseline-ui](#5-baseline-ui)
  - [fixing-accessibility](#6-fixing-accessibility)
  - [fixing-metadata](#7-fixing-metadata)
  - [fixing-motion-performance](#8-fixing-motion-performance)
- [การผูก Skill เข้ากับ Agent](#การผูก-skill-เข้ากับ-agent)
- [วิธีเรียกใช้ Skill](#วิธีเรียกใช้-skill)
- [วิธีเพิ่ม / อัปเดต / ลบ Skill](#วิธีเพิ่ม--อัปเดต--ลบ-skill)
- [ข้อควรรู้ / ข้อจำกัด](#ข้อควรรู้--ข้อจำกัด)

---

## Skill ทำงานยังไงใน Claude Code

- Claude Code จะ **discover** skill ทุกตัวใน `.claude/skills/*/SKILL.md` อัตโนมัติตอนเริ่ม session
- Claude อ่านเฉพาะช่อง `description` ของแต่ละ skill ก่อน (ยังไม่โหลดเนื้อหาเต็ม) แล้วใช้
  ข้อความ trigger ในนั้นตัดสินใจว่าจะหยิบ skill ไหนมาใช้เมื่อไหร่
- เมื่อจะใช้จริง Claude เรียกผ่าน **Skill tool** ซึ่งจะโหลด `SKILL.md` ฉบับเต็มเข้ามาแล้ว
  ทำตามคำสั่งในนั้น
- มี 3 ทางที่ skill จะถูกใช้:
  1. **ผู้ใช้พิมพ์เอง** — `/skill-name`
  2. **Auto-trigger** — Claude เลือกเองจากเงื่อนไขใน `description`
  3. **ผูกตายตัว** — agent/command ถูกสั่งไว้ในตัว prompt ให้เรียก skill นั้นเมื่อเข้าเงื่อนไข
     (ดูตาราง [การผูก Skill เข้ากับ Agent](#การผูก-skill-เข้ากับ-agent))

---

## แหล่งที่มา

### [thananon/9arm-skills](https://github.com/thananon/9arm-skills)
`debug-mantra`, `post-mortem`, `scrutinize`, `management-talk`

### [ibelick/ui-skills](https://github.com/ibelick/ui-skills)
`baseline-ui`, `fixing-accessibility`, `fixing-metadata`, `fixing-motion-performance`

> Skill ที่พึ่ง CLI ภายนอกถูกตัดออกไปแล้ว (`qwen-agent`, `qwenchance` ต้องใช้ `claude-9arm`;
> `ui-skills-root` ต้องใช้ `npx ui-skills`) — ที่เหลือทั้ง 8 ตัวเป็น guidance ล้วน ไม่พึ่ง CLI

---

## แคตตาล็อก Skill (รายละเอียดแต่ละตัว)

### 1. `debug-mantra`
> **หมวด:** Engineering · **ที่มา:** 9arm-skills

วินัยการ debug 4 ขั้น ให้ท่องบล็อก mantra ก่อนเริ่ม แล้วทำตามลำดับก่อนเสนอ fix ใดๆ

**4 ขั้นตอน:**
1. **Reproduce reliably** — สร้าง repro ที่รันซ้ำได้ก่อน (failing test / curl / replay harness); ถ้า flaky ให้ดันอัตราให้สูงก่อน; ถ้า repro ไม่ได้เลยให้หยุดและแจ้ง
2. **Know the fail path** — attach debugger ก่อน → source trace + ไล่ "knob" (config/flag/env/branch) → in-code instrumentation (tag ทุก probe เพื่อ grep ลบง่าย)
3. **Falsify the hypothesis** — ตั้งสมมติฐาน 3–5 ข้อแบบจัดอันดับ แล้ว **รัน disproof ก่อน**
4. **Every run is a breadcrumb** — เก็บ ledger ของทุกการทดลอง cross-reference กับทุกผลก่อนหน้า

**Trigger:** `/debug-mantra` หรือเมื่อผู้ใช้แจ้งบั๊ก / บอกว่าอะไรพัง throwing/failing / วางstack trace
**ผูกกับ:** `feature-developer` (โหมดวินิจฉัย), `/fix-bug`, `/hotfix`

---

### 2. `post-mortem`
> **หมวด:** Engineering · **ที่มา:** 9arm-skills

เขียนบันทึกทางวิศวกรรมฉบับ canonical ของบั๊กที่**แก้และ validate แล้ว** สำหรับวิศวกรอ่าน
(ใส่ code identifier ได้เต็มที่)

**เงื่อนไขก่อนเขียน (ขาดข้อใดข้อหนึ่ง = ปฏิเสธ):** มี repro ที่เชื่อถือได้, รู้ root cause จริง
(ไม่ใช่สมมติฐาน), ระบุ fix ได้ (PR/commit), fix ผ่านการ validate แล้ว

**โครงสร้าง:** Summary *(บังคับ)* → Symptom → Root cause *(บังคับ)* → Why it produced the
symptom → Fix *(บังคับ)* → Validation *(บังคับ)* → How it was found

**ไม่ใช้เมื่อ:** บั๊กยังไม่แก้/ยังไม่ validate, เป็น outage ที่ลูกค้าเห็น (ต้องใช้ incident report แยก),
fix จิ๊บจ๊อย (typo/one-liner)
**ประกอบกับ:** ส่งต่อ post-mortem ที่เสร็จแล้วให้ `management-talk` เพื่อทำเวอร์ชันสำหรับผู้บริหาร
**Trigger:** `/post-mortem`, "write the post-mortem / RCA", "document this fix"
**ผูกกับ:** `/fix-bug` (Step 4 หลัง verify), `/hotfix` (แนะนำใน follow-up)

---

### 3. `scrutinize`
> **หมวด:** Engineering · **ที่มา:** 9arm-skills

รีวิว plan / PR / โค้ดแบบมุมมองคนนอก — ตั้งคำถามก่อนว่า "สิ่งนี้ควรมีอยู่ไหม / มีวิธีที่ง่ายกว่าไหม"
แล้วค่อยไล่ code path จริงเพื่อยืนยันว่ามันทำตามที่อ้าง

**Workflow (ห้ามข้ามลำดับ):**
1. **Intent** — สรุปเป้าหมายเป็น 1 ประโยค; เสนอทางที่ง่าย/เล็ก/สง่ากว่า (ทำน้อยลง, ใช้ของที่มีอยู่, แก้คนละ layer) — นี่คือ output ที่มีค่าที่สุด
2. **Trace** — ไล่ code path end-to-end รวมโค้ดนอก diff ("บั๊กซ่อนอยู่ตรงรอยต่อ")
3. **Verify** — path ที่ไล่ให้ผลตามที่อ้างจริงไหม, input อะไรทำให้พัง, มันแอบเปลี่ยนอะไรเงียบๆ, test คุมจริงหรือแค่ผ่าน
4. **Report** — เรียงตาม severity (blocker → major → nit) แต่ละข้อมี Finding / Why / Evidence / Suggested change + verdict บรรทัดเดียว

**กฎ:** ห้าม rubber-stamp — "LGTM" ไม่ใช่ output
**Trigger:** `/scrutinize` หรือเมื่อขอ review / audit / sanity-check / second opinion
**ผูกกับ:** `code-reviewer` (ทุกครั้งก่อนสรุปรีวิว)

---

### 4. `management-talk`
> **หมวด:** Productivity · **ที่มา:** 9arm-skills

แปลง/เขียนเนื้อหา engineer-to-engineer ให้เหมาะกับผู้บริหารสาย engineering (VP, director, PM,
release manager) และ **ปรับรูปตามช่องทาง** ที่จะส่ง — JIRA / Slack / standup / email / talking-points

**หลักการ tone:**
- **Keep:** ชื่อ product/framework, JIRA key, PR number, ชื่อ workload/ลูกค้า
- **Strip:** function name, file path, struct field, commit SHA, env var, line number
- **Translate:** กลไกเป็นเหตุ-ผลภาษาคน 1–2 ประโยค (โดยไม่โกหก — race ยังเป็น race)
- **อย่า over-strip:** ผู้บริหารสาย eng อ่านศัพท์ระดับ concept ได้ (race condition, uninitialized buffer, fast-path) — อย่าลดเป็น "timing issue"

**ไม่ใช้กับ:** marketing / finance / customer-facing / ELI5 (ต้อง rewrite แบบอื่น)
**Trigger:** ขอเขียนให้ management/exec/VP/PM, "exec summary / leadership update", "make this less technical", "slack/email/standup version"
**การใช้:** ปล่อย auto-trigger ใน context หลัก (ไม่ผูกกับ subagent)

---

### 5. `baseline-ui`
> **หมวด:** UI · **ที่มา:** ui-skills

บังคับ UI baseline แบบมี opinion เพื่อกัน "AI-generated UI slop" — เก็บ spacing, hierarchy,
typography, layout เล็กๆ

**ครอบคลุม:** Stack (Tailwind defaults, `motion/react`, `cn` = clsx + tailwind-merge) ·
Components (ใช้ accessible primitives — Base UI/React Aria/Radix, `aria-label` บน icon-only button,
ห้าม mix primitive system) · Interaction (`AlertDialog` สำหรับ action อันตราย, `h-dvh` แทน `h-screen`,
respect `safe-area-inset`) · Animation (animate เฉพาะ `transform`/`opacity`, ≤200ms, respect
`prefers-reduced-motion`) · Typography

**Trigger:** `/baseline-ui` (ทั้ง conversation) หรือ `/baseline-ui <file>` (รีวิวไฟล์ → violation + เหตุผล + fix)
**ผูกกับ:** `feature-developer`, `code-reviewer` (เมื่อแตะ UI)

---

### 6. `fixing-accessibility`
> **หมวด:** UI · **ที่มา:** ui-skills

Audit และแก้ปัญหา a11y ของ HTML — เน้น fix เล็ก targeted ไม่ rewrite UI ทั้งก้อน

**หมวดกฎเรียงตาม priority:** accessible names → keyboard access → focus & dialogs → semantics →
forms & errors → announcements → contrast & states → media & motion → tool boundaries

**ตัวอย่างกฎ critical:** ทุก control ต้องมี accessible name, icon-only button ต้องมี `aria-label`,
ห้ามใช้ `div`/`span` เป็นปุ่มโดยไม่รองรับ keyboard, ทุก interactive element ต้อง Tab ถึง

**Trigger:** `/fixing-accessibility [<file>]` หรือเมื่อเพิ่ม control/form/dialog/keyboard interaction, รีวิว WCAG
**ผูกกับ:** `feature-developer`, `code-reviewer`, `qa-tester` (เมื่อมีส่วน UI)

---

### 7. `fixing-metadata`
> **หมวด:** UI/SEO · **ที่มา:** ui-skills

Audit และแก้ HTML metadata — title, description, canonical, Open Graph, Twitter card, favicon,
JSON-LD, robots

**Workflow:** หาหน้าที่ metadata หาย/ผิด → แก้ critical (duplicate/indexing) ก่อน → ให้ title/
description/canonical/og:url สอดคล้องกัน → verify social card บน URL จริง (ไม่ใช่ localhost) → diff เล็ก เฉพาะ metadata

**หมวดกฎเรียงตาม priority:** correctness & duplication → title & description → canonical & indexing →
social cards → icons & manifest → structured data → locale & alternates → tool boundaries

**Trigger:** `/fixing-metadata` หรือเมื่อเพิ่ม SEO metadata, แก้ social preview, ตั้ง canonical, ship หน้าใหม่
**ผูกกับ:** `feature-developer`, `code-reviewer` (เมื่อแตะหน้า/metadata)

---

### 8. `fixing-motion-performance`
> **หมวด:** UI · **ที่มา:** ui-skills

Audit และแก้ปัญหา performance ของ animation — layout thrashing, compositor properties,
scroll-linked motion, blur

**Glossary rendering steps:** composite = `transform`/`opacity` · paint = color/border/gradient/
mask/filter · layout = size/position/flow

**หมวดกฎเรียงตาม priority:** never patterns → choose the mechanism → measurement → scroll →
paint → layers → blur & filters → view transitions → tool boundaries

**ตัวอย่าง "never" critical:** ห้ามสลับ read/write layout ใน frame เดียว, ห้าม animate layout
ต่อเนื่องบน surface ใหญ่, ห้ามขับ animation จาก `scrollTop`/scroll event, ห้าม rAF loop ไม่มี stop condition

**Trigger:** `/fixing-motion-performance [<file>]` หรือเมื่อ animation กระตุก, รีวิว CSS/JS animation
**ผูกกับ:** `feature-developer`, `code-reviewer` (เมื่อแตะ animation)

---

## การผูก Skill เข้ากับ Agent

ใช้ 2 กลไกผสมกัน:

### 1. ผูกตายตัว (deterministic) — agent ถูกสั่งให้เรียก skill ตรงๆ
Agent เหล่านี้มี `Skill` tool ใน frontmatter และมีคำสั่งในตัว prompt ให้เรียก skill เมื่อเข้าเงื่อนไข:

| Agent / Command | Skill | เมื่อไหร่ |
|-----------------|-------|----------|
| `code-reviewer` | `scrutinize` | ทุกครั้งก่อนสรุปรีวิว |
| `code-reviewer` | `fixing-accessibility`, `fixing-motion-performance`, `fixing-metadata`, `baseline-ui` | เมื่อ diff แตะ UI/HTML/CSS |
| `feature-developer` | `debug-mantra` | โหมด debug/วินิจฉัย (`/fix-bug`, `/hotfix`) |
| `feature-developer` | `baseline-ui`, `fixing-accessibility`, `fixing-metadata`, `fixing-motion-performance` | เมื่อโค้ดที่แก้แตะ UI/HTML/CSS |
| `qa-tester` | `fixing-accessibility` | เมื่อทดสอบ UI/HTML |
| `/fix-bug` (Step 4) | `post-mortem` | หลัง fix ผ่านการยืนยัน |
| `/hotfix` (footer) | `post-mortem` | แนะนำเป็น follow-up |

### 2. อัตโนมัติ (auto) — โมเดลเลือกเองจาก `description`
`management-talk` และ skill อื่นๆ ข้างบน เมื่อใช้ **นอก** agent ที่ผูกไว้ ก็ยัง fire เองใน
conversation หลักตามข้อความ trigger หรือเรียกด้วย `/skill-name`

### Agent ที่ไม่ผูก skill
`system-analyst`, `code-explainer`, `pipeline-state` — ไม่มีงานที่ตรงกับ skill ที่มี จึงปล่อยไว้ไม่ผูก

> **ข้อจำกัดสำคัญ:** subagent จะเรียก skill ได้**ก็ต่อเมื่อ**มี `Skill` อยู่ในช่อง `tools:` ของ
> frontmatter เท่านั้น — agent 3 ตัวที่ผูกไว้ถูกเพิ่ม `Skill` ให้แล้ว ถ้าจะผูก skill เข้า agent ตัวใหม่
> อย่าลืมเพิ่ม `Skill` เข้า `tools:` ด้วย

---

## วิธีเรียกใช้ Skill

- **เรียกตรงทั้ง conversation:** `/skill-name` เช่น `/scrutinize`, `/baseline-ui`
- **เรียกกับไฟล์ (skill ที่รองรับ):** `/baseline-ui path/to/Component.tsx`
- **ปล่อย auto:** แค่ทำงานตามปกติ Claude จะหยิบ skill ที่ตรงเงื่อนไขมาใช้เอง
- **ผ่าน pipeline:** รัน `/fix-bug`, `/hotfix`, `/review-pr` ฯลฯ แล้ว agent ในนั้นจะเรียก skill ที่ผูกไว้ให้อัตโนมัติ

---

## วิธีเพิ่ม / อัปเดต / ลบ Skill

**เพิ่ม skill ใหม่**
1. สร้างโฟลเดอร์ `.claude/skills/<skill-name>/` แล้วใส่ `SKILL.md`
2. `SKILL.md` ต้องมี frontmatter `name` (ตรงกับชื่อโฟลเดอร์) และ `description` ที่มี trigger ชัด
3. (ถ้าต้องการผูกกับ agent) เพิ่ม `Skill` เข้า `tools:` ของ agent นั้น + เขียนคำสั่งเรียก skill ในตัว prompt
4. อัปเดตตารางใน README นี้

**อัปเดตจากต้นทาง** — skill พวกนี้เป็น **copy ไม่ใช่ submodule** ให้ re-copy โฟลเดอร์จาก `skills/`
ของรีโปต้นทางทับ (ระวัง path ของ 9arm ที่ซ้อน category เช่น `skills/engineering/<name>/`)

**ลบ skill** — ลบทั้งโฟลเดอร์ แล้วถอดการอ้างอิงออกจาก agent/command/README ให้ครบ

---

## ข้อควรรู้ / ข้อจำกัด

- Skill ทั้ง 8 ตัวในโฟลเดอร์นี้เป็น **guidance ล้วน ไม่พึ่ง CLI ภายนอก**
- subagent ที่ไม่มี `Skill` ใน `tools:` จะเรียก skill ไม่ได้ (แม้ skill จะถูก discover แล้วก็ตาม)
- การผูกตายตัวเขียนไว้ในตัว prompt ของ agent/command — ถ้าแก้ mapping ให้แก้ที่ไฟล์นั้นๆ แล้วอัปเดตตาราง README ให้ตรง
- Skill เหล่านี้เป็นสำเนา ณ เวลาที่ vendor เข้ามา — feature ที่ต้นทางอัปเดตทีหลังจะไม่มาเองจนกว่าจะ re-copy
