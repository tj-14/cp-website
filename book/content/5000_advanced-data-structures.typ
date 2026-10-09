#import "@preview/ilm:1.4.0": *

== Advanced Data Structures

บทนี้สรุปจากการสอนค่าย สสวท. (IOI Training Camp) เดือนตุลาคม 2024 สำหรับผู้ที่ผ่าน สอวน. และ TOI มาแล้ว จึงถือว่าเขียน segment tree, DFS บน tree และ binary search ได้คล่อง

- สไลด์: #link("https://docs.google.com/presentation/d/1jmAi2EfKdaHVtguGUg9acrTliq7tm36kW6EPNvQKK4k/edit?usp=sharing")[Advanced Data Structures (Oct'24)]
- เฉลยโจทย์ในสไลด์: #link("https://docs.google.com/presentation/d/1l6Ech3VsNqPxJNm8kqnhsojcqDZ6PMT5vXl1D3SkhHU/edit")[Advanced Data Structures (sol)]

ควรมองโครงสร้างข้อมูลขั้นสูงจากสองมุม

+ *คิดขึ้นมาได้อย่างไร*: โครงสร้างแต่ละแบบแก้จุดช้าของแบบที่ง่ายกว่า เช่น LCA แบบเดินทีละขั้นช้า จึงกระโดดทีละ $2^j$
+ *ใช้เป็นชิ้นส่วนอย่างไร*: โจทย์ระดับนี้ไม่ค่อยถามโครงสร้างตรง ๆ แต่ต้องแปลงโจทย์ให้เหลือ "update ช่วง / query ช่วง" หรือ "query บนเส้นทางใน tree" ก่อน

=== Lowest Common Ancestor (LCA)

LCA ของ $u$ และ $v$ ใน rooted tree คือ vertex ที่ลึกที่สุดที่เป็นบรรพบุรุษของทั้งคู่

วิธีตรงไปตรงมาคือยก vertex ที่ลึกกว่าขึ้นจนลึกเท่ากัน แล้วยกทั้งคู่ขึ้นทีละขั้นจนเจอกัน ซึ่งใช้ $O(n)$ ต่อคำถาม

*Binary lifting* เก็บ `up[j][v]` = บรรพบุรุษลำดับที่ $2^j$ ของ $v$ เพราะ $2^j = 2^(j-1) + 2^(j-1)$ จึงคำนวณได้จาก `up[j][v] = up[j-1][up[j-1][v]]` ทำให้กระโดดระยะใดก็ได้ใน $O(log n)$ ขั้น ตามบิตของระยะนั้น

```cpp
const int LOG = 18;  // 2^18 > 2e5
int up[LOG][N], dep[N];

void dfs(int u, int p) {
  up[0][u] = p;
  for (int v : adj[u]) {
    if (v == p) continue;
    dep[v] = dep[u] + 1;
    dfs(v, u);
  }
}

void build(int root, int n) {
  dfs(root, root);  // พ่อของ root คือตัวเอง จะได้ไม่กระโดดออกนอก tree
  for (int j = 1; j < LOG; j++)
    for (int v = 0; v < n; v++) up[j][v] = up[j - 1][up[j - 1][v]];
}

int lca(int a, int b) {
  if (dep[a] < dep[b]) swap(a, b);
  int diff = dep[a] - dep[b];
  for (int j = 0; j < LOG; j++)
    if (diff >> j & 1) a = up[j][a];
  if (a == b) return a;
  for (int j = LOG - 1; j >= 0; j--) {
    if (up[j][a] != up[j][b]) {  // ยังไม่เจอกัน กระโดดได้อย่างปลอดภัย
      a = up[j][a];
      b = up[j][b];
    }
  }
  return up[0][a];
}
```

ระยะทางระหว่าง $u$ กับ $v$ คือ `dep[u] + dep[v] - 2 * dep[lca(u, v)]`

=== Fenwick Tree (Binary Indexed Tree)

ถ้าต้องการแค่ point update กับ prefix sum, Fenwick tree สั้นกว่า segment tree มาก
ช่อง `bit[i]` เก็บผลรวมช่วงยาว `i & -i` (บิตต่ำสุดของ $i$) ที่จบที่ $i$

