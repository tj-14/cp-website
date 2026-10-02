#import "@preview/ilm:1.4.0": *
#import table: cell, header

== C++ Syntax

บทนี้สรุปภาษา C++ เท่าที่ต้องใช้ในการแข่งขัน ถ้าเคยเขียนภาษาอื่นมาก่อน ให้สังเกตจุดที่ C++ ต่างออกไป เช่น ต้องประกาศชนิดตัวแปรและระวังค่าล้น (overflow)

=== เครื่องมือที่ใช้เขียน

- เริ่มด้วย VS Code #footnote[https://code.visualstudio.com/] กับ extension Competitive Programming Helper (cph) #footnote[https://marketplace.visualstudio.com/items?itemName=DivyanshuAgrawal.competitive-programming-helper] ซึ่งช่วยรันโค้ดกับตัวอย่าง input/output ได้ในคลิกเดียว
- ต้องมี compiler เช่น `g++` แล้ว compile ด้วยคำสั่ง `g++ -std=c++17 -O2 -Wall a.cpp -o a` (`-Wall` ช่วยเตือนข้อผิดพลาดที่พบบ่อย)

=== โค้ดเริ่มต้น

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
  ios::sync_with_stdio(false);
  cin.tie(nullptr);

  // เขียนโปรแกรมที่นี่
  return 0;
}
```

- `#include <bits/stdc++.h>` include ทุก library มาตรฐานในบรรทัดเดียว (ใช้ได้กับ `g++` ซึ่ง grader ส่วนใหญ่ใช้)
- `using namespace std;` ทำให้เขียน `cout` แทน `std::cout` ได้
- สองบรรทัดแรกใน `main` ทำให้ `cin`/`cout` เร็วขึ้นมาก ควรใส่เสมอเมื่อ input ใหญ่ (แต่หลังจากนั้นห้ามใช้ `scanf`/`printf` ปนกับ `cin`/`cout`)

=== Comments

Comment คือข้อความที่ compiler ไม่สนใจ ใช้อธิบายโค้ดให้คนอ่าน

```cpp
// line comment: ตั้งแต่ // ถึงท้ายบรรทัด

/*
  block comment
  หลายบรรทัด
*/
```

=== ตัวแปรและชนิดข้อมูล

ใน C++ ต้องประกาศ *ชนิด* (type) ของตัวแปรเสมอ ซึ่งกำหนดว่าเก็บค่าอะไรได้และใช้หน่วยความจำเท่าไร

#table(
  columns: 3,
  header([ชนิด], [ขนาด (byte)], [เก็บอะไร]),
  [`bool`], [1], [`true` หรือ `false`],
  [`char`], [1], [ตัวอักษรหนึ่งตัว เช่น `'a'` (จริง ๆ คือเลข ASCII)],
  [`int`], [4], [จำนวนเต็ม ประมาณ $plus.minus 2.1 times 10^9$],
  [`long long`], [8], [จำนวนเต็ม ประมาณ $plus.minus 9.2 times 10^18$],
  [`double`], [8], [จำนวนจริง (ทศนิยม) ละเอียดประมาณ 15 หลัก],
  [`string`], [-], [ข้อความ],
)

==== Overflow

ถ้าค่าเกินขอบเขตของชนิด ผลลัพธ์จะผิดโดย *ไม่มี error เตือน* นี่คือสาเหตุอันดับต้น ๆ ที่ทำให้เสียคะแนน

```cpp
int a = 100000, b = 100000;
long long wrong = a * b;              // ผิด! a * b คำนวณเป็น int แล้วล้นก่อน
long long right = (long long)a * b;   // ถูก: 10000000000
```

กฎง่าย ๆ: ถ้าคำตอบหรือค่าระหว่างทางอาจเกิน $10^9$ ให้ใช้ `long long`

=== Input/Output

ใช้ `cin >>` รับค่าและ `cout <<` แสดงผล `cin` จะข้ามช่องว่างและขึ้นบรรทัดใหม่ให้อัตโนมัติ และแปลงข้อมูลตามชนิดของตัวแปร

```cpp
int n;
string name;
cin >> n >> name;  // input: 5 alice
cout << name << " has " << n << " apples\n";  // alice has 5 apples
```

`'\n'` คือขึ้นบรรทัดใหม่ ควรใช้แทน `endl` เพราะ `endl` สั่งล้าง buffer ทุกครั้งจึงช้ากว่ามากเมื่อพิมพ์หลายบรรทัด

ชนิดของตัวแปรมีผลกับการรับค่า เช่น ถ้าพิมพ์ `5` ให้ตัวแปร `char` จะได้ตัวอักษร `'5'` ซึ่งมีรหัส ASCII เท่ากับ 53 ไม่ใช่เลข 5

```cpp
char c;
cin >> c;               // input: 5
cout << (int)c << '\n'; // 53
cout << c - '0';        // 5 (แปลงตัวอักษรตัวเลขเป็นจำนวน)
```

การพิมพ์ทศนิยมให้กำหนดจำนวนตำแหน่งด้วย `fixed` และ `setprecision`

