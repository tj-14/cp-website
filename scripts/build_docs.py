#!/usr/bin/env python3
"""Build the GitHub Pages site from book/content/*.typ.

The Typst content files are the source of truth. This script generates every
HTML page in docs/, including index.html, so the website and book stay aligned.
"""

from __future__ import annotations

import html
import re
import shutil
import subprocess
from urllib.parse import urlparse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BOOK = ROOT / "book" / "content"
DOCS = ROOT / "docs"
BOOK_ASSETS = ROOT / "book" / "assets"
DOCS_ASSETS = DOCS / "assets"

SECTIONS = [
    (
        "เริ่มต้น",
        "Course orientation",
        [("0000_competitive-programming-starter", "โครงสร้างเนื้อหาการสอน")],
    ),
    (
        "ค่าย 1: Programming Basics",
        "C++ syntax, functions, recursion, and STL basics",
        [
            ("1001_basic", "การเขียนโปรแกรมเชิงแข่งขัน"),
            ("1002_stl", "Standard Template Library"),
            ("1003_syntax", "C++ Syntax"),
            ("1004_recursion", "Recursion"),
            ("1005_function", "Function"),
        ],
    ),
    (
        "ค่าย 2: Data Structures",
        "Core structures and complexity analysis",
        [
            ("2005_big-o-notation", "Big O Notation"),
            ("2010_stack-queue", "Stack and Queue"),
            ("2001_linked-list", "Linked List"),
            ("2002_dynamic-array", "Dynamic Array"),
            ("2004_binary-tree", "Binary Tree"),
            ("2008_heap", "Heap"),
            ("2006_priority-queue", "Priority Queue"),
            ("2003_binary-search-tree", "Binary Search Tree"),
            ("2007_set-map", "Set and Map"),
            ("2000_graph-structure", "Graph Structure"),
            ("2011_hash-table", "Hash Table"),
            ("2009_review", "Review"),
        ],
    ),
    (
        "ต่อยอด: Algorithms",
        "Greedy, search, dynamic programming, and divide and conquer",
        [
            ("3000_greedy-algorithm", "Greedy Algorithm"),
            ("3001_array-manipulation", "Array Manipulation"),
            ("3002_search", "Search"),
            ("3003_dynamic-programming", "Dynamic Programming"),
            ("3004_adhoc", "Ad-hoc Problems"),
            ("3005_divide-conquer", "Divide and Conquer"),
        ],
    ),
    (
        "Graph Algorithms",
        "Graph traversal, ordering, paths, circuits, and applications",
        [
            ("3100_graph-algorithm", "Graph Algorithm"),
            ("3101_topo-sort", "Topological Sort"),
            ("3102_path-circuit", "Path and Circuit"),
        ],
    ),
    (
        "เพิ่มเติม",
        "Advanced notes and learning resources",
        [
            ("4000_dp", "Dynamic Programming Advanced"),
            ("9000_resources", "Resources"),
        ],
    ),
]

ORDER = [item for _, _, items in SECTIONS for item in items]

KATEX_HEAD = """    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"
        onload="renderMathInElement(document.body, {
            delimiters: [
                {left: '$$', right: '$$', display: true},
                {left: '$', right: '$', display: false}
            ],
            throwOnError: false
        });"></script>"""


def shift_headings(fragment: str) -> str:
    for level in range(6, 1, -1):
        fragment = re.sub(fr"<h{level}([^>]*)>", fr"<h{min(level + 1, 6)}\1>", fragment)
        fragment = re.sub(fr"</h{level}>", fr"</h{min(level + 1, 6)}>", fragment)
    return fragment


def resource_label(url: str) -> str:
    host = urlparse(url).netloc.removeprefix("www.")
    known = {
        "visualgo.net": "VisuAlgo interactive visualization",
        "csacademy.com": "CS Academy interactive lesson",
        "redblobgames.com": "Red Blob Games interactive guide",
        "cp-algorithms.com": "CP-Algorithms reference",
        "upload.wikimedia.org": "Wikimedia Commons visual reference",
        "media.geeksforgeeks.org": "GeeksforGeeks visual reference",
        "cdn.programiz.com": "Programiz visual reference",
    }
    return known.get(host, f"External reference: {host}")


