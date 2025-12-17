#import "@preview/ilm:1.4.0": *

== Graph Algorithm

=== Search in Graph

- Depth-First Search
    - https://grader.mwit.ac.th/problem/vance dfs from all node
- Breadth-First Search
    - https://grader.mwit.ac.th/problem/toi17_wall dfs/bfs โจทย์ซับซ้อน
- Backtracking
    - เป็นการเก็บคำตอบย้อนหลัง หลังจากที่เข้าเงื่อนไขบางอย่างแล้ว
    - https://grader.mwit.ac.th/problem/walking_bot_2
- Branch and Bound (implementation)
    - https://grader.mwit.ac.th/problem/snakeword
- Challenge
    - https://grader.mwit.ac.th/problem/teleport ad-hoc, implementation
- Eulerian
- Hamiltonian

== Graph Applications

=== Colorings

สามารถใช้การ search ต่าง ๆ เช่น dfs ในการระบายสีโหนดได้

ปัญหาการระบายสีโหนดให้โหนดที่ติดกันมีสีต่างกันเสมอเป็นปัญหาที่พบเจอได้บ่อยในสาขาคอมพิวเตอร์

=== Connectivity check

DFS แล้วเช็คว่า visit ครบทุกโหนดหรือไม่

=== Finding cycles

https://visualgo.net/en/cyclefinding?slide=1

ถ้า component มี $c$ โหนด และไม่มี cycle เลยแล้ว component นั้นจะต้องมีเส้นเชื่อมทั้งหมด $c-1$ เส้น และเป็นกราฟต้นไม้

=== Bipartiteness check

กราฟ bipartite  เป็นกราฟเมื่อสามารถใช้สีสองสีในการระบายสีโหนดโดยทุกโหนดที่ติดกันต้องมีสีที่แตกต่างกัน

https://cp-algorithms.com/graph/bipartite-check.html

== Weighted Shortest Path

https://visualgo.net/en/sssp?slide=1

=== Dijkstra’s Algorithm (implementation)

https://cp-algorithms.com/graph/dijkstra.html

```cpp
const int INF = 1000000000;
vector<vector<pair<int, int>>> adj;

void dijkstra(int s, vector<int> & d, vector<int> & p) {
    int n = adj.size();
    d.assign(n, INF);
    p.assign(n, -1);
    vector<bool> u(n, false);

    d[s] = 0;
    for (int i = 0; i < n; i++) {
        int v = -1;
        for (int j = 0; j < n; j++) {
            if (!u[j] && (v == -1 || d[j] < d[v]))
                v = j;
        }

        if (d[v] == INF)
            break;

        u[v] = true;
        for (auto edge : adj[v]) {
            int to = edge.first;
            int len = edge.second;

            if (d[v] + len < d[to]) {
                d[to] = d[v] + len;
                p[to] = v;
            }
        }
    }
}
```

- https://grader.mwit.ac.th/problem/turboprogramming
    dijkstra ตรงๆ

    ```cpp
    // credit Mok MWIT29
    #include <bits/stdc++.h>
    #define ii pair<int, int>
    using namespace std;
    vector<ii> adj[100100];
    int dist[100100];
    int main() {
      int N, M, Q;
      scanf("%d %d %d", &N, &M, &Q);
      for (int i = 1, u, v, w; i <= M; i++) {
        scanf("%d %d %d", &u, &v, &w);
        adj[u].push_back(make_pair(v, w));
        // adj[v].push_back(make_pair(u, w));
      }
      for (int i = 1; i <= N; i++)
        dist[i] = INT_MAX;
      priority_queue<ii, vector<ii>, greater<ii>> pq;
      dist[1] = 0;
      pq.push(make_pair(0, 1));
      while (!pq.empty()) {
        int d = pq.top().first;
        int n = pq.top().second;
        pq.pop();
        for (auto x : adj[n]) {
          if (dist[x.first] > d + x.second) {
            dist[x.first] = d + x.second;
            pq.push(make_pair(d + x.second, x.first));
          }
        }
      }
      while (Q--) {
        int a;
        scanf("%d", &a);
        if (dist[a] == INT_MAX)
          printf("-1\n");
        else
          printf("%d\n", dist[a]);
      }
    }
    ```
