# レシピ#3-14: レスポンシブ（モバイルとデスクトップ両対応）

一つのコードで iPhone の縦画面からデスクトップの広い窓まで出すので、
幅に応じてレイアウトを変える必要がある。

## 幅で分岐する（page.width）

```python
def layout(page):
    narrow = (page.width or 0) < 600
    if narrow:
        return ft.Column([sidebar(), body()])       # 縦に積む
    return ft.Row([                                  # 横に並べる
        ft.Container(sidebar(), width=260),
        ft.Container(body(), expand=True),
    ])

def on_resize(e):
    root.content = layout(page)
    page.update()

page.on_resized = on_resize
```

## ResponsiveRow で列を可変にする

グリッド的に「広ければ横並び、狭ければ折り返し」は `ResponsiveRow` が楽。
`col` に画面サイズ別の占有列数（12分割）を渡す:

```python
ft.ResponsiveRow([
    ft.Container(card_a(), col={"xs": 12, "md": 6, "xl": 4}),
    ft.Container(card_b(), col={"xs": 12, "md": 6, "xl": 4}),
    ft.Container(card_c(), col={"xs": 12, "md": 12, "xl": 4}),
])
```

`xs`（極小=モバイル）で 12（全幅・1列）、`md` で 6（2列）、`xl` で 4（3列）。

## タッチとマウス両方を想定する

- ボタン・行は**指で押せる大きさ**（高さ 44〜48px 目安）に
- ホバー前提のUI（ツールチップだけで情報を出す等）に依存しない
- スクロールは `ListView`/`Column(scroll=...)` で明示的に

## 適応的コントロール

`adaptive=True` を付けると、iOS では Cupertino 風、Android/デスクトップ
では Material 風に、プラットフォームらしい見た目になるコントロールがある:

```python
ft.Switch(adaptive=True)
ft.AlertDialog(adaptive=True, ...)
```

!!! tip "まず1カラム、広ければ足す"
    モバイル（1カラム）を基準に作り、幅が広いときだけサイドバーや
    2カラムを**足す**方が楽。デスクトップ基準で作ってモバイルに
    詰め込むより破綻しにくい。

戻る: [ホーム](../index.md)
