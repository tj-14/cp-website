#import "@preview/ilm:1.4.0": *

== Topological sorting (implementation)

Topological sort คือการเรียงลำดับ vertex ของ directed graph เพื่อให้ทุก edge $u -> v$ มี $u$ มาก่อน $v$ ในลำดับคำตอบ

กราฟที่ทำ topological sort ได้ต้องเป็น DAG หรือ Directed Acyclic Graph คือกราฟมีทิศทางที่ไม่มี cycle

// <img src="/assets/competitive-programming-starter/graph-algorithm/topo-sort/Untitled.png" width="500px"/>
// <img src="/assets/competitive-programming-starter/graph-algorithm/topo-sort/Untitled 1.png" width="500px"/>

https://cp-algorithms.com/graph/topological-sort.html

=== Motivation problem

ถ้ามีวิชาหลายวิชาและบางวิชาต้องเรียนก่อนอีกวิชา เช่น `A -> B` หมายถึงต้องเรียน A ก่อน B เราต้องการลำดับการเรียนที่ไม่ผิด prerequisite

โจทย์ dependency เช่น build system, ตารางงาน, course planning และ task scheduling มักแปลงเป็น topological sort ได้

=== DFS approach

แนวคิดคือ DFS ลงไปให้สุดก่อน แล้วค่อยนำ vertex ใส่คำตอบตอนกำลังย้อนกลับ ถ้า reverse คำตอบหลังจบ DFS จะได้ลำดับ topological order

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

=== Kahn's algorithm

อีกวิธีคือใช้ indegree และ queue โดยเริ่มจาก vertex ที่ไม่มี edge เข้ามา

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

=== ข้อควรระวัง

- topological order อาจมีได้หลายคำตอบ
- ใช้ได้เฉพาะ directed graph
- ถ้ามี cycle จะไม่สามารถเรียงได้
- ถ้าโจทย์ต้องการลำดับเล็กสุด lexicographically ให้ใช้ priority queue แทน queue ใน Kahn's algorithm

=== แบบฝึกหัด

- TOI14 Technology #footnote[https://grader.mwit.ac.th/problem/toi14_technology]

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1679")[Course Schedule]
- #link("https://cses.fi/problemset/task/1757")[Course Schedule II]
- #link("https://cses.fi/problemset/task/1681")[Game Routes]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
