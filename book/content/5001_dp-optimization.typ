#import "@preview/ilm:1.4.0": *

== DP Optimization

บทนี้สรุปจากการสอนค่าย สสวท. (IOI Training Camp) เดือนมีนาคม 2025 ต่อจากบท Dynamic Programming ขั้นสูง ซึ่งเน้นการ *ออกแบบ* state และ transition
ที่นี่สมมติว่าออกแบบ DP ได้แล้วแต่ช้าเกินไป เช่น $O(n^2)$ หรือ $O(k n^2)$ แล้วใช้โครงสร้างของ transition เพื่อลดเวลา

- สไลด์: #link("https://docs.google.com/presentation/d/1h3v_uF4F0dW-j4JTjOrFzOpn2X6XM4wWw3iSlx76naE/edit?usp=sharing")[Advanced Dynamic Programming (Mar'25)]
- ชุดโจทย์ใน vjudge: #link("https://vjudge.net/contest/700721")[contest 1], #link("https://vjudge.net/contest/700742")[contest 2], #link("https://vjudge.net/contest/700730")[contest 3]

=== Convex Hull Trick และ Li Chao Tree

หลายโจทย์มี transition รูป

$ "dp"[i] = min_(j < i) (m_j dot x_i + c_j) $

โดย $m_j$ และ $c_j$ ขึ้นกับ $j$ เท่านั้น และ $x_i$ ขึ้นกับ $i$ เท่านั้น มองแต่ละ $j$ เป็น *เส้นตรง* $y = m_j x + c_j$ คำถามจะกลายเป็น "ที่ $x = x_i$ เส้นไหนต่ำสุด"

ตัวอย่าง #link("https://atcoder.jp/contests/dp/tasks/dp_z")[Frog 3]: กบกระโดดจากหิน $j$ ไปหิน $i$ เสีย $(h_i - h_j)^2 + C$ เมื่อกระจายกำลังสอง

$ "dp"[i] = h_i^2 + C + min_(j < i) (-2 h_j dot h_i + "dp"[j] + h_j^2) $

ได้เส้นตรง $m_j = -2 h_j$ และ $c_j = "dp"[j] + h_j^2$ ซึ่ง query ที่ $x = h_i$ เส้นที่ต่ำสุดในแต่ละจุดรวมกันเป็น *lower envelope* ซึ่งเป็นรูป convex

*Li Chao tree* คือ segment tree บนแกน $x$ ที่แต่ละ node เก็บเส้นเดียว คือเส้นที่ดีที่สุด ณ จุดกึ่งกลางของช่วงนั้น เมื่อเพิ่มเส้นใหม่ เส้นที่แพ้ตรงกลางจะชนะได้แค่ครึ่งเดียว (ซ้ายหรือขวา) จึงส่งลงไปแค่ฝั่งเดียว ทั้ง insert และ query ใช้ $O(log X)$ เมื่อ $X$ คือขนาดของแกน $x$

```cpp
struct Line {
  long long m, c;
  long long operator()(long long x) const { return m * x + c; }
};
Line t[4 * X];  // ทุก node เริ่มเป็น {0, INF}, เก็บค่าต่ำสุด, x อยู่ในช่วง [0, X)

void insert(int v, int l, int r, Line nw) {  // ช่วง [l, r)
  int mid = (l + r) / 2;
  bool winLeft = nw(l) < t[v](l);
  bool winMid = nw(mid) < t[v](mid);
  if (winMid) swap(t[v], nw);  // node เก็บเส้นที่ชนะตรงกลาง
  if (r - l == 1) return;
  if (winLeft != winMid) insert(2 * v, l, mid, nw);  // เส้นที่แพ้อาจชนะทางซ้าย
  else insert(2 * v + 1, mid, r, nw);                // หรือทางขวา
}

long long query(int v, int l, int r, int x) {
  long long res = t[v](x);
  if (r - l == 1) return res;
  int mid = (l + r) / 2;
  if (x < mid) return min(res, query(2 * v, l, mid, x));
  return min(res, query(2 * v + 1, mid, r, x));
}
```

ถ้าเส้นเข้ามาเรียงตาม slope และ query เรียงตาม $x$ ด้วย ใช้ *convex hull trick* แบบ deque ได้ $O(1)$ ต่อครั้ง แต่ Li Chao tree เขียนง่ายกว่าและไม่ต้องการเงื่อนไขเรื่องลำดับ

