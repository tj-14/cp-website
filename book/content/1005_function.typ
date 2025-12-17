#import "@preview/ilm:1.4.0": *

== Function

- ตัวอย่างฟังก์ชันที่มีใน `bits/stdc++.h`
- วิธีการเขียน user-defined functions
- เทียบมุมมองของฟังก์ชันทางคณิตศาสตร์และทางคอมพิวเตอร์

=== แนวคิด

การเขียนฟังก์ชันในโปรแกรมเป็นการรวมกลุ่มคำสั่งเพื่อทำงานตามจุดประสงค์ โดยสามารถเรียกใช้งานภายหลังในโปรแกรมนั้นได้

=== การเขียนโปรแกรม

==== ตัวอย่างฟังก์ชันพร้อมเรียกใช้งาน

ใน C++ Standard Template Library (STL) จะมีฟังก์ชันพร้อมเรียกใช้งานให้ใช้ ซึ่งเมื่อ

```cpp
#include <bits/stdc++.h>
```

แล้ว ในการเขียนโปรแกรมเชิงแข่งขันจะทำการ include STL ที่จำเป็นทั้งหมดมาให้ ซึ่งตัวอย่างฟังก์ชันที่ใช้งานบ่อยครั้งมีดังนี้
- abs, pow, sqrt, log2, exp จาก cmath
- swap, min, max, \_\_gcd, next_permutation จาก algorithm

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
  cout << "cmath examples\n";
  cout << "abs(-5): " << abs(-5) << "\n";
  cout << "pow(2, 3): " << pow(2, 3) << "\n";
  cout << "sqrt(64): " << sqrt(64) << "\n";
  cout << "log2(64): " << log2(64) << "\n";
  cout << "exp(3): " << exp(3) << "\n";
  cout << "\n";

  cout << "algorithm examples\n";
  int a = 4, b = 7;
  cout << "a b: " << a << " " << b << "\n";
  swap(a, b);
  cout << "a b: " << a << " " << b << "\n";
  cout << "min(a, b): " << min(a, b) << "\n";
  cout << "max(a, b): " << max(a, b) << "\n";
  cout << "__gcd(a, b): " << __gcd(a, b) << "\n";
}
```

Output:

```cpp
cmath examples             
abs(-5): 5                 
pow(2, 3): 8               
sqrt(64): 8                
log2(64): 6                
exp(3): 20.0855            

algorithm examples         
a b: 4 7                   
a b: 7 4                   
min(a, b): 4               
max(a, b): 7 
__gcd(a, b): 1
```

==== User-defined functions

เราสามารถเขียนฟังก์ชันด้วยตนเองได้ โดยการระบุ:
 - ชนิด (type) ของค่าที่จะคืนค่า
 - ชื่อ (name) ที่ใช้เรียกฟังก์ชันนั้น
 - พารามิเตอร์ (parameters) ที่ไว้รับค่าเข้าสู่ฟังก์ชัน
 - ชุดคำสั่ง (statements) ที่ระบุวิธีการทำงานของฟังก์ชันนั้น

ในรูปแบบ:

```cpp
type name ( param1, param2, ...) { statements }
```

ตัวอย่างการเขียนฟังก์ชัน:

```cpp
#include <bits/stdc++.h>
using namespace std;

int addition(int a, int b) {
  int r;
  r = a + b;
  return r;
}

int main() {
  int z;
  z = addition(5, 3);
  cout << "The result is " << z;
}
```

Output:

```
The result is 8
```

==== มุมมองของฟังก์ชัน

ทางคณิตศาสตร์จะเขียนฟังก์ชันอยู่ในรูป $y = f(x)$ ซึ่งเมื่อเทียบกับทางคอมพิวเตอร์แล้วจะเทียบเท่าเป็นฟังก์ชันที่มี:
- ไม่ได้ระบุชนิดค่าที่จะคืนออกมา
- ชื่อ f
- รับพารามิเตอร์ x

ตัวอย่างฟังก์ชันเอกลักษณ์:

$f(x) = x$

ในภาษา C++:

```cpp
int f(int x) {
  return x;
}
```

=== โจทย์ตัวอย่าง - ค่าถัดไปของฟังก์ชันเวียนเกิด

==== เนื้อหาโจทย์

จงเขียนฟังก์ชัน `next_a(int p, int pn)` หาค่า:

$a_n = a_{n-1} + n times 2$

เมื่อทราบค่า $a_{n-1}$

==== รหัสเทียม

```cpp
int next_a(int p, int pn) {
    return p + (pn + 1) * 2;
}
```

=== โจทย์ตัวอย่าง - ระยะห่างระหว่างสองจุด

==== เนื้อหาโจทย์

กำหนดให้ $A(x_1,y_1)$ และ $B(x_2, y_2)$ เป็นจุดสองจุดบนระนาบ

==== รหัสเทียม

```cpp
double distance(double x1, double y1, double x2, double y2) {
    return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}
```

=== โจทย์ตัวอย่าง - ระยะห่าง Manhattan

==== เนื้อหาโจทย์

จงเขียนฟังก์ชัน `manhattan(x1, y1, x2, y2)` เพื่อหาระยะ Manhattan ระหว่าง $A$ และ $B$

==== รหัสเทียม

```cpp
double manhattan(double x1, double y1, double x2, double y2) {
    return abs(x1 - x2) + abs(y1 - y2);
}
```

=== ปัญหาที่พบบ่อย

==== Scope of variables

แต่ละฟังก์ชันมี scope ของตัวเอง ตัวแปรแบ่งเป็น:
- Global variables
- Local variables

ตัวอย่าง:

```cpp
#include <bits/stdc++.h>
using namespace std;

int g;

int addition(int a, int b) {
  int r;
  g = b;
  r = a + b;
  return r;
}

int main() {
  int z;
  z = addition(5, 3);
  cout << "z is " << z << "\n";
  cout << "g is " << g;
}
```

Output:

```
z is 8
g is 3

Errors when accessing out-of-scope variables:

cout << "z is " << z << "\n";
```

==== Return/type

ลืม return จะเกิด warning

```cpp
#include <bits/stdc++.h>
using namespace std;

int addition(int a, int b) {
  int r;
  r = a + b;
}
```

Output:

```
warning: no return statement in function returning non-void
```

==== Arguments passed by value and by references

เพื่อให้เปลี่ยนค่าพารามิเตอร์ใช้ & ข้างหน้า

ตัวอย่าง:

```cpp
void swap(int &a, int &b) {
  int c = a;
  a = b;
  b = c;
}

in main: 0 1
in swap: 1 0
in main: 1 0
```
