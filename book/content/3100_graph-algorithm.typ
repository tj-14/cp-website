#import "@preview/ilm:1.4.0": *
#import table: cell, header
#import "widgets.typ": widget

== Graph Algorithm

บทนี้ต่อจากบท Graph Structure โดยเก็บกราฟแบบ adjacency list ให้ $n$ คือจำนวนโหนด (V) และ $m$ คือจำนวนเส้นเชื่อม (E)

```cpp
vector<int> adj[N];                 // unweighted
vector<pair<int, int>> wadj[N];     // weighted: {ปลายทาง, น้ำหนัก}

for (int i = 0; i < m; i++) {
  int u, v;
  cin >> u >> v;
  adj[u].push_back(v);
  adj[v].push_back(u);  // ลบบรรทัดนี้ถ้าเป็น directed graph
}
```

=== Graph traversal

การเดินสำรวจกราฟ (traversal) คือการเยี่ยมทุกโหนดที่ไปถึงได้จากจุดเริ่มต้น โดยแต่ละโหนดเยี่ยมเพียงครั้งเดียว มีสองแบบหลัก

==== Breadth-First Search (BFS)

BFS เยี่ยมโหนดเป็น *ชั้น* ตามระยะห่างจากจุดเริ่มต้น: ระยะ 0, ระยะ 1, ระยะ 2, ... โดยใช้ *queue* (เข้าก่อนออกก่อน)

เพราะเยี่ยมตามลำดับระยะทาง `dist[v]` ที่ได้จึงเป็น *shortest path ในกราฟไม่มีน้ำหนัก* เสมอ

```cpp
vector<int> dist(n, -1);  // -1 = ยังไม่เคยเจอ
queue<int> q;
dist[s] = 0;
q.push(s);
while (!q.empty()) {
  int u = q.front();
  q.pop();
  for (int v : adj[u]) {
    if (dist[v] != -1) continue;  // เคยเจอแล้ว
    dist[v] = dist[u] + 1;
    q.push(v);
  }
}
```

==== Depth-First Search (DFS)

DFS เดิน *ลึก* ไปเรื่อย ๆ จนไปต่อไม่ได้ แล้วจึงถอยกลับ (backtrack) มาลองทางอื่น เขียนด้วย recursion ได้สั้นที่สุด

```cpp
bool visited[N];

void dfs(int u) {
  visited[u] = true;
  for (int v : adj[u]) {
    if (!visited[v]) dfs(v);
  }
}
```

ทั้งสองแบบใช้เวลา $O(n + m)$ เพราะแต่ละโหนดถูกเยี่ยมครั้งเดียว และแต่ละ edge ถูกดูไม่เกินสองครั้ง

ลองเทียบลำดับการเยี่ยมของ BFS และ DFS บนกราฟเดียวกัน (เพื่อนบ้านถูกพิจารณาจากเลขน้อยไปมาก) เปิด "ให้ฉันทายก่อน" แล้วคลิกโหนดที่คิดว่าจะถูกเยี่ยมถัดไป ตัวเลขเล็กข้างโหนดใน BFS คือ `dist` และเส้นหนาคือเส้นที่ใช้เดินไปพบโหนดนั้นครั้งแรก

#widget("graph-traversal")

#table(
  columns: 3,
  header([], [BFS], [DFS]),
  [โครงสร้างข้อมูล], [queue], [recursion (call stack) หรือ stack],
  [ลำดับการเยี่ยม], [ตามระยะห่างจากจุดเริ่ม], [ลึกก่อน แล้วถอยกลับ],
  [ใช้บ่อยกับ], [shortest path ไม่มีน้ำหนัก, grid], [component, cycle, topological sort, tree],
  [ข้อควรระวัง], [ใช้หน่วยความจำตามความกว้างของชั้น], [recursion ลึกมากอาจ stack overflow],
)

=== Graph applications

==== Connected components

