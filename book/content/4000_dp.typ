#import "@preview/ilm:1.4.0": *
#import table: cell, header
#import "widgets.typ": widget

== Dynamic Programming ขั้นสูง

บทนี้ต่อจากบท Dynamic Programming ซึ่งปูพื้นเรื่อง memoization, tabulation, coin change และ LIS ไว้แล้ว ที่นี่จะเพิ่ม DP ที่มี state สองมิติขึ้นไป และกรอบความคิดสำหรับออกแบบ DP ใหม่ ๆ

=== กรอบความคิด SRTBOT

กรอบนี้มาจากวิชา MIT 6.006 ใช้ตรวจว่า DP ที่ออกแบบครบทุกส่วน

- *Subproblem*: นิยามปัญหาย่อย เช่น `dp[i][j]` หมายถึงอะไร
- *Relate*: ความสัมพันธ์ระหว่างปัญหาย่อย (transition)
- *Topological order*: ลำดับการคำนวณที่ปัญหาย่อยที่ต้องใช้ถูกคำนวณก่อนเสมอ (ไม่มีวงวน)
- *Base case*: ปัญหาย่อยที่ตอบได้ทันที
- *Original problem*: คำตอบของโจทย์อยู่ที่ state ไหน
- *Time*: (จำนวน state) $times$ (เวลาต่อ transition)

=== Grid paths

นับจำนวนทางเดินจากมุมซ้ายบนไปมุมขวาล่างของตาราง $n times n$ โดยเดินได้แค่ขวาหรือลง และห้ามผ่านช่องที่เป็น `*`

- *Subproblem*: `dp[r][c]` = จำนวนทางจาก $(0, 0)$ ถึง $(r, c)$
- *Relate*: มาถึง $(r, c)$ ได้จากบนหรือซ้ายเท่านั้น: `dp[r][c] = dp[r-1][c] + dp[r][c-1]`
- *Topological order*: แถวบนลงล่าง ซ้ายไปขวา
- *Base*: `dp[0][0] = 1` (ถ้าไม่ใช่ `*`)
- *Time*: $O(n^2)$

```cpp
dp[0][0] = (grid[0][0] == '.');
for (int r = 0; r < n; r++) {
  for (int c = 0; c < n; c++) {
    if (grid[r][c] == '*') { dp[r][c] = 0; continue; }
    if (r > 0) dp[r][c] = (dp[r][c] + dp[r - 1][c]) % MOD;
    if (c > 0) dp[r][c] = (dp[r][c] + dp[r][c - 1]) % MOD;
  }
}
// คำตอบ dp[n-1][n-1]
```

=== 0/1 Knapsack

มีของ $n$ ชิ้น ชิ้นที่ $i$ หนัก $w_i$ มีมูลค่า $v_i$ ใส่กระเป๋าที่รับน้ำหนักได้ $W$ ให้มูลค่ารวมมากที่สุด (แต่ละชิ้นเลือกได้ครั้งเดียว)

- *Subproblem*: `dp[i][c]` = มูลค่ามากสุดเมื่อพิจารณาของ $i$ ชิ้นแรก และน้ำหนักรวมไม่เกิน $c$
- *Relate*: ชิ้นที่ $i$ ไม่เลือกหรือเลือก: `dp[i][c] = max(dp[i-1][c], dp[i-1][c - w_i] + v_i)`
- *Base*: `dp[0][c] = 0`
- *Time*: $O(n W)$

สังเกตว่าแถว $i$ ใช้แค่แถว $i - 1$ จึงลดเหลือ array มิติเดียวได้ แต่ต้องวน $c$ *จากมากไปน้อย* เพื่อไม่ให้ใช้ชิ้นเดิมซ้ำในแถวเดียวกัน

```cpp
vector<long long> dp(W + 1, 0);
for (int i = 0; i < n; i++) {
  for (int c = W; c >= w[i]; c--) {  // มากไปน้อย: dp[c - w[i]] ยังเป็นค่าของแถวก่อน
    dp[c] = max(dp[c], dp[c - w[i]] + v[i]);
  }
}
// คำตอบ dp[W]
```

ถ้าวน $c$ จากน้อยไปมาก จะได้ *unbounded knapsack* (เลือกชิ้นเดิมได้ไม่จำกัด) ซึ่งเป็นอีกโจทย์หนึ่ง

=== Edit distance

แปลงข้อความ $a$ เป็น $b$ ด้วยการ *เพิ่ม*, *ลบ* หรือ *แทน* ตัวอักษรทีละตัว ใช้กี่ครั้งน้อยที่สุด

- *Subproblem*: `dp[i][j]` = จำนวนครั้งน้อยสุดที่แปลง $i$ ตัวแรกของ $a$ เป็น $j$ ตัวแรกของ $b$
- *Relate*: ดูตัวสุดท้ายของทั้งสองฝั่ง
  - ถ้า `a[i-1] == b[j-1]` ไม่ต้องแก้: `dp[i-1][j-1]`
  - ไม่เช่นนั้น $1 + min$ ของ ลบ `dp[i-1][j]`, เพิ่ม `dp[i][j-1]`, แทน `dp[i-1][j-1]`
