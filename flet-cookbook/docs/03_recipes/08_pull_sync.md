# レシピ#3-8: プル型同期とデータ保全（順序を間違えない）

サーバの受信箱からデータを引き取る「プル型」アプリの型。ここは**操作の
順序**を間違えるとデータを失う。実際に踏んだ設計を残す。

## カーソルで差分だけ取る

ローカルに取り込んだ最大IDを覚え、それより新しいものだけ取りに行く:

```python
def pull(conn, api):
    after = conn.execute("SELECT COALESCE(MAX(remote_id), 0) FROM item").fetchone()[0]
    while True:
        page = api.get_items(after=after, limit=500)
        if not page:
            break
        for it in page:
            conn.execute(
                "INSERT OR IGNORE INTO item (remote_id, body) VALUES (?, ?)",
                (it["id"], it["body"]))
        conn.commit()                    # ページ毎にcommit（中断に強い）
        after = max(it["id"] for it in page)
        if len(page) < 500:
            break
```

- **`INSERT OR IGNORE` ＋ `remote_id` に UNIQUE** で、重複取得しても冪等
- **ページ毎に commit**。途中で落ちても取り込んだ分は残り、次回続きから
- カーソルは `MAX(remote_id)`。IDが単調増加なら取りこぼさない

## 削除（ack）は「サーバ成功 → ローカル更新」の順で

「確認したらサーバの受信箱から消す」ような操作は、**順序が命**。

```python
async def confirm(item_id):
    # ✗ 逆順（ローカル先）だと、ack失敗時にローカルは確認済みのまま
    #    ボタンが disabled になり、サーバの行が二度と消せなくなる
    await api.ack([item_id])                     # 先にサーバ（削除）
    conn.execute("UPDATE item SET confirmed=1 WHERE remote_id=?", (item_id,))
    conn.commit()                                # 成功してからローカル
```

!!! warning "順序を逆にしない"
    「ローカルを確認済みにしてから ack」だと、ネットワーク断で ack が
    失敗したとき、UIは「確認済み」で操作不能になり、サーバ側の行は
    永久に残る（孤児行が溜まって受信箱が満杯になる）。**冪等な削除
    （ack）を先に**やれば、逆にローカル更新が失敗しても、再実行の ack は
    削除済みIDに対して0件で無害に成功する。

## プルは ack しない

取得（pull）と削除（ack）は分ける。pull は読むだけ・消さない。消すのは
利用者の明示操作（確認）だけ。これで「取っただけで消えた」を防ぐ。

次: [3-9 xlsx を読み書きする](09_xlsx.md)
