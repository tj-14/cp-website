#import "@preview/ilm:1.4.0": *
#import table: cell, header
#import "widgets.typ": widget

== Recursion

=== แนวคิด

Recursion คือการแก้ปัญหาโดยให้ฟังก์ชัน *เรียกตัวเอง* กับปัญหาที่เล็กลง ทุก recursive function ต้องมีสองส่วน

- *Base case*: ปัญหาที่เล็กพอจะตอบได้ทันทีโดยไม่ต้องเรียกตัวเองอีก
- *Recursive case*: ย่อยปัญหาให้เล็กลง เรียกตัวเองแก้ปัญหาที่เล็กกว่า แล้วนำคำตอบมารวมกัน

```cpp
int solve(int n) {
  if (n <= 1) {           // base case
    return ...;
  }
  return ... solve(n - 1) ...;  // recursive case: n ต้องเล็กลงทุกครั้ง
}
```

เคล็ดลับในการคิดคือ *เชื่อใจ recursive call* (leap of faith): ให้สมมติว่า `solve(n - 1)` ตอบถูกแล้ว แล้วถามตัวเองแค่ว่า "ถ้ารู้คำตอบของปัญหาที่เล็กกว่า จะได้คำตอบของ $n$ อย่างไร" ไม่ต้องไล่ทุกชั้นในหัว

=== Call stack

ทุกครั้งที่เรียกฟังก์ชัน โปรแกรมจะจองพื้นที่ใน *call stack* สำหรับตัวแปรและตำแหน่งที่ต้องกลับไป
เมื่อฟังก์ชันคืนค่า (return) พื้นที่นั้นจะถูกคืน และโปรแกรมกลับไปทำงานต่อที่ผู้เรียก

=== ตัวอย่าง: Factorial

$ n! = cases(
  1 & "if" n <= 1,
  n times (n-1)! & "otherwise",
) $

```cpp
#include <bits/stdc++.h>
using namespace std;

int factorial(int n) {
  if (n <= 1) return 1;            // base case
  return n * factorial(n - 1);     // recursive case
}

int main() {
  cout << factorial(4);  // 24
}
```

ลำดับการทำงานของ `factorial(4)` จะลงไปจนถึง base case ก่อน แล้วค่อยคูณกลับขึ้นมา

```
factorial(4) = 4 * factorial(3)
             = 4 * (3 * factorial(2))
             = 4 * (3 * (2 * factorial(1)))
             = 4 * (3 * (2 * 1))
             = 24
```

ระหว่างนั้น call stack ลึกสุด 4 ชั้น: `factorial(4) → factorial(3) → factorial(2) → factorial(1)`

=== ตัวอย่าง: Fibonacci

$ f(n) = cases(
  n & "if" n <= 1,
  f(n-1) + f(n-2) & "otherwise",
) $

ลำดับคือ $0, 1, 1, 2, 3, 5, 8, 13, dots.c$

```cpp
int fib(int n) {
  if (n <= 1) return n;              // base case
  return fib(n - 1) + fib(n - 2);    // recursive case เรียกตัวเองสองครั้ง
}

int main() {
  cout << fib(4);  // 3
}
```

ฟังก์ชันนี้เรียกตัวเอง *สองครั้ง* การเรียกจึงแตกกิ่งเป็นต้นไม้ (call tree) และมีการคำนวณ `fib` ของค่าเดิมซ้ำหลายรอบ

ลองกด "ถัดไป" เพื่อดูการเรียกทีละครั้ง กล่องสีแดงคือการคำนวณซ้ำ จากนั้นเปิด "ใช้ memoization" แล้วสังเกตว่าต้นไม้เล็กลงแค่ไหน และลองเปลี่ยนเป็น `factorial` เพื่อเทียบกับฟังก์ชันที่เรียกตัวเองครั้งเดียว

#widget("recursion-tree")

=== วิเคราะห์ประสิทธิภาพ

เวลาที่ใช้ $approx$ (จำนวนครั้งที่เรียกฟังก์ชัน) $times$ (งานที่ทำในแต่ละครั้งไม่นับการเรียกย่อย)

#table(
  columns: 4,
  header([ฟังก์ชัน], [จำนวนการเรียก], [Time], [ความลึกของ stack]),
  [`factorial(n)`], [$n$], [$O(n)$], [$n$],
  [`fib(n)`], [โตประมาณ $1.6^n$], [$O(2^n)$], [$n$],
  [`fib(n)` + memoization], [$2n - 1$], [$O(n)$], [$n$],
  [`gen(0)` สร้างลำดับยาว $n$ ค่า $0..r-1$], [$approx r^n$], [$O(n r^n)$], [$n$],
)

`fib(40)` แบบไม่จำคำตอบเรียกฟังก์ชันกว่า 300 ล้านครั้ง การจำคำตอบที่เคยคำนวณ (memoization) คือจุดเริ่มต้นของ Dynamic Programming

=== Complete search ด้วย recursion

Recursion เหมาะกับการลองทุกความเป็นไปได้ (complete search) โดยตัดสินใจทีละตำแหน่ง

