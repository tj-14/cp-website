#!/usr/bin/env python3
"""Validate the static docs output with dependency-free checks."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"


def check_page(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    errors: list[str] = []

    checks = {
        "html": (r"<html\b", r"</html>"),
        "head": (r"<head\b", r"</head>"),
        "body": (r"<body\b", r"</body>"),
    }
    for name, (open_pattern, close_pattern) in checks.items():
        open_count = len(re.findall(open_pattern, text, flags=re.I))
        close_count = len(re.findall(close_pattern, text, flags=re.I))
        if open_count != 1:
            errors.append(f"{path.name}: expected 1 <{name}>, found {open_count}")
        if close_count != 1:
            errors.append(f"{path.name}: expected 1 </{name}>, found {close_count}")

    if "<body" in text and "</head>" in text and text.find("<body") < text.find("</head>"):
        errors.append(f"{path.name}: body starts before head ends")

    if re.search(r"<li>\s*</li>", text, re.I):
        errors.append(f"{path.name}: empty list item")

    if "{left: '\n<body" in text or "right: '\n<body" in text:
        errors.append(f"{path.name}: broken KaTeX delimiter script")

    for href in re.findall(r'href="([^"]+)"', text, flags=re.I):
        if href.startswith(("#", "mailto:", "tel:")):
            continue
        parsed = urlsplit(href)
        if parsed.scheme in {"http", "https"}:
            continue
        target = (path.parent / parsed.path).resolve()
        if not target.exists():
            errors.append(f"{path.name}: broken local link {href}")

    return errors


def main() -> int:
    errors: list[str] = []
    for path in sorted(DOCS.glob("*.html")):
        errors.extend(check_page(path))

    if errors:
        print("\n".join(errors))
        return 1

    print(f"Validated {len(list(DOCS.glob('*.html')))} HTML pages.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
