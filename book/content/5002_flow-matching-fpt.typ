#import "@preview/ilm:1.4.0": *

== Max Flow, Matching และ FPT

บทนี้สรุปจากการสอนค่าย สสวท. (IOI Training Camp) เดือนพฤษภาคม 2026 มีสามหัวข้อที่เชื่อมกัน: max flow เป็นเครื่องมือหลัก, bipartite matching เป็นกรณีพิเศษของ flow และ fixed parameter algorithms ใช้กับปัญหาที่ไม่มีอัลกอริทึม polynomial เช่น vertex cover บนกราฟทั่วไป

ลองเล่นตัวอย่างโต้ตอบประกอบบทนี้

- #link("https://tossatree.com/assets/writing/ioi/gemini-code-edmonds-karp-dinic.html")[Edmonds-Karp vs Dinic Visualizer]: ใส่กราฟเองแล้วเดินทีละขั้น เทียบสองอัลกอริทึม
- #link("https://tossatree.com/assets/writing/ioi/gemini-code-vertex-cover.html")[Vertex Cover Solver]: ดู kernelization และการแตก branch ของ FPT

=== Max Flow

มี directed graph ที่แต่ละ edge มี *capacity* $c(u, v)$ ต้องการส่ง *flow* จาก source $s$ ไป sink $t$ ให้มากที่สุด โดย

- flow บน edge ไม่เกิน capacity
- ทุก vertex ยกเว้น $s$ และ $t$ มี flow เข้าเท่ากับ flow ออก

==== Residual graph และ augmenting path

ถ้าส่ง flow $f$ บน edge $u -> v$ ไปแล้ว เหลือส่งเพิ่มได้ $c(u, v) - f$ และ *ถอนคืน* ได้ $f$ ซึ่งแทนด้วย reverse edge $v -> u$ ที่มี capacity $f$
กราฟของความจุที่เหลือนี้เรียกว่า *residual graph*

*Ford-Fulkerson*: ตราบใดที่ยังมีเส้นทางจาก $s$ ถึง $t$ ใน residual graph (augmenting path) ให้ส่ง flow เพิ่มตามเส้นทางนั้นเท่ากับ capacity ที่น้อยที่สุดบนเส้นทาง
reverse edge สำคัญมาก เพราะทำให้แก้การตัดสินใจที่ผิดก่อนหน้าได้

- *Edmonds-Karp*: เลือก augmenting path ที่สั้นที่สุดด้วย BFS ได้ $O(V E^2)$
- *Dinic*: BFS แบ่ง vertex เป็นชั้นตามระยะจาก $s$ แล้ว DFS ส่ง flow เฉพาะ edge ที่ไปชั้นถัดไปจนตัน (blocking flow) ได้ $O(V^2 E)$ และเร็วกว่านั้นมากในทางปฏิบัติ บนกราฟที่ capacity เป็น 1 ทั้งหมดได้ $O(E sqrt(V))$

```cpp
struct Edge { int to; long long cap; };
vector<Edge> edges;
vector<vector<int>> g;     // g[u] = index ของ edge ที่ออกจาก u
vector<int> level, it;     // ทั้งสามตัว assign ขนาด n ก่อนใช้

void add_edge(int u, int v, long long cap) {
  g[u].push_back(edges.size());
  edges.push_back({v, cap});
  g[v].push_back(edges.size());
  edges.push_back({u, 0});  // reverse edge ของ edge id อยู่ที่ id ^ 1
}

bool bfs(int s, int t) {
  fill(level.begin(), level.end(), -1);
  level[s] = 0;
  queue<int> q;
  q.push(s);
  while (!q.empty()) {
    int u = q.front();
    q.pop();
    for (int id : g[u]) {
      int v = edges[id].to;
      if (edges[id].cap > 0 && level[v] < 0) {
        level[v] = level[u] + 1;
        q.push(v);
      }
    }
  }
  return level[t] >= 0;
}

long long dfs(int u, int t, long long pushed) {
  if (u == t) return pushed;
  for (int &i = it[u]; i < (int)g[u].size(); i++) {  // it[u] ข้าม edge ที่ตันแล้ว
    int id = g[u][i], v = edges[id].to;
    if (edges[id].cap == 0 || level[v] != level[u] + 1) continue;
    long long got = dfs(v, t, min(pushed, edges[id].cap));
    if (got > 0) {
      edges[id].cap -= got;
      edges[id ^ 1].cap += got;
      return got;
    }
  }
  return 0;
}

long long max_flow(int s, int t) {
  long long flow = 0;
  while (bfs(s, t)) {
    fill(it.begin(), it.end(), 0);
    while (long long f = dfs(s, t, LLONG_MAX)) flow += f;
  }
  return flow;
}
```

