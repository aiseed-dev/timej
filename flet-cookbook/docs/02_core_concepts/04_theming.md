# 重要概念#2-4: テーマとフォント（日本語もきれいに）

## テーマ

```python
def main(page: ft.Page):
    page.theme_mode = ft.ThemeMode.LIGHT          # LIGHT / DARK / SYSTEM
    page.theme = ft.Theme(color_scheme_seed=ft.Colors.INDIGO)
```

`color_scheme_seed` に1色を渡すと、Material の配色一式が生成される。
細かく決めたいなら `ft.ColorScheme(...)` を直接渡す。ダーク版は
`page.dark_theme` に別途。

## 日本語フォントを同梱する

既定フォントは日本語が今ひとつなことがある。フォントファイルを
`assets/` に置いて登録する:

```python
def main(page: ft.Page):
    page.fonts = {
        "Body": "fonts/NotoSansJP-Regular.ttf",
        "Mincho": "fonts/ipaexm.ttf",             # 明朝（外字も要るなら）
    }
    page.theme = ft.Theme(font_family="Body")


ft.run(main, assets_dir="assets")
```

- `ft.run(..., assets_dir="assets")` を忘れると `assets/` が配信されない
- 個々のコントロールは `ft.Text("…", font_family="Mincho")` で上書きできる

!!! note "Web版のフォントはシンボリックリンク不可"
    Web で配信するとき、`assets/fonts/` に**実ファイル**を置く。
    シンボリックリンクは配信サーバ（StaticFiles）が辿らないことがある。
    共有フォントは起動時に実コピーしておくと確実。

## 色とテーマ定数を一箇所に

アプリ全体で使う色・サイズは、モジュール先頭に定数で置くと散らからない:

```python
INK = ft.Colors.with_opacity(0.87, ft.Colors.BLACK)
SHU = "#B7282E"          # 差し色（朱）
BODY = 15                # 本文サイズ
CAPTION = 12
```

これは「自己完結・状態管理ライブラリなし」の流儀と相性がよい
（[1-3 プロジェクト構成](../01_the_kitchen/03_project_structure.md)）。

次: [3-1 0.85→0.86 の移行](../03_recipes/01_migrating_085_to_086.md)