- *Base*: `dp[i][0] = i` (ลบทุกตัว) และ `dp[0][j] = j` (เพิ่มทุกตัว)
- *Time*: $O(|a| |b|)$

ลองเติมตารางทีละช่อง สังเกตว่าแต่ละช่องใช้แค่สามช่อง (บน ซ้าย และทแยงซ้ายบน) เมื่อเติมครบ เส้นทางย้อนรอยจะบอกว่าต้องแก้อะไรบ้าง

#widget("edit-distance")

```cpp
int n = a.size(), m = b.size();
vector<vector<int>> dp(n + 1, vector<int>(m + 1));
for (int i = 0; i <= n; i++) {
  for (int j = 0; j <= m; j++) {
    if (i == 0 || j == 0) dp[i][j] = i + j;
    else if (a[i - 1] == b[j - 1]) dp[i][j] = dp[i - 1][j - 1];
    else dp[i][j] = 1 + min({dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]});
  }
}
```

*Longest common subsequence* (LCS) ใช้ตารางแบบเดียวกัน: ถ้าตัวอักษรตรงกันได้ `dp[i-1][j-1] + 1` ไม่เช่นนั้น `max(dp[i-1][j], dp[i][j-1])`

=== Interval DP

เมื่อปัญหาย่อยคือ *ช่วง* $[l, r]$ ของ array และปัญหาใหญ่สร้างจากช่วงที่สั้นกว่า

ตัวอย่าง (Removal Game): มีเลขเรียงกัน ผู้เล่นสองคนผลัดกันหยิบเลขจากหัวหรือท้าย ทั้งคู่เล่นดีที่สุด ผู้เล่นคนแรกได้คะแนนรวมเท่าไร

- *Subproblem*: `dp[l][r]` = (คะแนนของคนที่ได้เล่นตา) $-$ (คะแนนของอีกฝ่าย) เมื่อเหลือเลขช่วง $[l, r]$
- *Relate*: หยิบหัวหรือท้าย แล้วอีกฝ่ายจะได้เปรียบตามช่วงที่เหลือ: `dp[l][r] = max(x[l] - dp[l+1][r], x[r] - dp[l][r-1])`
- *Topological order*: ช่วงสั้นก่อนช่วงยาว
- *Base*: `dp[i][i] = x[i]`
- *Original*: คะแนนคนแรก $= ("sum" + "dp"[0][n-1]) / 2$

```cpp
for (int len = 1; len <= n; len++) {
  for (int l = 0; l + len - 1 < n; l++) {
    int r = l + len - 1;
    if (l == r) dp[l][r] = x[l];
    else dp[l][r] = max(x[l] - dp[l + 1][r], x[r] - dp[l][r - 1]);
  }
}
long long first = (total + dp[0][n - 1]) / 2;
```

Time $O(n^2)$ ถ้า transition ต้องลองจุดแบ่งทุกจุดในช่วง (เช่น matrix chain multiplication) จะเป็น $O(n^3)$

=== Bitmask DP

เมื่อ state ต้องจำว่า *เลือกอะไรไปแล้วบ้าง* จากของไม่เกินประมาณ 20 ชิ้น ให้แทนเซตด้วยบิตของจำนวนเต็ม `mask` (บิตที่ $i$ เป็น 1 แปลว่าเลือกชิ้นที่ $i$ แล้ว) มี state $2^n$ แบบ
ตัวอย่าง Hamiltonian path ใช้ `dp[mask][v]` ดูได้ในบท Paths and Circuits และ Travelling Salesman ใช้ state เดียวกันแต่เก็บระยะทางน้อยสุด

=== เคล็ดลับ

- ถ้าคิด transition ไม่ออก ลองถามว่า "การตัดสินใจ *สุดท้าย* คืออะไร" (ของชิ้นสุดท้าย ตัวอักษรสุดท้าย ก้าวสุดท้าย)
- เขียนแบบ top-down (memoization) ก่อนได้ถ้ายังไม่แน่ใจเรื่องลำดับการคำนวณ
- ถ้าแถว $i$ ใช้แค่แถว $i - 1$ ลดหน่วยความจำเหลือสองแถวหรือแถวเดียวได้
- ตรวจขนาดตาราง: $n W$ ที่ $10^5 times 10^5$ ใหญ่เกินหน่วยความจำแน่นอน

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1638")[Grid Paths I]
- #link("https://cses.fi/problemset/task/1158")[Book Shop] (0/1 knapsack)
- #link("https://cses.fi/problemset/task/1639")[Edit Distance]
- #link("https://cses.fi/problemset/task/1097")[Removal Game] (interval DP)
- #link("https://cses.fi/problemset/task/1746")[Array Description]
- #link("https://cses.fi/problemset/task/1140")[Projects] (DP + binary search)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
