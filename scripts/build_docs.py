#!/usr/bin/env python3
"""Build the GitHub Pages site from book/content/*.typ.

The Typst content files are the source of truth. This script generates every
HTML page in docs/, including index.html, 404.html, robots.txt and
sitemap.xml, so the website and book stay aligned.
"""

from __future__ import annotations

import datetime
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

SITE_URL = "https://tj-14.github.io/cp-website"
SITE_TITLE = "คู่มือโอลิมปิกคอมพิวเตอร์"
SITE_TAGLINE = "Computer Olympiad Guide for Thai High School Students"
DEFAULT_DESCRIPTION = "คู่มือการเขียนโปรแกรมเชิงแข่งขันสำหรับนักเรียนไทย สรุปอัลกอริทึมและโครงสร้างข้อมูลตั้งแต่พื้นฐานจนถึงระดับสูง พร้อมโจทย์ฝึกฝนจาก CSES และ programming.in.th"

KATEX_VERSION = "0.16.47"
KATEX_INTEGRITY = {
    "css": "sha384-nH0MfJ44wi1dd7w6jinlyBgljjS8EJAh2JBoRad8a3VDw2K69vfaaqm4WnR+gXtA",
    "js": "sha384-CwjPRVHTvLiMBFjEoij+QZViMV5rhTOIp7CJzl24JEqpRDA1sJFHVXXLURktbYYp",
    "auto": "sha384-bjyGPfbij8/NDKJhSGZNP/khQVgtHUE5exjm4Ydllo42FwIgYsdLO2lXGmRBf5Mz",
}

YEAR = datetime.date.today().year

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
SECTION_OF = {slug: section_title for section_title, _, items in SECTIONS for slug, _ in items}

KATEX_HEAD = f"""    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@{KATEX_VERSION}/dist/katex.min.css" integrity="{KATEX_INTEGRITY['css']}" crossorigin="anonymous">
    <script defer src="https://cdn.jsdelivr.net/npm/katex@{KATEX_VERSION}/dist/katex.min.js" integrity="{KATEX_INTEGRITY['js']}" crossorigin="anonymous"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/katex@{KATEX_VERSION}/dist/contrib/auto-render.min.js" integrity="{KATEX_INTEGRITY['auto']}" crossorigin="anonymous"
        onload="renderMathInElement(document.body, {{
            delimiters: [
                {{left: '$$', right: '$$', display: true}},
                {{left: '$', right: '$', display: false}}
            ],
            throwOnError: false
        }});"></script>"""

COPY_BUTTON_SCRIPT = """    <script>
        document.querySelectorAll('.content pre').forEach((pre) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'copy-btn';
            button.textContent = 'คัดลอก';
            button.addEventListener('click', () => {
                navigator.clipboard.writeText(pre.innerText).then(() => {
                    button.textContent = 'คัดลอกแล้ว';
                    setTimeout(() => { button.textContent = 'คัดลอก'; }, 1500);
                }, () => { button.textContent = 'คัดลอกไม่สำเร็จ'; });
            });
            pre.appendChild(button);
        });
    </script>"""

SEARCH_SCRIPT = """    <script>
        const searchInput = document.getElementById('topic-search');
        const results = document.getElementById('search-results');
        const items = Array.from(results.querySelectorAll('li:not(.search-empty)'));
        const emptyItem = results.querySelector('.search-empty');
        searchInput.addEventListener('input', () => {
            const query = searchInput.value.trim().toLowerCase();
            results.hidden = query.length === 0;
            let visible = 0;
            items.forEach((item) => {
                const show = item.dataset.title.includes(query);
                item.hidden = !show;
                if (show) visible += 1;
            });
            if (emptyItem) emptyItem.hidden = visible !== 0;
        });
        document.addEventListener('keydown', (event) => {
            if (event.key === '/' && event.target !== searchInput && !event.metaKey && !event.ctrlKey && !event.altKey) {
                event.preventDefault();
                searchInput.focus();
            }
        });
    </script>"""


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
        ["pandoc", "-f", "typst", "-t", "html", str(path)],
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=True,
    )
    fragment = shift_headings(result.stdout)
    fragment = fragment.replace("../assets/", "assets/")
    fragment = fragment.replace("book/assets/", "assets/")
    fragment = re.sub(r'src="[^"]*/book/(?:content/)?assets/', 'src="assets/', fragment)
    fragment = re.sub(r'<div class="sourceCode"[^>]*>\s*(<pre[^>]*>)', r"\1", fragment)
    fragment = re.sub(r"</pre>\s*</div>", "</pre>", fragment)
    fragment = enhance_resource_paragraphs(fragment)
    return fragment