=== Slope Trick

Slope trick ใช้กับ DP ที่ $"dp"_i (x)$ เป็นฟังก์ชันของค่า $x$ ที่

- ต่อเนื่อง และเป็นเส้นตรงเป็นท่อน ๆ (piecewise linear)
- slope เป็นจำนวนเต็ม
- เป็น convex

แทนที่จะเก็บค่าทุก $x$ ให้เก็บแค่ *จุดหักเห* (breakpoint) ที่ slope เปลี่ยนทีละ 1 ไว้ใน heap หรือ multiset การบวกฟังก์ชันอย่าง $|x - a|$ จึงเป็นแค่การเพิ่ม breakpoint

ตัวอย่าง #link("https://cses.fi/problemset/task/2132")[Increasing Array II]: เพิ่มหรือลดสมาชิกทีละ 1 ให้น้อยครั้งที่สุดจนได้ array ไม่ลดลง

ให้ $f_i (x)$ คือค่าใช้จ่ายน้อยสุดของ $i$ ตัวแรกเมื่อตัวที่ $i$ มีค่า *ไม่เกิน* $x$ แล้ว $f_i (x) = min_(y <= x) (f_(i-1)(y) + |y - a_i|)$
ฟังก์ชันนี้เป็น convex และไม่เพิ่มขึ้น จึงเก็บเฉพาะ breakpoint ทางซ้ายใน max-heap

- บวก $|x - a_i|$: เพิ่ม breakpoint ที่ $a_i$
- ถ้า breakpoint ขวาสุด (`top`) มากกว่า $a_i$ ค่าต่ำสุดเพิ่มขึ้น `top - a_i` และการตัดส่วนที่ slope เป็นบวกทิ้ง (ขั้น $min$ บน $y <= x$) คือการ pop `top` ออก

```cpp
priority_queue<long long> pq;
long long ans = 0;
for (long long a : arr) {
  pq.push(a);
  if (pq.top() > a) {
    ans += pq.top() - a;
    pq.pop();
    pq.push(a);
  }
}
```

ถ้าโจทย์ต้องการ *เพิ่มขึ้นแท้* (strictly increasing) ให้ใช้ $a_i - i$ แทน $a_i$ ซึ่งเป็นโจทย์ #link("https://codeforces.com/contest/713/problem/C")[CF 713C Sonya and Problem Wihtout a Legend]

=== Broken Profile DP (Plug DP)

ใช้กับโจทย์ปูกระเบื้องหรือเติมตารางที่มีมิติหนึ่งเล็ก (ประมาณ $n <= 10$) แทนที่จะเติมทีละ *คอลัมน์* ทั้งคอลัมน์ ให้เติมทีละ *ช่อง* แล้วเก็บ mask $n$ บิตเป็น "รอยต่อ" (plug หรือ profile) ระหว่างส่วนที่เติมแล้วกับส่วนที่ยังไม่เติม

ตัวอย่าง #link("https://cses.fi/problemset/task/2181")[Counting Tilings]: นับวิธีปูตาราง $n times m$ ด้วยโดมิโน $1 times 2$

เติมทีละคอลัมน์ ในคอลัมน์เติมจากบนลงล่าง ตอนอยู่ที่ช่อง $(i, j)$ บิตที่ $r < i$ บอกว่าช่อง $(r, j+1)$ ถูกจองแล้วหรือยัง และบิตที่ $r >= i$ บอกว่าช่อง $(r, j)$ ถูกจองแล้วหรือยัง

```cpp
vector<long long> dp(1 << n, 0), nd(1 << n);
dp[0] = 1;
for (int j = 0; j < m; j++) {
  for (int i = 0; i < n; i++) {
    fill(nd.begin(), nd.end(), 0);
    for (int mask = 0; mask < (1 << n); mask++) {
      if (dp[mask] == 0) continue;
      if (mask >> i & 1) {  // ช่องนี้ถูกจองแล้ว ช่องถัดไปทางขวายังว่าง
        nd[mask ^ (1 << i)] = (nd[mask ^ (1 << i)] + dp[mask]) % MOD;
        continue;
      }
      // วางแนวนอน: จองช่อง (i, j + 1)
      nd[mask | (1 << i)] = (nd[mask | (1 << i)] + dp[mask]) % MOD;
      // วางแนวตั้ง: จองช่อง (i + 1, j)
      if (i + 1 < n && !(mask >> (i + 1) & 1))
        nd[mask | (1 << (i + 1))] = (nd[mask | (1 << (i + 1))] + dp[mask]) % MOD;
    }
    swap(dp, nd);
  }
}
// คำตอบ dp[0]: ไม่มีโดมิโนยื่นออกนอกตาราง
```

