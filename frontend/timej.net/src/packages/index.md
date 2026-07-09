<!-- title: 開発から生まれたOSSパッケージ | timej.net -->
<!-- description: サイトやアプリをAIと協働で作る中で生まれた5つのOSSパッケージ。cf-publish、mdit-py-cjk-friendly、washi-md、flutter_svg_cjk_friendly、aiseed-migration-kit。 -->

# 開発から生まれたOSSパッケージ

このサイトも、世界時計アプリも、[IT移行の支援](../migration/)も、AIと協働する開発で作っています。
その過程で「無いと困る」道具を小さなパッケージに切り出し、
[GitHub (aiseed-dev)](https://github.com/aiseed-dev) で公開しています。
どれも机上の作品ではなく、**実際の製品の中で毎日動いているもの**です。

方針は一貫しています——大きなフレームワークに頼らず、
一つの問題を確実に解く小さな道具を作る。
AIと協働する開発では、依存が少なくシンプルな道具ほど正確に扱えるからです
(この考え方は [AI x Flutter Cookbook](../cookbook/) に詳しく書いています)。

---

## cf-publish — PythonだけでCloudflare Pagesへ配信

静的サイトを Cloudflare Pages へ Direct Upload する公式手段は wrangler で、
Node.js のツールチェーン一式が必要になります。ビルドパイプラインが Python
(あるいは「ただのフォルダ」)のとき、一度のHTTP会話のためには大掛かりすぎる——
それが出発点です。

cf-publish は同じアップロードプロトコルを**約300行のPython**で実装しています
(依存は `httpx` と `blake3` の2つだけ)。

```bash
pip install cf-publish
export CLOUDFLARE_API_TOKEN=...    # 「Cloudflare Pages: Edit」権限のトークン
export CLOUDFLARE_ACCOUNT_ID=...
cf-publish ./public --project my-site
```

- **内容アドレスの差分アップロード** — wrangler と同じ方式でファイルをハッシュし、
  変更のないファイルは再送しない(2回目以降のデプロイが速い)
- 429/5xx への**リトライと指数バックオフ**、並列アップロード
- Pages の制限(1ファイル25MiB・2万ファイル)を送信前に**事前検証**
- `_headers` / `_redirects` を wrangler と同じ方法でデプロイに添付
  (静的ファイルとして上げると効かない、という罠を踏まない)

この timej.net 自身も cf-publish で配信しています。

→ [GitHub: aiseed-dev/cf-publish](https://github.com/aiseed-dev/cf-publish)(PyPI公開は準備中)

---

## mdit-py-cjk-friendly — Markdownを日本語フレンドリーに

CommonMark は空白で単語を区切る言語を前提に設計されているため、
日本語のMarkdownでは有名な問題が2つ起きます。

1. **文中改行が半角スペースになる** — 長い文を途中で改行すると、
   描画後の文中に不要な空白が入る
2. **全角約物に隣接した強調が効かない** — `**「重要」**です` と書くと
   強調にならず、リテラルの `**` がそのまま残る

mdit-py-cjk-friendly は [markdown-it-py](https://github.com/executablebooks/markdown-it-py)
のプラグインとして、この2つをパーサレベルで解決します。

```python
from markdown_it import MarkdownIt
from mdit_py_cjk_friendly import cjk_friendly

md = MarkdownIt("commonmark").use(cjk_friendly)
md.render("これは**「重要」**です。")
# <p>これは<strong>「重要」</strong>です。</p>
```

強調の挙動は [CommonMark CJK-friendly 仕様ドラフト](https://github.com/tats-u/markdown-cjk-friendly)
の考え方に従った markdown-it-py 向けの独立実装で、
`.use()` したパーサ以外の挙動は一切変えません。

→ [GitHub: aiseed-dev/mdit-py-cjk-friendly](https://github.com/aiseed-dev/mdit-py-cjk-friendly)(PyPI公開は準備中)

---

## washi-md — Markdownから美しい日本語文書(HTML / PDF)

Markdown から、日本語らしく組版された文書をコマンド一つで作ります。
横書きのビジネス文書から、縦書きの小説、原稿用紙まで。

```bash
washi report.md          # → report.html(組版済み・自己完結・1ファイル)
washi report.md --pdf    # → report.pdf も出力(Chromeヘッドレス印刷)
```

- **フォントはUD系を最優先** — モリサワUD(あれば)→ BIZ UD → ヒラギノ/Noto の順で
  フォールバック。`--embed-fonts` で BIZ UD を埋め込めば相手の環境でも同じ見た目に
- **日本語組版CSSを同梱** — 本文は明朝・両端揃え・段落頭一字下げ、
  行頭禁則、約物の行頭詰め、句読点のぶら下げ
- **CJKフレンドリーなMarkdown解釈** — 上の mdit-py-cjk-friendly を内蔵
- **印刷/PDF対応** — A4・余白・ページ番号、表や見出しのページまたぎ抑止
- **縦書き(`--vertical`)と原稿用紙(`--genko`)**

→ [GitHub: aiseed-dev/washi-md](https://github.com/aiseed-dev/washi-md)(PyPI公開は準備中)

---

## flutter_svg_cjk_friendly — FlutterのSVGで日本語が豆腐になる問題を直す

[flutter_svg](https://pub.dev/packages/flutter_svg) は、CSSの font-family **リスト**
(`font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif` —
matplotlib はじめ多くのツールが出力する標準形)を、引用符もカンマも含めた
単一のフォント名として扱います。実在のフォントに一致しないため、
日本語テキストは豆腐(□)になります。

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

SvgPicture.string(cjkFriendlySvg(svg));
```

`cjkFriendlySvg` が全ての font-family をパースして正規化し、
アプリに同梱したフォントを優先させることもできます。
flutter_svg が無視してしまう**縦書きテキスト**(`writing-mode`)の展開にも対応。
実在の統計チャート(人口ピラミッド)で検証し、回帰テストで結果を固定しています。

→ [GitHub: aiseed-dev/flutter_svg_cjk_friendly](https://github.com/aiseed-dev/flutter_svg_cjk_friendly)(pub.dev公開は準備中)

---

## aiseed-migration-kit — 組織のITを開いた土台へ移すツール一式

CMS・グループウェア・業務システムという「閉じた世界」から、
git・SQL・メール・静的公開という開いた土台へ移行するためのキットです。
`amig` コマンドが移行のパイプラインを段階ごとに支援します。

```bash
amig new sites/mysite            # サイトの雛形を作る
amig ingest sites/mysite ~/data  # 元データ(HTML等)を取り込む
amig classify sites/mysite       # 記事/一覧に分類(結果は人が直せる)
amig convert sites/mysite        # Markdownへ機械変換(下書き)
amig build sites/mysite          # dist/ を生成
amig publish sites/mysite        # Cloudflare Pages へ配信
```

- 内容の正は **Markdown+frontmatter を git で版管理** — 特定の道具に囲い込まれない
- `convert` は既存の .md を上書きしない(人が仕上げた原稿を守る)
- 問い合わせは申込様式(xlsx)+メール受付で、Webフォームは作らない
- 配信は上の cf-publish、Markdown解釈は mdit-py-cjk-friendly を利用

この道具を使った移行支援そのものについては [IT移行のページ](../migration/) をどうぞ。

→ [GitHub: aiseed-dev/aiseed-migration-kit](https://github.com/aiseed-dev/aiseed-migration-kit)

---

## パッケージ同士の関係

5つはばらばらの作品ではなく、一つの開発スタイルの部品です。

- **washi-md** と **aiseed-migration-kit** は **mdit-py-cjk-friendly** の上に立ち、
- **aiseed-migration-kit** の配信は **cf-publish** が担い、
- **flutter_svg_cjk_friendly** はアプリ側で同じ「CJKフレンドリー」の思想を担います。

そしてどれも、このサイト・統計チャート・移行案件という実際の現場で毎日動いています。
「AIに道具を作らせて、作った道具で仕事をする」——
[自宅AIサーバー](../homeserver/)や [Cookbook](../cookbook/) で書いている開発スタイルの、
これが実物です。
