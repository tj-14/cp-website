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

เงื่อนไขที่จะมี Eulerian path สำหรับ

- กราฟไม่มีทิศทาง
    - ดีกรีของทุกโหนดเป็นจำนวนคู่ หรือ
    - ดีกรีของสองโหนดเป็นจำนวนคี่ (🧠 เพราะอะไร?)
- กราฟมีทิศทาง
    - ในแต่ละโหนด ดีกรีเข้าจะต้องเท่ากับดีกรีออก หรือ
    - มีโหนดหนึ่งมีดีกรีเข้ามากกว่าดีกรีออกเท่ากับหนึ่ง อีกโหนดหนึ่งมีดีกรีออกมากกว่าดีกรีเข้าเท่ากับหนึ่ง และโหนดที่เหลือมีดีกรีเข้่าเท่ากับดีกรีออก

==== Hierholzer’s algorithm

Hierholzer's algorithm ใช้หา Eulerian circuit/path เมื่อรู้แล้วว่าเงื่อนไขมีคำตอบ

แนวคิดคือเดินตาม edge ที่ยังไม่ใช้ไปเรื่อย ๆ ถ้าติดทางตันให้ย้อนกลับและใส่ vertex ลงคำตอบตอนย้อนกลับ

```cpp
vector<vector<int>> adj;
vector<int> path;

void dfs(int u) {
  while (!adj[u].empty()) {
    int v = adj[u].back();
    adj[u].pop_back();
    dfs(v);
  }
  path.push_back(u);
}
```

สำหรับกราฟไม่มีทิศทาง ต้องลบ edge ทั้งสองด้าน และควรมี id ของ edge เพื่อไม่ใช้ edge เดิมซ้ำ

เวลาทำงานคือ $O(V+E)$ ถ้าลบ edge ได้มีประสิทธิภาพ

=== Hamiltonian

เป็น path ที่ท่องไปในทุกโหนดเพียงหนึ่งครั้งเท่านั้น

==== Existence

ไม่มี efficient method เนื่องจากยังเป็นปัญหาประเภท NP-hard

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