วนทุกโหนด ถ้าเจอโหนดที่ยังไม่ถูกเยี่ยม แปลว่าเจอ component ใหม่ ให้ DFS จากโหนดนั้น กราฟ *connected* ก็ต่อเมื่อมีเพียง 1 component

```cpp
int components = 0;
for (int u = 0; u < n; u++) {
  if (!visited[u]) {
    components++;
    dfs(u);
  }
}
```

==== Grid เป็นกราฟ

ตาราง (grid) คือกราฟที่แต่ละช่องเป็นโหนด และเชื่อมกับช่องข้างเคียง 4 ทิศ ไม่ต้องสร้าง `adj` จริง ให้คำนวณเพื่อนบ้านตอนเดิน

```cpp
int dr[] = {-1, 1, 0, 0}, dc[] = {0, 0, -1, 1};

void dfs(int r, int c) {
  seen[r][c] = true;
  for (int k = 0; k < 4; k++) {
    int nr = r + dr[k], nc = c + dc[k];
    if (nr < 0 || nr >= R || nc < 0 || nc >= C) continue;  // ออกนอกตาราง
    if (grid[nr][nc] == '#' || seen[nr][nc]) continue;
    dfs(nr, nc);
  }
}
```

ระวัง: grid ขนาด $1000 times 1000$ อาจทำให้ recursion ลึกถึงหนึ่งล้านชั้น ถ้าเสี่ยงให้ใช้ BFS แทน

==== Cycle detection (undirected)

ระหว่าง DFS ถ้าเจอเพื่อนบ้านที่เคยเยี่ยมแล้ว *และไม่ใช่ parent* ที่เพิ่งเดินมา แปลว่ามี cycle

```cpp
bool hasCycle(int u, int parent) {
  visited[u] = true;
  for (int v : adj[u]) {
    if (v == parent) continue;
    if (visited[v] || hasCycle(v, u)) return true;
  }
  return false;
}
```

อีกวิธีคือนับ edge: component ที่มี $c$ โหนดและไม่มี cycle จะมี edge พอดี $c - 1$ เส้น (เป็นต้นไม้)
(ถ้ากราฟมี edge ซ้ำระหว่างคู่เดิม ต้องเช็คด้วย id ของ edge แทน parent)

==== Bipartite check

กราฟเป็น *bipartite* ถ้าระบายสีโหนดด้วยสองสีได้โดยโหนดที่ติดกันมีสีต่างกันเสมอ ให้ BFS แล้วระบายเพื่อนบ้านด้วยสีตรงข้าม ถ้าเจอเพื่อนบ้านสีเดียวกันแปลว่าไม่ใช่ bipartite (มี cycle ความยาวคี่)

```cpp
vector<int> color(n, -1);
bool bipartite = true;
for (int s = 0; s < n; s++) {
  if (color[s] != -1) continue;
  color[s] = 0;
  queue<int> q;
  q.push(s);
  while (!q.empty()) {
    int u = q.front();
    q.pop();
    for (int v : adj[u]) {
      if (color[v] == -1) {
        color[v] = 1 - color[u];
        q.push(v);
      } else if (color[v] == color[u]) {
        bipartite = false;
      }
    }
  }
}
```

=== Weighted shortest path

เมื่อ edge มีน้ำหนัก BFS ใช้ไม่ได้อีกแล้ว เพราะ path ที่ผ่าน edge น้อยกว่าอาจยาวกว่า

ทุกอัลกอริทึมในส่วนนี้ใช้ขั้นตอน *relax* เหมือนกัน: ถ้าไป `v` ผ่าน `u` แล้วสั้นกว่าเดิมให้อัปเดต

```cpp
if (dist[u] + w < dist[v]) dist[v] = dist[u] + w;
```

==== Dijkstra's Algorithm

ใช้กับกราฟที่ *ไม่มี edge น้ำหนักติดลบ* เลือกโหนดที่ `dist` น้อยที่สุดที่ยังไม่ได้ยืนยันด้วย priority queue โหนดนั้นจะมีระยะถูกต้องแน่นอน แล้ว relax เพื่อนบ้านของมัน

