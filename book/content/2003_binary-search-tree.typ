#import "@preview/ilm:1.4.0": *

== Binary Search Tree

=== Description

- Binary Search Tree เป็น binary tree ที่มีคุณสมบัติเพิ่มเติม
    - ทุกโหนดใน subtree ด้านซ้ายจะต้องมีค่าน้อยกว่า root
    - ทุกโหนดใน subtree ด้านขวาจะต้องมีค่ามากกว่า root
    - subtree ด้านซ้ายและด้านขวาจะต้องเป็น binary search tree

https://media.geeksforgeeks.org/wp-content/uploads/BSTSearch.png

=== Operations

- Search
- Insertion
- Traversal
    - Pre-order
    - In-order
    - Post-order

=== Example

```cpp
#include <cstdio>
#include <cstring>
int tree[1000];

int insert(int n, int p) {
  if (tree[p] == -1)
    return p;
  if (n < tree[p])
    return insert(n, p * 2 + 1);
  else
    return insert(n, p * 2 + 2);
}

void pre(int p) {
  if (tree[p] == -1)
    return;
  printf("%d\n", tree[p]);
  pre(p * 2 + 1);
  pre(p * 2 + 2);
}

void in(int p) {
  if (tree[p] == -1)
    return;
  in(p * 2 + 1);
  printf("%d\n", tree[p]);
  in(p * 2 + 2);
}

void pos(int p) {
  if (tree[p] == -1)
    return;
  pos(p * 2 + 1);
  pos(p * 2 + 2);
  printf("%d\n", tree[p]);
}

int main() {
  char a[5];
  scanf("%s", a);
  int x;
  scanf("%d", &x);
  int i;
  for (i = 0; i < 1000; i++)
    tree[i] = -1;
  while (x--) {
    int n;
    scanf("%d", &n);
    if (tree[0] == -1)
      tree[0] = n;
    else
      tree[insert(n, 0)] = n;
  }

  if (!strcmp(a, "PRE"))
    pre(0);
  if (!strcmp(a, "POS"))
    pos(0);
  if (!strcmp(a, "INF"))
    in(0);
  if (!strcmp(a, "BRF"))
    for (i = 0; i < 1000; i++)
      if (tree[i] != -1)
        printf("%d\n", tree[i]);
  return 0;
}
```
