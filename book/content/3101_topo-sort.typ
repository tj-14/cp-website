#import "@preview/ilm:1.4.0": *

== Topological sorting (implementation)

DAG - Directed Acyclic Graph

// <img src="/assets/competitive-programming-starter/graph-algorithm/topo-sort/Untitled.png" width="500px"/>
// <img src="/assets/competitive-programming-starter/graph-algorithm/topo-sort/Untitled 1.png" width="500px"/>

https://cp-algorithms.com/graph/topological-sort.html

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

- https://grader.mwit.ac.th/problem/toi14_technology
