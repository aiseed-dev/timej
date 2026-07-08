#!/usr/bin/env python3
"""docs/ のMarkdownから flutter.aiseed.dev の静的HTMLを生成する。

フレームワーク不使用。必要なのは python-markdown だけ:
    pip install markdown
使い方:
    python3 build.py        # site/ に出力
デザインは web/template.html と web/style.css を直接編集する（Claudeに任せてよい）。
"""

import re
import shutil
from pathlib import Path

import markdown

ROOT = Path(__file__).parent
DOCS = ROOT / "docs"
WEB = ROOT / "web"
OUT = ROOT / "site"

SITE_NAME = "AI x Flutter Cookbook"

# セクション（表示順）
SECTIONS = [
    ("01_the_kitchen", "1. キッチンの準備"),
    ("02_core_concepts", "2. Flutterの重要概念"),
    ("03_cooking_process", "3. 料理のプロセス"),
    ("04_secret_sauce_recipes", "4. 秘伝のソース"),
    ("05_chefs_specials", "5. シェフの特別料理"),
    ("06_collaboration", "6. 他のシェフとの協業"),
    ("07_troubleshooting", "7. 救急箱"),
    ("08_backend_for_frontend_with_ai", "8. BFFとサーバーサイドDart"),
    ("09_ai_for_design_and_prototyping", "9. 設計とプロトタイピング"),
]

# サイドバー表示用にH1タイトルを短くする
_TITLE_PREFIX = re.compile(
    r"^(レシピ|重要概念|ケーススタディ|トラブルシュート|トラブルシューティング)#([\d]+-[\d]+):\s*"
)


def page_title(md_text: str, fallback: str) -> str:
    for line in md_text.splitlines():
        if line.startswith("# "):
            return line[2:].strip().replace("`", "")
    return fallback


def nav_label(title: str) -> str:
    m = _TITLE_PREFIX.match(title)
    if m:
        return f"#{m.group(2)} {title[m.end():]}"
    return title


def convert(md_text: str) -> str:
    md = markdown.Markdown(
        extensions=["extra", "toc", "admonition", "sane_lists"],
        extension_configs={"toc": {"permalink": False}},
    )
    html = md.convert(md_text)
    # 内部リンクの .md → .html （外部URLは触らない）
    html = re.sub(
        r'href="(?!https?://)([^"#]+?)\.md(#[^"]*)?"',
        lambda m: f'href="{m.group(1)}.html{m.group(2) or ""}"',
        html,
    )
    return html


def collect():
    """{dirname: [(md_path, title)]} を返す"""
    tree = {}
    for dirname, _ in SECTIONS:
        files = sorted((DOCS / dirname).glob("*.md"))
        tree[dirname] = [
            (p, page_title(p.read_text(encoding="utf-8"), p.stem)) for p in files
        ]
    return tree


def render_nav(tree, current: Path | None, depth: int) -> str:
    """サイドバーのHTML。current は docs 相対の現在ページ"""
    rel = "../" * depth
    out = [f'<a class="nav-home" href="{rel}index.html">🍳 ホーム</a>']
    for dirname, label in SECTIONS:
        is_open = current is not None and current.parts[0] == dirname
        out.append(f'<details{" open" if is_open else ""}><summary>{label}</summary><ul>')
        for p, title in tree[dirname]:
            href = f"{rel}{dirname}/{p.stem}.html"
            cls = ' class="current"' if current == Path(dirname) / p.name else ""
            out.append(f'<li{cls}><a href="{href}">{nav_label(title)}</a></li>')
        out.append("</ul></details>")
    return "\n".join(out)


def main():
    template = (WEB / "template.html").read_text(encoding="utf-8")
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir()
    shutil.copy(WEB / "style.css", OUT / "style.css")

    tree = collect()
    pages = [(DOCS / "index.md", Path("index.md"))]
    for dirname, _ in SECTIONS:
        for p, _t in tree[dirname]:
            pages.append((p, Path(dirname) / p.name))

    for src, rel_path in pages:
        text = src.read_text(encoding="utf-8")
        title = page_title(text, src.stem)
        depth = len(rel_path.parts) - 1
        html = template.format(
            lang="ja",
            site_name=SITE_NAME,
            title=(SITE_NAME if rel_path.name == "index.md" else f"{title} - {SITE_NAME}"),
            root="../" * depth,
            nav=render_nav(tree, None if rel_path.name == "index.md" else rel_path, depth),
            content=convert(text),
        )
        dest = OUT / rel_path.with_suffix(".html")
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(html, encoding="utf-8")

    n = len(pages)
    print(f"OK: {n}ページを site/ に生成しました")


if __name__ == "__main__":
    main()
