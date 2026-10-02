#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Search

=== หลักการ

Search คือการลองสำรวจสถานะหรือคำตอบที่เป็นไปได้ทั้งหมดภายใต้เงื่อนไขของโจทย์ เทคนิคนี้เป็นพื้นฐานของ brute force, backtracking, graph traversal และ optimization หลายแบบ

ข้อดีคือคิดตรงไปตรงมาและใช้ตรวจคำตอบของวิธีที่ซับซ้อนได้ ข้อเสียคือ state space มักโตเร็วมาก จึงต้องวิเคราะห์จำนวนสถานะก่อนเขียนจริง

=== Motivation problem

สมมติมีตัวเลข $n$ ตัว และต้องเลือกบางตัวให้ผลรวมเท่ากับ $x$ วิธี brute force คือพิจารณาทุก subset

```cpp
for (int mask = 0; mask < (1 << n); mask++) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    if (mask & (1 << i)) sum += a[i];
  }
  if (sum == x) {
    cout << "found";
  }
}
```

จำนวน subset คือ $2^n$ ดังนั้นวิธีนี้เหมาะกับ $n <= 20$

=== Generating Permutations

เขียน recursive function เพื่อ generate ทุก permutation ที่เป็นไปได้

```cpp
vector<int> p;
vector<bool> used(n);

void gen() {
  if ((int)p.size() == n) {
    // process permutation
    return;
  }
  for (int i = 0; i < n; i++) {
    if (used[i]) continue;
    used[i] = true;
    p.push_back(i);
    gen();
    p.pop_back();
    used[i] = false;
  }
}
```

จำนวน permutation คือ $n!$ จึงใช้ได้เฉพาะ $n$ เล็กมาก

=== Backtracking และการตัดกิ่ง (pruning)

Backtracking คือ recursion ที่ค่อย ๆ สร้างคำตอบทีละส่วน และ *ถอยกลับทันที* เมื่อรู้ว่าส่วนที่สร้างมาไปต่อไม่ได้ การตัดกิ่งเร็วเท่าไร search ยิ่งเร็วขึ้นมาก

ตัวอย่าง: วาง queen $n$ ตัวบนกระดาน $n times n$ ไม่ให้กินกันได้ วางทีละแถว และเช็คคอลัมน์กับเส้นทแยงทั้งสองด้วย array จึงตัดตำแหน่งที่ชนได้ใน $O(1)$

```cpp
int n = 8, ways = 0;
bool col[20], diag1[40], diag2[40];

void place(int r) {
  if (r == n) { ways++; return; }
  for (int c = 0; c < n; c++) {
    if (col[c] || diag1[r + c] || diag2[r - c + n - 1]) continue;  // ตัดกิ่ง
    col[c] = diag1[r + c] = diag2[r - c + n - 1] = true;
    place(r + 1);
    col[c] = diag1[r + c] = diag2[r - c + n - 1] = false;           // backtrack
  }
}
// place(0) แล้ว ways = 92 เมื่อ n = 8
```

=== Search บน state ด้วย BFS

หลายโจทย์ไม่ได้ให้กราฟมาตรง ๆ แต่ถามว่า *ใช้กี่ขั้นน้อยที่สุด* ในการเปลี่ยนสถานะหนึ่งไปอีกสถานะหนึ่ง ให้มองแต่ละสถานะเป็น node และแต่ละการกระทำเป็น edge แล้ว BFS (ดูหลักการ BFS ใน widget ของบท Graph Algorithm)

ตัวอย่าง: เริ่มที่เลข $a$ ทำได้สองอย่างคือ คูณ 2 หรือ ลบ 1 ต้องใช้กี่ขั้นจึงได้ $b$

```cpp
int minSteps(int a, int b) {
  const int LIMIT = 2 * max(a, b) + 2;  // ไม่จำเป็นต้องไปไกลกว่านี้
  vector<int> dist(LIMIT, -1);
  queue<int> q;
  dist[a] = 0;
  q.push(a);
  while (!q.empty()) {
    int u = q.front();
    q.pop();
    if (u == b) return dist[u];
    for (int v : {u * 2, u - 1}) {
      if (v < 0 || v >= LIMIT || dist[v] != -1) continue;
      dist[v] = dist[u] + 1;
      q.push(v);
    }
  }
  return -1;
}
// minSteps(3, 10) = 3: 3 -> 6 -> 5 -> 10
```

=== Meet in the middle

ถ้า $n$ ใหญ่เกินกว่าจะลองทุก subset แต่ยังไม่ใหญ่มาก (ประมาณ 30-40) ให้ *แบ่งครึ่ง* แล้วลองทุก subset ของแต่ละครึ่งแยกกัน จากนั้นจับคู่ผลของสองฝั่ง

ตัวอย่าง subset sum ที่ $n = 40$: ทุก subset มี $2^40 approx 10^12$ ซึ่งมากเกินไป แต่สองครึ่งมีครึ่งละ $2^20 approx 10^6$ เท่านั้น

```cpp
vector<long long> sums(const vector<long long>& v) {  // ผลรวมของทุก subset
  vector<long long> out = {0};
  for (long long x : v) {
    int k = out.size();
    for (int i = 0; i < k; i++) out.push_back(out[i] + x);
  }
  return out;
}

// นับจำนวน subset ที่ผลรวมเท่ากับ target
long long countSubsets(const vector<long long>& a, long long target) {
  int h = a.size() / 2;
  vector<long long> L = sums({a.begin(), a.begin() + h});
  vector<long long> R = sums({a.begin() + h, a.end()});
  sort(R.begin(), R.end());
  long long ways = 0;
  for (long long s : L) {
    auto range = equal_range(R.begin(), R.end(), target - s);
    ways += range.second - range.first;
  }
  return ways;
}
```

เวลา $O(2^(n/2) dot n)$ แทน $O(2^n)$

=== การเลือกเทคนิค

#table(
  columns: 3,
  header([เทคนิค], [จำนวนสถานะ], [ใช้เมื่อ]),
  [Subset brute force], [$O(2^n)$], [$n$ เล็กและต้องลองเลือกหรือไม่เลือก],
  [Permutation brute force], [$O(n!)$], [ต้องลองลำดับทั้งหมด],
  [Backtracking + pruning], [ขึ้นกับการตัดกิ่ง], [มีเงื่อนไขที่ตรวจได้ระหว่างสร้างคำตอบ],
  [BFS บน state], [$O("states" + "transitions")$], [หาจำนวนขั้นน้อยสุด],
  [Meet in the middle], [$O(2^(n/2))$], [$n$ กลาง ๆ เช่น 30-44],
)

=== ข้อควรระวัง

- ต้องกำหนด state ให้ชัดว่าอะไรคือข้อมูลที่จำเป็นต่อการตัดสินใจต่อไป
- อย่าลืม mark visited ใน graph search ไม่เช่นนั้นอาจวนไม่จบ
- ถ้าใช้ recursion ลึกมาก อาจ stack overflow ได้
- วิเคราะห์จำนวนสถานะก่อนเสมอ เพราะ search ที่ถูกต้องแต่ช้าเกินไปจะไม่ผ่านเวลา

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1623")[Apple Division] (ทุก subset)
- #link("https://cses.fi/problemset/task/1622")[Creating Strings] (permutation)
- #link("https://cses.fi/problemset/task/1624")[Chessboard and Queens] (backtracking)
- #link("https://cses.fi/problemset/task/1628")[Meet in the Middle]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