==== Max-flow min-cut theorem

*Cut* คือการแบ่ง vertex เป็นฝั่ง $S$ (มี $s$) และ $T$ (มี $t$) ขนาดของ cut คือผลรวม capacity ของ edge จาก $S$ ไป $T$
ทฤษฎีบทบอกว่า *max flow = min cut* และหลังรัน max flow แล้ว vertex ที่ไปถึงได้จาก $s$ ใน residual graph คือฝั่ง $S$ ของ min cut

โจทย์ที่ถาม "ตัด edge น้อยสุดให้ $s$ ไปไม่ถึง $t$" จึงเป็น max flow โดยตรง เช่น #link("https://cses.fi/problemset/task/1695")[Police Chase]

=== Bipartite Matching

*Matching* คือเซตของ edge ที่ไม่มี vertex ร่วมกัน ใน bipartite graph (ฝั่งซ้าย $L$ ฝั่งขวา $R$) ต้องการ matching ใหญ่ที่สุด เช่น จับคู่นักเรียนกับงาน

แปลงเป็น max flow ได้ทันที: $s -> u$ ทุก $u in L$, $u -> v$ ทุก edge, $v -> t$ ทุก $v in R$ โดยทุก edge capacity 1 ขนาด max flow คือขนาด matching ใหญ่สุด และ Dinic บนกราฟนี้คือ *Hopcroft-Karp* ซึ่งได้ $O(E sqrt(V))$

ถ้า $V$ ไม่ใหญ่ *Kuhn's algorithm* เขียนสั้นกว่า: สำหรับ $u$ แต่ละตัวลองหา augmenting path ด้วย DFS ถ้า $v$ ว่างก็จับคู่เลย ถ้าไม่ว่างให้ลองย้ายคู่เดิมของ $v$ ไปที่อื่น ใช้ $O(V E)$

```cpp
vector<vector<int>> adj;  // adj[u] = vertex ฝั่งขวาที่ u (ฝั่งซ้าย) จับคู่ได้
vector<int> mt;           // mt[v] = คู่ของ v ฝั่งขวา หรือ -1
vector<char> used;

bool try_kuhn(int u) {
  for (int v : adj[u]) {
    if (used[v]) continue;
    used[v] = true;
    if (mt[v] == -1 || try_kuhn(mt[v])) {
      mt[v] = u;
      return true;
    }
  }
  return false;
}

int max_matching(int nl, int nr) {
  mt.assign(nr, -1);
  int res = 0;
  for (int u = 0; u < nl; u++) {
    used.assign(nr, false);
    if (try_kuhn(u)) res++;
  }
  return res;
}
```

*König's theorem*: ใน bipartite graph ขนาด *minimum vertex cover* (เซต vertex น้อยสุดที่แตะทุก edge) เท่ากับขนาด maximum matching จึงหาได้ด้วย flow ใน polynomial time

=== Fixed Parameter Algorithms (FPT)