*โจทย์*: พิมพ์ลำดับยาว $n$ ทั้งหมดที่แต่ละตัวมีค่า $0$ ถึง $r - 1$

- *State*: `d` = จำนวนตำแหน่งที่เติมแล้ว
- *Base case*: `d == n` แปลว่าได้ลำดับครบ ให้พิมพ์ออกมา
- *Recursive case*: ลองใส่ทุกค่าที่ตำแหน่ง `d` แล้วเรียก `gen(d + 1)`

```cpp
#include <bits/stdc++.h>
using namespace std;

int n = 3, r = 3;
int a[10];

void gen(int d) {
  if (d == n) {  // base case: ได้ลำดับครบ n ตัว
    for (int i = 0; i < n; i++) cout << a[i] << ' ';
    cout << '\n';
    return;
  }
  for (int v = 0; v < r; v++) {
    a[d] = v;    // เลือก
    gen(d + 1);  // ตัดสินใจตำแหน่งถัดไป
  }
}

int main() { gen(0); }
```

ผลลัพธ์มี $3^3 = 27$ บรรทัด

```
0 0 0
0 0 1
...
2 2 2
```

==== Backtracking: เลือก แล้วยกเลิก

ถ้ามีเงื่อนไข เช่น ห้ามใช้ค่าซ้ำ ให้เก็บสถานะว่าใช้อะไรไปแล้ว และ *คืนสถานะ* หลังเรียกเสร็จ เพื่อให้ทางเลือกถัดไปเริ่มจากสถานะเดิม

```cpp
bool used[10];

void perm(int d) {
  if (d == n) { /* พิมพ์ a[0..n-1] */ return; }
  for (int v = 0; v < n; v++) {
    if (used[v]) continue;
    used[v] = true;   // เลือก
    a[d] = v;
    perm(d + 1);
    used[v] = false;  // ยกเลิก (backtrack)
  }
}
```

จำนวน permutation คือ $n!$ จึงใช้ได้กับ $n$ ไม่เกินประมาณ 10 (ดูเพิ่มในบท Search)

=== ข้อผิดพลาดที่พบบ่อย

==== ไม่มี base case หรือปัญหาไม่เล็กลง

ฟังก์ชันจะเรียกตัวเองไม่รู้จบจน call stack เต็ม (stack overflow)

```cpp
int factorial(int n) { return n * factorial(n - 1); }  // ไม่มี base case
```

จะเกิด error เช่น

```
"./a.out" terminated by signal SIGSEGV (Address boundary error)
```

==== ลืมคืนสถานะใน backtracking

ถ้าลืม `used[v] = false` ทางเลือกถัดไปจะเห็นสถานะผิด และคำตอบหายไปบางส่วน

==== Recursion ลึกเกินไป

แม้จะถูกต้อง แต่ถ้าความลึกถึงหลักแสนหรือล้านชั้น (เช่น DFS บน path ยาว) อาจ stack overflow ได้ ขึ้นกับขนาด stack ของ grader ถ้าเสี่ยงให้เปลี่ยนเป็น loop หรือใช้ stack เอง

=== ลองคิด

+ `fib(5)` แบบไม่ใช้ memoization เรียกฟังก์ชันทั้งหมดกี่ครั้ง (ตรวจคำตอบกับ widget ด้านบนได้)
+ ถ้าเปลี่ยน base case ของ `factorial` เป็น `if (n == 1) return 1;` จะเกิดอะไรขึ้นเมื่อเรียก `factorial(0)`
+ เขียน recursive function กลับข้อความ (reverse string) โดยไม่ใช้ loop

==== เฉลย

+ 15 ครั้ง และเป็นการคำนวณซ้ำ 9 ครั้ง
+ ไม่มีวันถึง base case เพราะ $n$ ลดเป็น $-1, -2, dots.c$ ไปเรื่อย ๆ จน stack overflow
+ ตัวอย่าง: ถ้า `s` ว่าง คืน `""` ไม่เช่นนั้นคืน `rev(s.substr(1)) + s[0]`

=== โจทย์แนะนำ

- ลำดับยาว 5 ที่แต่ละหลักมีค่าไม่เกิน 6 โดยเพิ่มเงื่อนไขทีละข้อ
  - ตัวเลขก่อนหน้าต้องน้อยกว่าหรือเท่ากับตัวถัดไป
  - ตัวเลขห้ามซ้ำ
- กลับข้อความ (reverse string) โดยไม่ใช้ loop
  - กลับทั้งข้อความ เช่น `iamastring` เป็น `gnirtsamai`
  - กลับเฉพาะภายในคำที่คั่นด้วยเว้นวรรค เช่น `i am a string` เป็น `i ma a gnirts`
- programming.in.th: 0019 Perket, 0039 Food

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/2165")[Tower of Hanoi]
- #link("https://cses.fi/problemset/task/1622")[Creating Strings]
- #link("https://cses.fi/problemset/task/1623")[Apple Division]
- #link("https://cses.fi/problemset/task/2205")[Gray Code]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