```cpp
const long long INF = 1e18;
vector<long long> dist(n, INF);
priority_queue<pair<long long, int>, vector<pair<long long, int>>, greater<>> pq;
dist[s] = 0;
pq.push({0, s});
while (!pq.empty()) {
  auto [d, u] = pq.top();
  pq.pop();
  if (d != dist[u]) continue;  // ข้อมูลเก่า มีระยะที่ดีกว่าแล้ว
  for (auto [v, w] : wadj[u]) {
    if (dist[u] + w < dist[v]) {
      dist[v] = dist[u] + w;
      pq.push({dist[v], v});
    }
  }
}
```

Time complexity $O((n + m) log n)$ ระวังใช้ `long long` เมื่อผลรวมน้ำหนักอาจเกิน $2^31$

==== Bellman-Ford

Relax *ทุก edge* ซ้ำ $n - 1$ รอบ (shortest path ไม่มี cycle จึงมี edge ไม่เกิน $n - 1$ เส้น) ใช้ได้แม้มีน้ำหนักติดลบ
ถ้ารอบที่ $n$ ยัง relax ได้อีก แปลว่ามี *negative cycle* ที่ไปถึงได้จาก $s$

```cpp
struct Edge { int u, v; long long w; };
vector<Edge> edges;

vector<long long> dist(n, INF);
dist[s] = 0;
for (int round = 0; round < n - 1; round++) {
  for (auto [u, v, w] : edges) {
    if (dist[u] != INF && dist[u] + w < dist[v]) dist[v] = dist[u] + w;
  }
}
bool negativeCycle = false;
for (auto [u, v, w] : edges) {
  if (dist[u] != INF && dist[u] + w < dist[v]) negativeCycle = true;
}
```

Time complexity $O(n m)$

==== Floyd-Warshall

หาระยะสั้นสุดของ *ทุกคู่* โหนด `d[i][j]` หลังรอบที่ `k` คือระยะสั้นสุดที่ใช้โหนด $0..k$ เป็นจุดกลางทาง (นี่คือ DP) ต้องวน `k` เป็น loop นอกสุดเสมอ

```cpp
// เริ่มต้น: d[i][i] = 0, d[u][v] = w ถ้ามี edge, ที่เหลือ = INF
for (int k = 0; k < n; k++)
  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++)
      if (d[i][k] != INF && d[k][j] != INF)
        d[i][j] = min(d[i][j], d[i][k] + d[k][j]);
```

Time complexity $O(n^3)$ จึงใช้ได้กับ $n$ ไม่เกินประมาณ 500

==== เลือกใช้อะไรดี

#table(
  columns: 4,
  header([สถานการณ์], [อัลกอริทึม], [Time], [หมายเหตุ]),
  [ไม่มีน้ำหนัก], [BFS], [$O(n + m)$], [เร็วและง่ายที่สุด],
  [น้ำหนักไม่ติดลบ, จุดเริ่มเดียว], [Dijkstra], [$O((n + m) log n)$], [ใช้บ่อยที่สุด],
  [มีน้ำหนักติดลบ], [Bellman-Ford], [$O(n m)$], [ตรวจ negative cycle ได้],
  [ทุกคู่, $n$ เล็ก], [Floyd-Warshall], [$O(n^3)$], [เขียนสั้นที่สุด],
)

=== Minimum Spanning Tree (MST)

Spanning tree คือการเลือก edge $n - 1$ เส้นที่เชื่อมทุกโหนดโดยไม่มี cycle
MST คือ spanning tree ที่ผลรวมน้ำหนักน้อยที่สุด เช่น สร้างถนนให้ทุกเมืองไปถึงกันได้โดยค่าใช้จ่ายน้อยที่สุด

==== Union-Find (Disjoint Set Union)

