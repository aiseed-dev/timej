# レシピ#3-11: FilePicker（開く・保存・Web対応）

ファイルの入出力は、デスクトップと Web で挙動が違う。両対応の型を覚える。

## FilePicker を用意する

FilePicker は `page.overlay` に載せてから使う（0.86 系）:

```python
picker = ft.FilePicker()
page.overlay.append(picker)
page.update()
```

`@ft.component` なら `use_ref` に持たせ、`page.services`/`overlay` へ
登録してから使う（Service 系は登録前に呼ぶと落ちる ── [3-1](01_migrating_085_to_086.md)）。

## 開く：bytes とパスの両対応

```python
files = await picker.pick_files(
    dialog_title="ファイルを選ぶ",
    allowed_extensions=["txt", "md"],
    file_type=ft.FilePickerFileType.CUSTOM,
    with_data=True,                       # Web でも中身(bytes)を取る
)
if files:
    f = files[0]
    data = f.bytes if f.bytes is not None else Path(f.path).read_bytes()
    text = data.decode("utf-8-sig")       # BOM も許容
```

- **デスクトップ**は `f.path`（実ファイルパス）が使える
- **Web** は `f.path` が無く、`with_data=True` で得た `f.bytes` を使う
- 「bytes があればそれ、無ければパスから読む」で一本化できる

## 保存：src_bytes で Web はダウンロードになる

```python
data = text.encode("utf-8")
path = await picker.save_file(
    dialog_title="名前を付けて保存",
    file_name="output.txt",
    allowed_extensions=["txt"],
    file_type=ft.FilePickerFileType.CUSTOM,
    src_bytes=data,                       # Web: これでブラウザDLになる
)
if path:
    # デスクトップは実パスが返る。Web は "upload..." 等の擬似パス
    if not str(path).startswith("upload"):
        Path(path).write_bytes(data)      # デスクトップは自分で書く
```

- `src_bytes` を渡すと **Web ではブラウザのダウンロード**として保存される
- デスクトップでは選ばれた実パスが返るので、そこへ自分で `write_bytes`

!!! tip "往復は構造化形式で"
    「開く→編集→保存→また開く」を繰り返す作業ファイルは、プレーン
    テキストだと設定（モード等）が失われる。保存は自前の構造化形式
    （JSON等）にして、提出用のプレーンテキストは「エクスポート」として
    別に書き出すと、往復で情報が欠けない。

次: [3-12 テキスト編集の実戦](12_text_editing.md)
