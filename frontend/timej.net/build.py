#!/usr/bin/env python3
"""timej.net の静的サイトを生成する。

src/ のコンテンツ(.md または .html フラグメント)を web/template.html に
流し込んで html/ に出力する。html/cookbook/ と html/dyslexia/ は
このスクリプトの管轄外(既存の静的ツリー)で、一切触らない。

使い方:
    .venv/bin/python frontend/timej.net/build.py
依存: pip install markdown
"""

import re
import shutil
import sys
from pathlib import Path

import markdown

ROOT = Path(__file__).parent
SRC = ROOT / "src"
WEB = ROOT / "web"
OUT = ROOT / "html"

META_RE = re.compile(r"<!--\s*(title|description):\s*(.*?)\s*-->")


def parse_meta(text: str):
    meta = dict(META_RE.findall(text))
    body = META_RE.sub("", text, count=2).lstrip("\n")
    return meta, body


def convert_md(md_text: str) -> str:
    md = markdown.Markdown(
        extensions=["extra", "toc", "sane_lists"],
        extension_configs={"toc": {"permalink": False}},
    )
    html = md.convert(md_text)
    # 内部リンクの .md → ディレクトリ(外部URLは触らない)
    html = re.sub(
        r'href="(?!https?://)([^"#]+?)\.md(#[^"]*)?"',
        lambda m: f'href="{m.group(1)}/{m.group(2) or ""}"',
        html,
    )
    return f'<div class="container prose">\n{html}\n</div>'


def build_pages():
    template = (WEB / "template.html").read_text(encoding="utf-8")
    n = 0
    for src in sorted(SRC.rglob("*")):
        if src.suffix not in (".md", ".html") or not src.is_file():
            continue
        rel = src.relative_to(SRC).with_suffix(".html")
        depth = len(rel.parts) - 1
        meta, body = parse_meta(src.read_text(encoding="utf-8"))
        if "title" not in meta:
            sys.exit(f"NG: {src} に <!-- title: … --> がない")
        content = convert_md(body) if src.suffix == ".md" else body
        page = template
        for key, value in {
            "{title}": meta["title"],
            "{description}": meta.get("description", ""),
            "{root}": "../" * depth,
            "{path}": str(rel.parent) + "/" if depth else "",
            "{content}": content,
        }.items():
            page = page.replace(key, value)
        dest = OUT / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(page, encoding="utf-8")
        n += 1
    return n


def copy_assets():
    shutil.copy(WEB / "style.css", OUT / "style.css")
    for f in (WEB / "assets").iterdir():
        shutil.copy(f, OUT / f.name)


def check_links():
    """html/ 全体(cookbook/dyslexia含む)の相対リンクを検査"""
    missing = []
    for f in OUT.rglob("*.html"):
        for href in re.findall(r'(?:href|src)="([^"#]+)"', f.read_text(encoding="utf-8")):
            if href.startswith(("http", "data:", "mailto:", "/")):
                continue
            target = (f.parent / href.split("?")[0]).resolve()
            if not target.exists():
                missing.append((f.relative_to(OUT), href))
    return missing


def main():
    n = build_pages()
    copy_assets()
    missing = check_links()
    if missing:
        for f, href in missing:
            print(f"リンク切れ: {f} -> {href}")
        sys.exit(f"NG: リンク切れ {len(missing)} 件")
    print(f"OK: {n}ページを html/ に生成しました(リンク検査済み)")


if __name__ == "__main__":
    main()
