#import "@preview/ilm:1.4.0": *
#import "widgets.typ": widget

== Topological Sort

Topological sort คือการเรียงลำดับ vertex ของ directed graph เพื่อให้ทุก edge $u -> v$ มี $u$ มาก่อน $v$ ในลำดับคำตอบ

กราฟที่ทำ topological sort ได้ต้องเป็น DAG หรือ Directed Acyclic Graph คือกราฟมีทิศทางที่ไม่มี cycle

เช่น ถ้า `A -> C` และ `B -> C` แปลว่า A และ B ต้องมาก่อน C ลำดับ `A B C` และ `B A C` ถูกทั้งคู่

=== Motivation problem

ถ้ามีวิชาหลายวิชาและบางวิชาต้องเรียนก่อนอีกวิชา เช่น `A -> B` หมายถึงต้องเรียน A ก่อน B เราต้องการลำดับการเรียนที่ไม่ผิด prerequisite

โจทย์ dependency เช่น build system, ตารางงาน, course planning และ task scheduling มักแปลงเป็น topological sort ได้

=== Kahn's algorithm

แนวคิด: โหนดที่ *ไม่มี edge เข้ามา* (in-degree = 0) ไม่ต้องรอใคร จึงอยู่ลำดับแรกได้เลย
เอาโหนดนั้นออกพร้อม edge ที่ออกจากมัน โหนดอื่นจะมี in-degree ลดลง และอาจกลายเป็น 0 ทำซ้ำจนหมด

ลองทำตาม queue ทีละขั้น จากนั้นเปลี่ยนเป็นโหมด "เลือกเอง" แล้วลองเลือกลำดับต่างกัน สุดท้ายเลือกกราฟ "มี cycle" เพื่อดูว่าเกิดอะไรขึ้น

#widget("topo-sort")

=== Implementation ของ Kahn's algorithm

```cpp
vector<int> indeg(n);
for (int u = 0; u < n; u++) {
  for (int v : adj[u]) indeg[v]++;
}

queue<int> q;
for (int i = 0; i < n; i++) {
  if (indeg[i] == 0) q.push(i);
}

vector<int> order;
while (!q.empty()) {
  int u = q.front();
  q.pop();
  order.push_back(u);
  for (int v : adj[u]) {
    indeg[v]--;
    if (indeg[v] == 0) q.push(v);
  }
}
```

ถ้าหลังจบแล้ว `order.size() < n` แปลว่ากราฟมี cycle จึงไม่มี topological order

=== DFS approach

อีกวิธีคือ DFS แล้วนำ vertex ใส่คำตอบ *ตอนออก* จาก DFS (post-order) เพราะ vertex จะออกหลังจากทุกตัวที่มันชี้ไปออกหมดแล้ว เมื่อ reverse คำตอบจึงได้ topological order

```cpp
int n; // number of vertices
vector<vector<int>> adj; // adjacency list of graph
vector<bool> visited;
vector<int> ans;

void dfs(int v) {
    visited[v] = true;
    for (int u : adj[v]) {
        if (!visited[u])
            dfs(u);
    }
    ans.push_back(v);
}

void topological_sort() {
    visited.assign(n, false);
    ans.clear();
    for (int i = 0; i < n; ++i) {
        if (!visited[i])
            dfs(i);
    }
    reverse(ans.begin(), ans.end());
}
```

เวลาทำงานคือ $O(V+E)$ เพราะแต่ละ vertex และ edge ถูกพิจารณาจำนวนคงที่

=== DP บน DAG

Topological order รับประกันว่าเมื่อประมวลผล $v$ ทุกโหนดที่ชี้มาหา $v$ ถูกประมวลผลแล้ว จึงทำ DP บน DAG ได้ตรง ๆ เช่น นับจำนวนเส้นทางจาก $s$ ไปทุกโหนด

```cpp
vector<long long> ways(n, 0);
ways[s] = 1;
for (int u : order) {             // order จาก Kahn's algorithm
  for (int v : adj[u]) {
    ways[v] = (ways[v] + ways[u]) % MOD;
  }
}
```

เปลี่ยนการบวกเป็น `max(dist[u] + 1)` ก็ได้เส้นทางที่ยาวที่สุดใน DAG (ซึ่งในกราฟทั่วไปเป็นปัญหาที่ยากมาก)

=== ข้อควรระวัง

- topological order อาจมีได้หลายคำตอบ
- ใช้ได้เฉพาะ directed graph
- ถ้ามี cycle จะไม่สามารถเรียงได้
- ถ้าโจทย์ต้องการลำดับเล็กสุด lexicographically ให้ใช้ priority queue แทน queue ใน Kahn's algorithm

=== แบบฝึกหัด

- #link("https://grader.mwit.ac.th/problem/toi14_technology")[TOI14 Technology] (MWIT Grader)
- อ่านเพิ่ม: Topological sorting (CP-Algorithms) #footnote[https://cp-algorithms.com/graph/topological-sort.html]

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1679")[Course Schedule]
- #link("https://cses.fi/problemset/task/1757")[Course Schedule II]
- #link("https://cses.fi/problemset/task/1680")[Longest Flight Route] (DP บน DAG)
- #link("https://cses.fi/problemset/task/1681")[Game Routes] (นับเส้นทาง)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
