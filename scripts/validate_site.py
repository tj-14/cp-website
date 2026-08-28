#!/usr/bin/env python3
"""Validate the static docs output with dependency-free checks."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"


def local_target(path: Path, href: str) -> Path | None:
    parsed = urlsplit(href)
    if parsed.scheme in {"http", "https"} or href.startswith(("mailto:", "tel:")):
        return None
    return (path.parent / parsed.path).resolve()


def check_links(path: Path, text: str) -> list[str]:
    errors: list[str] = []
    ids = set(re.findall(r'id="([^"]+)"', text))
    for href in re.findall(r'href="([^"]+)"', text, flags=re.I):
        if href.startswith(("mailto:", "tel:")):
            continue
        parsed = urlsplit(href)
        if parsed.scheme in {"http", "https"}:
            continue
        target = (path.parent / parsed.path).resolve()
        if not target.exists():
            errors.append(f"{path.name}: broken local link {href}")
            continue
        fragment = parsed.fragment
        if not fragment:
            continue
        if target == path.resolve():
            if fragment not in ids:
                errors.append(f"{path.name}: missing anchor #{fragment}")
        elif target.suffix == ".html":
            target_text = target.read_text(encoding="utf-8")
            if fragment not in set(re.findall(r'id="([^"]+)"', target_text)):
                errors.append(f"{path.name}: missing anchor {href}")
    return errors


def check_images(path: Path, text: str) -> list[str]:
    errors: list[str] = []
    for src in re.findall(r'src="([^"]+)"', text, flags=re.I):
        parsed = urlsplit(src)
        if parsed.scheme in {"http", "https"}:
            continue
        target = (path.parent / parsed.path).resolve()
        if not target.exists():
            errors.append(f"{path.name}: missing image {src}")
    return errors


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

    errors.extend(check_links(path, text))
    errors.extend(check_images(path, text))
    return errors


def main() -> int:
    errors: list[str] = []
    pages = sorted(DOCS.glob("*.html"))
    for path in pages:
        errors.extend(check_page(path))

    if errors:
        print("\n".join(errors))
        return 1

    print(f"Validated {len(pages)} HTML pages.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
