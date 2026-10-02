#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Standard Template Library (STL)

STL คือชุดโครงสร้างข้อมูลและอัลกอริทึมสำเร็จรูปของ C++ ใช้ได้ทันทีหลัง `#include <bits/stdc++.h>`
การใช้ STL เป็นทำให้โค้ดสั้น ถูกต้อง และเร็ว จึงเป็นทักษะสำคัญในการแข่งขัน

=== min, max, swap

```cpp
cout << max(2, 4) << ' ' << min(2, 4);  // 4 2
cout << max({3, 9, 1});                  // 9 (หลายค่าใช้ปีกกา)

int a = 1, b = 2;
swap(a, b);                              // a = 2, b = 1
```

ระวัง: `max(a, b)` ต้องเป็นชนิดเดียวกัน เช่น `max(x, 0LL)` เมื่อ `x` เป็น `long long`

=== vector

`vector` คือ array ที่เปลี่ยนขนาดได้ (dynamic array) ใช้แทน array ธรรมดาได้เกือบทุกกรณี

```cpp
vector<int> v;             // ว่าง
vector<int> c(5, 0);       // ขนาด 5 ทุกตัวเป็น 0
vector<int> w = {3, 1, 2};

v.push_back(10);           // เพิ่มท้าย: {10}
v.push_back(20);           // {10, 20}
cout << v[0] << ' ' << v.back() << ' ' << v.size();  // 10 20 2
v.pop_back();              // ลบตัวท้าย: {10}
cout << v.empty();         // 0 (false)
```

วนทุกสมาชิกได้สองแบบ

```cpp
for (int i = 0; i < (int)w.size(); i++) cout << w[i] << ' ';
for (int x : w) cout << x << ' ';  // range-based for
```

`size()` คืนค่าชนิดไม่ติดลบ (unsigned) ดังนั้น `w.size() - 1` เมื่อ vector ว่างจะได้เลขมหาศาล ให้แปลงเป็น `int` ก่อนเสมอ

vector สองมิติ:

```cpp
vector<vector<int>> grid(n, vector<int>(m, 0));  // n แถว m คอลัมน์
```

=== pair

`pair` เก็บค่าสองค่าคู่กัน เข้าถึงด้วย `.first` และ `.second`

```cpp
pair<string, int> p = {"alice", 90};
cout << p.first << ' ' << p.second;  // alice 90
auto [name, score] = p;             // แยกตัวแปร (C++17)
```

การเปรียบเทียบ pair ดูตัว `first` ก่อน ถ้าเท่ากันจึงดู `second` จึงใช้ `sort` vector ของ pair ได้ทันที

=== sort

```cpp
vector<int> v = {5, 2, 8, 1};
sort(v.begin(), v.end());                 // 1 2 5 8
sort(v.begin(), v.end(), greater<int>()); // 8 5 2 1
reverse(v.begin(), v.end());              // กลับลำดับ: 1 2 5 8

int a[] = {3, 1, 2};
sort(a, a + 3);                           // array ธรรมดา: ส่งตำแหน่งเริ่มและตำแหน่งหลังตัวสุดท้าย
```

เรียงตามเงื่อนไขเองด้วย lambda เช่น เรียงคะแนนจากมากไปน้อย ถ้าเท่ากันเรียงชื่อตามตัวอักษร

```cpp
vector<pair<string, int>> s = {{"bob", 80}, {"amy", 90}, {"cat", 80}};
sort(s.begin(), s.end(), [](const auto& x, const auto& y) {
  if (x.second != y.second) return x.second > y.second;
  return x.first < y.first;
});
// amy 90, bob 80, cat 80
```

`sort` ใช้เวลา $O(n log n)$ ฟังก์ชันเปรียบเทียบต้องคืน `true` เมื่อ `x` ต้องมาก่อน `y` *อย่างเคร่งครัด* (ห้ามใช้ `<=`)

=== ค้นหาใน vector ที่เรียงแล้ว

#table(
  columns: 2,
  header([ฟังก์ชัน], [คืนค่า]),
  [`lower_bound(b, e, x)`], [ตำแหน่งแรกที่ค่า $>= x$],
  [`upper_bound(b, e, x)`], [ตำแหน่งแรกที่ค่า $> x$],
  [`binary_search(b, e, x)`], [`true` ถ้ามี $x$],
)

```cpp
vector<int> v = {1, 3, 3, 3, 7};
int i = lower_bound(v.begin(), v.end(), 3) - v.begin();  // 1
int j = upper_bound(v.begin(), v.end(), 3) - v.begin();  // 4
cout << j - i;  // 3 = จำนวนเลข 3 ใน v
```

ทั้งหมดใช้ binary search จึงเร็ว $O(log n)$ แต่ *ต้องเรียงข้อมูลก่อน* (ดูหลักการในบท Divide and Conquer)

=== อัลกอริทึมอื่นที่ใช้บ่อย

```cpp
vector<int> v = {3, 1, 3, 2, 1};
cout << accumulate(v.begin(), v.end(), 0LL);    // ผลรวม 10 (0LL ให้ผลรวมเป็น long long)
cout << count(v.begin(), v.end(), 3);           // 2
cout << *max_element(v.begin(), v.end());       // 3

sort(v.begin(), v.end());                       // 1 1 2 3 3
v.erase(unique(v.begin(), v.end()), v.end());   // ลบตัวซ้ำ: 1 2 3

vector<int> p = {1, 2, 3};
do {
  // ได้ทุก permutation: 123, 132, 213, 231, 312, 321
} while (next_permutation(p.begin(), p.end()));
```

=== string

```cpp
string s = "hello";
s += " world";                    // ต่อข้อความ
cout << s.size();                 // 11
cout << s.substr(0, 5);           // hello (เริ่มที่ 0 ยาว 5)
cout << (s.find("wor") != string::npos);  // 1 (เจอ)
sort(s.begin(), s.end());         // เรียงตัวอักษรได้เหมือน vector
string t = to_string(42);         // "42"
int x = stoi("123");              // 123
```

=== Container อื่น ๆ

แต่ละตัวมีรายละเอียดในบทของตัวเอง

#table(
  columns: 3,
  header([Container], [ใช้ทำอะไร], [บท]),
  [`stack`, `queue`, `deque`], [เข้า-ออกตามลำดับ LIFO / FIFO], [Stack and Queue],
  [`priority_queue`], [ดึงค่ามากสุด (หรือน้อยสุด) ได้เร็ว], [Priority Queue],
  [`set`, `multiset`], [เก็บค่าเรียงลำดับ ค้นหา/เพิ่ม/ลบ $O(log n)$], [Set and Map],
  [`map`], [จับคู่ key กับ value แบบเรียงลำดับ], [Set and Map],
  [`unordered_map`, `unordered_set`], [เหมือน map/set แต่ใช้ hash เฉลี่ย $O(1)$], [Hash Table],
)

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1621")[Distinct Numbers] (`sort` + `unique`)
- #link("https://cses.fi/problemset/task/1084")[Apartments] (`sort`)
- #link("https://cses.fi/problemset/task/1622")[Creating Strings] (`next_permutation`)
- #link("https://cses.fi/problemset/task/1640")[Sum of Two Values] (`sort` + pair)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
