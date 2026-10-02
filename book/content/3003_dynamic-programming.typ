#import "@preview/ilm:1.4.0": *
#import table: cell, header
#import "widgets.typ": widget

== Dynamic Programming

=== หลักการ

Dynamic programming (DP) คือการแก้ปัญหาใหญ่จากคำตอบของปัญหาย่อย (subproblem) โดย *จำคำตอบของแต่ละปัญหาย่อยไว้* เพื่อไม่ต้องคำนวณซ้ำ
DP ทำให้ complete search ที่ช้าแบบ exponential กลายเป็น polynomial ได้

ปัญหาที่ใช้ DP ได้มักมีสองคุณสมบัติ

- *Optimal substructure*: คำตอบที่ดีที่สุดของปัญหาใหญ่ สร้างได้จากคำตอบที่ดีที่สุดของปัญหาย่อย
- *Overlapping subproblems*: ปัญหาย่อยเดิมถูกถามซ้ำหลายครั้ง จึงคุ้มที่จะจำไว้

โจทย์ DP ส่วนใหญ่ถามหนึ่งในสองแบบ

- หาคำตอบที่ดีที่สุด (optimal) เช่น ใช้เหรียญน้อยที่สุด
- นับจำนวนวิธี (counting) เช่น มีกี่วิธีที่ทอนเงินได้

=== จาก recursion สู่ DP: Fibonacci

ลำดับ Fibonacci คือ $1, 1, 2, 3, 5, 8, 13, dots.c$ โดย $f(n) = f(n-1) + f(n-2)$

ถ้าเขียน recursion ตรง ๆ จะเรียก `fib(n - 2)` ซ้ำหลายรอบมาก เช่น `fib(5)` เรียก `fib(3)` สองครั้ง และ `fib(2)` สามครั้ง
จำนวนการเรียกฟังก์ชันจึงโตแบบ $O(2^n)$

```cpp
long long fib(int n) {
  if (n <= 2) return 1;
  return fib(n - 1) + fib(n - 2);  // คำนวณ subproblem เดิมซ้ำ
}
```

==== Top-down (memoization)

เก็บคำตอบที่เคยคำนวณไว้ใน array แล้วตอบทันทีเมื่อถูกถามซ้ำ แต่ละ $n$ คำนวณจริงเพียงครั้งเดียว จึงเหลือ $O(n)$

```cpp
long long memo[91];  // 0 = ยังไม่เคยคำนวณ

long long fib(int n) {
  if (n <= 2) return 1;
  if (memo[n] != 0) return memo[n];
  return memo[n] = fib(n - 1) + fib(n - 2);
}
```

==== Bottom-up (tabulation)

เติมตารางจากปัญหาเล็กไปใหญ่ด้วย loop ไม่ต้องใช้ recursion จึงไม่เสี่ยง stack overflow และมักเร็วกว่าเล็กน้อย

```cpp
long long dp[91];
dp[1] = dp[2] = 1;
for (int i = 3; i <= n; i++) {
  dp[i] = dp[i - 1] + dp[i - 2];
}
```

ในการแข่งขันนิยมเขียนแบบ bottom-up แต่ top-down มักคิดง่ายกว่าเมื่อเพิ่งเริ่มออกแบบ state

=== สี่ขั้นตอนในการออกแบบ DP

+ *State*: `dp[i]` หมายถึงอะไร ต้องเขียนเป็นประโยคให้ชัด
+ *Transition*: คำนวณ `dp[i]` จาก state ที่เล็กกว่าอย่างไร
+ *Base case*: state เล็กสุดที่รู้คำตอบทันที
+ *Answer และลำดับการคำนวณ*: คำตอบอยู่ที่ state ไหน และต้องเติมตารางตามลำดับใดให้ state ที่ต้องใช้ถูกคำนวณก่อนเสมอ

Time complexity โดยประมาณคือ (จำนวน state) $times$ (เวลาต่อหนึ่ง transition)

=== ปัญหาการทอนเหรียญ (Coin Change)

มีเหรียญมูลค่า $c_1, c_2, dots.c, c_k$ แต่ละแบบใช้ได้ไม่จำกัด ต้องการทอนเงิน $n$ บาทโดยใช้เหรียญ *น้อยที่สุด*

