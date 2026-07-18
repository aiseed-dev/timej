# 救急箱#4-1: よくある詰まりと直し方

実際に踏んだものだけ。症状から引ける形で。

## 画面が変わらない

`page.update()`（または `control.update()`）を呼んでいない。値を書き換えた
イベントハンドラの最後で必ず呼ぶ。→ [2-1](../02_core_concepts/01_page_and_controls.md)

## Web版で処理が途中で止まる／スピナーのまま

重い同期処理をイベントハンドラで直接回して、UIスレッド（WebSocket）を
塞いでいる。`page.run_thread()` に逃がす。→ [3-2](../03_recipes/02_ui_thread.md)

## ボタンを押しても無反応（async ハンドラ）

`async def` のハンドラを同期文脈から `f()` と素で呼び、コルーチンが実行
されていない。`page.run_task(f, *args)` を使う。→ [3-2](../03_recipes/02_ui_thread.md)

## 起動直後にフリーズ（RuntimeError: Control must be added to the page first）

`ft.StoragePaths()` 等の Service を `page.services.append()` せずに使った。
登録してから await する。→ [3-1](../03_recipes/01_migrating_085_to_086.md)

## TypeError: Tab.__init__() got an unexpected keyword argument 'text'

0.86 の API 変更。`Tab(text=)` → `Tab(label=)`、`Tabs(tabs=)` →
`Tabs(length=, content=TabBar(tabs=[...]))`。→ [3-1](../03_recipes/01_migrating_085_to_086.md)

## 手元では動くのに flet build した版で ModuleNotFoundError

`requirements.txt` に同梱依存を書いていない（`pyproject.toml` の
`project.dependencies` が空だと requirements.txt が読まれる）。GUIが実行時に
使うものを列挙する。→ [1-2](../01_the_kitchen/02_bundled_python.md)

## ビルド版だけ「保存」や「書き出し」が失敗する

0.86 の同梱ファイルは読み取り専用。自分の隣（assets/ 等）に書いている。
`FLET_APP_STORAGE_DATA` へ書く。→ [1-2](../01_the_kitchen/02_bundled_python.md)

## PDF化・プレビューだけ FileNotFoundError

`google-chrome` 決め打ちで、環境には Chromium しか無い。候補を順に探す
`find_chrome()` を使う。→ [3-3](../03_recipes/03_external_process.md)

## Ctrl+Z で消したはずの内容が復活する（自作エディタ）

プログラムから本文を差し替えたのに、打鍵の節目スナップショットを同期して
いない。本文を差し替える全経路で、undo用スナップショットも更新する。
