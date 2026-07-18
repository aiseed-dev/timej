# レシピ#3-12: テキスト編集の実戦（選択・挿入・Undo）

自前のエディタ（注記を挿入する・記法を補助する等）を作るときの型。
`TextField` を土台に、選択とスナップショットを自分で扱う。

## 複数行の TextField と選択の把握

```python
editor = ft.TextField(multiline=True, min_lines=20, expand=True)
sel = {"start": 0, "end": 0}

def on_selection(e):
    sel["start"] = editor.selection.base_offset or 0
    sel["end"] = editor.selection.extent_offset or 0

editor.on_selection_change = on_selection
```

## 選択範囲を注記で包む／カーソル位置に挿入

「選択語にルビを付ける」のような補助は、選択範囲を取り、前後を挟んで
本文を作り直す:

```python
def wrap_ruby(e):
    v = editor.value or ""
    a, b = sel["start"], sel["end"]
    a, b = max(0, min(a, len(v))), max(0, min(b, len(v)))
    target = v[a:b] or "親文字"
    ins = f"｜{target}《よみ》"
    new = v[:a] + ins + v[b:]
    apply_text(new, cursor=a + len(f"｜{target}《"), extent=a + len(f"｜{target}《") + 2)
```

挿入後にカーソル/選択を狙った位置へ置くと、続けて打ちやすい
（上の例は「《よみ》」の中を選択状態にしている）。

## Undo/Redo を自前で持つ

```python
undo, redo = [], []
snapshot = {"v": ""}          # 打鍵の節目スナップショット

def push_undo():
    undo.append(editor.value or "")
    if len(undo) > 200: undo.pop(0)
    redo.clear()

def apply_text(new, cursor, extent):
    push_undo()
    editor.value = new
    snapshot["v"] = new                       # ← 差し替えたら必ず同期
    editor.selection = ft.TextSelection(base_offset=cursor, extent_offset=extent)
    editor.focus()
    page.update()

def do_undo(e=None):
    if not undo: return
    redo.append(editor.value or "")
    v = undo.pop()
    editor.value = v
    snapshot["v"] = v                          # ← ここも同期
    page.update()
```

打鍵のまとまり（一定文字数ごと等）でも履歴を積む:

```python
def on_change(e):
    v = editor.value or ""
    prev = snapshot["v"]
    if abs(len(v) - len(prev)) >= 30 or v.endswith("\n") != prev.endswith("\n"):
        undo.append(prev); snapshot["v"] = v
    page.update()

editor.on_change = on_change
```

!!! warning "本文を差し替える全経路でスナップショットを同期する"
    「新規作成」「開く」「挿入」「取り込み」など、**プログラムから
    `editor.value` を書き換える所すべてで `snapshot["v"]` を更新する**。
    忘れると、直後の `on_change` が古い全文を undo に積み、`Ctrl+Z` で
    消したはずの旧文書が復活する。実際に踏むバグ。

次: [3-13 通知（プッシュ）](13_notifications.md)
