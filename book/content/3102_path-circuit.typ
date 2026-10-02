#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Paths and circuits

=== Eulerian

Eulerian path และ Hamiltonian path เป็นโจทย์ที่ดูคล้ายกันมาก แต่เงื่อนไขต่างกันและความยากต่างกันมาก

- Eulerian สนใจการเดินผ่านทุก edge
- Hamiltonian สนใจการเดินผ่านทุก vertex

==== Path

เป็น path ที่ท่องไปในเส้นเชื่อมทุกเส้นเพียงหนึ่งครั้งเท่านั้น

==== Circuit

เป็น Eulerian path ที่เริ่มและจบที่โหนดเดียวกัน

==== Existence

เงื่อนไขแรกเสมอ: ทุก edge ต้องอยู่ใน *component เดียวกัน* (โหนดที่ไม่มี edge เลยไม่นับ) จากนั้น

- กราฟไม่มีทิศทาง
    - Eulerian circuit: ดีกรีของทุกโหนดเป็นจำนวนคู่
    - Eulerian path: มีโหนดดีกรีคี่ 0 หรือ 2 โหนด ถ้ามี 2 โหนด path ต้องเริ่มที่โหนดหนึ่งและจบที่อีกโหนด
- กราฟมีทิศทาง
    - Eulerian circuit: ทุกโหนดมีดีกรีเข้าเท่ากับดีกรีออก
    - Eulerian path: มีโหนดเริ่มที่ดีกรีออกมากกว่าดีกรีเข้า 1 โหนดจบที่ดีกรีเข้ามากกว่าดีกรีออก 1 และโหนดที่เหลือดีกรีเข้าเท่ากับดีกรีออก

*ทำไมต้องเป็นดีกรีคู่*: ทุกครั้งที่ path ผ่านโหนดกลางทาง จะใช้ edge สองเส้น (เข้าหนึ่ง ออกหนึ่ง) โหนดกลางทางจึงใช้ edge เป็นจำนวนคู่เสมอ มีแค่โหนดเริ่มและโหนดจบเท่านั้นที่ใช้ edge เป็นจำนวนคี่ได้

==== Hierholzer’s algorithm

Hierholzer's algorithm ใช้หา Eulerian circuit/path เมื่อรู้แล้วว่าเงื่อนไขมีคำตอบ

แนวคิดคือเดินตาม edge ที่ยังไม่ใช้ไปเรื่อย ๆ ถ้าติดทางตันให้ย้อนกลับและใส่ vertex ลงคำตอบตอนย้อนกลับ

สำหรับกราฟไม่มีทิศทาง edge หนึ่งเส้นอยู่ใน adjacency list ของปลายทั้งสอง จึงเก็บ *id* ของ edge และทำเครื่องหมายว่าใช้แล้ว เพื่อไม่เดิน edge เดิมซ้ำจากอีกฝั่ง

```cpp
vector<vector<pair<int, int>>> adj;  // {เพื่อนบ้าน, id ของ edge}
vector<bool> used;                   // used[id]
vector<int> ptr, path;               // ptr[u] = edge ถัดไปที่ต้องลองของ u

void dfs(int u) {
  while (ptr[u] < (int)adj[u].size()) {
    auto [v, id] = adj[u][ptr[u]++];
    if (used[id]) continue;
    used[id] = true;
    dfs(v);
  }
  path.push_back(u);  // ใส่ตอนออก: path ที่ได้เรียงกลับด้าน
}
// เรียก dfs(start) โดย start เป็นโหนดดีกรีคี่ (ถ้ามี) แล้ว path.size() ต้องเท่ากับ m + 1
// ถ้าน้อยกว่าแปลว่าบาง edge อยู่คนละ component จึงไม่มีคำตอบ
```

ใช้ `ptr[u]` เพื่อไม่ต้องไล่ edge ที่ใช้แล้วซ้ำ เวลาทำงานจึงเป็น $O(V + E)$

=== Hamiltonian

เป็น path ที่ท่องไปในทุกโหนดเพียงหนึ่งครั้งเท่านั้น

==== Existence

ยังไม่มีใครรู้วิธีที่เร็ว (เป็นปัญหา NP-complete) แต่ถ้า $n <= 20$ ใช้ bitmask DP ได้: `dp[mask][v]` = จำนวนวิธีเดินผ่านโหนดในเซต `mask` ครบพอดีและจบที่ `v`

```cpp
// dp[1 << 0][0] = 1 (เริ่มที่โหนด 0)
for (int mask = 1; mask < (1 << n); mask++) {
  for (int v = 0; v < n; v++) {
    if (!dp[mask][v]) continue;
    for (int w : adj[v]) {
      if (mask & (1 << w)) continue;  // ไปแล้ว
      dp[mask | (1 << w)][w] = (dp[mask | (1 << w)][w] + dp[mask][v]) % MOD;
    }
  }
}
// คำตอบสำหรับ path ที่ผ่านทุกโหนดและจบที่ t: dp[(1 << n) - 1][t]
```

เวลา $O(2^n n^2)$ (หรือ $O(2^n (n + m))$ เมื่อใช้ adjacency list)

=== เปรียบเทียบ

#table(
  columns: 4,
  header([ชนิด], [ต้องผ่าน], [ตรวจเงื่อนไขเร็วไหม], [วิธีที่ใช้บ่อย]),
  [Eulerian path], [ทุก edge หนึ่งครั้ง], [เร็ว], [degree + Hierholzer],
  [Eulerian circuit], [ทุก edge หนึ่งครั้งและกลับจุดเริ่ม], [เร็ว], [degree + Hierholzer],
  [Hamiltonian path], [ทุก vertex หนึ่งครั้ง], [โดยทั่วไปยาก], [backtracking หรือ DP bitmask],
)

=== ตัวอย่างโจทย์

- ถ้าโจทย์พูดถึงการใช้ถนนทุกเส้นหนึ่งครั้ง ให้นึกถึง Eulerian
- ถ้าโจทย์พูดถึงการเยี่ยมเมืองทุกเมืองหนึ่งครั้ง ให้นึกถึง Hamiltonian
- ถ้ากราฟมีขนาดเล็กมาก เช่น $n <= 20$ Hamiltonian อาจใช้ DP bitmask ได้

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1691")[Mail Delivery] (Eulerian circuit)
- #link("https://cses.fi/problemset/task/1693")[Teleporters Path] (Eulerian path, directed)
- #link("https://cses.fi/problemset/task/1692")[De Bruijn Sequence]
- #link("https://cses.fi/problemset/task/1690")[Hamiltonian Flights] (bitmask DP)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