def enhance_resource_paragraphs(fragment: str) -> str:
    before_footnotes, sep, after_footnotes = fragment.partition('<section id="footnotes"')

    def repl(match: re.Match[str]) -> str:
        url = html.unescape(match.group(1))
        label = resource_label(url)
        escaped_url = html.escape(url, quote=True)
        escaped_label = html.escape(label)
        if re.search(r"\.(png|svg|jpe?g|gif|webp)(?:[?#].*)?$", url, flags=re.I):
            return (
                '<figure class="external-figure">'
                f'<a href="{escaped_url}" target="_blank" rel="noopener">'
                f'<img src="{escaped_url}" alt="{escaped_label}" loading="lazy">'
                "</a>"
                f"<figcaption>{escaped_label}. Source: <a href=\"{escaped_url}\" target=\"_blank\" rel=\"noopener\">{html.escape(urlparse(url).netloc)}</a></figcaption>"
                "</figure>"
            )
        if any(host in url for host in ("visualgo.net", "csacademy.com", "redblobgames.com")):
            return (
                f'<p><a class="resource-card" href="{escaped_url}" target="_blank" rel="noopener">'
                f"<strong>{escaped_label}</strong><span>{html.escape(urlparse(url).netloc)}</span></a></p>"
            )
        return match.group(0)

    before_footnotes = re.sub(
        r'<p><a\s+href="([^"]+)">https?://[^<]+</a></p>',
        repl,
        before_footnotes,
        flags=re.S,
    )
    return before_footnotes + (sep + after_footnotes if sep else "")


def render_content(path: Path) -> str:
    result = subprocess.run(
        ["pandoc", "--no-highlight", "-f", "typst", "-t", "html", str(path)],
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=True,
    )
    fragment = shift_headings(result.stdout)
    fragment = fragment.replace("../assets/", "assets/")
    fragment = fragment.replace("book/assets/", "assets/")
    fragment = re.sub(r'src="[^"]*/book/(?:content/)?assets/', 'src="assets/', fragment)
    fragment = re.sub(r'<div class="sourceCode"[^>]*>\s*<pre[^>]*>', "<pre>", fragment)
    fragment = re.sub(r"</pre>\s*</div>", "</pre>", fragment)
    fragment = enhance_resource_paragraphs(fragment)
    return fragment


def copy_assets() -> None:
    if DOCS_ASSETS.exists():
        shutil.rmtree(DOCS_ASSETS)
    if BOOK_ASSETS.exists():
        shutil.copytree(BOOK_ASSETS, DOCS_ASSETS)


def page_nav(index: int) -> str:
    prev_html = ""
    next_html = ""
    if index > 0:
        slug, title = ORDER[index - 1]
        prev_html = f'<a href="{slug}.html" class="prev">{html.escape(title)}</a>'
    if index < len(ORDER) - 1:
        slug, title = ORDER[index + 1]
        next_html = f'<a href="{slug}.html" class="next">{html.escape(title)}</a>'
    return f"""            <div class="page-nav">
                {prev_html}
                {next_html}
            </div>"""


def site_nav(current_slug: str) -> str:
    groups = []
    for section_title, _, items in SECTIONS:
        links = []
        for slug, title in items:
            active = ' aria-current="page"' if slug == current_slug else ""
            links.append(f'                <li><a href="{slug}.html"{active}>{html.escape(title)}</a></li>')
        groups.append(
            f"""            <section>
                <h2>{html.escape(section_title)}</h2>
                <ul>
{chr(10).join(links)}
                </ul>
            </section>"""
        )
    return f"""        <aside class="site-nav" aria-label="สารบัญหลัก">
            <a class="site-nav-home" href="index.html">ภาพรวมหลักสูตร</a>
{chr(10).join(groups)}
        </aside>"""