เก็บว่าแต่ละโหนดอยู่กลุ่มไหน รองรับสองคำสั่ง: `find(x)` หาตัวแทนของกลุ่ม และ `unite(a, b)` รวมสองกลุ่ม
เมื่อใช้ path compression และ union by size แต่ละคำสั่งเร็วจนเกือบเป็น $O(1)$

```cpp
vector<int> par, sz;

int find(int x) {
  return par[x] == x ? x : par[x] = find(par[x]);  // path compression
}

bool unite(int a, int b) {
  a = find(a), b = find(b);
  if (a == b) return false;     // อยู่กลุ่มเดียวกันแล้ว
  if (sz[a] < sz[b]) swap(a, b);
  par[b] = a;                   // ต่อต้นไม้เล็กเข้ากับต้นไม้ใหญ่
  sz[a] += sz[b];
  return true;
}
// เริ่มต้น: par[i] = i, sz[i] = 1
```

==== Kruskal's Algorithm

เรียง edge จากน้ำหนักน้อยไปมาก แล้วหยิบทีละเส้น ถ้าเส้นนั้นไม่ทำให้เกิด cycle (สองปลายอยู่คนละกลุ่ม) ให้เลือกใส่ MST

```cpp
sort(edges.begin(), edges.end(),
     [](const Edge& a, const Edge& b) { return a.w < b.w; });
long long total = 0;
int used = 0;
for (auto [u, v, w] : edges) {
  if (unite(u, v)) {
    total += w;
    used++;
  }
}
// ถ้า used < n - 1 แปลว่ากราฟไม่ connected จึงไม่มี MST
```

Time complexity $O(m log m)$ จากการ sort

==== Prim's Algorithm

เริ่มจากโหนดเดียว แล้วขยายต้นไม้ทีละโหนดด้วย edge ที่เบาที่สุดที่ออกจากต้นไม้ เขียนคล้าย Dijkstra

```cpp
vector<bool> inTree(n, false);
priority_queue<pair<int, int>, vector<pair<int, int>>, greater<>> pq;  // {w, v}
long long total = 0;
pq.push({0, 0});
while (!pq.empty()) {
  auto [w, u] = pq.top();
  pq.pop();
  if (inTree[u]) continue;
  inTree[u] = true;
  total += w;
  for (auto [v, wv] : wadj[u]) {
    if (!inTree[v]) pq.push({wv, v});
  }
}
```

Time complexity $O(m log m)$

=== Tree algorithms

ต้นไม้ (tree) คือกราฟ connected ที่ไม่มี cycle มี $n - 1$ edge และมี path เดียวระหว่างทุกคู่โหนด

==== Diameter

Diameter คือ path ที่ยาวที่สุดในต้นไม้ หาได้ด้วยการ BFS/DFS สองครั้ง

+ เริ่มจากโหนดใดก็ได้ $a$ หาโหนดที่ไกลที่สุดจาก $a$ เรียกว่า $b$
+ หาโหนดที่ไกลที่สุดจาก $b$ เรียกว่า $c$
+ Path จาก $b$ ไป $c$ คือ diameter

(อีกวิธีคือ DP บนต้นไม้: ที่แต่ละโหนด รวมความลึกของลูกสองสายที่ลึกที่สุด)

==== Lowest Common Ancestor (LCA)

LCA ของ $a$ และ $b$ คือบรรพบุรุษร่วมที่ลึกที่สุด ใช้ *binary lifting*: เก็บ `up[j][v]` = บรรพบุรุษชั้นที่ $2^j$ ของ `v` แล้วกระโดดทีละ $2^j$ ทำให้ตอบแต่ละคำถามได้ใน $O(log n)$

