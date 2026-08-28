# คู่มือโอลิมปิกคอมพิวเตอร์ | Computer Olympiad Guide

เว็บไซต์คู่มือสำหรับนักเรียนมัธยมปลายที่สนใจการแข่งขันโอลิมปิกคอมพิวเตอร์ พัฒนาขึ้นจากประสบการณ์การสอนค่าย สอวน. สามปี

A guide website for Thai high school students interested in Computer Olympiad competitions. Developed from three years of teaching experience at POSN camps.

## 🎯 เป้าหมาย (Goals)

- สร้างเนื้อหาการเรียนรู้ที่เข้าถึงง่ายสำหรับนักเรียนไทย
- ใช้ภาษาไทยประกอบกับคำศัพท์ภาษาอังกฤษที่สำคัญ
- เนื้อหาครอบคลุมตั้งแต่พื้นฐานจนถึงระดับสูง
- ออกแบบเว็บไซต์ให้เรียบง่าย ใช้งานง่าย และบำรุงรักษาง่าย

## 📚 เนื้อหา (Content)

เนื้อหาแบ่งตามระดับของค่าย สอวน.:
- **ค่าย 1**: พื้นฐานการเขียนโปรแกรม C/C++
- **ค่าย 2**: โครงสร้างข้อมูลและอัลกอริทึม
- **ระดับสูงขึ้น**: เทคนิคขั้นสูงและการแก้ปัญหา

## 🛠️ เทคโนโลยี (Tech Stack)

- **HTML5**: โครงสร้างเนื้อหา (สร้างจาก Typst ด้วย pandoc)
- **CSS3**: การจัดรูปแบบที่เรียบง่าย รองรับ dark mode
- **Vanilla JavaScript เล็กน้อย**: ค้นหาหัวข้อ ปุ่มคัดลอกโค้ด (ไม่ใช้ framework)
- **KaTeX**: แสดงสมการคณิตศาสตร์ (โหลดเฉพาะหน้าที่มีสมการ)
- **Typst**: สร้างหนังสือเวอร์ชัน PDF
- **GitHub Pages**: สำหรับการ deploy

### สิ่งที่ต้องติดตั้ง (Prerequisites)

- `pandoc` (แปลง `.typ` เป็น HTML)
- `typst` (สร้าง PDF)
- `python3` (สำหรับ build/validate scripts)

macOS: `brew install pandoc typst`

## 🚀 การใช้งาน (Usage)

### วิธีแก้ไขเนื้อหาและเว็บไซต์ (Editing Workflow)

- แก้เนื้อหาบทเรียนที่ `book/content/*.typ`
- แก้ diagram/image ที่ `book/assets/`
- แก้หน้าตาเว็บไซต์ที่ `docs/style.css`
- แก้โครงสร้าง HTML/navigation/meta tags ที่ `scripts/build_docs.py`
- ไม่ควรแก้ `docs/*.html` โดยตรง เพราะ `make site` จะสร้างไฟล์เหล่านี้ใหม่และเขียนทับ

หลังแก้ไข ให้รัน:

```bash
make site
make validate
```

ถ้าต้องการตรวจทั้งเว็บไซต์และ PDF:

```bash
make check
```

`book/content/*.typ` เป็น source of truth สำหรับทั้งหนังสือและเว็บไซต์ ส่วน `docs/` เป็นไฟล์ static ที่สร้างไว้สำหรับ GitHub Pages

build จะสร้าง `index.html`, `404.html`, `robots.txt`, `sitemap.xml` และโหลด KaTeX เฉพาะหน้าที่มีสมการ พร้อมแนบ SRI integrity hashes

ตรวจว่า PDF ยัง build ได้:

```bash
make pdf
```

หมายเหตุ: การ build เว็บไซต์ใช้ `pandoc` สำหรับแปลงไฟล์ `.typ` เป็น HTML

### ดูเว็บไซต์ในเครื่อง (Local Development)

