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

=== Graph Traversal

https://visualgo.net/en/dfsbfs?slide=1

- BFS ใช้ queue และสำรวจตามระยะทางจากจุดเริ่มต้น เหมาะกับ shortest path ในกราฟไม่มีน้ำหนัก
- DFS ใช้ recursion หรือ stack เหมาะกับ connectivity, cycle detection และ topological sort
    - preorder: ทำงานกับ node ก่อนเข้าลูก
    - inorder: ใช้กับ binary tree
    - postorder: ทำงานกับ node หลังออกจากลูก
- Topological Sort

ตัวอย่าง BFS

```cpp
queue<int> q;
vector<int> dist(n, -1);

dist[start] = 0;
q.push(start);

while (!q.empty()) {
  int u = q.front();
  q.pop();
  for (int v : adj[u]) {
    if (dist[v] != -1) continue;
    dist[v] = dist[u] + 1;
    q.push(v);
  }
}
```

=== Binary Search Tree

https://visualgo.net/en/bst?slide=1

- create
- search(v)
- insert(v)
- remove(v)

=== Meet in the middle

- เป็นเทคนิคที่ถ้า search จากต้นทางแล้ว space ใหญ่เกินไป ให้ search จากปลายทางแล้วมาเจอกันตรงกลาง

ตัวอย่างเช่น subset sum ที่ $n=40$ ถ้าลองทุก subset จะเป็น $2^40$ ซึ่งมากเกินไป แต่ถ้าแบ่ง array เป็นสองครึ่ง จะได้สองชุดขนาด $2^20$ แล้วนำผลรวมของสองฝั่งมาจับคู่กัน

ขั้นตอนทั่วไป

- แบ่งข้อมูลเป็นสองส่วน
- generate คำตอบย่อยของแต่ละส่วน
- sort หรือใช้ hash เพื่อหาคู่ที่รวมกันเป็นคำตอบ

=== การเลือกเทคนิค

#table(
  columns: 3,
  header([เทคนิค], [จำนวนสถานะ], [ใช้เมื่อ]),
  [Subset brute force], [$O(2^n)$], [$n$ เล็กและต้องลองเลือกหรือไม่เลือก],
  [Permutation brute force], [$O(n!)$], [ต้องลองลำดับทั้งหมด],
  [BFS], [$O(V+E)$], [กราฟไม่มีน้ำหนักหรือหาจำนวนก้าวน้อยสุด],
  [DFS], [$O(V+E)$], [สำรวจ component, cycle, ordering],
  [Meet in the middle], [$O(2^{n/2})$], [$n$ กลาง ๆ เช่น 30-44],
)

=== ข้อควรระวัง

- ต้องกำหนด state ให้ชัดว่าอะไรคือข้อมูลที่จำเป็นต่อการตัดสินใจต่อไป
- อย่าลืม mark visited ใน graph search ไม่เช่นนั้นอาจวนไม่จบ
- ถ้าใช้ recursion ลึกมาก อาจ stack overflow ได้
- วิเคราะห์จำนวนสถานะก่อนเสมอ เพราะ search ที่ถูกต้องแต่ช้าเกินไปจะไม่ผ่านเวลา

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1084")[Apartments]
- #link("https://cses.fi/problemset/task/1620")[Factory Machines]
- #link("https://cses.fi/problemset/task/2422")[Multiplication Table]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
