# レシピ#3-4: ダイアログ（確認・入力・API変更に注意）

ダイアログの出し方は Flet のバージョンで変わってきた。今の書き方と、
古い記事との差を押さえる。

## 今の出し方: show_dialog / pop_dialog

```python
def edit_title(page, current):
    field = ft.TextField(label="題名", value=current, autofocus=True)

    def apply(e):
        save_title(field.value)
        page.pop_dialog()          # 閉じる
        page.update()

    dlg = ft.AlertDialog(
        title=ft.Text("題名の編集"),
        content=field,
        actions=[
            ft.TextButton("キャンセル", on_click=lambda e: page.pop_dialog()),
            ft.FilledButton("保存", on_click=apply),
        ],
    )
    page.show_dialog(dlg)          # 開く
    page.update()
```

!!! warning "古い記事の `page.dialog = ...; dlg.open = True` は避ける"
    以前は `page.dialog` に代入して `open=True`／`page.open(dlg)`／
    `page.close(dlg)` という書き方があったが、今は **`page.show_dialog(dlg)` /
    `page.pop_dialog()`** を使う。古い書き方をコピーして「ダイアログが
    出ない・閉じない」で詰まるのは、この API の食い違いが原因のことが多い。

## 確認ダイアログ（はい/いいえ）

```python
def confirm(page, message, on_yes):
    def yes(e):
        page.pop_dialog()
        on_yes()

    page.show_dialog(ft.AlertDialog(
        title=ft.Text("確認"),
        content=ft.Text(message),
        actions=[
            ft.TextButton("いいえ", on_click=lambda e: page.pop_dialog()),
            ft.FilledButton("はい", on_click=yes),
        ],
    ))
    page.update()
```

## 別ダイアログに逃がす設計

本文編集の最中に「書誌情報（題名・著者）」のようなメタ情報をいじりたい
とき、本文エリアに混ぜず**別ダイアログ**にすると、誤入力が本文に紛れない。
編集画面が主・設定は従、という分離は実アプリで効く。

次: [3-5 メニューとショートカット](05_menus_and_shortcuts.md)
