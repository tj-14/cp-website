#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Array Manipulation

=== คำอธิบาย

โจทย์กลุ่ม array manipulation คือโจทย์ที่มีข้อมูลเรียงเป็นลำดับ แล้วต้องตอบคำถามหรือแก้ไขค่าในช่วงของ array ให้เร็วกว่าไล่ดูทุกช่องทุกครั้ง

ตัวอย่างคำถามที่พบบ่อย

- หาผลรวมช่วง $[l,r]$
- เพิ่มค่าทุกตำแหน่งในช่วง $[l,r]$
- หาค่าน้อยสุดหรือมากสุดในช่วง
- นับจำนวนค่าที่ตรงเงื่อนไขบางอย่าง

=== Motivation problem

ถ้ามี array ขนาด $n$ และมีคำถาม $q$ ครั้ง แต่ละครั้งถามผลรวมตั้งแต่ตำแหน่ง $l$ ถึง $r$ วิธีตรงไปตรงมาคือวนตั้งแต่ $l$ ถึง $r$

```cpp
long long sum = 0;
for (int i = l; i <= r; i++) {
  sum += a[i];
}
```

ถ้าแต่ละ query ใช้เวลา $O(n)$ เวลารวมจะเป็น $O(n q)$ ซึ่งช้าเกินไปเมื่อ $n,q$ มีค่าประมาณ $10^5$

=== Prefix sum

ถ้า array ไม่มีการแก้ไขค่า เราสามารถ preprocess ด้วย prefix sum ได้

```cpp
pref[0] = 0;
for (int i = 1; i <= n; i++) {
  pref[i] = pref[i - 1] + a[i];
}
```

ผลรวมช่วง $[l,r]$ คือ

`pref[r] - pref[l-1]`

เวลา preprocess คือ $O(n)$ และตอบแต่ละ query ได้ใน $O(1)$

=== Difference array

ถ้าโจทย์ให้เพิ่มค่า $x$ ทุกตำแหน่งในช่วง $[l,r]$ หลายครั้ง แล้วค่อยถามค่า array สุดท้าย ใช้ difference array ได้

```cpp
diff[l] += x;
diff[r + 1] -= x;
```

หลังจากทำทุก update แล้ว คำนวณค่าจริงด้วย prefix sum ของ `diff`

```cpp
long long cur = 0;
for (int i = 1; i <= n; i++) {
  cur += diff[i];
  a[i] += cur;
}
```

เทคนิคนี้เหมาะกับโจทย์ offline ที่รู้ update ทั้งหมดก่อนตอบคำถาม

=== Fenwick Tree

Fenwick Tree หรือ Binary Indexed Tree ใช้ตอบ range sum และ point update ได้เร็ว

- update หนึ่งตำแหน่ง: $O(log n)$
- query prefix sum: $O(log n)$
- ใช้หน่วยความจำ $O(n)$

```cpp
vector<long long> bit(n + 1);

void add(int idx, long long val) {
  for (; idx <= n; idx += idx & -idx) {
    bit[idx] += val;
  }
}

long long sum(int idx) {
  long long res = 0;
  for (; idx > 0; idx -= idx & -idx) {
    res += bit[idx];
  }
  return res;
}

long long range_sum(int l, int r) {
  return sum(r) - sum(l - 1);
}
```

ใช้กับโจทย์ Dynamic Range Sum Queries #footnote[https://cses.fi/problemset/task/1648/] ได้โดยตรง

=== Segment Tree

Segment Tree เหมาะเมื่อ operation ซับซ้อนกว่า sum เช่น min, max, gcd หรือมี range update

- build: $O(n)$
- query ช่วง: $O(log n)$
- update หนึ่งตำแหน่ง: $O(log n)$
- ใช้หน่วยความจำประมาณ $O(4n)$

```cpp
vector<long long> seg(4 * n);

void build(int node, int l, int r) {
  if (l == r) {
    seg[node] = a[l];
    return;
  }
  int mid = (l + r) / 2;
  build(node * 2, l, mid);
  build(node * 2 + 1, mid + 1, r);
  seg[node] = seg[node * 2] + seg[node * 2 + 1];
}
```

=== เลือกใช้อะไรดี

#table(
  columns: 4,
  header([เทคนิค], [update], [query], [เหมาะกับ]),
  [Prefix sum], [$O(1)$ หลัง preprocess], [$O(1)$], [ไม่มีการแก้ค่า],
  [Difference array], [$O(1)$ ต่อช่วง], [$O(n)$ เพื่อสรุปผล], [update หลายช่วงแบบ offline],
  [Fenwick Tree], [$O(log n)$], [$O(log n)$], [sum และ frequency],
  [Segment Tree], [$O(log n)$], [$O(log n)$], [operation หลากหลาย],
)

=== แหล่งฝึก

- Fenwick Tree #footnote[https://csacademy.com/lesson/fenwick_trees/]
- Segment Tree #footnote[https://csacademy.com/lesson/segment_trees/]
- Visualgo Fenwick Tree #footnote[https://visualgo.net/en/fenwicktree?slide=1]
- Visualgo Segment Tree #footnote[https://visualgo.net/en/segmenttree?slide=1]

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1660")[Subarray Sums I]
- #link("https://cses.fi/problemset/task/1643")[Maximum Subarray Sum]
- #link("https://cses.fi/problemset/task/2216")[Collecting Numbers]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
