# レシピ#3-6: SQLite を手元に持つ（保存・スレッド・バックアップ）

Flet アプリのローカル保存は、標準ライブラリの `sqlite3` 一つで足りる。
サーバも ORM も要らない。

## 保存先とスキーマ

書き込み可能なデータ領域にDBを置く（[1-2](../01_the_kitchen/02_bundled_python.md)：
ビルド版は同梱の隣に書けない）:

```python
import sqlite3
from pathlib import Path

def open_db(data_dir: Path) -> sqlite3.Connection:
    data_dir.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(data_dir / "app.db")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS item (
            id INTEGER PRIMARY KEY,
            body TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (datetime('now'))
        )""")
    conn.commit()
    return conn
```

## 値は必ずプレースホルダで

文字列連結でSQLを組まない。ユーザー入力は `?` で渡す:

```python
conn.execute("SELECT * FROM item WHERE body LIKE ?", (f"%{q}%",))
```

!!! warning "LIKE のワイルドカードは無害化する"
    `LIKE ?` に渡す値に `%` や `_` が含まれると、パターンとして解釈される。
    利用者の検索語をそのまま入れると意図しない一致になる。エスケープする:

    ```python
    esc = q.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
    conn.execute("SELECT * FROM item WHERE body LIKE ? ESCAPE '\\'",
                 (f"%{esc}%",))
    ```

## スレッドをまたぐとき

重い処理を `page.run_thread`（[3-2](02_ui_thread.md)）で回し、その中でDBを
触るなら、`sqlite3` の「接続は作ったスレッドでのみ使う」制約に注意。
簡単なのは**そのスレッドで接続を開いて閉じる**か、接続時に
`check_same_thread=False` を付けて自分でロックする。小規模アプリなら
前者（都度接続）が素直。

## バックアップは conn.backup で

開いているDBファイルを `shutil.copy` で生コピーすると、WAL/ジャーナルが
未反映のまま写り**壊れたバックアップ**になりうる。`sqlite3` のバックアップ
APIを使えば一貫したスナップショットが取れる:

```python
def backup(conn, dest: Path):
    with sqlite3.connect(dest) as bck:
        conn.backup(bck)          # ロックを取り、整合したコピー
```

古いバックアップを消すときは、**自分の命名（`app-YYYYMMDD.db` 等）だけ**を
対象にする。ディレクトリ内の全ファイルを消すと、利用者が置いた別物まで
巻き込む。

次: [3-7 Pythonのパイプラインを直接呼ぶ](07_calling_python_pipeline.md)
