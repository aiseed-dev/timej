# AI x Flutter Cookbook(原稿)

timej.net/cookbook/ で公開している「AI x Flutter Cookbook」の原稿とビルド一式。
元は独立リポジトリ(ai-x-flutter/cookbook)だったものを 2026-07-08 に取り込んだ。

- `docs/**/*.md` — 原稿(`docs/index.md` がトップページ)
- `web/` — HTMLテンプレートとCSS
- `build.py` — Markdown → HTML 変換(依存は `markdown` のみ)
- `articles/` — サイトには載せていない記事

## ビルド

```bash
# リポジトリルートで(初回準備で .venv に markdown も入る)
.venv/bin/python cookbook/build.py
rm -rf frontend/timej.net/html/cookbook
cp -r cookbook/site frontend/timej.net/html/cookbook
```

`cookbook/site/` は生成物なのでコミットしない(公開物は `frontend/timej.net/html/cookbook/` の凍結コピー)。

## ライセンス

ドキュメントは CC BY-SA 4.0(LICENSE 参照)。
