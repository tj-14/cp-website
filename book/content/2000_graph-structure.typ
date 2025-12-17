#import "@preview/ilm:1.4.0": *

== Graph Structure

=== คำอธิบาย

- กราฟเป็นโครงสร้างข้อมูลไม่เชิงเส้น ประกอบด้วย node (vertex) และ edge
- มีนิยามดังนี้

  > A Graph consists of a finite set of vertices (or nodes) and set of Edges which connect a pair of nodes

=== Example

https://www.geeksforgeeks.org/wp-content/uploads/undirectedgraph.png

- ในกราฟด้านบนประกอบด้วย set of vertices $V = {0,1,2,3,4}$ และ set of edges $E = {01, 12, 23, 34, 04, 14, 13}$.
- กราฟสามารถใช้ในการแก้ปัญหาจริงได้หลายปัญหา
- กราฟสามารถใช้แสดงแทนเครือข่าย
- เช่น เส้นทางในเมือง หรือเครือข่ายโทรศัพท์ หรือวงจรไฟฟ้า เป็นต้น
- กราฟถูกใช้ใน social network เช่น LinkedIn และ Facebook
- เช่น ใน Facebook บุคคลเป็น node ที่เก็บข้อมูลไอดี ชื่อ เพศ ต่าง ๆ และเชื่อมกันด้วยเส้นเชื่อมประเภทต่าง ๆ เช่น การเป็นเพื่อน

=== Type
https://csacademy.com/lesson/introduction_to_graphs/
- Undirected graph
- Directed graph

=== Representation
https://csacademy.com/lesson/graph_representation/
- adjacency matrix
- adjacency list

=== Traversal
https://usaco.guide/CPH.pdf#page=119
- graph traversal