==== ทำไม greedy ไม่พอ

ในบท Greedy เราหยิบเหรียญมูลค่ามากที่สุดก่อน ซึ่งใช้ได้กับเหรียญไทย แต่ถ้าเหรียญเป็น $\{1, 3, 4\}$ และ $n = 6$

- Greedy: $4 + 1 + 1$ ใช้ 3 เหรียญ
- คำตอบจริง: $3 + 3$ ใช้ 2 เหรียญ

การเลือกที่ดูดีที่สุดตอนนี้ (หยิบ 4) ทำให้คำตอบรวมแย่ลง เราจึงต้องลองทุกทางเลือก แล้วใช้ DP จำผลไว้

==== ออกแบบ DP

+ *State*: `dp[i]` = จำนวนเหรียญน้อยที่สุดที่ใช้ทอนเงิน $i$ บาท
+ *Transition*: เหรียญสุดท้ายที่ใช้ต้องเป็นเหรียญใดเหรียญหนึ่ง ถ้าเหรียญสุดท้ายคือ $c$ ที่เหลือคือการทอน $i - c$ ให้ดีที่สุด
  $ "dp"[i] = min_(c <= i) ("dp"[i - c] + 1) $
+ *Base case*: `dp[0] = 0` และถ้าทอนไม่ได้ให้ `dp[i]` เป็น $infinity$
+ *Answer*: `dp[n]` โดยเติมจาก $i = 1$ ขึ้นไป เพราะ `dp[i]` ใช้แค่ช่องที่ดัชนีน้อยกว่า

ผลลัพธ์เมื่อเหรียญเป็น $\{1, 3, 4\}$

#table(
  columns: 12,
  header([$i$], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10]),
  [`dp[i]`], [0], [1], [2], [1], [1], [2], [2], [2], [2], [3], [3],
)

ลองเติมตารางเองทีละช่องด้านล่าง เปิด "ให้ฉันทายก่อน" เพื่อทายค่าแต่ละช่องก่อนดูเฉลย และลองเปลี่ยนชุดเหรียญเพื่อหาตัวอย่างที่ greedy ผิด

#widget("coin-change")

==== Implementation

```cpp
const int INF = 1e9;
vector<int> dp(n + 1, INF);
dp[0] = 0;
for (int i = 1; i <= n; i++) {
  for (int c : coins) {
    if (c <= i && dp[i - c] != INF) {
      dp[i] = min(dp[i], dp[i - c] + 1);
    }
  }
}
cout << (dp[n] == INF ? -1 : dp[n]);
```

Time complexity $O(n k)$ เพราะมี $n$ state และแต่ละ state ลอง $k$ เหรียญ

==== ย้อนรอยหาเหรียญที่ใช้ (backtracking)

ถ้าโจทย์ถามว่าใช้เหรียญอะไรบ้าง ให้เก็บ `pick[i]` = เหรียญที่ทำให้ `dp[i]` ดีที่สุด แล้วเดินย้อนจาก $n$

```cpp
// ใน loop: ถ้า dp[i - c] + 1 < dp[i] ให้ตั้ง dp[i] และ pick[i] = c
for (int i = n; i > 0; i -= pick[i]) {
  cout << pick[i] << ' ';
}
```

==== นับจำนวนวิธี

ถ้าเปลี่ยนคำถามเป็น "มีกี่ลำดับการหยิบเหรียญที่รวมได้ $n$" ให้เปลี่ยน $min$ เป็นผลบวก

$ "dp"[0] = 1, quad "dp"[i] = sum_(c <= i) "dp"[i - c] $

นี่คือโจทย์ CSES Coin Combinations I (อย่าลืม mod $10^9 + 7$)

=== Longest Increasing Subsequence (LIS)

ให้ array $a$ จงหาความยาวของ subsequence ที่เพิ่มขึ้นอย่างเดียว (strictly increasing) ที่ยาวที่สุด
Subsequence คือการเลือกบางตัวโดยคงลำดับเดิม ไม่จำเป็นต้องติดกัน

ตัวอย่าง `1 5 3 2 8 9 3 6` มี LIS ยาว 4 เช่น `1 5 8 9` หรือ `1 2 3 6`

==== วิธี $O(n^2)$

