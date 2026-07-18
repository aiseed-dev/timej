# Flet をインストールして最初のアプリを動かす

## インストール

```bash
pip install "flet[all]"
```

`[all]` はデスクトップ実行・Web配信・CLI（`flet` コマンド）を一式入れる。
最小でよければ `pip install flet` だが、`flet run` や `flet build` を
使うなら `[all]` が楽。

## 最初のアプリ

`main.py`:

```python
import flet as ft


def main(page: ft.Page):
    page.title = "はじめての Flet"
    page.add(ft.Text("こんにちは、Flet"))


ft.run(main)
```

```bash
flet run              # デスクトップウィンドウで開く
flet run --web        # ブラウザで開く（http://localhost:8550 など）
python main.py        # ft.run(main) を直接呼んでもよい
```

!!! note "`ft.app` ではなく `ft.run`"
    新しめの Flet は起動関数が `ft.run(main)`。古い記事の `ft.app(target=main)`
    も当面動くが、新規は `ft.run` で書く。

## Webサーバとして公開する

同じアプリを、同一LANのスマホからも開けるサーバにできる:

```python
import os
port = int(os.environ.get("PORT", "8550"))
ft.run(main, view=ft.AppView.WEB_BROWSER, port=port, host="0.0.0.0")
```

`host="0.0.0.0"` で LAN 公開になる。**無認証で公開される点に注意**（社内・
手元向け。外に出すなら前段に認証を置く）。

## どこで動くか

| ターゲット | コマンド | 備考 |
|---|---|---|
| デスクトップ | `flet run` | Windows / macOS / Linux |
| ブラウザ | `flet run --web` | Python は手元で動く（サーバ側実行） |
| モバイル/配布 | `flet build apk` / `ipa` / … | [1-2 同梱Python](02_bundled_python.md) 参照 |

次: [1-2 同梱Pythonとプロジェクト構成](02_bundled_python.md)。
