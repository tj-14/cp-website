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

- **HTML5**: โครงสร้างเนื้อหา
- **CSS3**: การจัดรูปแบบที่เรียบง่าย
- **No JavaScript frameworks**: เพื่อความเรียบง่ายและบำรุงรักษาง่าย
- **GitHub Pages**: สำหรับการ deploy

## 🚀 การใช้งาน (Usage)

### ดูเว็บไซต์ในเครื่อง (Local Development)

```bash
cd docs
python3 -m http.server 8080
```

จากนั้นเปิดเว็บเบราว์เซอร์ที่ `http://localhost:8080`

### โครงสร้างโปรเจค (Project Structure)

```
cp-website/
├── book/              # ซอร์สโค้ด Typst (ต้นฉบับ)
│   ├── content/      # ไฟล์เนื้อหา .typ
│   └── comp_book.typ # ไฟล์หลัก
├── docs/              # เว็บไซต์ HTML (GitHub Pages)
│   ├── index.html    # หน้าแรก
│   ├── style.css     # สไตล์ทั่วทั้งเว็บ
│   └── *.html        # หน้าเนื้อหาต่างๆ
├── GEMINI.md         # ข้อกำหนดและคำแนะนำ
└── README.md         # ไฟล์นี้
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

