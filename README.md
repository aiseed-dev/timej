# timej

timej.net の公開サイト。

- `frontend/timej.net/html` — timej.net(アプリと開発レシピ)
- `frontend/app.timej.net/html` — app.timej.net(世界時計アプリのランディングページ)

## timej.net のページを直す・増やす

原稿は `frontend/timej.net/src/`(.md または本文だけの .html)、
共通の骨格は `frontend/timej.net/web/template.html`、デザインの正本は `web/style.css`。
直したら再ビルドで `html/` に反映する(設計は [DESIGN.md](DESIGN.md)):

```bash
.venv/bin/python frontend/timej.net/build.py   # リンク検査込み
```

ページ追加は `src/<name>/index.md` を1つ置くだけ(先頭に `<!-- title: … -->` と
`<!-- description: … -->`)。`html/cookbook/` と `html/dyslexia/` はビルド対象外の
静的ツリーなので直接触る。

## cookbook(timej.net/cookbook/)

原稿とビルド一式は [cookbook/](cookbook/) にある(旧 ai-x-flutter/cookbook を取り込み)。
`frontend/timej.net/html/cookbook/` はそのビルド成果物の凍結コピー。原稿を直したら:

```bash
.venv/bin/python cookbook/build.py
rm -rf frontend/timej.net/html/cookbook
cp -r cookbook/site frontend/timej.net/html/cookbook
```

## 公開(Cloudflare Pages)

[cf-publish](https://github.com/aiseed-dev/cf-publish) で 2 つの Pages プロジェクトに直接デプロイする。
Zed のタスクメニューに同じコマンドが入っている。

```bash
# 初回のみ
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# お試し公開(preview URL が返る)
.venv/bin/cf-publish frontend/timej.net/html --project timej-net --branch preview
.venv/bin/cf-publish frontend/app.timej.net/html --project app-timej-net --branch preview

# 本番公開
.venv/bin/cf-publish frontend/timej.net/html --project timej-net --branch main
.venv/bin/cf-publish frontend/app.timej.net/html --project app-timej-net --branch main
```

認証情報は `~/.config/cloudflare/pages.env`(`CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`)から読まれる。

### 初回デプロイ後のカスタムドメイン設定

プロジェクトは初回デプロイ時に自動作成される。本番 URL を timej.net / app.timej.net にするには、
Cloudflare ダッシュボード → Workers & Pages → 各プロジェクト → Custom domains で
`timej.net` と `app.timej.net` を割り当てる(ゾーンは Cloudflare 管理済みなので DNS は自動設定)。
現在の配信元から切り替わるのはこの割り当てを行った時点。