def slugify(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text).strip().lower()
    text = re.sub(r"[^\wก-๙]+", "-", text, flags=re.UNICODE)
    return text.strip("-") or "section"


def add_heading_anchors(fragment: str) -> tuple[str, list[tuple[str, str]]]:
    used: dict[str, int] = {}
    sections: list[tuple[str, str]] = []

    def repl(match: re.Match[str]) -> str:
        tag, attrs, inner = match.group(1), match.group(2), match.group(3)
        label = re.sub(r"<[^>]+>", "", html.unescape(inner)).strip()
        id_match = re.search(r'id="([^"]+)"', attrs)
        if id_match:
            section_id = id_match.group(1)
        else:
            base = slugify(inner)
            count = used.get(base, 0)
            used[base] = count + 1
            section_id = base if count == 0 else f"{base}-{count + 1}"
            attrs = f'{attrs} id="{section_id}"'
        anchor = f'<a class="heading-anchor" href="#{section_id}" aria-hidden="true" tabindex="-1">#</a>'
        if tag == "h4":
            sections.append((section_id, label))
        return f"<{tag}{attrs}>{inner}{anchor}</{tag}>"

    return re.sub(r"<(h[2-5])([^>]*)>(.*?)</\1>", repl, fragment, flags=re.S), sections


def insert_lesson_toc(fragment: str, sections: list[tuple[str, str]]) -> str:
    if len(sections) < 3:
        return fragment
    match = re.search(r"<h3[^>]*>.*?</h3>", fragment, re.S)
    if not match:
        return fragment
    links = "\n".join(
        f'                    <li><a href="#{section_id}">{html.escape(label)}</a></li>'
        for section_id, label in sections
    )
    toc = f"""
            <nav class="lesson-toc" aria-label="สารบัญในบทเรียน">
                <h4>ในบทนี้</h4>
                <ul>
{links}
                </ul>
            </nav>"""
    return fragment[: match.end()] + toc + fragment[match.end() :]


def page_description(fragment: str) -> str:
    match = re.search(r"<p>(.*?)</p>", fragment, re.S)
    text = ""
    if match:
        text = re.sub(r"<[^>]+>", "", match.group(1))
        text = html.unescape(text)
        text = re.sub(r"\\\((.*?)\\\)", r"\1", text)
        text = re.sub(r"\s+", " ", text).strip()
    if len(text) < 20:
        text = DEFAULT_DESCRIPTION
    if len(text) > 157:
        text = text[:157].rsplit(" ", 1)[0] + "…"
    return text


def page_head(title: str, description: str, canonical: str | None = None, with_math: bool = False) -> str:
    canonical_html = f'    <link rel="canonical" href="{html.escape(canonical, quote=True)}">\n' if canonical else ""
    og_url = f'    <meta property="og:url" content="{html.escape(canonical or SITE_URL, quote=True)}">\n' if canonical else ""
    katex = KATEX_HEAD + "\n" if with_math else ""
    return f"""    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="{html.escape(description, quote=True)}">
    <meta name="theme-color" content="#253241">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="{SITE_TITLE}">
    <meta property="og:locale" content="th_TH">
    <meta property="og:title" content="{html.escape(title, quote=True)}">
    <meta property="og:description" content="{html.escape(description, quote=True)}">
{og_url}{canonical_html}    <link rel="icon" type="image/svg+xml" href="assets/favicon.svg">
    <title>{html.escape(title)}</title>
    <link rel="stylesheet" href="style.css">
{katex}"""


def header_html() -> str:
    return f"""    <header>
        <h1><a href="index.html">{SITE_TITLE}</a></h1>
        <p>{SITE_TAGLINE}</p>
    </header>"""


def footer_html() -> str:
    return f"""    <footer>
        <p>&copy; 2023-{YEAR} Computer Olympiad Guide | เนื้อหาจากประสบการณ์การสอนค่าย สอวน.</p>
        <p>สนามฝึกซ้อม: <a href="https://programming.in.th/" target="_blank" rel="noopener">programming.in.th</a> | <a href="https://cses.fi/problemset/" target="_blank" rel="noopener">CSES Problem Set</a></p>
    </footer>"""


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


def wrap_page(
    slug: str,
    title: str,
    content: str,
    nav: str,
    description: str,
    with_math: bool,
) -> str:
    head = page_head(
        f"{title} | {SITE_TITLE}",
        description,
        canonical=f"{SITE_URL}/{slug}.html",
        with_math=with_math,
    )
    return f"""<!DOCTYPE html>
<html lang="th">
<head>
{head}</head>
<body>
{header_html()}

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

{footer_html()}

{COPY_BUTTON_SCRIPT}
</body>
</html>
"""


