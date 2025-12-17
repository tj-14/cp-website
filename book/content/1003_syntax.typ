#import "@preview/ilm:1.4.0": *
#import table: cell, header

== พื้นฐาน

=== โปรแกรมที่ใช้เขียน
- เริ่มด้วย VS Code #footnote[https://code.visualstudio.com/] กับ plugin cph #footnote[https://marketplace.visualstudio.com/items?itemName=DivyanshuAgrawal.competitive-programming-helper] น่าจะง่ายสุดแล้ว

=== โค้ดเริ่มต้น

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  return 0;
}
```

- `bits/stdc++.h` เป็น library ครอบจักรวาล
- `using namespace std` ใช้เพื่อความสะดวก
  - เดิมต้องเขียน `std::cout << "Hello World!";` ในการแสดงผล `Hello World!` 
  - ถ้ามี `using namespace std` จะไม่ต้องพิมพ์ `std::`
  - ก็คือจะเหลือ `cout << "Hello World!;` พอ

=== Comments

คอมเม้นท์ไว้บอกคอมว่าไม่ต้องรันบรรทัดนั้นๆ ทำได้สองแบบ

```cpp
// line comment 

/*
block 
comment
*/
```

=== Variables Data Types

ในภาษา C++ จำเป็นจะต้องประกาศ "ชนิด" ของตัวแปรเสมอ (ต่างจาก Python)

ชนิดที่พบบ่อยคือ

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
)

#table(
    columns: 3,
    header(
      [ชนิด],
      [ขนาด (byte)],
      [],
    ),
[`bool`      ],[ 1            ],[ ค่าความจริง true, false (0-1)],
[`char`      ],[ 2            ],[ ตัวอักษร],
[`int`       ],[ 4            ],[ จำนวนเต็ม],
[`long long` ],[ 8            ],[ จำนวนเต็มที่เก็บค่าได้มากกว่า],
[`float`     ],[ 4            ],[ จำนวนจริง],
[`double`    ],[ 8            ],[ จำนวนจริงที่เก็บค่าได้มากกว่า],
)

สาเหตุที่มีชนิดเดียวกันที่เก็บค่าได้แตกต่างกันเพราะการจองพื้นที่ memory ขนาดไม่เท่ากัน

=== Input/Output

- ใช้ `cin` ในการรับค่า โดยที่ `cin` จะดูชนิดของตัวแปรให้ตอนที่รับค่า

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  int a;
  cin >> a;
  return 0;
}
```

หากพิมพ์ `5` หลังจากรันโปรแกรมแล้ว `a` จะมีค่าเท่ากับ $5$ ที่เป็น `integer`

ถ้า

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  char a;
  cin >> a;
  return 0;
}
```

แล้วพิมพ์ `5` หลังจากรันโปรแกรมแล้ว `a` จะมีค่าเท่ากับ `'5'` ที่เป็น `character`

ตัวอย่างเช่น

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  char a;
  int b;
  cin >> a >> b;
  int c = a;
  cout << c << " " << b;
  return 0;
}
```
แล้วพิมพ์ `5 5` จะได้ผลลัพธ์เป็น `53 5` เนื่องจาก character `'5'` มีค่า ascii เป็น $53$ (ถูกแปลงค่า)

- `'\n'` เป็น special character ที่ใช้สำหรับขึ้นบรรทัดใหม่ในการแสดงผล เช่น

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  char a;
  int b;
  cin >> a >> b;
  int c = a;
  cout << c << "\n" << b;
  return 0;
}
```
แล้วพิมพ์ `5 5` จะได้ผลลัพธ์เป็น 

```
53 
5
```

- สังเกตว่า `cout` ต้องใช้เป็นท่อน ๆ คือส่ง `<<` ได้ทีละตัวแปรหรือทีละ string เท่านั้น

- เช่นเดียวกัน `cin` ที่ใช้เป็นท่อน ๆ คือรับ `>>` เข้าทีละตัวแปร โดยตัด input ตามประเภทตัวแปร

=== Control Structures

==== condition

- `if`-`else if`-`else`
```cpp 
if (x > 0)
  cout << "x is positive";
else if (x < 0)
  cout << "x is negative";
else
  cout << "x is 0";
```

==== loop

- `while`
```cpp
int i = 0;
while (i < 10) {
  cout << i << " ";
  i++;
} 
```

- `for`

```cpp
for (int i = 0; i < 10; i++) {
  cout << i << " ";
} 
```

=== Arrays

ใน C++ นั้นตัวแปรทุกชนิดสามารถทำเป็นตัวแปรชุด (Array) ได้ด้วยการใส่วงเล็บ `[]` ด้านหลังชื่อตัวแปร เช่น

จาก `int a` เป็นการประกาศตัวแปรที่เป็นจำนวนเต็มหนึ่งจำนวน

สามารถเป็น `int a[10]` เป็นการประกาศตัวแปรที่เป็นจำนวนเต็ม `10` จำนวน โดยจะเรียกสมาชิกได้ เช่น

`a[0]` เป็นการเรียกสมาชิกตัวแรกใน array นั้น

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  int n;
  int a[20];
  cin >> n;
  for (int i = 0; i < n; i++) {
    cin >> a[i];
  }
  return 0;
}
```

ตัวอย่างด้านบนจะเป็นการรับค่า `n` เพื่อที่จะรับจำนวนเต็มต่ออีก $n$ จำนวน (ใช้ต่อในเงื่อนไขของ for loop)

จากนั้นรับค่าเข้าสู่ `a[i]` ไปเรื่อย ๆ โดย $i=\{0,1,dots,n\}$

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  int n;
  int a[20];
  cin >> n;
  for (int i = 0; i < n; i++) {
    cin >> a[i];
  }
  int sm = 0;
  for (int i = 0; i < n; i++) {
    sm += a[i];
  }
  cout << sm;
  return 0;
}
```

ตัวอย่างด้านบนเป็นการนำค่าที่รับเข้ามาไปใช้หาผลรวมต่อในตัวแปร `sm`

=== Strings

ใน C++ มี `string` ให้ใช้ใน STL ซึ่งถูกรวมอยู่ใน `bits/stdc++.h` แล้ว

จากที่ภาษา C ธรรมดาจะต้องใช้เป็น array of characters จึงสะดวกขึ้นเยอะ

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  string a;
  cin >> a;
  cout << a;
  return 0;
}
```

ตัวอย่างด้านบนเป็นการรับค่า string แล้วส่งออกเลย

=== Functions

```cpp
#include <bits/stdc++.h>

using namespace std;

int addint(int a, int b) {
  return a + b;
}

int main() {
  cout << addint(1, 4);
  return 0;
}
```

ตัวอย่างด้านบนเป็นการสร้างฟังก์ชัน $f(a, b) = a+b$ โดยให้ชื่อว่า `addint` พร้อมตัวอย่างการเรียกใช้

=== Array หลายมิติ

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  int a[5][5];
  int n, m;
  cin >> n >> m;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      cin >> a[i][j];
    }
  }
  return 0;
}
```
