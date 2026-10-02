#import "@preview/ilm:1.4.0": *
#import table: cell, header
#import "widgets.typ": widget

== Divide & Conquer

=== หลักการ

Divide and conquer แก้ปัญหาด้วยสามขั้นตอน

+ *Divide*: แบ่งปัญหาเป็นปัญหาแบบเดียวกันที่เล็กลง (มักแบ่งครึ่ง)
+ *Conquer*: แก้ปัญหาย่อยด้วย recursion จนเล็กพอจะตอบได้ทันที (base case)
+ *Combine*: รวมคำตอบของปัญหาย่อยเป็นคำตอบของปัญหาเดิม

```
solve(problem):
    if problem is small enough:
        return direct answer                 // base case
    split problem into halves A and B         // divide
    return combine(solve(A), solve(B))        // conquer + combine
```

การแบ่งครึ่งซ้ำ ๆ ทำได้ $log_2 n$ ชั้น ถ้าแต่ละชั้นทำงานรวม $O(n)$ เวลารวมจะเป็น $O(n log n)$ (เช่น merge sort) และถ้าทิ้งครึ่งหนึ่งไปเลยทุกครั้ง จะเหลือ $O(log n)$ (เช่น binary search)

=== Binary search

หาค่าใน array *ที่เรียงแล้ว* โดยเทียบกับตัวตรงกลาง แล้วทิ้งครึ่งที่ไม่มีคำตอบแน่นอน ทุกขั้นช่วงที่เหลือเล็กลงครึ่งหนึ่ง จึงใช้เพียง $O(log n)$ ขั้น (array $10^6$ ตัวใช้ไม่เกิน 20 ขั้น)

รูปแบบที่ปลอดภัยที่สุดคือหา *ตำแหน่งแรกที่ `a[i] >= x`* (lower bound) บนช่วงครึ่งเปิด `[lo, hi)`

```cpp
int lo = 0, hi = n;          // คำตอบอยู่ใน [lo, hi] เสมอ (hi = n แปลว่าไม่มี)
while (lo < hi) {
  int mid = lo + (hi - lo) / 2;
  if (a[mid] < x) lo = mid + 1;  // a[mid] ไม่ใช่คำตอบ คำตอบอยู่ทางขวา
  else hi = mid;                 // a[mid] อาจเป็นคำตอบ เก็บ mid ไว้
}
// lo = ตำแหน่งแรกที่ a[lo] >= x และ x มีใน array ถ้า lo < n && a[lo] == x
```

ลองหาค่าต่าง ๆ ใน array ที่มีค่าซ้ำ เปิด "ให้ฉันทายก่อน" เพื่อทายว่าแต่ละขั้นคำตอบอยู่ฝั่งไหน

#widget("binary-search")

==== ข้อผิดพลาดที่พบบ่อย

- *วนไม่จบ*: ถ้าเขียน `lo = mid` แทน `lo = mid + 1` ช่วงอาจไม่เล็กลงเมื่อเหลือสองตัว
- *overflow*: `(lo + hi) / 2` ล้นได้ถ้า `lo + hi` เกินขอบเขต `int` ใช้ `lo + (hi - lo) / 2`
- *ลืม sort* ก่อน binary search
- *เข้าถึง `a[n]`*: เมื่อไม่มีคำตอบ `lo` จะเป็น `n` ต้องเช็คก่อนใช้ `a[lo]`

STL มีให้ใช้แล้วคือ `lower_bound` (แรกที่ $>= x$) และ `upper_bound` (แรกที่ $> x$) ดูบท STL

=== Binary search คำตอบ

หลายโจทย์ถามหา *ค่าน้อยสุด* ที่ทำให้เงื่อนไขเป็นจริง ถ้าเงื่อนไขเป็นแบบ *monotonic* คือเมื่อค่าหนึ่งทำได้ ค่าที่มากกว่าก็ทำได้เสมอ

```
t:        1  2  3  4  5  6  7  8
ok(t):    F  F  F  F  T  T  T  T   ← หาตัว T ตัวแรก
```

ก็ binary search บนคำตอบได้ โดยไม่ต้องรู้สูตรตรง ๆ แค่เขียนฟังก์ชัน `ok(t)` ที่ตรวจได้เร็ว

ตัวอย่าง (Factory Machines): มีเครื่องจักร $n$ เครื่อง เครื่องที่ $i$ ผลิตของหนึ่งชิ้นใช้เวลา $k_i$ ต้องการของ $t$ ชิ้น ใช้เวลาน้อยที่สุดเท่าไร
ในเวลา $T$ เครื่องที่ $i$ ผลิตได้ $floor(T / k_i)$ ชิ้น ยิ่ง $T$ มากยิ่งผลิตได้มาก จึงเป็น monotonic

```cpp
bool ok(long long T) {
  long long made = 0;
  for (long long k : machines) {
    made += T / k;
    if (made >= target) return true;  // หยุดก่อนเพื่อกัน overflow
  }
  return false;
}

long long lo = 1, hi = 1e18;  // hi ต้องทำได้แน่นอน
while (lo < hi) {
  long long mid = lo + (hi - lo) / 2;
  if (ok(mid)) hi = mid;
  else lo = mid + 1;
}
// lo = เวลาน้อยสุดที่ทำได้
```