def build_index(entries: list[tuple[str, str, str]]) -> str:
    cards = []
    for section_title, section_desc, items in SECTIONS:
        links = []
        for slug, title in items:
            links.append(f'                    <li><a href="{slug}.html">{html.escape(title)}</a></li>')
        cards.append(
            f"""            <section class="course-section">
                <h3>{html.escape(section_title)}</h3>
                <p>{html.escape(section_desc)}</p>
                <ol>
{chr(10).join(links)}
                </ol>
            </section>"""
        )
    search_items = []
    for slug, title, heading_text in entries:
        section_title = SECTION_OF.get(slug, "")
        data_title = f"{title} {section_title} {heading_text}".lower()
        search_items.append(
            f'                    <li data-title="{html.escape(data_title, quote=True)}">'
            f'<a href="{slug}.html"><strong>{html.escape(title)}</strong><span>{html.escape(section_title)}</span></a></li>'
        )

    head = page_head(
        f"{SITE_TITLE} | Computer Olympiad Guide",
        DEFAULT_DESCRIPTION,
        canonical=f"{SITE_URL}/index.html",
    )
    return f"""<!DOCTYPE html>
<html lang="th">
<head>
{head}</head>
<body>
{header_html()}

    <main class="container home">
        <section class="home-intro">
            <h2>เส้นทางเรียน Competitive Programming สำหรับนักเรียนไทย</h2>
            <p>อ่านตามลำดับค่าย สอวน. หรือค้นหาหัวข้อที่ต้องใช้ทบทวนได้ทันที เว็บไซต์นี้สร้างจาก source เดียวกับหนังสือใน <code>book/content</code></p>
            <label class="search-box">
                <span>ค้นหาหัวข้อ</span>
                <input id="topic-search" type="search" placeholder="เช่น DP, graph, recursion, queue (กด / เพื่อค้นหา)" autocomplete="off">
            </label>
            <ul id="search-results" class="search-results" hidden>
{chr(10).join(search_items)}
                    <li class="search-empty" hidden>ไม่พบหัวข้อที่ค้นหา</li>
            </ul>
        </section>

        <section class="course-grid" aria-label="ลำดับบทเรียน">
{chr(10).join(cards)}
        </section>
    </main>

{footer_html()}

{SEARCH_SCRIPT}
</body>
</html>
"""


def build_404() -> str:
    head = page_head(
        f"ไม่พบหน้า | {SITE_TITLE}",
        "หน้าที่ค้นหาไม่พบ กลับสู่หน้าหลักของคู่มือโอลิมปิกคอมพิวเตอร์",
    )
    return f"""<!DOCTYPE html>
<html lang="th">
<head>
{head}</head>
<body>
{header_html()}

    <main class="container">
        <section class="not-found">
            <h2>ไม่พบหน้าที่ค้นหา (404)</h2>
            <p>หน้าที่คุณพยายามเปิดอาจถูกย้ายหรือลบไปแล้ว</p>
            <p><a href="index.html">← กลับสู่หน้าหลัก</a></p>
        </section>
    </main>

{footer_html()}
</body>
</html>
"""


def write_extras() -> None:
    (DOCS / "404.html").write_text(build_404(), encoding="utf-8")
    (DOCS / "robots.txt").write_text(
        f"User-agent: *\nAllow: /\nSitemap: {SITE_URL}/sitemap.xml\n",
        encoding="utf-8",
    )
    today = datetime.date.today().isoformat()
    pages = ["index.html"]
    pages += [f"{slug}.html" for slug, _ in ORDER if (BOOK / f"{slug}.typ").exists()]
    urls = "\n".join(
        f"  <url><loc>{SITE_URL}/{page}</loc><lastmod>{today}</lastmod></url>"
        for page in pages
    )
    (DOCS / "sitemap.xml").write_text(
        f'<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n{urls}\n</urlset>\n',
        encoding="utf-8",
    )


def main() -> None:
    copy_assets()
    entries: list[tuple[str, str, str]] = []
    for index, (slug, title) in enumerate(ORDER):
        source = BOOK / f"{slug}.typ"
        if not source.exists():
            continue
        fragment = render_content(source)
        fragment, sections = add_heading_anchors(fragment)
        fragment = insert_lesson_toc(fragment, sections)
        with_math = 'class="math' in fragment
        description = page_description(fragment)
        page_html = wrap_page(slug, title, fragment, page_nav(index), description, with_math)
        (DOCS / f"{slug}.html").write_text(page_html, encoding="utf-8")
        heading_text = " ".join(label for _, label in sections)
        entries.append((slug, title, heading_text))

    (DOCS / "index.html").write_text(build_index(entries), encoding="utf-8")
    write_extras()
    print(f"Built {len(entries)} lesson pages plus index, 404, robots.txt, sitemap.xml.")


if __name__ == "__main__":
    main()