+ *State*: `dp[i]` = ความยาว LIS ที่ *ลงท้ายด้วย* `a[i]` พอดี
+ *Transition*: ตัวก่อนหน้าคือ `a[j]` ใดก็ได้ที่ $j < i$ และ `a[j] < a[i]`
  $ "dp"[i] = 1 + max_(j < i, a[j] < a[i]) "dp"[j] $
  (ถ้าไม่มี $j$ ที่ใช้ได้ `dp[i] = 1`)
+ *Answer*: $max_i "dp"[i]$ ไม่ใช่ `dp[n-1]` เพราะ LIS อาจไม่ได้จบที่ตัวสุดท้าย

#table(
  columns: 9,
  header([$i$], [0], [1], [2], [3], [4], [5], [6], [7]),
  [`a[i]`], [1], [5], [3], [2], [8], [9], [3], [6],
  [`dp[i]`], [1], [2], [2], [2], [3], [4], [3], [4],
  [`parent[i]`], [-], [0], [0], [0], [1], [4], [3], [6],
)

`parent[i]` คือ $j$ ที่ให้ค่าดีที่สุด ใช้ย้อนรอยหา LIS จริง เช่น จาก $i = 7$: `6 ← 3 ← 2 ← 1`

```cpp
vector<int> dp(n, 1);
for (int i = 0; i < n; i++) {
  for (int j = 0; j < i; j++) {
    if (a[j] < a[i]) dp[i] = max(dp[i], dp[j] + 1);
  }
}
cout << *max_element(dp.begin(), dp.end());
```

==== วิธี $O(n log n)$

เปลี่ยน state เป็น `tail[k]` = ค่าสุดท้ายที่ *น้อยที่สุด* ของ increasing subsequence ที่ยาว $k + 1$
ยิ่งค่าสุดท้ายน้อย ยิ่งต่อตัวถัดไปได้ง่าย และ `tail` จะเรียงจากน้อยไปมากเสมอ จึงใช้ binary search ได้

สำหรับแต่ละ $x$ ให้หาตำแหน่งแรกที่ `tail[k] >= x`

- ถ้าไม่มี: $x$ ต่อท้ายได้ทุก subsequence จึง `push_back(x)` (LIS ยาวขึ้น 1)
- ถ้ามี: แทน `tail[k] = x` เพราะได้ subsequence ยาวเท่าเดิมแต่ปลายเล็กกว่า

#table(
  columns: 2,
  header([อ่าน $x$], [`tail` หลังอัปเดต]),
  [1], [`1`],
  [5], [`1 5`],
  [3], [`1 3`],
  [2], [`1 2`],
  [8], [`1 2 8`],
  [9], [`1 2 8 9`],
  [3], [`1 2 3 9`],
  [6], [`1 2 3 6`],
)

คำตอบคือขนาดของ `tail` = 4 (ระวัง: `tail` ไม่จำเป็นต้องเป็น LIS จริงเสมอไป)

```cpp
vector<int> tail;
for (int x : a) {
  auto it = lower_bound(tail.begin(), tail.end(), x);
  if (it == tail.end()) tail.push_back(x);
  else *it = x;
}
cout << tail.size();
```

ถ้าโจทย์ยอมให้เท่ากันได้ (non-decreasing) ให้เปลี่ยน `lower_bound` เป็น `upper_bound`

=== DP ที่พบบ่อย