def wrap_page(slug: str, title: str, content: str, nav: str) -> str:
    return f"""<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{html.escape(title)} | คู่มือโอลิมปิกคอมพิวเตอร์</title>
    <link rel="stylesheet" href="style.css">
{KATEX_HEAD}
</head>
<body>
    <header>
        <h1><a href="index.html">คู่มือโอลิมปิกคอมพิวเตอร์</a></h1>
        <p>Computer Olympiad Guide for Thai High School Students</p>
    </header>

    <div class="container page-layout">
{site_nav(slug)}
        <main>
            <div class="breadcrumb">
                <a href="index.html">← กลับสู่หน้าหลัก (Back to Home)</a>
            </div>

            <article class="content">
{content}
{nav}
            </article>
        </main>
    </div>

    <footer>
        <p>&copy; 2023-2024 Computer Olympiad Guide | <a href="index.html">หน้าหลัก</a></p>
        <p>สนามฝึกซ้อม: <a href="https://programming.in.th/" target="_blank" rel="noopener">programming.in.th</a> | <a href="https://cses.fi/problemset/" target="_blank" rel="noopener">CSES Problem Set</a></p>
    </footer>
</body>
</html>
"""


def build_index() -> str:
    cards = []
    search_items = []
    for section_title, section_desc, items in SECTIONS:
        links = []
        for slug, title in items:
            links.append(f'                    <li><a href="{slug}.html">{html.escape(title)}</a></li>')
            search_text = html.escape(f"{title} {section_title}".lower())
            search_items.append(
                f'                    <li data-title="{search_text}"><a href="{slug}.html"><strong>{html.escape(title)}</strong><span>{html.escape(section_title)}</span></a></li>'
            )
        cards.append(
            f"""            <section class="course-section">
                <h3>{html.escape(section_title)}</h3>
                <p>{html.escape(section_desc)}</p>
                <ol>
{chr(10).join(links)}
                </ol>
            </section>"""
        )

    return f"""<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>คู่มือโอลิมปิกคอมพิวเตอร์ | Computer Olympiad Guide</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1><a href="index.html">คู่มือโอลิมปิกคอมพิวเตอร์</a></h1>
        <p>Computer Olympiad Guide for Thai High School Students</p>
    </header>

    <main class="container home">
        <section class="home-intro">
            <h2>เส้นทางเรียน Competitive Programming สำหรับนักเรียนไทย</h2>
            <p>อ่านตามลำดับค่าย สอวน. หรือค้นหาหัวข้อที่ต้องใช้ทบทวนได้ทันที เว็บไซต์นี้สร้างจาก source เดียวกับหนังสือใน <code>book/content</code></p>
            <label class="search-box">
                <span>ค้นหาหัวข้อ</span>
                <input id="topic-search" type="search" placeholder="เช่น DP, graph, recursion, queue" autocomplete="off">
            </label>
            <ul id="search-results" class="search-results" hidden>
{chr(10).join(search_items)}
            </ul>
        </section>

        <section class="course-grid" aria-label="ลำดับบทเรียน">
{chr(10).join(cards)}
        </section>
    </main>

    <footer>
        <p>&copy; 2023-2024 Computer Olympiad Guide | เนื้อหาจากประสบการณ์การสอนค่าย สอวน.</p>
        <p>สนามฝึกซ้อม: <a href="https://programming.in.th/" target="_blank" rel="noopener">programming.in.th</a> | <a href="https://cses.fi/problemset/" target="_blank" rel="noopener">CSES Problem Set</a></p>
    </footer>

    <script>
        const searchInput = document.getElementById('topic-search');
        const results = document.getElementById('search-results');
        const items = Array.from(results.querySelectorAll('li'));
        searchInput.addEventListener('input', () => {{
            const query = searchInput.value.trim().toLowerCase();
            results.hidden = query.length === 0;
            items.forEach((item) => {{
                item.hidden = query.length > 0 && !item.dataset.title.includes(query);
            }});
        }});
    </script>
</body>
</html>
"""


def main() -> None:
    copy_assets()
    (DOCS / "index.html").write_text(build_index(), encoding="utf-8")
    for index, (slug, title) in enumerate(ORDER):
        source = BOOK / f"{slug}.typ"
        if not source.exists():
            continue
        content = render_content(source)
        (DOCS / f"{slug}.html").write_text(wrap_page(slug, title, content, page_nav(index)), encoding="utf-8")


if __name__ == "__main__":
    main()
