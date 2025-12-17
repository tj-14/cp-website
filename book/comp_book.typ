#import "@preview/ilm:1.4.0": *

#set text(lang: "th", font: "Laksaman")

#show: ilm.with(
  title: [a way in competitive programming],



  author: "ทศพร แสงจ้า",
  // date: datetime(year: 2024, month: 03, day: 19),
  abstract: [
   แนวทางเริ่มเขียนโปรแกรมเชิงแข่งขัน
  ],
  // chapter-pagebreak: false,
  // bibliography: bibliography("refs.bib"),
  // figure-index: (enabled: true),
  // table-index: (enabled: true),
  // listing-index: (enabled: true),
)

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
)

= บทนำ
#include "content/0000_competitive-programming-starter.typ"

= ค่ายหนึ่ง
#include "content/1003_syntax.typ"
#include "content/1002_stl.typ"
#include "content/1005_function.typ"
#include "content/1004_recursion.typ"

= ค่ายสอง
#include "content/1001_basic.typ"
#include "content/2005_big-o-notation.typ"
#include "content/2010_stack-queue.typ"
#include "content/2001_linked-list.typ"
#include "content/2002_dynamic-array.typ"
#include "content/2004_binary-tree.typ"
#include "content/2008_heap.typ"
#include "content/2006_priority-queue.typ"
#include "content/2003_binary-search-tree.typ"
#include "content/2007_set-map.typ"
#include "content/2000_graph-structure.typ"
#include "content/2011_hash-table.typ"
#include "content/2009_review.typ"

= ค่ายต่อ ๆ ไป

#include "content/3000_greedy-algorithm.typ"
#include "content/3001_array-manipulation.typ"
#include "content/3002_search.typ"
#include "content/3003_dynamic-programming.typ"
#include "content/3004_adhoc.typ"
#include "content/3005_divide-conquer.typ"
#include "content/3100_graph-algorithm.typ"
#include "content/3101_topo-sort.typ"
#include "content/3102_path-circuit.typ"

= จิปาถะ

#include "content/9000_resources.typ"

// #include "content/4000_dp.typ"