- https://grader.mwit.ac.th/problem/town
    dijkstra ไม่ตรงมาก
- https://grader.mwit.ac.th/problem/followpeatt
    dijkstra แบบมีเงื่อนไข
- https://grader.mwit.ac.th/problem/toi14_logistics
    dijkstra ซับซ้อนขึ้น

=== Bellman-Ford

- Negative cycles

```cpp
// credit from https://github.com/Autoratch/practice
#include <bits/stdc++.h>
using namespace std;

int n, m, s, e;
vector<pair<int, pair<int, int>>> adj;
vector<int> dist;

int main() {
  ios_base::sync_with_stdio(0);
  cin.tie(0);

  cin >> n >> m >> s >> e;

  adj.resize(m);
  dist.assign(n, INT_MAX);

  for (int i = 0; i < m; i++) {
    int a, b, d;
    cin >> a >> b >> d;
    adj[i] = {d, {a, b}};
  }

  dist[0] = 0;
  for (int i = 0; i < n - 1; i++)
    for (int j = 0; j < m; j++) {
      int a = adj[i].second.first, b = adj[i].second.second, d = adj[i].first;
      if (dist[a] != INT_MAX and dist[a] + d < dist[b])
        dist[b] = dist[a] + d;
    }

  cout << dist[e];
}
```

=== Floyd-Warshall (implementation)

https://cp-algorithms.com/graph/all-pair-shortest-path-floyd-warshall.html

```cpp
for (int k = 0; k < n; ++k) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            d[i][j] = min(d[i][j], d[i][k] + d[k][j]); 
        }
    }
}
```

- https://grader.mwit.ac.th/problem/toi17_1221
    all-pair

=== Johnson (exist)

=== A\* Search

https://www.redblobgames.com/pathfinding/a-star/introduction.html

== Minimum Spanning Tree

https://visualgo.net/en/mst?slide=1

=== Kruskal’s (implementation)

- Union-find

```cpp
// credit from https://github.com/Autoratch/practice
#include <bits/stdc++.h>
using namespace std;
#define endl '\n'
#define MOD 1e9 + 7
#define pii pair<int, pair<int, int>>

int n, m;
vector<int> pa;
priority_queue<pii, vector<pii>, greater<pii>> q;

int root(int x) {
  if (pa[x] == x)
    return x;
  else
    return pa[x] = root(pa[x]);
}

int kruskal() {
  int ans = 0;

  pa.resize(n);
  for (int i = 0; i < n; i++)
    pa[i] = i;

  while (!q.empty()) {
    int w = q.top().first, x = q.top().second.first, y = q.top().second.second;
    q.pop();
    if (root(x) == root(y))
      continue;
    ans += w;
    pa[root(x)] = pa[root(y)];
  }

  return ans;
}

int main() {
  ios_base::sync_with_stdio(0);
  cin.tie(0);

  cin >> n >> m;

  for (int i = 0; i < m; i++) {
    int a, b, d;
    cin >> a >> b >> d;
    q.push({d, {a, b}});
  }

  cout << kruskal();
}
```

- https://grader.mwit.ac.th/problem/mst ตรงสุด ๆ

=== Prim’s

```cpp
// credit from https://github.com/Autoratch/practice
#include <bits/stdc++.h>
using namespace std;
#define endl '\n'
#define MOD 1e9 + 7

int n, m, ans;
vector<bool> visited;
vector<vector<pair<int, int>>> adj;
priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>>
    q;

int main() {
  ios_base::sync_with_stdio(0);
  cin.tie(0);

  cin >> n >> m;

  adj.resize(n);
  visited.resize(n);

  for (int i = 0; i < m; i++) {
    int a, b, d;
    cin >> a >> b >> d;
    adj[a].push_back({d, b});
    adj[b].push_back({d, a});
  }

  q.push({0, 0});

  while (!q.empty()) {
    int w = q.top().first, p = q.top().second;
    q.pop();
    if (visited[p])
      continue;
    visited[p] = true;
    ans += w;
    for (int i = 0; i < adj[p].size(); i++)
      if (!visited[adj[p][i].second])
        q.push(adj[p][i]);
  }

  cout << ans;
}
```