```cpp
long long bit[N];  // 1-indexed

void add(int i, long long x) {
  for (; i < N; i += i & -i) bit[i] += x;
}

long long prefix(int i) {  // a[1] + ... + a[i]
  long long s = 0;
  for (; i > 0; i -= i & -i) s += bit[i];
  return s;
}
// sum ของ [l, r] = prefix(r) - prefix(l - 1)
```

ซ้อนลูปสองชั้นจะได้ *2D Fenwick tree* สำหรับผลรวมสี่เหลี่ยม ใช้ $O(log^2 n)$ ต่อคำสั่ง

=== Lazy: เลื่อนงานไปทำทีหลัง

แนวคิด lazy คือ *ไม่ทำงานจนกว่าจะจำเป็น* แล้วจดไว้ว่าค้างอะไรอยู่

==== Lazy deletion ใน heap

`priority_queue` ลบสมาชิกที่ไม่ใช่ top ไม่ได้ วิธีแก้คือเก็บอีก heap หนึ่งไว้จดว่า "ลบแล้ว" และค่อยทิ้งตอนมันขึ้นมาเป็น top

```cpp
priority_queue<int> pq, removed;

void erase(int x) { removed.push(x); }

int top() {
  while (!removed.empty() && pq.top() == removed.top()) {
    pq.pop();
    removed.pop();
  }
  return pq.top();
}
```

==== Lazy propagation ใน segment tree

ถ้าบวก $x$ ทั้งช่วง $[l, r]$ โดย update ทีละตัวจะใช้ $O(n log n)$ แทนที่จะเป็นอย่างนั้น เมื่อ node ครอบช่วงทั้งหมดก็หยุดลงไปแล้วจดค่า `lz` ไว้ที่ node นั้น พอต้องลงไปที่ลูกครั้งถัดไปจึง *push* ค่าที่ค้างลงไป

ฟังก์ชันที่ต้องคิดให้ครบมีสี่ตัว: build, update, query และ push (pushdown)

```cpp
long long t[4 * N], lz[4 * N];  // range add, range sum

void apply(int v, int len, long long x) {
  t[v] += x * len;
  lz[v] += x;
}

void push(int v, int tl, int tr) {
  if (lz[v] == 0) return;
  int tm = (tl + tr) / 2;
  apply(2 * v, tm - tl + 1, lz[v]);
  apply(2 * v + 1, tr - tm, lz[v]);
  lz[v] = 0;
}

void update(int v, int tl, int tr, int l, int r, long long x) {
  if (r < tl || tr < l) return;
  if (l <= tl && tr <= r) {
    apply(v, tr - tl + 1, x);
    return;
  }
  push(v, tl, tr);
  int tm = (tl + tr) / 2;
  update(2 * v, tl, tm, l, r, x);
  update(2 * v + 1, tm + 1, tr, l, r, x);
  t[v] = t[2 * v] + t[2 * v + 1];
}

long long query(int v, int tl, int tr, int l, int r) {
  if (r < tl || tr < l) return 0;
  if (l <= tl && tr <= r) return t[v];
  push(v, tl, tr);
  int tm = (tl + tr) / 2;
  return query(2 * v, tl, tm, l, r) + query(2 * v + 1, tm + 1, tr, l, r);
}
```

ถ้ามี update หลายแบบ เช่น *set* และ *add* ให้เก็บ lazy แยกกัน (`lzSet`, `lzAdd`) และคิดให้ดีว่าเมื่อซ้อนกันต้องทำอะไรก่อน เช่น set ล้าง add ที่ค้างอยู่ทั้งหมด

=== Persistent Segment Tree

Persistent data structure เก็บ *ทุกเวอร์ชัน* หลังการ update แต่ละครั้ง และ query เวอร์ชันเก่าได้

สังเกตว่า point update เปลี่ยนแค่ node บนเส้นทางจาก root ถึง leaf ซึ่งมี $O(log n)$ node จึงสร้าง node ใหม่เฉพาะเส้นทางนั้น แล้วชี้ไปที่ลูกเดิมสำหรับส่วนที่ไม่เปลี่ยน แต่ละเวอร์ชันจำแค่ root ของตัวเอง

