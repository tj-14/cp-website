#import "@preview/ilm:1.4.0": *

== Ad-hoc

=== หลักการ

Ad-hoc คือโจทย์ที่ไม่มีสูตรหรือ data structure ตายตัว จุดสำคัญอยู่ที่การอ่านเงื่อนไขให้ครบ แปลงเงื่อนไขเป็นขั้นตอนที่ชัด แล้ว implement อย่างระวัง

โจทย์กลุ่มนี้มักวัด

- ความละเอียดในการจัดการ case ย่อย
- การจำลองสถานการณ์ตามโจทย์
- การจัดรูปแบบ input/output
- การใช้ string, array, map หรือ set ให้เหมาะกับข้อมูล

=== วิธีคิด

ขั้นตอนที่แนะนำเวลาเจอโจทย์ ad-hoc

- เขียนตัวอย่างด้วยมือก่อน 2-3 ชุด
- ระบุ state ที่ต้องเก็บ เช่น ตำแหน่งปัจจุบัน คะแนน เวลา หรือสถานะเปิดปิด
- แยกเงื่อนไขสำคัญออกเป็น case
- เลือกโครงสร้างข้อมูลที่ทำให้ code ตรงกับโจทย์ที่สุด
- ทดสอบ edge cases เช่น input ว่าง, ค่าเท่ากัน, ค่าเล็กสุด, ค่าใหญ่สุด

=== Simulation

โจทย์ simulation ให้ทำตามกติกาทีละขั้น เหมาะกับการเขียนฟังก์ชันเล็ก ๆ แยกส่วน

```cpp
for (char command : commands) {
  if (command == 'L') turn_left();
  else if (command == 'R') turn_right();
  else if (command == 'F') move_forward();
}
```

ข้อผิดพลาดที่พบบ่อยคือ update state ผิดลำดับ เช่น ควรตรวจชนกำแพงก่อนหรือหลังขยับตำแหน่ง

=== Counting and frequency

หลายโจทย์ ad-hoc แก้ด้วยการนับความถี่

```cpp
map<string, int> cnt;
for (string name : names) {
  cnt[name]++;
}
```

ถ้าข้อมูลเป็นเลขช่วงเล็ก ใช้ array จะเร็วและง่ายกว่า map

```cpp
vector<int> cnt(101);
for (int x : a) {
  cnt[x]++;
}
```

=== String

โจทย์ string มีทั้งแบบง่าย เช่น นับตัวอักษร ตรวจ palindrome และแบบยาก เช่น pattern matching

ตัวอย่างตรวจ palindrome

```cpp
bool ok = true;
for (int l = 0, r = s.size() - 1; l < r; l++, r--) {
  if (s[l] != s[r]) ok = false;
}
```

สำหรับ pattern matching ขนาดใหญ่ควรรู้จัก

- Rabin-Karp #footnote[https://cp-algorithms.com/string/rabin-karp.html]
- Knuth-Morris-Pratt #footnote[https://cp-algorithms.com/string/prefix-function.html]

=== Checklist ก่อนส่ง

- อ่าน constraint แล้ว complexity เพียงพอหรือไม่
- ตรวจ index ว่าใช้ 0-based หรือ 1-based
- ตรวจกรณีแรกและกรณีสุดท้ายของ loop
- ตรวจ input ที่มีช่องว่าง ถ้าต้องอ่านทั้งบรรทัดควรใช้ `getline`
- ลอง test ด้วยตัวอย่างที่คิดเอง ไม่ใช่เฉพาะ sample

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1755")[Palindrome Reorder]
- #link("https://cses.fi/problemset/task/2205")[Gray Code]
- #link("https://cses.fi/problemset/task/1092")[Two Sets]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
