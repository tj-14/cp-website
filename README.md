# คู่มือโอลิมปิกคอมพิวเตอร์

เนื้อหาคอมพิวเตอร์โอลิมปิกที่เคยสอนในค่าย สอวน. และ สสวท. รวมไว้เป็นเว็บไซต์และหนังสือ PDF

- เว็บไซต์: https://tossatree.com/cp-website/
- PDF: https://tossatree.com/assets/pdf/comp_book.pdf

เนื้อหาเรียงตามลำดับค่าย ตั้งแต่ C++ พื้นฐาน (ค่าย 1), data structures (ค่าย 2), algorithms ไปจนถึงหัวข้อค่าย สสวท. เช่น HLD, DP optimization และ max flow

ถ้าเจอเนื้อหาผิดหรือมีไอเดีย แจ้งได้ที่ [Issues](https://github.com/tj-14/cp-website/issues)

## แก้ไขเนื้อหา

เนื้อหาทั้งหมดอยู่ที่ `book/content/*.typ` (Typst) ใช้สร้างทั้งเว็บไซต์และ PDF

- บทเรียน: `book/content/*.typ`
- รูปและ widget: `book/assets/` (widget ใส่ในบทด้วย `#widget("name")` แล้วเขียน `book/assets/widgets/name.js`)
- หน้าตาเว็บ: `docs/style.css`
- ลำดับบทและ template HTML: `scripts/build_docs.py`

ไฟล์ `docs/*.html` สร้างจาก `make site` ไม่ต้องแก้เอง

## Build

ต้องมี `pandoc`, `typst`, `python3` และ Node.js (สำหรับ test)

```bash
brew install pandoc typst
make check   # build เว็บ + PDF, ตรวจลิงก์, รัน test
make serve   # ดูเว็บที่ http://localhost:8080
```

CI รัน `make check` และตรวจว่า `docs/` ที่ commit ตรงกับที่ build ใหม่ ใช้ pandoc เวอร์ชันเดียวกับใน `.github/workflows/ci.yml` เพราะ pandoc ต่างเวอร์ชันจะได้ HTML ต่างกัน

เว็บ deploy ผ่าน GitHub Pages จากโฟลเดอร์ `docs/` บน branch `main`