```cpp
struct Node { long long sum; int l, r; };
vector<Node> nodes = {{0, 0, 0}};  // node 0 คือ tree ว่าง ลูกชี้กลับมาที่ตัวเอง

int update(int v, int tl, int tr, int pos, long long val) {
  Node copy = nodes[v];  // copy node เดิม
  int u = nodes.size();
  nodes.push_back(copy);
  if (tl == tr) {
    nodes[u].sum = val;
    return u;
  }
  int tm = (tl + tr) / 2;
  if (pos <= tm) {
    int child = update(nodes[v].l, tl, tm, pos, val);
    nodes[u].l = child;  // เก็บใส่ตัวแปรก่อน: push_back ใน update อาจย้าย memory ของ nodes
  } else {
    int child = update(nodes[v].r, tm + 1, tr, pos, val);
    nodes[u].r = child;
  }
  nodes[u].sum = nodes[nodes[u].l].sum + nodes[nodes[u].r].sum;
  return u;
}

long long query(int v, int tl, int tr, int l, int r) {
  if (v == 0 || r < tl || tr < l) return 0;
  if (l <= tl && tr <= r) return nodes[v].sum;
  int tm = (tl + tr) / 2;
  return query(nodes[v].l, tl, tm, l, r) + query(nodes[v].r, tm + 1, tr, l, r);
}
// roots[k] = update(roots[k - 1], 0, n - 1, pos, val);
```

หน่วยความจำรวม $O(n + q log n)$ ต่างจากการ copy ทั้ง tree ทุกครั้งซึ่งใช้ $O(n q)$

=== Heavy-Light Decomposition (HLD)

HLD ใช้ตอบ query บน *เส้นทาง* ใน tree เช่น "ค่ามากสุดบนเส้นทาง $u$ ถึง $v$" พร้อม update ค่าใน vertex

- *Heavy child* ของ $v$ คือลูกที่ subtree ใหญ่ที่สุด ลูกที่เหลือเป็น *light child*
- ต่อ heavy edge กันได้เป็น *heavy path* และแต่ละ vertex อยู่ใน heavy path เดียว
- ทุกครั้งที่เดินผ่าน light edge ขึ้นไป ขนาด subtree อย่างน้อยเท่าตัว ดังนั้นเส้นทางใด ๆ ผ่าน light edge ไม่เกิน $O(log n)$ ครั้ง

ถ้า DFS โดยไปที่ heavy child ก่อนเสมอ แต่ละ heavy path จะได้ลำดับ `in[]` ที่ติดกัน จึงใช้ segment tree ตัวเดียวบน `in[]` ได้ เส้นทางหนึ่งแตกเป็น $O(log n)$ ช่วง แต่ละช่วงใช้ $O(log n)$ รวม $O(log^2 n)$

```cpp
// g[v] คือรายชื่อลูก (rooted tree ที่ root = 0) หลัง dfs_sz ลูกตัวแรกคือ heavy child
int sz[N], par[N], dep[N], in[N], out[N], nxt[N], timer = 0;

void dfs_sz(int v) {
  sz[v] = 1;
  for (int &u : g[v]) {
    par[u] = v;
    dep[u] = dep[v] + 1;
    dfs_sz(u);
    sz[v] += sz[u];
    if (sz[u] > sz[g[v][0]]) swap(u, g[v][0]);
  }
}

void dfs_hld(int v) {
  in[v] = timer++;
  for (int u : g[v]) {
    nxt[u] = (u == g[v][0] ? nxt[v] : u);  // nxt = หัวของ heavy path
    dfs_hld(u);
  }
  out[v] = timer;  // subtree ของ v คือช่วง [in[v], out[v])
}

int path_max(int a, int b) {  // seg_max(l, r) = max ของ segment tree บนช่วง [l, r]
  int res = INT_MIN;
  while (nxt[a] != nxt[b]) {
    if (dep[nxt[a]] < dep[nxt[b]]) swap(a, b);
    res = max(res, seg_max(in[nxt[a]], in[a]));
    a = par[nxt[a]];
  }
  if (dep[a] > dep[b]) swap(a, b);
  return max(res, seg_max(in[a], in[b]));
}
// เริ่มด้วย dfs_sz(0); nxt[0] = 0; dfs_hld(0);
```

ข้อดีของการเรียงแบบนี้คือได้ทั้ง path query และ subtree query (ช่วง `[in[v], out[v])`) ในโครงสร้างเดียว

