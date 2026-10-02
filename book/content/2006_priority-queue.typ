#import "@preview/ilm:1.4.0": *
#import table: cell, header

== Priority Queue

=== คำอธิบาย

- Priority queue คล้าย queue แต่สมาชิกแต่ละตัวมี *priority* และตัวที่ priority สูงสุดจะถูกนำออกก่อนเสมอ ไม่ว่าจะเข้ามาเมื่อไร
- ถ้า priority เท่ากัน `priority_queue` ของ STL *ไม่รับประกัน* ว่าตัวไหนออกก่อน ถ้าลำดับสำคัญให้ใส่ค่าที่ใช้ตัดสินเพิ่ม เช่น เก็บ pair ของ (priority, ลำดับที่เข้า)

#figure(
  image("../assets/diagrams/priority-queue.svg", width: 86%),
  caption: [Priority queue removes the highest-priority item first. Original diagram for this guide.],
)

=== Operations

- `insert(item, priority)`: เพิ่มสมาชิกพร้อมระบุ priority
- `getHighestPriority()`: คืนค่าสมาชิกที่มี priority สูงสุด
- `deleteHighestPriority()`: นำออกสมาชิกที่มี priority สูงสุด

=== Implementation

- ภายในคือ *heap* (ดูวิธีทำงานทีละขั้นได้ใน widget ของบท Heap) ทุก operation จึงเป็น $O(log n)$
- ในการแข่งขันใช้ `priority_queue` ของ STL ได้เลย

โดยปกติ `priority_queue<int>` ใน C++ เป็น max-heap คือค่ามากที่สุดอยู่ด้านบน ถ้าต้องการ min-heap ให้ใช้ `greater<int>`

#table(
  columns: 3,
  header([operation], [STL], [time complexity]),
  [เพิ่มข้อมูล], [`push`], [$O(log n)$],
  [ดูค่าบนสุด], [`top`], [$O(1)$],
  [ลบค่าบนสุด], [`pop`], [$O(log n)$],
  [จำนวนสมาชิก], [`size`], [$O(1)$],
)

=== ตัวอย่าง (STL)

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  priority_queue<int, vector<int>, greater<int>> q;
  q.push(3);
  q.push(2);
  q.push(15);
  q.push(5);
  q.push(4);
  q.push(45);
  printf("top %d\n", q.top());
  q.pop();
  printf("top %d\n", q.top());
  q.pop();
  printf("top %d\n", q.top());
  return 0;
}
```

ตัวอย่างด้านบนเป็น min-heap เพราะใช้ `greater<int>` ดังนั้น `top()` จะคืนค่าที่น้อยที่สุด ได้ผลลัพธ์

```
top 2
top 3
top 4
```

=== เรียงตามเงื่อนไขเอง

ถ้าต้องการให้ priority มาจากหลายค่า ให้เก็บเป็น pair หรือ tuple ที่เรียงตามที่ต้องการ หรือเขียนตัวเปรียบเทียบเอง
ระวังว่าตัวเปรียบเทียบของ `priority_queue` *กลับด้าน* จาก `sort`: คืน `true` เมื่อ `a` มี priority *ต่ำกว่า* `b`

```cpp
struct Task {
  int deadline, id;
};

struct ByDeadline {
  bool operator()(const Task& a, const Task& b) const {
    return a.deadline > b.deadline;  // deadline มากกว่า = priority ต่ำกว่า
  }
};

priority_queue<Task, vector<Task>, ByDeadline> pq;  // ดึงงานที่ deadline ใกล้สุดก่อน
```

=== ใช้กับ pair

ในการเขียน Dijkstra มักเก็บ pair เป็น `(distance, vertex)` และใช้ min-heap

```cpp
priority_queue<
  pair<int, int>,
  vector<pair<int, int>>,
  greater<pair<int, int>>
> pq;

pq.push({0, start});
```

เมื่อใช้ pair การเปรียบเทียบจะดูสมาชิกตัวแรกก่อน ถ้าเท่ากันจึงดูสมาชิกตัวที่สอง

=== ข้อควรระวัง

- `priority_queue` ไม่มี operation ลบค่าที่อยู่กลาง heap
- ถ้าข้อมูลที่อยู่ใน queue เก่าแล้ว ให้ใช้วิธี lazy deletion เช่น pop ทิ้งเมื่อพบว่าไม่ตรงกับ distance ปัจจุบัน
- ถ้าต้องการเรียงข้อมูลทั้งหมด ใช้ `sort` ง่ายกว่า
- ถ้าต้องการดึงค่าน้อยสุดและลบค่าใดก็ได้ อาจใช้ `set` หรือ `multiset` แทน

=== โจทย์ฝึกฝน (Practice Problems)

ลองทำโจทย์เหล่านี้จาก CSES Problem Set เพื่อฝึกใช้ทักษะจากบทนี้ โดยเริ่มจากโจทย์ที่ง่ายที่สุดก่อน

- #link("https://cses.fi/problemset/task/1164")[Room Allocation]
- #link("https://cses.fi/problemset/task/1671")[Shortest Routes I] (Dijkstra)
- #link("https://cses.fi/problemset/task/1076")[Sliding Window Median] (ท้าทาย)

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
