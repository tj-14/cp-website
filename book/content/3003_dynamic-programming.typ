#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Dynamic Programming

=== หลักการ

- Dynamic programming (DP) เป็นเทคนิคที่รวมการค้นหาทั้งหมดเข้ากับวิธีคิดแบบ greedy
- DP จะแก้ปัญหาได้หากปัญหานั้นสามารถแบ่งออกมาเป็นปัญหาย่อยที่ทับซ้อนกันและสามารถแก้ได้อย่างมีประสิทธิภาพ
- ประโยชน์หลักของ DP คือ
    - หาวิธีแก้ปัญหาที่ optimal
    - หาจำนวนวิธีแก้ปัญหา
- ไอเดีย DP เป็นไอเดียที่ง่ายแต่ส่วนที่ยากจะเป็นการนำไปใช้กับปัญหาจริง
ซึ่งต้องใช้ประสบการณ์
- Backtracking สร้างตารางคู่เก็บที่มาขอคำตอบหากโจทย์ต้องการ

=== ปัญหาการทอนเหรียญ (ปัญหาเดียวกับ Greedy)

พิจารณาปัญหาที่ต้องการทอนเงินมูลค่า $n$ โดยใช้เหรียญที่มีมูลค่า
$\{c_1, c_2, dots.c, c_k\}$
จำนวนเหรียญที่น้อยที่สุดที่ต้องใช้เป็นเท่าไร?

หากมูลค่าของเหรียญเป็น

$\{1,3,4\}$

#table(
    columns: 2,
    header(
      [มูลค่ารวม $n$], [จำนวนเหรียญที่น้อยที่สุด],
    ),
[ 0 ],[ 0 ],
[ 1 ],[ 1 ],
[ 2 ],[ 2 ],
[ 3 ],[ 1 ],
[ 4 ],[ 1 ],
[ 5 ],[ 2 ],
[ 6 ],[ 2 ],
[ 7 ],[ 2 ],
[ 8 ],[ 2 ],
[ 9 ],[ 3 ],
[ 10 ],[ 3 ],
)

นิยาม $d_n$ ให้เก็บค่าแทนจำนวนเหรียญที่น้อยที่สุดที่ใช้ทอนเงินมูลค่า $n$

จะได้ว่า

$d_i = \min{(d_{i-1}+1, d_{i-3}+1, d_{i-4}+1)}$

ซึ่งเป็น recursive case โดย base case คือ $d_0 = 0$

=== Longest Increasing Subsequence

https://cp-algorithms.com/sequences/longest_increasing_subsequence.html

=== Review

==== คืออะไร?

- คำนวณค่าใน state หนึ่งจาก state ก่อนหน้า โดยไม่ต้องไปคำนวณใหม่
- recursion ที่เรียก overlapping sub-problem
แล้วเอามาใช้ได้เลยโดยไม่ต้องไปคำนวณใหม่
- แก้โจทย์โดยการจำ เล่นกับหน่วยความจำ เพื่อที่จะได้ไม่ต้องคำนวณซ้ำ
- หาค่าปัจจุบันจากค่าก่อนหน้า แล้วเราหาเคสเล็ก

==== มีอะไรบ้าง?

- quicksum `dp[i] = dp[i-1] + a[i]`
- knapsack `dp[i] = max(dp[i-wi] + ci)`
- fibonacci `dp[i] = dp[i-2] + dp[i-1]`
- dijkstra `dp[v] = min(dp[u] + w)`
- LIS longest increasing subsequence
- pascal (nCr) `dp[i][j] = dp[i-1][j-1] + dp[i-1][j]`
- coin change `dp[i] = f(dp[i-xj])`
- matrix chain $N^3$, `dp[i][j] = min(f(dp[i][k],dp[k+1][j]))`
- LCS longest common subsequence
- LCA lowest common ancestor
- \#paths ~~ pascal
- longest common substring ~~ lis
- matrix exponential ~~ divide&conquer/bitwise 
  - $x^9$
  - $9 = {1001}_2$
  - $x^1 *x^8$
- KMP Knutt-Morris-Pratt
- z-function
- floyd-warshall ~~ matrix chain $N^3$, `dp[i][j] = min(f(dp[i][k], dp[k][j]))`
- Manacher algorithm
- TSP travelling salesman $2^n * n$, `dp[i][j]` โดยที่ $i$ เป็น set
ของเมืองที่เคยผ่านไปแล้ว และ $j$ เป็นเมืองสุดท้ายที่อยู่ตอนนั้น
- tribonacci

==== example

===== fibonacci 
$f(n) = f(n-1) + f(n-2)$
  - 1 1 2 3 5 8 11 ..
  - $f(10) = f(9) + f(8)$
  - $f(9) = f(8) + f(7)$

`for (i: 2 → n) dp[i] = dp[i-1] + dp[i-2]`

===== LIS

หาลำดับย่อยที่ยาวที่สุดที่เป็น increasing subsequence

`1 5 3 2 8 9 3 6 → 1 2 3 6 / 1 2 8 9 / 1 5 8 9 / == 4`

$N^2$ solution:

define state: `dp[i] = ความยาวสูงสุดของ increasing subsequence เมื่อพิจารณาช่องที่ 0-i แล้วลงท้ายด้วยเลข a[i]`

คำตอบสุดท้าย `max(dp[1:N])`

update state: new input: x, พิจารณา $a[j] < x$, แล้วเก็บค่า $"dp"[i] = max("dp"[j]+1)$

backtrack: + ให้เก็บด้วย j เป็นเท่าไร

```
     0 1 2 3 4 5 6 7 8

a  : 1 5 3 2 8 9 3 6
dp : 0 1 2 2 2 3 4 3 4
bt : 0 0 1 1 1 4 5 4 7
```

$N log{N}$ solution:

define state: `dp[i] = ค่าที่น้อยที่สุดที่เป็นค่าสุดท้ายของ increasing subsequence ความยาว i`

update state: new input: x ไล่ตั้่งแต่ `dp[j: 0 → mx]` 

- ถ้าค่า dp[j] มากกว่า x และ j มีค่าน้อยที่สุด, `dp[j] = x`,
- แต่ถ้าหาไม่ได้เลย ก็ให้ `dp[mx+1] = x`

คำตอบสุดท้าย mx

```
dp[0] = 0 
dp[1] = 1
dp[2] = 2
dp[3] = 3
dp[4] = 6
dp[5] =
```

=== เพิ่มเติม

- An Introduction to Dynamic Programming (aquablitz11) #footnote[http://tcpc.me/2019/01/28/an-introduction-to-dynamic-programming.html]
- Dynamic Programming by Aj. Nattee #footnote[https://github.com/nattee/ioi-training-note/blob/main/Dynamic%20Programming/01-dynamic%20programming.pdf]
