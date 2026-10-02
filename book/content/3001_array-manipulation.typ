#import "@preview/ilm:1.4.0": *
#import table: cell, header
#import "widgets.typ": widget

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

ลองคลิกสองช่องเพื่อดูว่าผลรวมช่วงมาจาก prefix sum สองค่าอย่างไร แล้วเปลี่ยนเป็นโหมด difference array เพื่อเพิ่มค่าทั้งช่วงหลายครั้ง

#widget("prefix-sum")

=== Prefix sum สองมิติ

สำหรับตาราง ให้ `P[i][j]` เป็นผลรวมของสี่เหลี่ยมตั้งแต่ $(1, 1)$ ถึง $(i, j)$ ผลรวมของสี่เหลี่ยม $(r_1, c_1)$ ถึง $(r_2, c_2)$ หาได้ใน $O(1)$ ด้วยหลัก inclusion-exclusion

```cpp
for (int i = 1; i <= n; i++)
  for (int j = 1; j <= m; j++)
    P[i][j] = a[i][j] + P[i - 1][j] + P[i][j - 1] - P[i - 1][j - 1];

long long rect(int r1, int c1, int r2, int c2) {
  return P[r2][c2] - P[r1 - 1][c2] - P[r2][c1 - 1] + P[r1 - 1][c1 - 1];
}
```

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

// node เก็บผลรวมของช่วง [l, r] ลูกคือ 2*node และ 2*node+1
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

void update(int node, int l, int r, int pos, long long val) {  // a[pos] = val
  if (l == r) {
    seg[node] = val;
    return;
  }
  int mid = (l + r) / 2;
  if (pos <= mid) update(node * 2, l, mid, pos, val);
  else update(node * 2 + 1, mid + 1, r, pos, val);
  seg[node] = seg[node * 2] + seg[node * 2 + 1];
}

long long query(int node, int l, int r, int ql, int qr) {  // ผลรวม a[ql..qr]
  if (qr < l || r < ql) return 0;              // ไม่ทับกันเลย
  if (ql <= l && r <= qr) return seg[node];    // อยู่ในช่วงทั้งหมด
  int mid = (l + r) / 2;
  return query(node * 2, l, mid, ql, qr) + query(node * 2 + 1, mid + 1, r, ql, qr);
}
// เรียกใช้: build(1, 1, n); update(1, 1, n, pos, val); query(1, 1, n, l, r);
```

เปลี่ยน `+` เป็น `min`, `max` หรือ `gcd` (และค่าที่คืนเมื่อไม่ทับกันเป็น identity ของ operation นั้น) ก็ได้ segment tree สำหรับ operation อื่นทันที

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

- #link("https://cses.fi/problemset/task/1646")[Static Range Sum Queries] (prefix sum)
- #link("https://cses.fi/problemset/task/1652")[Forest Queries] (prefix sum 2 มิติ)
- #link("https://cses.fi/problemset/task/1660")[Subarray Sums I]
- #link("https://cses.fi/problemset/task/1643")[Maximum Subarray Sum]
- #link("https://cses.fi/problemset/task/1648")[Dynamic Range Sum Queries] (Fenwick / segment tree)
- #link("https://cses.fi/problemset/task/1649")[Dynamic Range Minimum Queries] (segment tree)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