เวลา $O(n log("hi"))$: binary search ประมาณ 60 รอบ รอบละ $O(n)$

=== Fast exponentiation

คำนวณ $a^n$ ด้วยการคูณตรง ๆ ใช้ $O(n)$ แต่ถ้าแบ่งครึ่ง

$ a^n = cases(
  1 & "if" n = 0,
  (a^(n/2))^2 & "if" n "is even",
  (a^((n-1)/2))^2 dot a & "if" n "is odd",
) $

จะเหลือ $O(log n)$ เพราะ $n$ ลดลงครึ่งหนึ่งทุกครั้ง (ระวังกรณีคี่: ต้องคูณ $a$ เพิ่มอีกหนึ่งตัว)

```cpp
const long long MOD = 1e9 + 7;

long long power(long long a, long long n) {
  if (n == 0) return 1;
  long long half = power(a, n / 2);   // n / 2 ปัดลงอยู่แล้วเมื่อ n คี่
  long long res = half * half % MOD;
  if (n % 2 == 1) res = res * a % MOD;
  return res;
}
```

เขียนแบบ loop ได้โดยดูบิตของ $n$ ทีละบิต เช่น $a^13 = a^8 dot a^4 dot a^1$ เพราะ $13 = 1101_2$

```cpp
long long power(long long a, long long n) {
  long long res = 1;
  a %= MOD;
  while (n > 0) {
    if (n & 1) res = res * a % MOD;
    a = a * a % MOD;
    n >>= 1;
  }
  return res;
}
```

==== Fibonacci ใน $O(log n)$

เพราะ $mat(F_(n+1); F_n) = mat(1, 1; 1, 0) mat(F_n; F_(n-1))$ จึงได้ $F_n$ จากการยกกำลังเมทริกซ์ $2 times 2$ ด้วยวิธีเดียวกัน ใช้เวลา $O(log n)$ แม้ $n = 10^18$

```cpp
typedef array<array<long long, 2>, 2> Mat;

Mat mul(const Mat& A, const Mat& B) {
  Mat C{};
  for (int i = 0; i < 2; i++)
    for (int j = 0; j < 2; j++)
      for (int k = 0; k < 2; k++)
        C[i][j] = (C[i][j] + A[i][k] * B[k][j]) % MOD;
  return C;
}

long long fib(long long n) {  // F_0 = 0, F_1 = 1
  Mat res = {{{1, 0}, {0, 1}}}, base = {{{1, 1}, {1, 0}}};
  while (n > 0) {
    if (n & 1) res = mul(res, base);
    base = mul(base, base);
    n >>= 1;
  }
  return res[0][1];
}
```

=== Merge sort

แบ่ง array เป็นสองครึ่ง sort แต่ละครึ่งด้วย recursion แล้ว *merge* สองครึ่งที่เรียงแล้วด้วยสองตัวชี้ ใช้เวลา $O(n log n)$ เสมอ

```cpp
vector<int> a, tmp;

void mergeSort(int l, int r) {  // sort a[l..r]
  if (l >= r) return;
  int m = (l + r) / 2;
  mergeSort(l, m);
  mergeSort(m + 1, r);
  int i = l, j = m + 1, k = l;
  while (i <= m && j <= r) tmp[k++] = (a[i] <= a[j]) ? a[i++] : a[j++];
  while (i <= m) tmp[k++] = a[i++];
  while (j <= r) tmp[k++] = a[j++];
  for (int t = l; t <= r; t++) a[t] = tmp[t];
}
// เรียกใช้: tmp.resize(n); mergeSort(0, n - 1);
```

ขั้น merge ช่วยนับ *inversion* (คู่ $i < j$ ที่ `a[i] > a[j]`) ได้ด้วย: ทุกครั้งที่หยิบจากฝั่งขวา ตัวที่เหลือในฝั่งซ้ายทั้งหมด $m - i + 1$ ตัวเป็น inversion กับมัน

=== หัวข้อเพิ่มเติม

- *Closest pair of points*: แบ่งจุดเป็นสองฝั่งตามแกน $x$ แล้วตรวจเฉพาะแถบแคบ ๆ ตรงกลางตอนรวม ได้ $O(n log n)$ (CP-Algorithms #footnote[https://cp-algorithms.com/geometry/nearest_points.html])
- *Square root decomposition*: แบ่ง array เป็นก้อนละ $sqrt(n)$ ตัว ตอบคำถามช่วงได้ $O(sqrt(n))$ (USACO Guide #footnote[https://usaco.guide/plat/sqrt?lang=cpp], CP-Algorithms #footnote[https://cp-algorithms.com/data_structures/sqrt_decomposition.html])
- สอน Binary Search ฉบับสมบูรณ์โคตร ๆ (aquablitz11) #footnote[https://aquablitz11.github.io/2019/04/12/complete-bsearch-tutorial.html]

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1095")[Exponentiation]
- #link("https://cses.fi/problemset/task/1620")[Factory Machines] (binary search คำตอบ)
- #link("https://cses.fi/problemset/task/1085")[Array Division] (binary search คำตอบ)
- #link("https://cses.fi/problemset/task/2422")[Multiplication Table] (binary search คำตอบ)
- #link("https://cses.fi/problemset/task/1722")[Fibonacci Numbers] (matrix exponentiation)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