=== Treap (ไม่ออกสอบ)

Treap คือ binary search tree ที่แต่ละ node มี priority แบบสุ่ม และเรียงเป็น heap ตาม priority ทำให้ความสูงเฉลี่ย $O(log n)$
รุ่นที่ใช้บ่อยคือ *implicit treap* ซึ่ง split/merge ตามตำแหน่ง ใช้ตัด แปะ หรือกลับด้านช่วงของ array ได้ใน $O(log n)$

อ่านเพิ่ม: #link("https://cp-algorithms.com/data_structures/treap.html")[Treap (CP-Algorithms)], #link("https://usaco.guide/adv/treaps?lang=cpp")[Treaps (USACO Guide)], #link("https://www.youtube.com/watch?v=obNToo8ZfTk&list=PLrOEQRd-CQtRp8TRICVsyG9bFqu-IfW1Z")[วิดีโอ Treap]

=== โจทย์ฝึกฝน (Practice Problems)

LCA

- #link("https://cses.fi/problemset/task/1687")[Company Queries I] (binary lifting)
- #link("https://cses.fi/problemset/task/1688")[Company Queries II]
- #link("https://cses.fi/problemset/task/1135")[Distance Queries]
- `o61_mar_c1_salary` (ฝึก LCA) และ `o60_may4_power` (LCA + observation) บน Evaluator

Fenwick tree และ lazy segment tree

- #link("https://cses.fi/problemset/task/1648")[Dynamic Range Sum Queries]
- #link("https://cses.fi/problemset/task/1739")[Forest Queries II] (2D Fenwick)
- #link("https://cses.fi/problemset/task/1735")[Range Updates and Sums] (set และ add)
- #link("https://cses.fi/problemset/task/1736")[Polynomial Queries]
- `o60_oct_c2_tower` (lazy เบื้องต้น) และ `o61_may02_bread` (lazy ยากขึ้น) บน Evaluator
- #link("https://oj.uz/problem/view/IOI07_sails")[IOI 2007 Sails],
  #link("https://codeforces.com/problemset/problem/446/C")[CF 446C],
  #link("https://codeforces.com/problemset/problem/242/E")[CF 242E],
  #link("https://codeforces.com/problemset/problem/1114/F")[CF 1114F]

Persistent และ HLD

- #link("https://cses.fi/problemset/task/1737")[Range Queries and Copies] (persistent segment tree)
- #link("https://cses.fi/problemset/task/2134")[Path Queries II] (HLD)
- #link("https://acm.timus.ru/problem.aspx?space=1&num=1553")[Timus 1553 Caves and Tunnels] (HLD)
- `o57_mar_c2_circleempire` บน Evaluator

=== อ่านเพิ่ม

- LCA: #link("https://usaco.guide/plat/binary-jump?lang=cpp")[Binary Jumping (USACO Guide)], #link("https://cp-algorithms.com/graph/lca_binary_lifting.html")[Binary Lifting (CP-Algorithms)], #link("https://youtu.be/9qHdxEKF6qs")[วิดีโอ LCA ภาษาไทย]
- Fenwick: #link("https://cp-algorithms.com/data_structures/fenwick.html")[Fenwick Tree (CP-Algorithms)]
- Lazy segment tree: #link("https://cp-algorithms.com/data_structures/segment_tree.html#range-updates-lazy-propagation")[Range updates (CP-Algorithms)], #link("https://usaco.guide/plat/RURQ?lang=cpp")[Range Update Range Query (USACO Guide)]
- Persistent: #link("https://usaco.guide/adv/persistent?lang=cpp")[Persistent Data Structures (USACO Guide)]
- HLD: #link("https://codeforces.com/blog/entry/53170")[Easiest HLD with subtree queries], #link("https://cp-algorithms.com/graph/hld.html")[HLD (CP-Algorithms)], #link("https://usaco.guide/plat/hld?lang=cpp")[HLD (USACO Guide)]
- HKOI training: #link("https://assets.hkoi.org/training2024/ds-ii.pdf")[DS (II)], #link("https://assets.hkoi.org/training2024/ds-iii.pdf")[DS (III)], #link("https://assets.hkoi.org/training2024/ds-iv.pdf")[DS (IV)]
