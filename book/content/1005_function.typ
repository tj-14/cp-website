#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Function

Function คือการรวมกลุ่มคำสั่งที่ทำงานหนึ่งอย่างไว้ภายใต้ชื่อเดียว แล้วเรียกใช้ซ้ำได้
ช่วยให้โค้ดสั้นลง อ่านง่าย และแก้ bug ที่เดียวได้ผลทุกที่ที่เรียกใช้

=== ฟังก์ชันสำเร็จรูป

หลัง `#include <bits/stdc++.h>` จะมีฟังก์ชันให้ใช้มากมาย ที่ใช้บ่อยคือ

```cpp
cout << abs(-5) << '\n';        // 5
cout << sqrt(64.0) << '\n';     // 8
cout << pow(2, 10) << '\n';     // 1024 (คืนค่าเป็น double)
cout << log2(64) << '\n';       // 6
cout << gcd(12, 18) << '\n';    // 6 (C++17)
cout << lcm(4, 6) << '\n';      // 12 (C++17)
```

ระวัง: `pow` และ `sqrt` คืนค่าเป็น `double` ซึ่งอาจคลาดเคลื่อนเล็กน้อย เช่น `(int)pow(10, 2)` อาจได้ 99 บางเครื่อง
ถ้าต้องการยกกำลังจำนวนเต็มให้เขียน loop คูณเอง หรือใช้ fast exponentiation ในบท Divide and Conquer

=== เขียนฟังก์ชันเอง

ฟังก์ชันหนึ่งประกอบด้วย

- ชนิดของค่าที่คืน (return type) ถ้าไม่คืนค่าใช้ `void`
- ชื่อฟังก์ชัน
- parameters ที่รับเข้ามา
- ชุดคำสั่ง (body) และ `return`

```cpp
#include <bits/stdc++.h>
using namespace std;

int addition(int a, int b) {
  return a + b;
}

void greet(string name) {     // void: ไม่คืนค่า
  cout << "Hello " << name << '\n';
}

int main() {
  int z = addition(5, 3);
  cout << "The result is " << z << '\n';  // The result is 8
  greet("POSN");                           // Hello POSN
}
```

ฟังก์ชันต้องถูกประกาศ *ก่อน* จุดที่เรียกใช้ จึงมักเขียนไว้เหนือ `main`

=== เทียบกับฟังก์ชันทางคณิตศาสตร์

ฟังก์ชัน $f(x) = x^2 + 1$ ในคณิตศาสตร์เขียนเป็น C++ ได้ตรง ๆ โดยต้องระบุชนิดของ $x$ และผลลัพธ์เพิ่ม

```cpp
long long f(long long x) {
  return x * x + 1;
}
```

ต่างจากคณิตศาสตร์ตรงที่ฟังก์ชันใน C++ อาจทำงานอื่นด้วย เช่น พิมพ์ผลหรือแก้ไขตัวแปร global (เรียกว่า side effect)

=== Pass by value และ pass by reference

ปกติ parameter จะ *คัดลอกค่า* เข้ามา (pass by value) การแก้ไขในฟังก์ชันจึงไม่กระทบตัวแปรต้นฉบับ
ถ้าต้องการแก้ตัวแปรต้นฉบับ ให้ใส่ `&` หน้าชื่อ parameter (pass by reference)

```cpp
void swapByValue(int a, int b) {
  int c = a; a = b; b = c;      // สลับแค่สำเนา
}

void swapByRef(int &a, int &b) {
  int c = a; a = b; b = c;      // สลับตัวแปรต้นฉบับ
}

int main() {
  int x = 0, y = 1;
  swapByValue(x, y);
  cout << x << ' ' << y << '\n';  // 0 1
  swapByRef(x, y);
  cout << x << ' ' << y << '\n';  // 1 0
}
```

==== ส่ง vector และ string ด้วย reference

การส่ง `vector` แบบ by value จะคัดลอกทั้งก้อนทุกครั้งที่เรียก ซึ่งใช้เวลา $O(n)$ ถ้าเรียกบ่อย (เช่น ใน recursion) จะ TLE ได้
ให้ส่งด้วย `const &` เมื่อไม่ต้องการแก้ไข

```cpp
long long total(const vector<int> &v) {  // ไม่คัดลอก และห้ามแก้ v
  long long s = 0;
  for (int x : v) s += x;
  return s;
}
```

=== Scope ของตัวแปร

- *Local variable* ประกาศใน function หรือใน `{ }` ใช้ได้เฉพาะในบล็อกนั้น
- *Global variable* ประกาศนอกทุก function ใช้ได้ทุกที่ และมีค่าเริ่มต้นเป็น 0

```cpp
int g;  // global

int addition(int a, int b) {
  int r = a + b;  // r เป็น local ของ addition
  g = b;          // แก้ global ได้
  return r;
}

int main() {
  int z = addition(5, 3);
  cout << "z is " << z << '\n';  // z is 8
  cout << "g is " << g << '\n';  // g is 3
  // cout << r;  // error: 'r' was not declared in this scope
}
```

ในการแข่งขันนิยมใช้ global สำหรับ array ขนาดใหญ่และข้อมูลที่หลายฟังก์ชันใช้ร่วมกัน เช่น กราฟ

=== ตัวอย่าง

==== ระยะทางระหว่างสองจุด

ระยะทางแบบยุคลิด (Euclidean) ระหว่าง $A(x_1, y_1)$ และ $B(x_2, y_2)$ คือ $sqrt((x_1 - x_2)^2 + (y_1 - y_2)^2)$

```cpp
double dist(double x1, double y1, double x2, double y2) {
  return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}
```

==== ระยะทางแบบ Manhattan

ระยะเมื่อเดินได้แค่แนวตั้งและแนวนอน เช่น เดินตามถนนที่ตัดเป็นตาราง: $|x_1 - x_2| + |y_1 - y_2|$

```cpp
long long manhattan(long long x1, long long y1, long long x2, long long y2) {
  return abs(x1 - x2) + abs(y1 - y2);
}
```

==== ลำดับที่นิยามจากพจน์ก่อนหน้า

ถ้า $a_1 = 2$ และ $a_n = a_(n-1) + 2n$ จะเขียนฟังก์ชันหาพจน์ถัดไปจากพจน์ก่อนหน้าได้

```cpp
long long nextTerm(long long prev, int n) {  // คืน a_n เมื่อรู้ a_(n-1)
  return prev + 2LL * n;
}

int main() {
  long long a = 2;  // a_1
  for (int n = 2; n <= 5; n++) {
    a = nextTerm(a, n);
    cout << a << ' ';  // 6 12 20 30
  }
}
```

=== ข้อผิดพลาดที่พบบ่อย

- *ลืม `return`* ในฟังก์ชันที่ไม่ใช่ `void`: compile ผ่านแค่ warning แต่ค่าที่ได้เป็นขยะ (undefined behavior) ให้ compile ด้วย `-Wall` เสมอ
- *คาดว่าแก้ค่า parameter แล้วต้นฉบับจะเปลี่ยน* แต่ลืมใส่ `&`
- *ส่ง vector ขนาดใหญ่ by value* ในฟังก์ชันที่ถูกเรียกบ่อย
- *ใช้ `pow` กับจำนวนเต็ม* แล้วได้ค่าคลาดเคลื่อน

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1070")[Permutations]
- #link("https://cses.fi/problemset/task/1071")[Number Spiral]
- #link("https://cses.fi/problemset/task/1072")[Two Knights]
- #link("https://cses.fi/problemset/task/1617")[Bit Strings]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