== Tree algorithms

=== Diameter

- Algorithm 1
    - ดึง node มั่ว ๆ มาเป็น root
    - หา path ยาวสุดของแต่ละลูก แล้วหาเส้นผ่านศูนย์กลาง

// <img src="/assets/competitive-programming-starter/graph-algorithm/tree-algorithm/Untitled.png"/>

- Algorithm 2
    - เลือกโหนดมั่ว ๆ เป็นโหนด a
    - หาโหนดที่อยู่ไกลที่สุดจากโหนด a เป็นโหนด b
    - หาโหนดที่อยู่ไกลที่สุดจากโหนด b เป็นโหนด c
    - จะได้เส้นผ่านศูนย์กลางคือเส้นทางจาก b ไป c
    
// <img src="/assets/competitive-programming-starter/graph-algorithm/tree-algorithm/Untitled 1.png"/>

=== Lowest common ancestor (implementation)

```cpp
// credit from https://github.com/Autoratch/practice
#include <bits/stdc++.h>
using namespace std;

const int N = 1e5 + 1;

int n, q;
int dp[21][N], lv[N];
vector<int> adj[N];

void dfs(int u, int p, int l) {
  dp[0][u] = p, lv[u] = l;
  for (int v : adj[u])
    dfs(v, u, l + 1);
}

int lca(int a, int b) {
  if (lv[a] < lv[b])
    swap(a, b);
  for (int i = 20; i >= 0; i--)
    if (lv[dp[i][a]] >= lv[b])
      a = dp[i][a];
  if (a == b)
    return a;
  for (int i = 20; i >= 0; i--)
    if (dp[i][a] != dp[i][b])
      a = dp[i][a], b = dp[i][b];
  return dp[0][a];
}

int main() {
  ios_base::sync_with_stdio(0);
  cin.tie(0);

  cin >> n;

  for (int i = 0; i < n - 1; i++) {
    int a, b;
    cin >> a >> b;
    adj[a].push_back(b);
  }

  dfs(0, 0, 1);

  for (int i = 1; i <= 20; i++)
    for (int j = 1; j <= n; j++)
      dp[i][j] = dp[i - 1][dp[i - 1][j]];

  cin >> q;

  while (q--) {
    int a, b;
    cin >> a >> b;
    cout << lca(a, b) << '\n';
  }
}
```

=== Euler Tour Technique

https://usaco.guide/gold/tree-euler?lang=cpp
https://cses.fi/problemset/task/1137

=== Challenge

- https://grader.mwit.ac.th/problem/toi12_weakpoint one-cycle, dp?
- https://grader.mwit.ac.th/problem/toi14_technology

== Strong connectivity

https://cp-algorithms.com/graph/strongly-connected-components.html

=== Kosaraju’s

```cpp
// credit from https://github.com/Autoratch/practice
#include <bits/stdc++.h>
using namespace std;

const int N = 1e5 + 1;

int n, m;
vector<int> adj[N], rev[N];
stack<int> st;
bool visited[N];

void dfs(int u) {
  if (visited[u])
    return;
  visited[u] = true;
  for (int v : adj[u])
    dfs(v);
  st.push(u);
}

void scc(int u) {
  if (visited[u])
    return;
  visited[u] = true;
  cout << u << ' ';
  for (int v : rev[u])
    scc(v);
}

int main() {
  ios_base::sync_with_stdio(0);
  cin.tie(0);

  cin >> n >> m;

  for (int i = 0; i < m; i++) {
    int a, b;
    cin >> a >> b;
    adj[a].push_back(b);
    rev[b].push_back(a);
  }

  for (int i = 1; i <= n; i++)
    if (!visited[i])
      dfs(i);

  memset(visited, 0, sizeof visited);

  while (!st.empty()) {
    int u = st.top();
    st.pop();
    if (visited[u])
      continue;
    scc(u);
    cout << '\n';
  }
}
```

=== Challenge
- https://grader.mwit.ac.th/problem/walk_around cycle, union find, reverse query

=== เพิ่มเติม

- ตะลุยโจทย์ Graph ระดับโหดใน Competitive Programming (aquablitz11) #footnote[http://tcpc.me/2019/08/19/state-graph-tutorial.html]
