# レシピ#3-2: 重い処理とUIスレッド（フリーズと無反応を防ぐ）

Flet アプリが「固まる」「ボタンが黙る」の大半は、UIスレッドの扱いを
間違えている。3つの型を覚えれば防げる。

## 型1: 重い同期処理は `page.run_thread()` へ

ネットワーク取得・変換・subprocess など時間のかかる同期処理を
イベントハンドラの中で直接回すと、**Web版では WebSocket が切れて処理が
完走しない**（デスクトップでもUIが固まる）。別スレッドに逃がす:

```python
def on_click(e):
    status.value = "処理中…"
    page.update()

    def work():
        try:
            result = heavy_convert(text)     # 重い同期処理
            status.value = f"完了: {result}"
        except Exception as ex:
            status.value = f"失敗: {ex}"
        finally:
            page.update()

    page.run_thread(work)                    # UIスレッドを塞がない
```

!!! warning "例外を握る"
    `run_thread` の中の例外は握って `status` に出す。放っておくと
    スレッドが黙って死に、UIは「処理中…」のまま残る。`finally` で
    ビジー表示を必ず戻す。

## 型2: 同期ハンドラから async を呼ぶなら `page.run_task()`

`async def` のハンドラを、同期の文脈（キーボードイベント等）から素で
呼ぶと、**コルーチンを作るだけで実行されない**（`Ctrl+S` が黙って
無反応、というバグの典型）。

```python
async def save(e): ...

def on_key(e: ft.KeyboardEvent):
    if e.ctrl and (e.key or "").upper() == "S":
        page.run_task(save, None)     # ○ 実行される
        # save(None)                  # ✗ コルーチンが作られるだけ
```

メニュー等から Flet が直接呼ぶ場合は Flet が await するので動く。
**自分で同期文脈から呼ぶ時だけ** `run_task` が要る。

## 型3: 連打の多重起動を実際に弾く

ビジー表示（ProgressRing の visible）は**見た目だけ**で、連打は防げない。
重い処理が Chrome ヘッドレス等を起動するなら、並走すると壊れる。実行中
フラグで弾く:

```python
running = {"on": False}

def on_click(e):
    if running["on"]:
        status.value = "実行中です。少し待ってください"
        page.update(); return
    running["on"] = True
    busy.visible = True
    page.update()

    def work():
        try:
            ...
        finally:
            running["on"] = False       # フラグは finally で必ず戻す
            busy.visible = False
            page.update()
    page.run_thread(work)
```

## まとめ

| 状況 | 使うもの |
|---|---|
| 重い**同期**処理（取得・変換・subprocess） | `page.run_thread(fn)` |
| 同期文脈から **async** ハンドラを呼ぶ | `page.run_task(coro, *args)` |
| 連打の多重起動を防ぐ | 実行中フラグ（`finally` で戻す） |

次: [3-3 外部プロセスと連携する](03_external_process.md)。
