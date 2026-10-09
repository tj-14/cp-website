#import "@preview/ilm:1.4.0": *

== โครงสร้างเนื้อหาการสอน

เนื้อหาไล่ระดับตามที่ใช้สอนในค่าย สอวน. ค่าย 1, ค่าย 2, ผู้แทนศูนย์ และ สสวท. โดยแต่ละช่วงมีเป้าหมายดังนี้

=== ค่าย 1: พื้นฐานการเขียนโปรแกรม

ปูพื้นฐานภาษา C++ ให้ compile ได้และถ่ายทอดความคิดออกมาเป็นโปรแกรมที่ทำงานได้จริง

- โครงสร้างโปรแกรม ตัวแปร input/output, if-else และ loop
- array, string และ STL พื้นฐาน เช่น `vector`, `sort`
- function และการส่งค่า
- recursion และ complete search

=== ค่าย 2: โครงสร้างข้อมูลและการวิเคราะห์

ก้าวสู่การเขียนโปรแกรมเชิงแข่งขัน เน้นการวิเคราะห์ความเร็วของอัลกอริทึมและเลือกโครงสร้างข้อมูลให้เหมาะกับโจทย์

- time complexity และ Big O notation
- stack, queue, linked list, dynamic array
- tree, heap, priority queue, binary search tree, set, map, hash table
- การแทนกราฟ

=== ระดับสูงขึ้น: อัลกอริทึม

เทคนิคที่ใช้ในการแข่งขันระดับผู้แทนศูนย์และ TOI

- greedy, prefix sum และ data structure สำหรับช่วงข้อมูล
- search, divide and conquer และ binary search
- dynamic programming
- graph algorithms: BFS/DFS, shortest path, MST, topological sort และอื่น ๆ

=== ค่าย สสวท.: IOI Training Camp

สำหรับผู้ที่ผ่าน สอวน. และ TOI แล้ว เนื้อหาเป็นหัวข้อขั้นสูงที่สอนในค่ายคัดผู้แทนประเทศไทย ปีละไม่กี่ครั้ง

- advanced data structures: LCA, lazy/persistent segment tree, heavy-light decomposition
- DP optimization: convex hull trick, slope trick, divide and conquer, WQS binary search
- max flow, bipartite matching และ fixed parameter algorithms

=== วิธีใช้คู่มือนี้

- อ่านตามลำดับบท เพราะบทหลังใช้ความรู้จากบทก่อนหน้า
- หลายบทมี *แบบฝึกโต้ตอบ* (interactive) บนเว็บไซต์ ให้ลองทายคำตอบก่อนกดดูเฉลย จะจำได้ดีกว่าการอ่านอย่างเดียว
- ทุกบทจบด้วยโจทย์ฝึกฝนจาก CSES และ programming.in.th ความเข้าใจจริงมาจากการลงมือทำโจทย์
