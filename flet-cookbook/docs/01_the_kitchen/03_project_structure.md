# プロジェクト構成と自己完結コントロール（AIに任せやすい形）

Flet アプリを AI と作るとき、**小さく自己完結した部品**に割ると速い。
1ファイルが肥大化すると、AIも人も見通しを失う。

## 目安

- **1コントロール（画面/部品）= 1関数、200行が目安**。超えたら切り出す
- 画面は `list_view.py` / `detail_view.py` のように**画面ごとにファイル**
- 状態は上位（App）に置き、子はコールバックを受け取る
   （[2-3 画面遷移](../02_core_concepts/03_navigation.md)）
- 色・サイズ・フォントは `theme.py` に定数で集約
   （[2-4 テーマ](../02_core_concepts/04_theming.md)）

```
my_app/
  main.py            # 入口: ft.run(App)。フォント・ウィンドウ設定
  app.py             # App: 画面の切り替え（use_state）
  list_view.py       # 一覧画面（1コンポーネント）
  detail_view.py     # 詳細画面
  settings_view.py   # 設定画面
  db.py              # 保存（SQLite）
  theme.py           # 色・サイズの定数
  assets/            # フォント・画像
  requirements.txt   # flet build の同梱依存
```

## 三状態（null / error / data）で描く

データを取ってくる画面は、**「まだ無い / 失敗 / ある」の3つ**を必ず描く。
これを省くと「空白のまま無反応」に見える。

```python
@ft.component
def Inbox():
    items, set_items = ft.use_state(None)      # None=ロード中
    error, set_error = ft.use_state("")

    async def load():
        try:
            set_items(await fetch())
        except Exception as ex:
            set_error(str(ex))
    ft.use_effect(load, dependencies=[])

    if error:
        return ft.Text(f"取得に失敗しました: {error}", color=ft.Colors.ERROR)
    if items is None:
        return ft.ProgressRing()
    if not items:
        return ft.Text("まだありません")
    return ft.ListView([Row(i) for i in items], expand=True)
```

## なぜこの形か

AIにタスクを任せるとき、**「このファイル1枚を、この責務で」**と切ると
指示も差分レビューも小さく済む。抽象化・設定項目・拡張ポイントを先回りで
作らず、いま要るものだけを自己完結で書く ── 仕様変更はAIで安いので、
必要になってから足せばよい。

次: [2-1 page と control](../02_core_concepts/01_page_and_controls.md)
