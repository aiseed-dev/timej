# レシピ#3-7: Pythonのパイプラインを直接呼ぶ（Fletの真価）

これが Flet を選ぶ最大の理由。**UIと業務ロジックが同じ Python・同じ
プロセス**なので、自分のデータ処理パイプラインを import して直接叩ける。
サーバも API も、言語の切り替えも要らない。

## そのまま import して呼ぶ

たとえば「テキスト → 変換 → プレビュー」を、変換ライブラリを直接呼んで
実現する:

```python
from mypipeline import convert, to_html      # 自作の処理をそのまま import

def on_preview(e):
    busy.visible = True; page.update()

    def work():
        try:
            doc = convert(editor.value)        # 重い変換
            preview.value = to_html(doc)
        except Exception as ex:
            status.value = f"変換に失敗: {ex}"
        finally:
            busy.visible = False; page.update()

    page.run_thread(work)                       # 重いのでスレッドへ（3-2）
```

Web アプリなら「フロントで入力 → API に POST → バックエンドで変換 →
返す」の一往復が要るところを、Flet は**関数呼び出し1回**で済ませる。
プロトタイプから実運用まで、この近さがそのまま速さになる。

## 外部レンダラの結果を画像で見せる

自前で描けない高度な組版（縦書き・ルビ等）は、外部ツールにHTML→画像化
させ、結果を `ft.Image` に流す。ヘッドレスChromeでスクリーンショットを
撮り、base64 で埋め込む:

```python
import base64, subprocess, tempfile
from pathlib import Path

def render_png(html: str, w: int, h: int) -> bytes:
    chrome = find_chrome()                      # レシピ#3-3
    with tempfile.TemporaryDirectory() as td:
        p = Path(td) / "p.html"; png = Path(td) / "p.png"
        p.write_text(html, encoding="utf-8")
        subprocess.run(
            [chrome, "--headless", "--disable-gpu",
             "--force-device-scale-factor=2",     # 2倍でくっきり
             f"--window-size={w},{h}", f"--screenshot={png}",
             p.resolve().as_uri()],
            check=True, capture_output=True)
        return png.read_bytes()

def show_preview(html):
    png = render_png(html, 794, 1123)            # A4相当
    preview.src = "data:image/png;base64," + base64.b64encode(png).decode()
    page.update()
```

`ft.Image(src="data:image/png;base64,...")` で外部レンダリング結果を
表示できる。`ft.InteractiveViewer` で囲めば拡大・パンもつく。

!!! tip "薄いUI・重いロジックは外へ"
    Flet 側は「入力を集め、結果を見せる」だけに徹し、変換・組版・生成は
    ライブラリや外部プロセスに委ねると、アプリが小さく保てる。UIと
    ロジックが同居できるのは利点だが、**なんでもUIファイルに書かない**。

次: [3-8 プル型同期とデータ保全](08_pull_sync.md)
