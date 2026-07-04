---
description: สร้าง/อัปเดตแผนที่โปรเจกต์ (.claude/blueprint.md) เพื่อให้ session หน้าอ่านแทนการสแกนทั้งโปรเจกต์
---

You maintain the **project blueprint** — a lean map of this project at `.claude/blueprint.md`
so future sessions can start from it instead of re-scanning the whole tree. เป้าหมายคือ
**ประหยัด context**: blueprint ต้องเป็น *ดัชนี/แผนที่* (ชี้ว่าอะไรอยู่ไหน) ไม่ใช่การ dump เนื้อโค้ด

Optional focus argument (โฟกัสเฉพาะส่วน เช่น path/โมดูล): $ARGUMENTS

## โหมดการทำงาน — ตรวจก่อนว่าสร้างใหม่หรือ refresh

1. เช็คว่ามี `.claude/blueprint.md` อยู่แล้วไหม
2. **ถ้ามี → REFRESH (แบบประหยัด ไม่สแกนใหม่ทั้งก้อน):**
   - อ่าน SHA ที่ stamp ไว้ (บรรทัด `<!-- blueprint-sha: <sha> ... -->`)
   - `git diff --name-only <sha>..HEAD` เพื่อดูว่าเปลี่ยนไฟล์ไหนบ้าง
   - อัปเดต **เฉพาะส่วนของ blueprint ที่เกี่ยวกับไฟล์ที่เปลี่ยน** — ส่วนที่ไม่กระทบให้คงเดิม
   - ถ้า `$ARGUMENTS` ระบุ path ให้จำกัดการตรวจไว้แค่ส่วนนั้น
3. **ถ้าไม่มี → CREATE (สแกนครั้งแรก):** สำรวจโครงสร้างโปรเจกต์ให้พอเขียนแผนที่ได้ (ใช้ Glob/Grep/อ่าน manifest — อย่าอ่านทุกไฟล์)

## ข้อมูลที่ต้องเก็บลง blueprint (lean — บรรทัดสั้น ชี้ path)

เขียนไฟล์ `.claude/blueprint.md` ตามโครงนี้ (ข้ามหัวข้อที่ไม่มีจริงในโปรเจกต์):

```
<!-- blueprint-sha: <FULL_HEAD_SHA> generated: <YYYY-MM-DD HH:MM> -->

# Project Blueprint

> แผนที่โปรเจกต์แบบ lean — อ่านไฟล์นี้ก่อนเริ่มงานแทนการสแกนทั้งโปรเจกต์
> ถ้า SessionStart แจ้งว่า blueprint เก่ากว่า HEAD ให้ยึดโค้ดจริงเหนือ blueprint เฉพาะไฟล์ที่ระบุ

## ภาพรวม
<โปรเจกต์นี้คืออะไร ทำอะไร 1–3 บรรทัด>

## Tech stack
<ภาษา / เฟรมเวิร์ก / build tool / package manager — จาก package.json, go.mod, pyproject, ฯลฯ>

## โครงสร้างหลัก
| path | หน้าที่ (1 บรรทัด) |
|------|-------------------|
| ... | ... |

## Entry points
<ไฟล์เริ่มต้น / main / route / config หลัก — path + บทบาทสั้นๆ>

## คำสั่งสำคัญ
<build / test / run / lint / typecheck — คำสั่งจริงจาก scripts หรือ Makefile>

## อยากได้ X ดูที่ไหน
<index งานที่ทำบ่อย → path/โมดูล เช่น "เพิ่ม API route → src/routes/", "แก้ schema → prisma/schema.prisma">

## Conventions / gotchas
<naming, pattern, ข้อควรระวังเฉพาะโปรเจกต์นี้>
```

## กฎการเขียน
- **Lean เสมอ** — ถ้าเกิน ~150 บรรทัดแปลว่ายัดเนื้อมากไป ตัดเหลือดัชนี
- **แม่นยำ > ครบ** — เขียนเฉพาะที่ยืนยันจากไฟล์จริง อย่าเดา
- **Stamp ให้ถูก** — บรรทัดแรกต้องมี `blueprint-sha:` = ผลของ `git rev-parse HEAD` และวันที่จาก shell (`date '+%Y-%m-%d %H:%M'`); SessionStart hook ใช้ค่านี้ตรวจความสด ถ้าไม่มีจะเช็คไม่ได้

## ปิดงาน
1. เขียน/อัปเดต `.claude/blueprint.md` พร้อม stamp SHA ล่าสุด
2. Commit เฉพาะไฟล์นี้ (ไม่รวมงานอื่น): `git commit .claude/blueprint.md -m "chore: update project blueprint"` — ถ้า repo อยู่กลาง merge/ห้าม commit ให้ข้ามแล้วแจ้งผู้ใช้ว่ายังไม่ได้ commit
3. รายงานสั้นๆ เป็นภาษาไทย: สร้างใหม่หรือ refresh, ส่วนที่อัปเดต, path ไฟล์
