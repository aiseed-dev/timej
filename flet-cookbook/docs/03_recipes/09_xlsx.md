# レシピ#3-9: xlsx を読み書きする（名簿・台帳の出力）

業務アプリは「一覧を Excel で出したい」が必ず来る。表計算は表の編集・
共有に強く、OnlyOffice / LibreOffice でも開ける。

## 素直に openpyxl

アプリ（サーバ・職員側）なら openpyxl が手軽:

```python
import openpyxl

def export_roster(rows, path):
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "名簿"
    ws.append(["受付番号", "氏名", "メール"])       # 見出し
    for r in rows:
        ws.append([r["no"], r["name"], r["email"]])
    wb.save(path)
```

読むのも `openpyxl.load_workbook(path)` で行を回すだけ。**申込様式を
xlsx で配って記入・返送してもらい、`load_workbook` で自動取り込み**、と
いう運用も組める（Webフォームを作らずに済む）。

## 依存を足したくないなら stdlib だけでも書ける

xlsx は実体が zip + XML なので、`zipfile` と `xml` だけで最小の読み書きが
書ける（openpyxl を同梱したくない・ゼロ依存を保ちたいアプリ向け）。
セルを inline string で書けば `sharedStrings` も要らない。要点だけ:

```python
import io, zipfile
from xml.sax.saxutils import escape

def _sheet_xml(rows):
    out = ['<?xml version="1.0"?><worksheet '
           'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
           '<sheetData>']
    for ri, row in enumerate(rows, 1):
        out.append(f'<row r="{ri}">')
        for ci, v in enumerate(row):
            col = chr(65 + ci)                      # A,B,C…（26列まで簡易）
            out.append(f'<c r="{col}{ri}" t="inlineStr">'
                       f'<is><t>{escape(str(v))}</t></is></c>')
        out.append('</row>')
    out.append('</sheetData></worksheet>')
    return ''.join(out)
```

（実用には `[Content_Types].xml` / `_rels` / `workbook.xml` / `styles.xml`
も要る。フル実装は 200 行ほどで収まる。表計算1枚の出力なら十分。）

!!! tip "どちらを選ぶか"
    帳票を色々出すサーバ/職員アプリ → **openpyxl**（罫線・書式が楽）。
    配布アプリで依存を絞りたい → **stdlib 最小実装**。用途で選ぶ。

## 表 → Markdown / AsciiDoc

読み込んだ表を文書に埋めるなら、Markdown 表や AsciiDoc 表に変換する。
`|` を含むセルは各記法のエスケープ（Markdownは `\|`、AsciiDocも `\|`）を
忘れずに ── これを怠るとセルが割れて表が崩れる。

次: [3-10 配布する（flet build）](10_distribution.md)
