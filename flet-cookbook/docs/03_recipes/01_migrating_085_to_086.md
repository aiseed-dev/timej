# レシピ#3-1: Flet 0.85 → 0.86 の移行と落とし穴

0.86 は良い更新だが、破壊的変更がいくつかある。実際に移行して踏んだものを、
直し方つきで残す。公式の変更履歴に無い実挙動も含む。

## Tabs の API が変わった（一番刺さる）

0.85 までよく書いた `Tabs(tabs=[Tab(text=...)])` は **0.86 で通らない**。
Tab は `text=` を受けず、Tabs は `tabs=` を受けない。

```python
# ✗ 0.85 まで（0.86 で TypeError）
ft.Tabs(
    selected_index=i,
    on_change=lambda e: set_i(int(e.control.selected_index)),
    tabs=[ft.Tab(text=name) for name in names],
)

# ○ 0.86
ft.Tabs(
    length=len(names),
    selected_index=i,
    on_change=lambda e: set_i(int(e.data)),   # e.data が新インデックス
    content=ft.TabBar(tabs=[ft.Tab(label=name) for name in names]),
)
```

- `Tab(text=)` → **`Tab(label=)`**
- `Tabs(tabs=[...])` → **`Tabs(length=N, content=ft.TabBar(tabs=[...]))`**。
  Tabs はコーディネータになり、タブ列は `TabBar` に移った
- 本文まで Tabs に組ませるなら `TabBarView` を併用する。自前で描くなら
  `TabBar` だけでよい
- `on_change` の新インデックスは **`e.data`** から取る

## StoragePaths は Service。登録してから使う

`ft.StoragePaths()` は Service なので、`page.services` に**登録してから**
呼ぶ。登録せず `await` すると `RuntimeError("Control must be added to the
page first")` で、起動処理ごと死ぬ（画面がスピナーのまま固まる）。

```python
async def data_dir(page: ft.Page):
    storage = ft.StoragePaths()
    page.services.append(storage)                  # ← これが必須
    docs = await storage.get_application_documents_directory()
    return Path(docs) / "data"
```

## 同梱Pythonが 3.14 に・アプリは読み取り専用に

[1-2](../01_the_kitchen/02_bundled_python.md) の通り。既定同梱Pythonが 3.14、
同梱ファイルは読み取り専用（書き込みは `FLET_APP_STORAGE_DATA` へ）。
`--python-version 3.12` で戻せる。

## バージョン不一致は動かない

0.86 で UDS/TCP のワイヤ形式が「4バイト長＋1バイト種別」に変わり、
**0.86 未満のサーバ/クライアントと混在できない**。CLI と実行時の flet を
揃える。拡張パッケージ（flet-camera 等）も同じ系列（0.86.x）に上げる。

## バイトコード事前コンパイルが既定on

0.86 からアプリ/パッケージの `.pyc` 事前コンパイルが既定で有効。従来挙動に
戻すなら `--no-compile-app` / `--no-compile-packages`。

## 移行チェックリスト

- [ ] `Tab(text=` → `Tab(label=` に全置換
- [ ] `Tabs(tabs=` → `Tabs(length=, content=TabBar(tabs=...))`、`e.data` 参照
- [ ] `StoragePaths()` を `page.services.append()` してから await
- [ ] 同梱の隣に書き込む処理 → `FLET_APP_STORAGE_DATA`
- [ ] `requirements.txt` と開発venvの flet を 0.86 に統一
- [ ] 拡張パッケージを 0.86 系へ

次: [3-2 重い処理とUIスレッド](02_ui_thread.md)。