#table(
  columns: 4,
  header([โจทย์], [State], [Transition], [Time]),
  [Prefix sum], [`s[i]` ผลรวม $a_0..a_(i-1)$], [`s[i] = s[i-1] + a[i-1]`], [$O(n)$],
  [Coin change (min)], [`dp[i]` เหรียญน้อยสุดของ $i$], [`min(dp[i-c] + 1)`], [$O(n k)$],
  [0/1 Knapsack], [`dp[i][w]` ใช้ของ $i$ ชิ้นแรก น้ำหนักไม่เกิน $w$], [`max(dp[i-1][w], dp[i-1][w-wi] + vi)`], [$O(n W)$],
  [LIS], [`dp[i]` LIS ที่จบที่ $i$], [`max(dp[j]) + 1`], [$O(n^2)$ หรือ $O(n log n)$],
  [LCS], [`dp[i][j]` ของ prefix ยาว $i$ และ $j$], [เท่ากันใช้ `dp[i-1][j-1] + 1` ไม่เท่าใช้ max], [$O(n m)$],
  [$binom(n, r)$ (Pascal)], [`C[i][j]`], [`C[i-1][j-1] + C[i-1][j]`], [$O(n r)$],
  [Grid paths], [`dp[r][c]` จำนวนทางมาช่อง $(r, c)$], [`dp[r-1][c] + dp[r][c-1]`], [$O(R C)$],
  [Interval DP (matrix chain)], [`dp[l][r]` ช่วง $l..r$], [`min(dp[l][k] + dp[k+1][r] + cost)`], [$O(n^3)$],
  [Floyd-Warshall], [`d[i][j]` ใช้จุดกลางได้แค่ $0..k$], [`min(d[i][j], d[i][k] + d[k][j])`], [$O(n^3)$],
  [Bitmask DP (TSP)], [`dp[mask][v]` ไปแล้วตาม mask และอยู่ที่ $v$], [`min(dp[mask ^ (1<<v)][u] + w(u, v))`], [$O(2^n n^2)$],
)

=== ข้อผิดพลาดที่พบบ่อย

- *State ไม่ชัด*: ถ้าอธิบาย `dp[i]` เป็นประโยคไม่ได้ มักจะเขียน transition ผิด
- *ลืม base case* หรือกำหนด base case ผิด เช่น `dp[0] = 0` กับ `dp[0] = 1` ให้ความหมายต่างกันมาก
- *INF overflow*: ถ้าใช้ `INT_MAX` เป็น $infinity$ แล้วบวก 1 จะกลายเป็นค่าติดลบ ใช้ `1e9` และเช็คก่อนบวก
- *ลำดับการเติมตารางผิด*: ต้องคำนวณ state ที่ต้องใช้ก่อนเสมอ
- *ขนาด array*: state `0..n` ต้องใช้ขนาด $n + 1$
- *ลืม mod* ในโจทย์นับจำนวนวิธี ทำให้ overflow

=== ลองคิด

+ ถ้าเหรียญเป็น $\{1, 5, 6, 9\}$ greedy ให้คำตอบผิดเมื่อทอน $n = 11$ หรือไม่
+ ใน Coin Change ถ้าไม่มีเหรียญ 1 บาท ช่องไหนบ้างที่อาจเป็น $infinity$
+ ทำไมคำตอบของ LIS แบบ $O(n^2)$ ต้องเป็น $max_i "dp"[i]$ แทนที่จะเป็น `dp[n-1]`

==== เฉลย

+ ผิด greedy ได้ $9 + 1 + 1$ (3 เหรียญ) แต่ $5 + 6$ ใช้แค่ 2 เหรียญ (ลองกับ widget ด้านบนได้)
+ ช่อง $i$ ที่เขียนเป็นผลรวมของเหรียญไม่ได้ เช่น เหรียญ $\{3, 5\}$ จะทอน $1, 2, 4, 7$ ไม่ได้
+ เพราะ `dp[i]` บังคับให้ LIS จบที่ `a[i]` ถ้าตัวสุดท้ายของ array มีค่าน้อย `dp[n-1]` จะสั้นกว่าคำตอบจริง

=== เพิ่มเติม

- An Introduction to Dynamic Programming (aquablitz11) #footnote[http://tcpc.me/2019/01/28/an-introduction-to-dynamic-programming.html]
- Dynamic Programming by Aj. Nattee #footnote[https://github.com/nattee/ioi-training-note/blob/main/Dynamic%20Programming/01-dynamic%20programming.pdf]
- Longest Increasing Subsequence (CP-Algorithms) #footnote[https://cp-algorithms.com/sequences/longest_increasing_subsequence.html]
- เทคนิค DP ขั้นสูงอยู่ในบท Dynamic Programming Advanced

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1633")[Dice Combinations]
- #link("https://cses.fi/problemset/task/1634")[Minimizing Coins]
- #link("https://cses.fi/problemset/task/1635")[Coin Combinations I]
- #link("https://cses.fi/problemset/task/1637")[Removing Digits]
- #link("https://cses.fi/problemset/task/1145")[Increasing Subsequence]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