```cpp
double x = 2.0 / 3;
cout << fixed << setprecision(3) << x;  // 0.667
```

=== Operators

#table(
  columns: 3,
  header([operator], [ความหมาย], [ตัวอย่าง]),
  [`+ - *`], [บวก ลบ คูณ], [`7 * 3` = 21],
  [`/`], [หาร (ถ้าเป็น `int` ทั้งคู่จะปัดเศษทิ้ง)], [`7 / 2` = 3, `7.0 / 2` = 3.5],
  [`%`], [เศษจากการหาร (ใช้กับจำนวนเต็ม)], [`7 % 3` = 1],
  [`== !=`], [เท่ากัน ไม่เท่ากัน], [`a == b`],
  [`< <= > >=`], [เปรียบเทียบ], [`a < b`],
  [`&& || !`], [และ หรือ ไม่], [`a > 0 && b > 0`],
  [`++ += -=`], [เพิ่ม/ลดค่า], [`i++`, `s += x`],
)

ระวัง: `-7 % 3` ใน C++ ได้ `-1` (ไม่ใช่ 2) ถ้าต้องการเศษที่ไม่ติดลบให้เขียน `((a % m) + m) % m`

=== Control structures

==== if / else

```cpp
if (x > 0) {
  cout << "positive";
} else if (x < 0) {
  cout << "negative";
} else {
  cout << "zero";
}
```

ระวังเขียน `if (x = 0)` (กำหนดค่า) แทน `if (x == 0)` (เปรียบเทียบ) ซึ่ง compile ผ่านแต่ทำงานผิด `-Wall` จะช่วยเตือน

==== for และ while

```cpp
for (int i = 0; i < 10; i++) {  // i = 0, 1, ..., 9
  cout << i << ' ';
}

int n = 37;
while (n > 0) {  // พิมพ์เลขฐานสองของ 37 จากหลักขวาไปซ้าย
  cout << n % 2;
  n /= 2;
}
```

ใช้ `break` เพื่อออกจาก loop ทันที และ `continue` เพื่อข้ามไปรอบถัดไป

=== Arrays

Array เก็บข้อมูลชนิดเดียวกันหลายตัวต่อกัน เข้าถึงด้วย index ที่เริ่มจาก *0*

```cpp
int n;
int a[100005];  // ประกาศให้ใหญ่กว่า n สูงสุดเล็กน้อย

cin >> n;
for (int i = 0; i < n; i++) cin >> a[i];  // a[0], a[1], ..., a[n-1]

long long sum = 0;
for (int i = 0; i < n; i++) sum += a[i];
cout << sum;
```

- Array ขนาด $n$ มี index $0$ ถึง $n - 1$ การเข้าถึง `a[n]` หรือ index ติดลบเป็นข้อผิดพลาดที่อาจไม่ crash แต่ให้คำตอบผิด
- Array ขนาดใหญ่ (เกินประมาณ $10^5$ ตัว) ควรประกาศเป็น *global* คือนอก `main` เพราะตัวแปรใน function ใช้พื้นที่ stack ซึ่งมีจำกัด และ global array จะมีค่าเริ่มต้นเป็น 0 ให้อัตโนมัติ

==== Array หลายมิติ

```cpp
int grid[505][505];

int r, c;
cin >> r >> c;
for (int i = 0; i < r; i++)
  for (int j = 0; j < c; j++)
    cin >> grid[i][j];
```

=== Strings

`string` เก็บข้อความและใช้งานคล้าย array ของ `char`

```cpp
string s;
cin >> s;            // อ่านหนึ่งคำ (หยุดที่ช่องว่าง)
cout << s.size();    // ความยาว
cout << s[0];        // ตัวอักษรแรก
s += "!";            // ต่อข้อความ

string line;
getline(cin, line);  // อ่านทั้งบรรทัดรวมช่องว่าง
```

ถ้าใช้ `getline` หลัง `cin >>` ต้องอ่านทิ้งบรรทัดที่ค้างอยู่ก่อนด้วย `cin.ignore()`

=== Functions

```cpp
long long square(long long x) {
  return x * x;
}

int main() {
  cout << square(12);  // 144
}
```

รายละเอียดเรื่อง function, parameter และ scope อยู่ในบท Function

=== ข้อผิดพลาดที่พบบ่อย

- ใช้ `int` กับค่าที่เกิน $2.1 times 10^9$ (overflow)
- ลืมว่า `7 / 2` เป็น 3 เมื่อหารจำนวนเต็ม
- เข้าถึง array นอกขอบเขต โดยเฉพาะ `a[n]`
- ประกาศ array ใหญ่ไว้ใน `main` จน stack overflow
- ใช้ `endl` พิมพ์หลายแสนบรรทัดจนเกินเวลา

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1068")[Weird Algorithm] (ระวัง overflow)
- #link("https://cses.fi/problemset/task/1083")[Missing Number]
- #link("https://cses.fi/problemset/task/1069")[Repetitions]
- #link("https://cses.fi/problemset/task/1094")[Increasing Array]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
