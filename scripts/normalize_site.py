#!/usr/bin/env python3
"""Normalize generated lesson pages in docs/.

This is a post-processing guard for generated pages: it rebuilds a clean head
and adds an in-page table of contents from lesson section headings.
"""

from __future__ import annotations

import html
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"

KATEX_HEAD = """    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"
        onload="renderMathInElement(document.body, {
            delimiters: [
                {left: '$$', right: '$$', display: true},
                {left: '$', right: '$', display: false}
            ],
            throwOnError: false
        });"></script>
"""


def slugify(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text).strip().lower()
    text = re.sub(r"[^\wก-๙]+", "-", text, flags=re.UNICODE)
    return text.strip("-") or "section"


def extract_title(source: str, fallback: str) -> str:
    match = re.search(r"<title>(.*?)</title>", source, re.S | re.I)
    if match:
        return html.unescape(match.group(1)).strip()
    return fallback.replace("-", " ").replace("_", " ").title()


def extract_final_body(source: str) -> str:
    match = re.search(r"<body\b[^>]*hx-boost=\"true\"[^>]*>.*?</body>", source, re.S | re.I)
    if match:
        # Keep the last boosted body. Earlier matches may be inside a broken
        # JavaScript string from the old KaTeX delimiter generation.
        matches = re.findall(r"<body\b[^>]*hx-boost=\"true\"[^>]*>.*?</body>", source, re.S | re.I)
        return matches[-1]

    matches = re.findall(r"<body\b[^>]*>.*?</body>", source, re.S | re.I)
    if matches:
        return matches[-1]

    raise ValueError("could not find a body element")


def add_section_ids(content: str) -> tuple[str, list[tuple[str, str]]]:
    used: dict[str, int] = {}
    toc: list[tuple[str, str]] = []

    def repl(match: re.Match[str]) -> str:
        attrs, text = match.group(1), match.group(2)
        if " id=" in attrs:
            id_match = re.search(r'id="([^"]+)"', attrs)
            section_id = id_match.group(1) if id_match else slugify(text)
        else:
            base = slugify(text)
            count = used.get(base, 0)
            used[base] = count + 1
            section_id = base if count == 0 else f"{base}-{count + 1}"
            attrs = f'{attrs} id="{section_id}"'
        toc.append((section_id, re.sub(r"<[^>]+>", "", html.unescape(text)).strip()))
        return f"<h4{attrs}>{text}</h4>"

    return re.sub(r"<h4([^>]*)>(.*?)</h4>", repl, content, flags=re.S | re.I), toc


def insert_toc(body: str) -> str:
    content_match = re.search(r'(<(?:div|article) class="content">\s*<h3[^>]*>.*?</h3>)(.*?)(<div class="page-nav">)', body, re.S | re.I)
    if not content_match:
        return body

    prefix, content, suffix = content_match.groups()
    content, toc = add_section_ids(content)
    if len(toc) < 3 or 'class="lesson-toc"' in content:
        return body[: content_match.start()] + prefix + content + suffix + body[content_match.end() :]

    links = "\n".join(f'                    <li><a href="#{section_id}">{html.escape(label)}</a></li>' for section_id, label in toc)
    toc_html = f"""
            <nav class="lesson-toc" aria-label="สารบัญในบทเรียน">
                <h4>ในบทนี้</h4>
                <ul>
{links}
                </ul>
            </nav>
"""
    return body[: content_match.start()] + prefix + toc_html + content + suffix + body[content_match.end() :]


def normalize_page(path: Path) -> None:
    source = path.read_text(encoding="utf-8")
    title = extract_title(source, path.stem)
    body = extract_final_body(source)
    body = re.sub(r"<body\b[^>]*>", '<body>', body, count=1, flags=re.I)
    body = insert_toc(body)

    document = f"""<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{html.escape(title)}</title>
    <link rel="stylesheet" href="style.css">
{KATEX_HEAD}
</head>
{body}
</html>
"""
    path.write_text(document, encoding="utf-8")


def main() -> None:
    for path in sorted(DOCS.glob("*.html")):
        if path.name == "index.html":
            continue
        normalize_page(path)


if __name__ == "__main__":
    main()
