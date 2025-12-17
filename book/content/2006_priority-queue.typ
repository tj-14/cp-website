#import "@preview/ilm:1.4.0": *

== Priority Queue

=== คำอธิบาย

- Priority Queue เป็นส่วนเสริมของ queue โดยเพิ่มคุณสมบัติดังนี้
    - ทุก ๆ สมาชิกจะมี priority ของตนเอง
    - สมาชิกที่มี priority สูงสุดจะถูก dequeue ก่อนสมาชิกที่มี priority ต่ำกว่า
    - หากมีสมาชิกที่ priority เท่ากัน จะถูกนำออกตามลำดับเข้าของ queue
- ใน priority queue ด้านล่าง สมาชิกที่มีค่า ASCII มากจะมี priority สูง

https://media.geeksforgeeks.org/wp-content/cdn-uploads/Priority-Queue-min-1024x512.png

=== Operations

- `insert(item, priority)`: เพิ่มสมาชิกพร้อมระบุ priority
- `getHighestPriority()`: คืนค่าสมาชิกที่มี priority สูงสุด
- `deleteHighestPriority()`: นำออกสมาชิกที่มี priority สูงสุด

=== Implementation

- Heap: สามารถใช้ heap ในการสร้าง priority queue ได้
- STL: ใน STL นั้นมี priority_queue ให้ใช้ได้เลย

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