Time $O(n m 2^n)$ ถ้าเติมทีละคอลัมน์ทั้งคอลัมน์จะต้องลองทุกคู่ mask ได้ $O(m 4^n)$

=== Divide and Conquer Optimization

ใช้กับ DP แบ่ง array เป็น $k$ กลุ่ม

$ "dp"_k [i] = min_(j < i) ("dp"_(k-1) [j] + C(j, i)) $

โดย $C(j, i)$ คือค่าใช้จ่ายของกลุ่มสมาชิก $j+1$ ถึง $i$ ถ้าทำตรง ๆ ใช้ $O(k n^2)$

ให้ $"opt"(i)$ คือ $j$ ที่ดีที่สุดของ $i$ ถ้า $"opt"(i) <= "opt"(i+1)$ เสมอ (monotone ซึ่งเป็นจริงเมื่อ $C$ ทำตาม quadrangle inequality) เราคำนวณ `dp[mid]` ก่อน แล้วรู้ว่าครึ่งซ้ายต้องหา $j$ ไม่เกิน `opt(mid)` และครึ่งขวาหาจาก `opt(mid)` ขึ้นไป แต่ละชั้นของ recursion ตรวจรวม $O(n)$ ตัว จึงได้ $O(n log n)$ ต่อ layer และ $O(k n log n)$ ทั้งหมด

```cpp
const long long INF = 1e18;  // ไม่ใช้ LLONG_MAX เพราะ INF + C จะ overflow
vector<long long> dp_prev(n + 1, INF), dp_cur(n + 1, INF);

void compute(int l, int r, int optl, int optr) {
  if (l > r) return;
  int mid = (l + r) / 2;
  pair<long long, int> best = {LLONG_MAX, -1};
  for (int j = optl; j <= min(mid - 1, optr); j++)
    best = min(best, {dp_prev[j] + C(j, mid), j});
  dp_cur[mid] = best.first;
  compute(l, mid - 1, optl, best.second);
  compute(mid + 1, r, best.second, optr);
}

// dp_prev[0] = 0;
// for (int g = 1; g <= k; g++) { compute(1, n, 0, n - 1); swap(dp_prev, dp_cur); }
// คำตอบ dp_prev[n]
```

เทคนิคใกล้เคียงกันคือ *Knuth optimization* สำหรับ interval DP ที่ $"opt"[l][r-1] <= "opt"[l][r] <= "opt"[l+1][r]$ ลดจาก $O(n^3)$ เหลือ $O(n^2)$

=== WQS Binary Search (Aliens Trick)

ถ้าโจทย์บังคับให้ใช้ *พอดี* $k$ กลุ่ม (หรือเลือกพอดี $k$ ชิ้น) state ต้องมีมิติ $k$ เพิ่มขึ้นมา
แนวคิด WQS คือเอาเงื่อนไขนั้นออก แล้ว *ปรับ* $lambda$ ทุกครั้งที่เปิดกลุ่มใหม่แทน

- $lambda$ มาก: DP จะเลือกใช้กลุ่มน้อย
- $lambda$ น้อย: DP จะเลือกใช้กลุ่มมาก
- binary search $lambda$ จนได้จำนวนกลุ่มพอดี $k$ แล้วคืนค่าปรับ $lambda k$

ใช้ได้เมื่อคำตอบ $g(k)$ (ค่าที่ดีที่สุดเมื่อใช้พอดี $k$ กลุ่ม) เป็น *convex* ใน $k$ ซึ่งมักต้องเชื่อจากการทดลองด้วย brute force เล็ก ๆ มากกว่าพิสูจน์ในห้องสอบ

