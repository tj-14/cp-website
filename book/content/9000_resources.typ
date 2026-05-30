#import "@preview/ilm:1.4.0": *

== แนวทางการฝึกด้วยตัวเอง

อ้างอิงเนื้อหาตามลำดับของค่าย สอวน. เพราะเป็นแนวทางหลักในเส้นทางการเขียนโปรแกรมเชิงแข่งขัน 

=== สำหรับก่อน สอวน. ค่าย 1

ถ้าหากไม่เคยเขียนภาษา C++ มาก่อน แนะนำให้เริ่มจากหนังสือ C++ Language Tutorial #footnote[https://cplusplus.com/files/tutorial.pdf] แล้วใช้หนังสือ Competitive Programmer's Handbook #footnote[https://cses.fi/book/book.pdf] 

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
- หากไม่เข้าใจแล้วอยากอ่านเพิ่มเป็นหัวข้อ
 - USACO Guide #footnote[https://usaco.guide/]
 - CP-Algorithm #footnote[https://cp-algorithms.com/]
- เว็บไซต์สำหรับทำโจทย์ (graders)
 - https://cses.fi/problemset/ แหล่งเดียวกับหนังสือหลัก
 - https://beta.programming.in.th/ เว็บหลักในไทย
 - https://otog.in.th/ เว็บที่นักเรียน สอวน ช่วยกันทำขึ้นมาเอง
 - https://codeforces.com/ เว็บหลักในต่างประเทศ
 - Kattis #footnote[https://open.kattis.com/]
 - AtCoder #footnote[https://atcoder.jp/] (ใช้ร่วมกับ Kenkoooo #footnote[https://kenkoooo.com/atcoder#/table/])
- หนังสือเพิ่มเติม (เนื้อหาจะซ้ำซ้อนกับด้านบน) https://usaco.guide/PAPS.pdf
- การบรรยายวิชา การออกแบบและวิเคราะห์อัลกอริทึม โดย สมชาย ประสิทธิ์จูตระกูล #footnote[https://www.youtube.com/watch?v=1S0mP_I8YzU&list=PL0ROnaCzUGB65_YkASLAEmcW_mtxFtq4m]

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
