// Interactive widgets. The website build (scripts/build_docs.py) replaces this
// paragraph with book/assets/widgets/<name>.js; the PDF shows a link instead.
#let widget(name) = block(inset: 8pt, stroke: 0.5pt + gray, radius: 4pt, width: 100%)[
  ▶ Interactive: #raw(name) - แบบฝึกโต้ตอบ ลองเล่นได้บน#link("https://tossatree.com/cp-website/")[เว็บไซต์]
]
