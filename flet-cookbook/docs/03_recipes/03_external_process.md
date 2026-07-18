# レシピ#3-3: 外部プロセスと連携する（Chrome・エディタ・ファイル）

Flet アプリは薄いUIに徹し、重い仕事は外部の道具に投げると強い。実際に
使ったパターンを3つ。

## ヘッドレスChromeを「探して」呼ぶ

PDF化やページ画像化に Chrome を使うとき、`google-chrome` 決め打ちは
危険。Chromium しか無い環境で `FileNotFoundError` になる。候補を順に探す:

```python
import shutil, subprocess

def find_chrome():
    for c in ("google-chrome", "chromium", "chromium-browser",
              "google-chrome-stable"):
        if shutil.which(c):
            return c
    return None

def to_pdf(html_path, pdf_path):
    chrome = find_chrome()
    if not chrome:
        raise RuntimeError("Chrome/Chromium が必要です")
    subprocess.run(
        [chrome, "--headless", "--disable-gpu", "--no-pdf-header-footer",
         f"--print-to-pdf={pdf_path}", html_path.resolve().as_uri()],
        check=True, capture_output=True)
```

## 外部エディタで開いて、保存を取り込む

「使い慣れたエディタで本文を書きたい」に応えるパターン。特定の製品名を
アプリに持たせず、環境変数で解決する（利用者が OnlyOffice でも VSCode でも
選べる）:

```python
import os, subprocess, sys
from pathlib import Path

def editor_cmd():
    import shlex
    for env in ("MYAPP_EDITOR", "VISUAL", "EDITOR"):
        if os.environ.get(env):
            return shlex.split(os.environ[env])
    return None    # None = OSの既定アプリ

def open_external(path: Path):
    cmd = editor_cmd()
    if cmd:
        subprocess.Popen(cmd + [str(path)])
    elif sys.platform == "darwin":
        subprocess.Popen(["open", str(path)])
    elif os.name == "nt":
        os.startfile(str(path))
    else:
        subprocess.Popen(["xdg-open", str(path)])
```

保存の検知は mtime のポーリングで十分。**自動で取り込まず**、変更を検知
したら通知だけ出し、反映は利用者の明示操作にする（アプリ側の未保存編集を
黙って潰さないため）。監視は [3-2](02_ui_thread.md) の `page.run_thread` で。

## ファイル選択は bytes とパスの両対応にする

`FilePicker` はデスクトップでは**パス**、Web では**バイト**を返す。両対応:

```python
files = await picker.pick_files(with_data=True)
if files:
    f = files[0]
    data = f.bytes if f.bytes is not None else Path(f.path).read_bytes()
```

`with_data=True` を付けると Web でも中身（bytes）が取れる。デスクトップは
`f.path` が使えるので、`bytes` が無ければパスから読む、と書けば一本化できる。

## Web版でファイルを書き出して開かせる

Web では利用者のブラウザにサーバ側から新規タブを開かせる。共有の固定名で
書くと**複数セッションで競合・情報漏えい**する。セッション毎の推測困難な
名前にし、古いものは掃除する:

```python
import secrets, time
name = f"{secrets.token_urlsafe(16)}.html"
(pv_dir / name).write_text(html, encoding="utf-8")
page.launch_url(f"/_out/{name}")
# 起動時などに pv_dir の古いファイル（mtime 1時間超）を unlink しておく
```

次: [4-1 救急箱](../04_troubleshooting/01_common_pitfalls.md)。