```bash
make serve
```

จากนั้นเปิดเว็บเบราว์เซอร์ที่ `http://localhost:8080`

### Deploy ด้วย GitHub Pages

ตั้งค่า repository ที่ GitHub:

1. ไปที่ `Settings` → `Pages`
2. เลือก `Deploy from a branch`
3. เลือก branch หลักของโปรเจค
4. เลือก folder เป็น `/docs`
5. กด save

เว็บไซต์ไม่ต้องใช้ backend server เพราะ `docs/` เป็น static HTML/CSS/JS ทั้งหมด

### CI

`.github/workflows/ci.yml` จะรัน `make check` (build เว็บไซต์ + PDF + validate) ทุก PR และตรวจว่า `docs/` ที่ commit ไว้เป็นเวอร์ชันล่าสุด (drift check) โดย pin เวอร์ชัน pandoc และ typst ให้ตรงกับเครื่อง

### โครงสร้างโปรเจค (Project Structure)

```
cp-website/
├── book/                 # ซอร์สโค้ด Typst (ต้นฉบับ)
│   ├── content/         # ไฟล์เนื้อหา .typ
│   ├── assets/          # รูปภาพ + favicon
│   └── comp_book.typ    # ไฟล์หลัก (PDF build ได้จาก make pdf)
├── docs/                 # เว็บไซต์ HTML (GitHub Pages, สร้างโดย make site)
│   ├── index.html       # หน้าแรก
│   ├── style.css        # สไตล์ทั้งเว็บ
│   └── *.html           # หน้าเนื้อหาต่างๆ
├── scripts/              # เครื่องมือ build/validate เว็บไซต์
│   ├── build_docs.py    # สร้างทุกหน้า HTML จาก .typ
│   └── validate_site.py # ตรวจ link/anchor/image ที่พัง
├── .github/workflows/    # CI (build + validate)
├── AGENTS.md             # ข้อกำหนดและคำแนะนำ
└── README.md             # ไฟล์นี้
```

## 📖 แหล่งข้อมูลที่แนะนำ (Recommended Resources)

### สนามฝึกซ้อม (Practice Platforms)
- [programming.in.th](https://programming.in.th/) - แพลตฟอร์มหลักในไทย
- [CSES Problem Set](https://cses.fi/problemset/) - โจทย์จากหนังสือ Competitive Programmer's Handbook

### หนังสือ (Books)
- [Competitive Programmer's Handbook](https://cses.fi/book/book.pdf) - หนังสือหลัก
- [Principles of Algorithmic Problem Solving](https://www.csc.kth.se/~jsannemo/slask/main.pdf)

### เว็บไซต์อ้างอิง (Reference Sites)
- [CP-Algorithms](https://cp-algorithms.com/) - อัลกอริทึมต่างๆ อย่างละเอียด
- [USACO Guide](https://usaco.guide/) - คู่มือสำหรับ USA Computing Olympiad

## 🎨 การออกแบบ (Design Principles)

- **มินิมอล**: ไม่มีฟีเจอร์ที่ไม่จำเป็น
- **อ่านง่าย**: Typography และ spacing ที่เหมาะสม
- **Navigation ชัดเจน**: เดินทางระหว่างหน้าได้สะดวก
- **Responsive**: ใช้งานได้ดีทั้งมือถือและคอมพิวเตอร์

## 🤝 การมีส่วนร่วม (Contributing)

ยินดีรับข้อเสนอแนะและการแก้ไข! กรุณา:
1. Fork repository นี้
2. สร้าง branch สำหรับการแก้ไข
3. ทำการแก้ไขและ test
4. ส่ง Pull Request

## 📝 License

เนื้อหาสร้างขึ้นเพื่อการศึกษา สามารถนำไปใช้และแชร์ได้อย่างอิสระ

---

พัฒนาด้วย ❤️ สำหรับนักเรียนไทยที่รักการเขียนโปรแกรม