```cpp
const int LOG = 17;  // 2^17 > 100000
int up[LOG][N], depth[N];

void dfs(int u, int p) {
  up[0][u] = p;
  for (int j = 1; j < LOG; j++) up[j][u] = up[j - 1][up[j - 1][u]];
  for (int v : adj[u]) {
    if (v == p) continue;
    depth[v] = depth[u] + 1;
    dfs(v, u);
  }
}

int lca(int a, int b) {
  if (depth[a] < depth[b]) swap(a, b);
  for (int j = LOG - 1; j >= 0; j--)        // ยก a ขึ้นให้ลึกเท่า b
    if (depth[a] - (1 << j) >= depth[b]) a = up[j][a];
  if (a == b) return a;
  for (int j = LOG - 1; j >= 0; j--)        // ยกทั้งคู่จนอยู่ใต้ LCA พอดี
    if (up[j][a] != up[j][b]) a = up[j][a], b = up[j][b];
  return up[0][a];
}
// เรียก dfs(root, root) ก่อน ราก (root) จะเป็นบรรพบุรุษของตัวเอง
```

==== Euler Tour Technique

DFS แล้วบันทึกเวลาเข้า `tin[u]` และเวลาออก `tout[u]` ของแต่ละโหนด subtree ของ `u` จะกลายเป็นช่วงต่อเนื่อง `[tin[u], tout[u]]` ใน array
จึงใช้ prefix sum หรือ segment tree ตอบคำถามเกี่ยวกับ subtree ได้ (อ่านเพิ่ม: USACO Guide Euler Tour #footnote[https://usaco.guide/gold/tree-euler?lang=cpp] และโจทย์ CSES Subtree Queries)

=== Strongly Connected Components (SCC)

ใน directed graph กลุ่มโหนดที่ *ทุกคู่เดินไปหากันได้ทั้งสองทาง* เรียกว่า SCC

==== Kosaraju's Algorithm

+ DFS บนกราฟเดิม และเก็บโหนดลง list ตามลำดับที่ *ออกจาก* DFS (post-order)
+ ไล่โหนดจากท้าย list ไปหน้า แล้ว DFS บน *กราฟกลับทิศ* แต่ละครั้งที่เริ่ม DFS ใหม่จะได้ SCC หนึ่งกลุ่ม

```cpp
vector<int> adj[N], radj[N], order;
int comp[N];  // เริ่มต้นเป็น -1
bool visited[N];

void dfs1(int u) {
  visited[u] = true;
  for (int v : adj[u]) if (!visited[v]) dfs1(v);
  order.push_back(u);  // post-order
}

void dfs2(int u, int c) {
  comp[u] = c;
  for (int v : radj[u]) if (comp[v] == -1) dfs2(v, c);
}

// main
for (int u = 0; u < n; u++) if (!visited[u]) dfs1(u);
int count = 0;
for (int i = n - 1; i >= 0; i--) {
  int u = order[i];
  if (comp[u] == -1) dfs2(u, count++);
}
```

Time complexity $O(n + m)$

=== ลองคิด

+ บนกราฟตัวอย่างใน widget ถ้าเริ่มที่โหนด 7 โหนดไหนถูกเยี่ยมเป็นลำดับสุดท้ายใน BFS
+ ทำไม Dijkstra ใช้ไม่ได้เมื่อมี edge ติดลบ ลองหาตัวอย่างกราฟ 3 โหนด
+ ใน Floyd-Warshall ถ้าย้าย loop `k` ไปไว้ในสุดจะเกิดอะไรขึ้น

==== เฉลย

+ โหนด 0 (ระยะ 3) ลองตรวจด้วย widget ได้
+ ตัวอย่าง edge $s -> a$ น้ำหนัก 2, $s -> b$ น้ำหนัก 3, $b -> a$ น้ำหนัก $-2$ Dijkstra นำ $a$ ออกจาก priority queue ที่ระยะ 2 ก่อน แต่ระยะจริงคือ $3 - 2 = 1$ หลักการ "โหนดที่ออกจาก queue มีระยะถูกต้องแล้ว" จึงไม่จริง (โค้ดด้านบนกลับมาแก้ค่าได้ แต่ในกราฟทั่วไปอาจช้าแบบ exponential จึงควรใช้ Bellman-Ford)
+ คำตอบผิด เพราะตอนคำนวณ `d[i][j]` ค่า `d[i][k]` และ `d[k][j]` ยังไม่ได้ใช้จุดกลางครบ

=== เพิ่มเติม

- ตะลุยโจทย์ Graph ระดับโหดใน Competitive Programming (aquablitz11) #footnote[https://web.archive.org/web/20250515101547/https://tcpc.me/2019/08/19/state-graph-tutorial.html]
- VisuAlgo: Graph Traversal #footnote[https://visualgo.net/en/dfsbfs], Single-Source Shortest Paths #footnote[https://visualgo.net/en/sssp], Minimum Spanning Tree #footnote[https://visualgo.net/en/mst]
- CP-Algorithms: Dijkstra #footnote[https://cp-algorithms.com/graph/dijkstra.html], Bipartite check #footnote[https://cp-algorithms.com/graph/bipartite-check.html], SCC #footnote[https://cp-algorithms.com/graph/strongly-connected-components.html]
- A\* Search (Red Blob Games) #footnote[https://www.redblobgames.com/pathfinding/a-star/introduction.html] ต่อยอดจาก Dijkstra ด้วยการประมาณระยะที่เหลือ
- Johnson's algorithm ใช้ Bellman-Ford ปรับน้ำหนักให้ไม่ติดลบ แล้วรัน Dijkstra จากทุกโหนด

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1192")[Counting Rooms] (grid DFS)
- #link("https://cses.fi/problemset/task/1666")[Building Roads] (connected components)
- #link("https://cses.fi/problemset/task/1667")[Message Route] (BFS)
- #link("https://cses.fi/problemset/task/1668")[Building Teams] (bipartite)
- #link("https://cses.fi/problemset/task/1669")[Round Trip] (cycle)
- #link("https://cses.fi/problemset/task/1671")[Shortest Routes I] (Dijkstra)
- #link("https://cses.fi/problemset/task/1672")[Shortest Routes II] (Floyd-Warshall)
- #link("https://cses.fi/problemset/task/1197")[Cycle Finding] (Bellman-Ford)
- #link("https://cses.fi/problemset/task/1675")[Road Reparation] (MST)
- #link("https://cses.fi/problemset/task/1131")[Tree Diameter]
- #link("https://cses.fi/problemset/task/1688")[Company Queries II] (LCA)
- #link("https://cses.fi/problemset/task/1683")[Planets and Kingdoms] (SCC)

==== โจทย์จาก MWIT Grader

- Search: #link("https://grader.mwit.ac.th/problem/vance")[vance] (DFS จากทุกโหนด), #link("https://grader.mwit.ac.th/problem/toi17_wall")[toi17_wall] (DFS/BFS โจทย์ซับซ้อน), #link("https://grader.mwit.ac.th/problem/walking_bot_2")[walking_bot_2] (backtracking), #link("https://grader.mwit.ac.th/problem/snakeword")[snakeword] (branch and bound), #link("https://grader.mwit.ac.th/problem/teleport")[teleport] (ad-hoc)
- Dijkstra: #link("https://grader.mwit.ac.th/problem/turboprogramming")[turboprogramming] (ตรง ๆ), #link("https://grader.mwit.ac.th/problem/town")[town], #link("https://grader.mwit.ac.th/problem/followpeatt")[followpeatt] (มีเงื่อนไข), #link("https://grader.mwit.ac.th/problem/toi14_logistics")[toi14_logistics] (ซับซ้อนขึ้น)
- All-pairs: #link("https://grader.mwit.ac.th/problem/toi17_1221")[toi17_1221]
- MST: #link("https://grader.mwit.ac.th/problem/mst")[mst] (ตรงสุด ๆ)
- Tree challenge: #link("https://grader.mwit.ac.th/problem/toi12_weakpoint")[toi12_weakpoint] (one-cycle), #link("https://grader.mwit.ac.th/problem/toi14_technology")[toi14_technology]
- Connectivity challenge: #link("https://grader.mwit.ac.th/problem/walk_around")[walk_around] (union-find, reverse query)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