บนกราฟทั่วไป minimum vertex cover เป็น NP-hard จึงไม่น่าจะมีอัลกอริทึม polynomial แต่ถ้าโจทย์บอกว่าคำตอบ $k$ เล็ก (เช่น $k <= 20$) ขณะที่ $n$ ใหญ่ เราแยกความยากไปไว้ที่ $k$ ได้

ปัญหาเป็น *fixed parameter tractable* (FPT) ถ้าแก้ได้ใน $O(f(k) dot "poly"(n))$ เช่น $O(2^k (n + m))$ ซึ่งเร็วกว่า $O(n^k)$ จากการลองทุกเซตขนาด $k$ มาก

==== Bounded search tree

สำหรับ edge $(u, v)$ ใด ๆ ที่ยังไม่ถูกครอบ cover *ต้อง* มี $u$ หรือ $v$ อย่างน้อยหนึ่งตัว จึงแตกเป็นสองกรณี แต่ละกรณีใช้งบ $k$ ไป 1 ความลึกไม่เกิน $k$ จึงมีไม่เกิน $2^k$ ใบ

```cpp
// มี vertex cover ขนาดไม่เกิน k ที่ครอบทุก edge ใน es หรือไม่
bool vertex_cover(const vector<pair<int, int>> &es, int k) {
  if (es.empty()) return true;
  if (k == 0) return false;
  auto [u, v] = es[0];
  for (int pick : {u, v}) {
    vector<pair<int, int>> rest;
    for (auto [a, b] : es)
      if (a != pick && b != pick) rest.push_back({a, b});
    if (vertex_cover(rest, k - 1)) return true;
  }
  return false;
}
```

Time $O(2^k m)$

==== Kernelization

ก่อนแตก branch ให้ลดขนาดกราฟด้วยกฎที่ปลอดภัยเสมอ (Buss's kernel)

- vertex ที่ degree มากกว่า $k$ *ต้อง* อยู่ใน cover เพราะถ้าไม่เลือกมัน ต้องเลือกเพื่อนบ้านทั้งหมดซึ่งเกิน $k$ ตัว จึงเลือกแล้วลด $k$ ลง 1
- หลังจากนั้นทุก vertex มี degree ไม่เกิน $k$ ดังนั้น $k$ ตัวครอบได้ไม่เกิน $k^2$ edge ถ้าเหลือ edge มากกว่า $k^2$ ตอบ "ไม่ได้" ทันที

กราฟที่เหลือ (kernel) มีขนาดขึ้นกับ $k$ เท่านั้น จึงรวมเป็น $O(n + m + 2^k k^2)$

แนวคิด FPT ยังใช้กับปัญหาอื่น เช่น หา path ยาว $k$ ด้วย color coding หรือ DP บน tree decomposition ที่ treewidth เล็ก

=== โจทย์ฝึกฝน (Practice Problems)

- #link("https://cses.fi/problemset/task/1694")[Download Speed] (max flow)
- #link("https://cses.fi/problemset/task/1695")[Police Chase] (min cut)
- #link("https://cses.fi/problemset/task/1696")[School Dance] (bipartite matching)
- #link("https://cses.fi/problemset/task/1711")[Distinct Routes] (flow + หาเส้นทางจาก flow)

=== อ่านเพิ่ม

- #link("https://cp-algorithms.com/graph/edmonds_karp.html")[Edmonds-Karp (CP-Algorithms)], #link("https://cp-algorithms.com/graph/dinic.html")[Dinic (CP-Algorithms)]
- #link("https://cp-algorithms.com/graph/kuhn_maximum_bipartite_matching.html")[Kuhn's Algorithm (CP-Algorithms)]
- #link("https://usaco.guide/adv/max-flow?lang=cpp")[Maximum Flow (USACO Guide)]
- #link("https://en.wikipedia.org/wiki/K%C5%91nig%27s_theorem_(graph_theory)")[König's theorem (Wikipedia)], #link("https://en.wikipedia.org/wiki/Parameterized_complexity")[Parameterized complexity (Wikipedia)]
