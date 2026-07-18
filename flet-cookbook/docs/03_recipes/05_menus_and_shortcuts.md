# レシピ#3-5: メニューバーとキーボードショートカット

デスクトップらしいアプリには、メニューバーとショートカットが要る。

## メニューバー

`MenuBar` に `SubmenuButton`（トップの「ファイル」等）を並べ、その中に
`MenuItemButton`（各項目）を入れる:

```python
def menu_item(label, on_click):
    return ft.MenuItemButton(
        content=ft.Text(label),
        on_click=on_click,
    )

menubar = ft.MenuBar(controls=[
    ft.SubmenuButton(content=ft.Text("ファイル"), controls=[
        menu_item("新規", on_new),
        menu_item("開く…", on_open),
        menu_item("保存", on_save),
        ft.Divider(),
        menu_item("外部エディタで開く", on_ext_open),
    ]),
    ft.SubmenuButton(content=ft.Text("編集"), controls=[
        menu_item("元に戻す", on_undo),
        menu_item("やり直す", on_redo),
    ]),
])
```

`SubmenuButton` は入れ子にできる（サブメニュー）。区切りは `ft.Divider()`。

## キーボードショートカット

`page.on_keyboard_event` に1つハンドラを置き、キーで分岐する:

```python
def on_key(e: ft.KeyboardEvent):
    if not e.ctrl:
        return
    k = (e.key or "").upper()
    if k == "S":
        page.run_task(save, None)      # async は run_task（レシピ#3-2）
    elif k == "Z":
        do_undo()
    elif k == "Y":
        do_redo()
    elif k == "P":
        do_print(None)

page.on_keyboard_event = on_key
```

- `e.ctrl` / `e.shift` / `e.alt` / `e.meta` で修飾キー、`e.key` で本体キー
- **`async` の処理を呼ぶなら `page.run_task`**。同期ハンドラから素で
  `save(None)` と呼ぶとコルーチンが実行されず、`Ctrl+S` が無反応になる
  （[3-2](02_ui_thread.md) の型2）

!!! tip "メニューとショートカットで同じ関数を呼ぶ"
    「保存」はメニュー項目とショートカットの両方から同じ関数を指す。
    ただしメニューは Flet が await してくれるが、キーハンドラ（同期）は
    自分で `run_task` する必要がある ── この非対称に注意。

次: [3-6 SQLite を手元に持つ](06_sqlite.md)
