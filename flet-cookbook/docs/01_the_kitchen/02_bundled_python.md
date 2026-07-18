# 同梱Pythonとプロジェクト構成（flet build の勘所）

`flet build` はアプリに **Python ランタイムごと** 同梱する。ここがデスクトップ/
モバイル配布でつまずきやすいので、先に押さえておく。

## 同梱Pythonのバージョン

Flet 0.86 から、`flet build` が同梱する Python の既定が **3.14** になった
（0.85 までは 3.12）。ネイティブ拡張を使うライブラリで 3.14 の wheel が
まだ無い場合は、明示的に下げる:

```bash
flet build apk --python-version 3.12
```

!!! tip "開発環境も同梱に合わせる"
    「手元で動くのに配布版で動かない」を避けるには、開発用の venv も
    同梱Pythonに合わせるのが安全。例えば miniforge の Python 3.14 で
    venv を作る:

    ```bash
    ~/miniforge3/bin/python -m venv .venv
    ```

## 依存は requirements.txt に書く（ハマりどころ）

`flet build` は同梱する依存を次の優先順で決める:

1. poetry の依存
2. `pyproject.toml` の `project.dependencies`
3. **`requirements.txt`**
4. 何も無ければ flet 単体

`pyproject.toml` の `dependencies` を空にしていると、**flet だけが同梱され、
実行時に自作以外のライブラリが軒並み `ModuleNotFoundError`** になる。
これは実機ビルドで初めて発覚しがち（`flet run` は開発環境の venv を使うので
気づけない）。GUIが実行時に使うものを `requirements.txt` に列挙する:

```
# requirements.txt — flet build が同梱する依存
flet==0.86.0
pywashi>=0.10.1
ebooklib>=0.18
```

CLI専用の重い依存（データ生成にしか使わないもの）は入れない ── 同梱サイズを
無駄に膨らませないため。

## 0.86 のアプリバンドルは読み取り専用

0.86 から、ビルドしたアプリの同梱ファイルは**読み取り専用**になった。
`Path(__file__).parent / "assets" / "out.html"` のように**自分の隣に書き込む**
コードは、`flet run` では動くのにビルド版で失敗する。書き込みは
アプリ専用のデータ領域へ:

```python
import os
data_dir = os.environ["FLET_APP_STORAGE_DATA"]   # 書き込み可
```

（環境変数 `FLET_APP_STORAGE_DATA` / `FLET_APP_STORAGE_TEMP` /
`FLET_APP_STORAGE_CACHE` で用途別の可書きディレクトリが取れる。）

!!! warning "バージョンを揃える"
    0.86 で通信のワイヤ形式が変わり、**CLI と実行時で flet のバージョンが
    食い違うと動かない**。`requirements.txt` の flet と、開発venvの flet を
    同じに保つこと。拡張（flet-camera 等）も同じ系列に合わせる。

次: [2-1 page と control](../02_core_concepts/01_page_and_controls.md)。