```cpp
// solve(lambda): DP ที่ไม่มีมิติ k แต่บวก lambda ทุกครั้งที่เปิดกลุ่มใหม่
// คืน {ค่าต่ำสุด, จำนวนกลุ่มน้อยสุดที่ได้ค่านั้น} (ถ้าเสมอให้เลือกกลุ่มน้อย)
long long lo = 0, hi = MAX_SLOPE;  // ขอบบนของ |g(k) - g(k + 1)|
while (lo < hi) {
  long long mid = (lo + hi) / 2;
  if (solve(mid).cnt <= k) hi = mid;
  else lo = mid + 1;
}
long long answer = solve(lo).val - lo * k;
```

การ tie-break ให้นับกลุ่มน้อยสุดสำคัญมาก: บาง $lambda$ ให้คำตอบเท่ากันหลายจำนวนกลุ่ม และ $k$ อาจไม่ใช่ค่าที่ DP คืนมาพอดี แต่สูตร $"val" - lambda k$ ยังถูกต้อง

Time $O(T log("MAX_SLOPE"))$ เมื่อ $T$ คือเวลาของ DP ที่ไม่มีมิติ $k$

=== โจทย์ฝึกฝน (Practice Problems)

Convex hull trick และ Li Chao tree

- #link("https://atcoder.jp/contests/dp/tasks/dp_z")[AtCoder DP Z - Frog 3]
- #link("https://codeforces.com/problemset/problem/932/F")[CF 932F Escape Through Leaf] (Li Chao tree + small-to-large)
- #link("https://codeforces.com/contest/631/problem/E")[CF 631E],
  #link("https://codeforces.com/contest/660/problem/F")[CF 660F],
  #link("https://codeforces.com/contest/311/problem/B")[CF 311B],
  #link("https://codeforces.com/contest/673/problem/E")[CF 673E],
  #link("https://codeforces.com/contest/455/problem/E")[CF 455E],
  #link("https://codeforces.com/contest/1179/problem/D")[CF 1179D]

เทคนิคอื่น

- #link("https://cses.fi/problemset/task/2132")[Increasing Array II] และ #link("https://codeforces.com/contest/713/problem/C")[CF 713C] (slope trick)
- #link("https://cses.fi/problemset/task/2181")[Counting Tilings] (broken profile)
- #link("https://codeforces.com/contest/321/problem/E")[CF 321E Ciel and Gondolas] และ #link("https://codeforces.com/contest/868/problem/F")[CF 868F Yet Another Minimization Problem] (D&C optimization)
- #link("https://codeforces.com/contest/739/problem/E")[CF 739E Gosha is hunting] (WQS)

=== อ่านเพิ่ม

- Li Chao tree: #link("https://robert1003.github.io/2020/02/06/li-chao-segment-tree.html")[A Simple Introduction to Li-Chao Segment Tree], #link("https://codeforces.com/blog/entry/86731")[Li Chao Tree Extended], #link("https://www.youtube.com/watch?v=qTE1OSUNR3w")[Convex Hull Trick Visualisation], #link("https://robert1003.github.io/2020/02/17/dp-opt-convex-hull-trick.html")[Convex Hull Optimization]
- Slope trick: #link("https://codeforces.com/blog/entry/77298")[Slope trick explained], #link("https://codeforces.com/blog/entry/47821")[Tutorial Slope Trick], #link("https://www.youtube.com/watch?v=p8RxN6Y9OOA")[Slope Trick Visualised]
- Broken profile: #link("https://codeforces.com/blog/entry/90841")[An Introduction to Plug DP], #link("https://usaco.guide/adv/dp-more?lang=cpp#dp-on-broken-profile")[DP on Broken Profile (USACO Guide)]
- D&C และ Knuth: #link("https://cp-algorithms.com/dynamic_programming/divide-and-conquer-dp.html")[Divide and Conquer DP (CP-Algorithms)], #link("https://robert1003.github.io/2020/02/25/dp-opt-divide-and-conquer.html")[Divide and Conquer Optimization], #link("https://robert1003.github.io/2020/02/29/dp-opt-knuth.html")[Knuth Optimization]
- WQS: #link("https://robert1003.github.io/2020/02/26/dp-opt-wqs-binary-search.html")[WQS Binary Search Optimization], #link("https://codeforces.com/blog/entry/49691")[DP optimization from N^3 to N log^2 N], #link("https://codeforces.com/blog/entry/60302")[Intuition behind Aliens trick], #link("https://www.serbanology.com/vault/The%20Trick%20From%20Aliens")[The Trick From Aliens]
