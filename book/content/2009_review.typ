#import "@preview/ilm:1.4.0": *
#import table: cell, header
#import "widgets.typ": widget

== ทบทวนโครงสร้างข้อมูล

บทนี้สรุปโครงสร้างข้อมูลทั้งหมดของค่าย 2 ในที่เดียว หัวใจของการเลือกใช้คือถามว่า *โจทย์ต้องทำ operation อะไรบ่อยที่สุด* แล้วเลือกโครงสร้างที่ทำ operation นั้นได้เร็ว

=== สรุปความเร็ว

#table(
  columns: 5,
  header([โครงสร้าง], [STL], [เพิ่ม], [ลบ], [ค้นหา / ดูค่า]),
  [Dynamic array], [`vector`], [ท้าย $O(1)$\*], [ท้าย $O(1)$, กลาง $O(n)$], [ตัวที่ $i$: $O(1)$, หาค่า: $O(n)$],
  [Linked list], [`list`], [$O(1)$ เมื่อรู้ตำแหน่ง], [$O(1)$ เมื่อรู้ตำแหน่ง], [$O(n)$],
  [Stack], [`stack`], [บนสุด $O(1)$], [บนสุด $O(1)$], [บนสุด $O(1)$],
  [Queue], [`queue`], [ท้าย $O(1)$], [หน้า $O(1)$], [หน้า/ท้าย $O(1)$],
  [Deque], [`deque`], [หัว/ท้าย $O(1)$], [หัว/ท้าย $O(1)$], [ตัวที่ $i$: $O(1)$],
  [Heap], [`priority_queue`], [$O(log n)$], [ค่าสูงสุด $O(log n)$], [ค่าสูงสุด $O(1)$],
  [Balanced BST], [`set`, `map`], [$O(log n)$], [$O(log n)$], [$O(log n)$, มี `lower_bound`],
  [Hash table], [`unordered_set`, `unordered_map`], [เฉลี่ย $O(1)$], [เฉลี่ย $O(1)$], [เฉลี่ย $O(1)$, ไม่เรียงลำดับ],
)

\* amortized: เฉลี่ยต่อครั้ง ดูบท Dynamic Array

=== เลือกใช้อะไรดี

- ต้องการ *ลำดับการเข้า-ออก*: ล่าสุดออกก่อนใช้ stack, มาก่อนออกก่อนใช้ queue, ทั้งสองด้านใช้ deque
- ต้องการ *ค่ามากสุดหรือน้อยสุด* ซ้ำ ๆ ขณะที่ข้อมูลเปลี่ยน: priority queue
- ต้องการ *ค่าที่ใกล้ $x$ ที่สุด* หรือข้อมูลเรียงลำดับตลอดเวลา: set หรือ map
- ต้องการแค่ *มีหรือไม่มี* หรือนับความถี่โดยไม่สนลำดับ: unordered_set หรือ unordered_map (หรือ array ถ้าค่าอยู่ในช่วงเล็ก)
- ข้อมูลไม่เปลี่ยนและต้อง *ตอบคำถามช่วง*: prefix sum (บท Array Manipulation)
- ข้อมูลเป็น *ความสัมพันธ์* ระหว่างสิ่งของ: กราฟ หรือ tree

=== แบบทดสอบ

ลองเลือกโครงสร้างข้อมูลที่เหมาะกับแต่ละสถานการณ์ แต่ละข้อมีคำอธิบายหลังตอบ

#widget("ds-quiz")

=== โจทย์ฝึกฝน (Practice Problems)

โจทย์ชุดนี้ต้องเลือกโครงสร้างข้อมูลเอง ลองคิดก่อนว่าต้องใช้ operation อะไรบ่อยที่สุด

- #link("https://cses.fi/problemset/task/1640")[Sum of Two Values]
- #link("https://cses.fi/problemset/task/1091")[Concert Tickets]
- #link("https://cses.fi/problemset/task/1164")[Room Allocation]
- #link("https://cses.fi/problemset/task/1192")[Counting Rooms]
- #link("https://cses.fi/problemset/task/1074")[Stick Lengths]

โจทย์เพิ่มเติม: #link("https://cses.fi/problemset/")[CSES Problem Set] และ #link("https://programming.in.th/")[programming.in.th]
