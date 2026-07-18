# 重要概念#2-1: page と control、そして update

Flet の世界は3つで説明できる。**page**（1枚のウィンドウ/タブ）、**control**
（page に載せる部品）、そして **`page.update()`**（変更を画面へ反映）。

## page に control を載せる

```python
import flet as ft


def main(page: ft.Page):
    page.title = "メモ"
    field = ft.TextField(label="ひとこと")
    label = ft.Text()

    def on_click(e):
        label.value = field.value       # 値を変える
        page.update()                   # ← これで画面に反映

    page.add(
        field,
        ft.FilledButton("表示", on_click=on_click),
        label,
    )


ft.run(main)
```

要点は **値を変えても `page.update()` を呼ぶまで画面は変わらない**こと。
イベントハンドラの最後に `page.update()`（または個々のコントロールの
`.update()`）を呼ぶ、と覚える。

## 命令的スタイルと宣言的スタイル

上のように「コントロールを作って値を書き換え、update する」のが**命令的**
スタイル。小さな自己完結アプリはこれで十分読みやすい。

新しめの Flet には `@ft.component` と `use_state` / `use_ref` を使う
**宣言的**スタイルもある:

```python
@ft.component
def Counter():
    n, set_n = ft.use_state(0)
    return ft.Row([
        ft.Text(f"{n}"),
        ft.FilledButton("+1", on_click=lambda e: set_n(n + 1)),
    ])
```

- `use_state` は「状態と、その更新関数」を返す。更新すると再描画される
- **状態管理ライブラリは要らない**。画面間の受け渡しも `use_state` を
  上位に置いて関数で渡すだけで足りる（小〜中規模アプリの実感）

!!! tip "どちらで書くか"
    迷ったら、単発の小さな画面は命令的、状態が絡む再利用部品は
    `@ft.component`。混在してもよい。**まず動かして、複雑になったら
    component に切り出す**のが楽。

## よく使うレイアウト

- `ft.Row([...])` / `ft.Column([...])` — 横並び・縦並び。`expand=True` で伸ばす
- `ft.Container(content=..., padding=..., border=...)` — 余白・枠・背景
- `ft.ListView(controls=[...], expand=True)` — 長いリスト（スクロール）
- `alignment` / `horizontal_alignment` — 寄せ

次: [3-1 0.85→0.86 の移行](../03_recipes/01_migrating_085_to_086.md)。
