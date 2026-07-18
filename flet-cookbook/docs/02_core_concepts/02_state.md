# 重要概念#2-2: 状態 — use_state / use_ref / use_effect

`@ft.component` で書くとき、状態の道具は3つ。使い分けを間違えると
「値が古いまま」「再描画されない」で詰まる。

## use_state — 変わったら再描画してほしい値

```python
@ft.component
def Counter():
    n, set_n = ft.use_state(0)
    return ft.FilledButton(f"{n}", on_click=lambda e: set_n(n + 1))
```

`set_n(v)` で値を更新すると**再描画される**。関数を渡すと現在値から
計算できる（複数更新が重なっても安全）:

```python
set_n(lambda cur: cur + 1)
```

## use_ref — 再描画は要らない、でも最新を保持したい値

`use_ref` は `.current` に値を持つ。**更新しても再描画しない**。
「バックグラウンドのタスクハンドル」「実行中フラグ」「クロージャに
最新値を見せたい」といった、UI に出さない状態に使う。

```python
@ft.component
def Inbox():
    busy = ft.use_ref(False)          # 表示に出さない実行中フラグ
    timer = ft.use_ref(None)          # タイマータスクのハンドル
    ...
```

!!! warning "effect のクロージャは初回の値を覚えている"
    マウント時に1度だけ動く効果（下記 use_effect）の中から状態を読むと、
    **初回レンダーのスナップショット**を見てしまう。ループやタイマーから
    「今の値」を見たいときは、state ではなく **ref**（`.current`）を使う。
    これは実アプリで実際に踏む罠。

## use_effect — マウント時の副作用と後始末

購読開始・タイマー起動・初回ロードなど。`dependencies=[]` で「マウント時に
1回」、`cleanup` でアンマウント時の後始末を書く:

```python
@ft.component
def Inbox():
    timer = ft.use_ref(None)

    async def setup():
        timer.current = asyncio.create_task(periodic_loop())
        await first_load()

    def cleanup():
        if timer.current:
            timer.current.cancel()

    ft.use_effect(setup, dependencies=[], cleanup=cleanup)
    ...
```

## 使い分け早見

| 欲しいもの | 道具 |
|---|---|
| 変わったら画面を更新 | `use_state` |
| 保持するが再描画不要／最新をクロージャに見せる | `use_ref`（`.current`） |
| マウント時の副作用＋後始末 | `use_effect(setup, dependencies=[], cleanup=...)` |

状態管理ライブラリは要らない。画面をまたぐ状態は、上位コンポーネントの
`use_state` を関数で子に渡すだけで足りる。→ [2-3 画面遷移](03_navigation.md)
