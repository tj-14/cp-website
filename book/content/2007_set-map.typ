#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Set & Map

=== คำอธิบาย

`set` และ `map` ใน STL เก็บข้อมูล *เรียงลำดับเสมอ* โดยภายในเป็น red-black tree (self-balancing BST แบบหนึ่ง ดูบท Binary Search Tree) ความสูงจึงเป็น $O(log n)$ ทำให้ค้นหา เพิ่ม และลบได้ใน $O(log n)$

- `set` เก็บ *key* ที่ไม่ซ้ำกัน เหมือนเซตในคณิตศาสตร์
- `multiset` เหมือน `set` แต่เก็บค่าซ้ำได้
- `map` เก็บคู่ *key-value* ที่ key ไม่ซ้ำกัน เหมือน dictionary ใน Python หรือ array ที่ index เป็นอะไรก็ได้

=== set

```cpp
set<int> s;
s.insert(2);
s.insert(10);
s.insert(5);
s.insert(5);                 // ซ้ำ: ไม่มีผล
for (int x : s) cout << x << ' ';  // 2 5 10 (เรียงเสมอ)

cout << s.size();            // 3
cout << s.count(5);          // 1 (มี) หรือ 0 (ไม่มี)
s.erase(5);                  // ลบ 5
cout << *s.begin();          // 2 = ค่าน้อยสุด
cout << *s.rbegin();         // 10 = ค่ามากสุด
```

==== ค้นหาค่าที่ใกล้ที่สุด

เพราะข้อมูลเรียงอยู่แล้ว จึงหาค่าแรกที่ $>= x$ หรือ $> x$ ได้ใน $O(log n)$ ใช้บ่อยมากในการแข่งขัน

```cpp
set<int> s = {10, 20, 30};
auto it = s.lower_bound(15);  // ตัวแรกที่ >= 15
cout << *it;                  // 20
it = s.upper_bound(30);       // ตัวแรกที่ > 30
if (it == s.end()) cout << "none";

auto jt = s.lower_bound(25);  // ค่าที่มากที่สุดที่ < 25: ถอยหนึ่งตำแหน่ง
if (jt != s.begin()) cout << *prev(jt);  // 20
```

ต้องใช้ `s.lower_bound(x)` ไม่ใช่ `lower_bound(s.begin(), s.end(), x)` เพราะแบบหลังกับ set ใช้เวลา $O(n)$

=== multiset

```cpp
multiset<int> ms = {5, 1, 5, 3};
cout << ms.count(5);      // 2
ms.erase(ms.find(5));     // ลบ 5 ออกหนึ่งตัว
cout << ms.count(5);      // 1
ms.erase(5);              // ระวัง: ลบ 5 ออก *ทุกตัว*
```

`ms.erase(x)` ลบทุกตัวที่เท่ากับ `x` ถ้าต้องการลบตัวเดียวต้องใช้ `ms.erase(ms.find(x))` (ตรวจก่อนว่า `find` ไม่คืน `end()`)

=== map

```cpp
map<string, int> cnt;
cnt["apple"] = 3;          // เพิ่มหรือแก้ค่า
cnt["banana"]++;           // key ที่ยังไม่มี จะถูกสร้างด้วยค่า 0 ก่อน แล้ว ++ เป็น 1

for (auto [key, value] : cnt) {   // เรียงตาม key
  cout << key << ' ' << value << '\n';
}
// apple 3
// banana 1

if (cnt.count("cherry")) cout << "found";  // ตรวจว่ามี key โดยไม่สร้างใหม่
cnt.erase("apple");
```

ระวัง: แค่ *อ่าน* `cnt["cherry"]` ก็สร้าง key `"cherry"` ด้วยค่า 0 ขึ้นมาทันที ถ้าต้องการแค่ตรวจให้ใช้ `count` หรือ `find`

=== ความเร็ว

#table(
  columns: 3,
  header([Operation], [set / map], [vector ที่ไม่เรียง]),
  [insert], [$O(log n)$], [$O(1)$ ท้าย],
  [ค้นหาว่ามี $x$ หรือไม่], [$O(log n)$], [$O(n)$],
  [erase ค่า $x$], [$O(log n)$], [$O(n)$],
  [ค่าน้อยสุด/มากสุด], [$O(1)$], [$O(n)$],
  [ค่าแรกที่ $>= x$], [$O(log n)$], [$O(n)$],
)

ถ้าไม่ต้องการลำดับ `unordered_set` และ `unordered_map` ใช้ hash table (ดูบท Hash Table) เร็วกว่าเฉลี่ย $O(1)$ แต่ไม่มี `lower_bound` และอาจช้าลงมากถ้าถูกออกแบบ input มาให้ชนกัน

=== ตัวอย่าง: นับความถี่และหาค่าที่พบบ่อยที่สุด

```cpp
vector<string> words = {"a", "b", "a", "c", "b", "a"};
map<string, int> freq;
for (const string& w : words) freq[w]++;

string best;
for (auto [w, c] : freq) {
  if (best.empty() || c > freq[best]) best = w;
}
cout << best << ' ' << freq[best];  // a 3
```

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1621")[Distinct Numbers] (`set`)
- #link("https://cses.fi/problemset/task/1091")[Concert Tickets] (`multiset` + `upper_bound`)
- #link("https://cses.fi/problemset/task/1141")[Playlist] (`map` หรือ `set` กับสองตัวชี้)
- #link("https://cses.fi/problemset/task/1163")[Traffic Lights] (`set` + `multiset`)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
