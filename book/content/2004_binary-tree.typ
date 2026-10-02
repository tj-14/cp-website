#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Binary Tree

=== คำอธิบาย

*Tree* คือโครงสร้างข้อมูลแบบลำดับชั้น (hierarchical) ต่างจาก array, linked list, stack และ queue ที่เป็นเชิงเส้น
*Binary tree* คือ tree ที่แต่ละ node มีลูกได้ไม่เกินสองตัว เรียกว่า *left child* และ *right child*

#figure(
  image("../assets/diagrams/binary-tree.svg", width: 82%),
  caption: [Binary tree. Original diagram for this guide.],
)

=== คำศัพท์

```
       j        <-- root (depth 0)
     /   \
    f     k     <-- depth 1
   / \     \
  a   h     z   <-- leaves (depth 2)
```

- *root*: node บนสุด ไม่มี parent (`j`)
- *parent* / *child*: `f` เป็น parent ของ `a` และ `a` เป็น child ของ `f`
- *leaf*: node ที่ไม่มีลูก (`a`, `h`, `z`)
- *subtree*: node หนึ่งพร้อมลูกหลานทั้งหมดของมัน
- *depth* ของ node: จำนวน edge จาก root ถึง node นั้น
- *height* ของ tree: depth ที่มากที่สุด (tree ด้านบนสูง 2)

=== ชนิดของ binary tree

- *Full*: ทุก node มีลูก 0 หรือ 2 ตัว
- *Complete*: ทุกชั้นเต็มยกเว้นชั้นล่างสุดซึ่งเติมจากซ้ายไปขวา (เช่น heap)
- *Perfect*: ทุกชั้นเต็ม มี $2^(h+1) - 1$ node เมื่อสูง $h$
- *Balanced*: ความสูงเป็น $O(log n)$

=== เมื่อไรใช้ tree

- ข้อมูลที่มีลำดับชั้น เช่น ระบบไฟล์ ผังองค์กร
- เมื่อรวมกับการจัดเรียงบางอย่าง เช่น BST หรือ heap จะค้นหา เพิ่ม และลบได้ใน $O(log n)$
- โจทย์กราฟจำนวนมากเป็น tree (กราฟ connected ที่ไม่มี cycle)

=== การเก็บ binary tree

==== ด้วย pointer

```cpp
struct Node {
  int data;
  Node* left = nullptr;
  Node* right = nullptr;
};

Node* root = new Node{1};
root->left = new Node{2};
root->right = new Node{3};
root->left->left = new Node{4};
/*
        1
      /   \
     2     3
    /
   4
*/
```

==== ด้วย array ของลูก (นิยมในการแข่งขัน)

โจทย์มักให้ node เป็นหมายเลข $1..n$ พร้อมลูกซ้ายและขวา เก็บใน array ได้ทันที (0 = ไม่มีลูก)

```cpp
int L[N], R[N];  // L[u], R[u] = ลูกซ้าย/ขวาของ u
```

==== ด้วย index (สำหรับ complete tree)

ถ้าเป็น complete tree และเริ่ม index ที่ 1: ลูกของ $i$ คือ $2i$ และ $2i + 1$ และ parent คือ $floor(i / 2)$ ไม่ต้องเก็บ pointer เลย (ใช้ใน heap และ segment tree)

=== Traversal

การเยี่ยมทุก node มีสามแบบหลักตามจังหวะที่ประมวลผล node เทียบกับลูก

#table(
  columns: 3,
  header([ชื่อ], [ลำดับ], [ผลกับ tree ตัวอย่าง (1, 2, 3, 4) ด้านบน]),
  [Preorder], [node, ซ้าย, ขวา], [`1 2 4 3`],
  [Inorder], [ซ้าย, node, ขวา], [`4 2 1 3`],
  [Postorder], [ซ้าย, ขวา, node], [`4 2 3 1`],
  [Level order], [ทีละชั้น (BFS)], [`1 2 3 4`],
)

```cpp
void preorder(Node* t) {
  if (t == nullptr) return;
  cout << t->data << ' ';
  preorder(t->left);
  preorder(t->right);
}
// inorder และ postorder สลับตำแหน่งบรรทัด cout
```

ลองดู traversal ทั้งสี่แบบทีละ node ได้ใน widget ของบท Binary Search Tree

=== คำนวณค่าด้วย recursion

หลายคำถามเกี่ยวกับ tree ตอบได้จากคำตอบของ subtree ซ้ายและขวา

```cpp
int size(Node* t) {    // จำนวน node
  if (t == nullptr) return 0;
  return 1 + size(t->left) + size(t->right);
}

int height(Node* t) {  // ความสูง (tree ว่าง = -1, node เดียว = 0)
  if (t == nullptr) return -1;
  return 1 + max(height(t->left), height(t->right));
}
```

ทั้งสองฟังก์ชันเยี่ยมทุก node ครั้งเดียว จึงเป็น $O(n)$

=== Tree ทั่วไป (ลูกกี่ตัวก็ได้)

ในโจทย์ส่วนใหญ่ tree ไม่จำกัดจำนวนลูก ให้เก็บแบบ adjacency list เหมือนกราฟ แล้ว DFS โดยจำ parent ไว้เพื่อไม่เดินย้อนกลับ

```cpp
vector<int> children[N];
int sub[N];  // sub[u] = จำนวน node ใน subtree ของ u

void dfs(int u) {
  sub[u] = 1;
  for (int v : children[u]) {
    dfs(v);
    sub[u] += sub[v];
  }
}
```

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1674")[Subordinates] (ขนาด subtree)
- #link("https://cses.fi/problemset/task/1131")[Tree Diameter]
- #link("https://cses.fi/problemset/task/1132")[Tree Distances I]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
