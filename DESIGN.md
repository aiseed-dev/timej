# DESIGN: timej.net のテンプレート方式ビルド

2026-07-09 起案。対象は timej.net のみ(app.timej.net は1ページ+privacyなので手書き継続)。

## 目的

- ページの追加を「`src/` に1ファイル足して再ビルド」にする
- ヘッダー・ナビ・フッター・OGP・GAタグの一元管理。
  現状は全ページにコピペされていて、既にナビが3種類に分岐している
  (トップ=6項目+ハンバーガー、homeserver=旧4項目、migration=別の4項目、privacy=ナビなし)

## 方式 — cookbook/build.py の踏襲

フレームワーク不使用。python-markdown だけの ~150行の build スクリプト。

```
frontend/timej.net/
├── build.py            # src/ + web/ → html/ を生成
├── src/                # コンテンツ(原稿)
│   ├── index.html      # htmlフラグメント(リッチなページ)
│   ├── homeserver/index.html
│   ├── migration/index.html
│   ├── privacy/index.md   # 文章ページは Markdown
│   └── <新ページ>/index.md
├── web/
│   ├── template.html   # 全ページ共通の骨格(head/OGP/GA/ヘッダー/フッター)
│   └── style.css       # デザインの正本
└── html/               # 生成物(従来どおり凍結コミット、cf-publishの対象)
```

- **コンテンツは2形式**: 文章ページは `.md`、構造が濃いページ(トップ等)は
  本文だけの `.html` フラグメント。どちらも template.html に流し込む
- **メタ情報**は各ファイル先頭のコメントヘッダで指定:
  `<!-- title: … / description: … -->`(mdはHTMLコメント可)。無指定はH1から補完
- **ナビは build.py の PAGES リスト一箇所**で定義(トップと同じ6項目+ハンバーガーを全ページに)
- **アセット**(favicon/app_icon/og-image/summary_large_image/style.css)は web/ から html/ へコピー

## 生成対象外(html/ に静的ツリーとして残す)

- `html/cookbook/` — 既存の cookbook/build.py の成果物(現行運用のまま)
- `html/dyslexia/` — 独自デザインの読み物サイト。凍結レガシー扱い。
  build.py は触らずに残す(rm -rf しない設計にする)

## 検証

- 初回移植後、生成 html/ と現行 html/ の diff をレビューし、
  意図した差分(ナビ統一・GA/OGP漏れの補完)だけであることを確認
- 既存の全ページ相対リンク検査を build.py 末尾に組み込み、リンク切れ0でなければ失敗させる

## 運用

- Zed タスク「timej.net再ビルド」を追加(cookbook再ビルドと同様の1コマンド)
- デプロイは従来どおり cf-publish(html/ を上げるだけ、変更なし)

## 段階

1. build.py + template.html + src/ への移植(index / homeserver / migration / privacy)
2. diff・プレビュー・リンク検査で検証
3. コミット。以後、ページ追加は src/ への1ファイル

## 実装済み(2026-07-09)

上記のとおり実装。初回移植は index / homeserver / homeserver/oss-models /
migration / privacy の5ページ+新設の packages(Markdown)。privacy は
md化せず html フラグメントで移植(内容を変えないため)。リンク検査で
dyslexia/resources の既存の画像パスミスを検出・修正。
