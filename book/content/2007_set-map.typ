#import "@preview/ilm:1.4.0": *

== Set & Map

=== คำอธิบาย

`set` และ `map` ใน STL นั้นมีความคล้ายกันในแง่ที่ทั้งคู่ใช้โครงสร้างข้อมูล Red Black Tree (self balancing BST ประเภทหนึ่ง) โดยใช้เวลาในการ search, insert และ delete เพียง $O(log n)$

=== ข้อแตกต่าง

- `set` ใช้เก็บ keys แต่ `map` ใช้เก็บคู่ key-value
- ตัวอย่างเช่น หากเราต้องการแสดงค่าสมาชิกที่แตกต่างกันเท่านั้น เราสามารถใช้ set ได้เนื่องจากต้องการเก็บแค่ key
- แต่ถ้าหากเราต้องการเก็บความถี่ของแต่ละสมาชิกด้วย เราควรใช้ map เพื่อเก็บ key ตามสมาชิกโดย value เป็นความถี่

=== Set example

```cpp
// CPP program to demonstrate working of set
#include <bits/stdc++.h> 
using namespace std; 

int main() { 
  set<int> s1; 
  // self-balancing binary search tree
  // binary search tree ที่มีความสูงไม่เกิน O(log n) เสมอ
  s1.insert(2); // log(n)
  s1.insert(10);
  s1.insert(5); 
  s1.insert(3); 
  s1.insert(6); 

  cout << "Elements in set:\n"; 
  for (auto it : s1) 
    cout << it << " "; // Sorted 

  return 0; 
}
```

output

```
Elements in set:
2 3 5 6
```

=== Map example

```cpp
// CPP program to demonstrate working of map
#include <bits/stdc++.h>
using namespace std;

int main() {
  map<int, int> m;
  // คล้ายๆ dictionary ในภาษา python
  // โครงสร้างเดียวกับ set ก็คือ self-balancing binary search tree

  m[1] = 2; // Insertion by indexing

  // Insertion of pair by make_pair
  m.insert(make_pair(8, 5));

  cout << "Elements in m:\n";
  for (auto it : m)
    cout << "[ " << it.first << ", " << it.second << "]\n"; // Sorted

  map<string, int> m2;
  m2["tt"] = 5; // log(n)
  m2["aw"] = 2399;

  cout << "Elements in m2:\n";
  for (auto it : m2)
    cout << "[ " << it.first << ", " << it.second << "]\n"; // Sorted

  return 0;
}
```

output
```
Elements in m:
[ 1, 2]
[ 8, 5]
Elements in m2:
[ aw, 2399]
[ tt, 5]
```
