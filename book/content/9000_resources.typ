#import "@preview/ilm:1.4.0": *

== แนวทางการฝึกด้วยตัวเอง

อ้างอิงเนื้อหาตามลำดับของค่าย สอวน. เพราะเป็นแนวทางหลักในเส้นทางการเขียนโปรแกรมเชิงแข่งขัน 

=== สำหรับก่อน สอวน. ค่าย 1

ถ้าไม่เคยเขียนภาษา C++ มาก่อน แนะนำให้เริ่มจาก #link("https://cplusplus.com/files/tutorial.pdf")[C++ Language Tutorial] แล้วต่อด้วย #link("https://cses.fi/book/book.pdf")[Competitive Programmer's Handbook] ซึ่งเป็นหนังสือหลักของคู่มือนี้

เป้าหมายของช่วงนี้คือเขียนโปรแกรมพื้นฐานได้คล่อง

- input/output
- if/else และ loop
- array และ string
- function
- recursion แบบง่าย

ควรฝึกโจทย์ที่ไม่ต้องใช้อัลกอริทึมซับซ้อนก่อน เพื่อให้ชินกับการอ่านโจทย์และ debug

=== สำหรับ สอวน. ค่าย 1

หัวข้อที่ควรมั่นใจ

- C++ syntax และ STL พื้นฐาน เช่น `vector`, `pair`, `sort`
- การคิด brute force และ simulation
- recursion
- time complexity เบื้องต้น
- การจัดการ array และ string

วิธีฝึกที่แนะนำคือเลือกโจทย์ง่ายวันละ 2-3 ข้อ แล้วหลังทำเสร็จให้จดว่าโจทย์นั้นใช้ pattern อะไร

=== สำหรับ สอวน. ค่าย 2

หัวข้อหลักจะเริ่มเป็น data structures และ algorithms

- stack, queue, priority queue
- set, map, hash table
- tree และ graph representation
- BFS/DFS
- binary search
- greedy
- dynamic programming เบื้องต้น

ในช่วงนี้ควรเริ่มอ่านเฉลยหลังพยายามเองพอสมควร เพราะสิ่งสำคัญคือการสะสม pattern ของโจทย์

=== สำหรับขั้นต่อไป

==== อ่านเพิ่มเป็นหัวข้อ

- #link("https://usaco.guide/")[USACO Guide] เนื้อหาเรียงตามระดับ พร้อมโจทย์
- #link("https://cp-algorithms.com/")[CP-Algorithms] อธิบายอัลกอริทึมละเอียดพร้อม implementation
- #link("https://usaco.guide/PAPS.pdf")[Principles of Algorithmic Problem Solving] (เนื้อหาซ้อนกับ Competitive Programmer's Handbook บางส่วน)
- #link("https://www.youtube.com/watch?v=1S0mP_I8YzU&list=PL0ROnaCzUGB65_YkASLAEmcW_mtxFtq4m")[การออกแบบและวิเคราะห์อัลกอริทึม] โดย อ.สมชาย ประสิทธิ์จูตระกูล

==== เว็บไซต์ทำโจทย์ (graders)

- #link("https://cses.fi/problemset/")[CSES Problem Set] ชุดโจทย์คู่กับหนังสือหลัก เรียงตามหัวข้อ
- #link("https://programming.in.th/")[programming.in.th] เว็บหลักในไทย มีโจทย์ TOI และ สอวน.
- #link("https://otog.in.th/")[OTOG] เว็บที่นักเรียน สอวน. ช่วยกันทำ
- #link("https://codeforces.com/")[Codeforces] แข่งออนไลน์สม่ำเสมอ เหมาะฝึกความเร็ว
- #link("https://atcoder.jp/")[AtCoder] โจทย์คุณภาพดี ใช้คู่กับ #link("https://kenkoooo.com/atcoder/")[AtCoder Problems] เพื่อเลือกโจทย์ตามระดับ
- #link("https://open.kattis.com/")[Kattis]

=== สำหรับค่าย สสวท.

- #link("https://thailand-oi-task-team.github.io/materials/")[เอกสารค่าย สสวท. (ThailandOI)] รวมเอกสารและลิงก์จากค่ายตุลาและค่ายมีนาแต่ละปี
- บท Advanced Data Structures, DP Optimization และ Max Flow, Matching และ FPT ในคู่มือนี้ สรุปจากสไลด์ที่ใช้สอนในค่าย

=== วิธีใช้เวลาอ่านเฉลย

- อ่านเฉพาะ idea ก่อน อย่าเพิ่งดู code
- ปิดเฉลยแล้วลอง implement เอง
- ถ้าติด ให้เทียบเฉพาะส่วนที่ต่าง
- หลังผ่านแล้ว ให้เขียนสรุป 2-3 บรรทัดว่าโจทย์นี้สอน pattern อะไร

=== Checklist การฝึก

- ทำโจทย์ง่ายให้เร็วและถูกก่อนเพิ่มความยาก
- หลัง contest ให้ upsolve ข้อที่ทำไม่ได้อย่างน้อย 1 ข้อ
- เก็บ template ที่ใช้บ่อย แต่ต้องเข้าใจทุกบรรทัด
- วัดความก้าวหน้าจากจำนวน pattern ที่จำได้ ไม่ใช่จำนวนโจทย์อย่างเดียว
