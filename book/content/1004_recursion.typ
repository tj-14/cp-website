#import "@preview/ilm:1.4.0": *

== Recursion

=== แนวคิด

- Recursion คือกระบวนการเรียกตัวเอง
- ตามปกติแล้วแบ่งกรณีเป็น
  - base case
  - recursion case
  โดยที่จะย่อยปัญหาให้เล็กลงจนกระทั่งแก้ได้ด้วย base case

=== การเขียนโปรแกรม

จะเขียนกระบวนการนั้นด้วยฟังก์ชัน และการเรียกตัวเองจะเป็นการเรียกฟังก์ชันที่เขียนขึ้นมาภายในฟังก์ชันนั้น

ตัวอย่างการเขียน recursive function ในภาษา C++ โดยยังไม่คำนึงถึงการนำไปใช้แก้โจทย์ปัญหา

```cpp
void recursive_function() {
    if (base condition)
        return; // base case
    else
        recursive_function(); // recursion case
}
```

=== วิเคราะห์ประสิทธิภาพ

จะใช้วิธีการนับจำนวนครั้งที่จะมีการเรียกฟังก์ชันเกิดขึ้นตามพารามิเตอร์ของฟังก์ชันนั้น

=== โจทย์ตัวอย่าง - Factorial

==== เนื้อหาโจทย์

จงหาค่าของ $n!$ โดย $n! = n times (n-1) times (n-2) times dots.c times 1$

==== แนวคิด

โจทย์นี้สามารถใช้โครงสร้าง loop ในการแก้ปัญหาได้ แต่นำมาเป็นตัวอย่างเริ่มต้นในการใช้โครงสร้างของ recursion ในการแก้ปัญหา

โดยมองค่าของ $n!$ เป็น recursive function ดังนี้

$ f(n) = cases(
1 "if" n <= 1,
n times f(n-1) "else",
)
$

==== รหัสเทียม

```cpp
#include <bits/stdc++.h>

using namespace std;

int factorial(int n) {
  if (n <= 1) { // base case
    return n;
  } else {
    return n * factorial(n - 1);
  }
}

int main() {
  cout << factorial(4);
  return 0;
}
```

จะได้ output

```
24
```

=== โจทย์ตัวอย่าง - Fibonacci

==== เนื้อหาโจทย์

จงหาค่าของเลขฟิโบนัชชีลำดับที่ $n$ โดยที่ เลขฟิโบนัชชีลำดับที่ $n$ จะมีค่าเท่ากับผลบวกของเลขฟิโบนัชชีลำดับที่ $n-1$ และ $n-2$

==== แนวคิด

โจทย์นี้สามารถใช้โครงสร้าง loop ในการแก้ปัญหาได้เช่นกัน แต่นำมาเป็นอีกตัวอย่างหนึ่งในการใช้โครงสร้างของ recursion ในการแก้ปัญหา

โดยมองค่าของเลขฟิโบนัชชีลำดับที่ $n$ เป็น recursive function ดังนี้

$ f(n) = cases(
n "if" n <= 1,
f(n-1) + f(n-2) "else",
)
$

==== รหัสเทียม

```cpp
#include <bits/stdc++.h>

using namespace std;

int fibo(int n) {
  if (n <= 1) { // base case
    return 1;
  } else {
    return fibo(n - 1) + fibo(n - 2);
  }
}

int main() {
  cout << fibo(4);
  return 0;
}
```

จะได้ output

```
3
```

=== โจทย์ตัวอย่าง - Permutation

==== เนื้อหาโจทย์

จงหาลำดับที่มีสมาชิก $n$ ตัว โดยที่แต่ละสมาชิกมีค่าน้อยกว่า $r$ ทั้งหมดที่เป็นไปได้ (จำเป็นต้องใช้ array)

==== แนวคิด

เป็นการค้นทุกวิธีที่เป็นไปได้ (complete search) ซึ่งจะนำ recursive function เข้ามาใช้ โดยเริ่มต้นด้วยการสร้างลำดับที่ยังไม่มีสมาชิกใด ๆ และค่อย ๆ เติมสมาชิกเข้าไปในลำดับนั้น

base case จะเป็นเงื่อนไขเมื่อลำดับมีสมาชิกครบ $n$

recursive case จะเป็นการเติมสมาชิกลำดับถัดไปด้วยทุกค่าที่เป็นไปได้

==== รหัสเทียม

```cpp
#include <bits/stdc++.h>

using namespace std;

int a[10];

void perm(int d, int r, int n) {
  if (d == n) { // base case
    for (int i = 0; i < n; i++) {
      cout << a[i] << " ";
    }
    cout << "\n";
    return;
  }
  for (int i = 0; i < r; i++) {
    a[d] = i;
    perm(d + 1, r, n); // recursive case
  }
}

int main() { perm(0, 3, 3); }
```

จะได้ output

```
0 0 0
0 0 1
...
2 2 2
```

=== ปัญหาที่พบบ่อย

==== Overflow

กรณีไม่มี base case หรือ base case ไม่ครอบคลุม จะทำให้เกิดการ overflow ได้

```cpp
#include <bits/stdc++.h>

using namespace std;

int factorial(int n) { return n * factorial(n - 1); }

int main() {
  cout << factorial(4);
  return 0;
}
```

จะเกิด error เช่น:

```
"./a.out" terminated by signal SIGSEGV (Address boundary error)
```

=== โจทย์แนะนำ
- หาลำดับ permutation โดยมีเงื่อนไขที่แตกต่างกัน
  - จำนวน 5 หลัก และแต่ละหลักมีค่าไม่เกิน 6
  - ตัวเลขก่อนหน้าต้องน้อยกว่าหรือเท่ากับตัวถัดไป
  - ตัวเลขห้ามซ้ำ
- กลับข้อความ (reverse string) ห้ามใช้ loop, array หรือ string
  - กลับทั้งข้อความ เช่น: “iamastring” เป็น “gnirtsamai”
  - กลับเฉพาะภายในคำที่คั่นด้วยเว้นวรรค เช่น: “i am a string” เป็น “i ma a gnirts”
- Programming.in.th
  - 0019 Perket
  - 0039 Food
- cses.fi
  - 2205 Gray Code
  - 2165 Tower of Hanoi
  - 1622 Creating Strings
  - 1623 Apple Division
