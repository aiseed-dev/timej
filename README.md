# timej

timej.net の公開サイト。

- `frontend/timej.net/html` — timej.net(AIとの暮らし方)
- `frontend/app.timej.net/html` — app.timej.net(世界時計アプリのランディングページ)

## cookbook(timej.net/cookbook/)

`frontend/timej.net/html/cookbook/` は
[ai-x-flutter/cookbook](https://github.com/ai-x-flutter/cookbook) のビルド成果物の凍結コピー。
原稿の更新は cookbook リポジトリで行い、以下で再生成してコピーする:

```bash
cd ../cookbook          # ai-x-flutter/cookbook のクローン
python3 build.py        # 要: pip install markdown
rm -rf ../timej/frontend/timej.net/html/cookbook
cp -r site ../timej/frontend/timej.net/html/cookbook
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
