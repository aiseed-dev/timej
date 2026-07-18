# 重要概念#2-3: 画面遷移（ルーターを使わず use_state で）

数画面のアプリなら、ルーティングライブラリは要らない。**上位の
`use_state` に「今どの画面か」を持ち、値で分岐する**だけで足りる。

## App の中で画面を切り替える

```python
@ft.component
def App():
    screen, set_screen = ft.use_state("list")     # "list" | "settings" | "detail"
    selected, set_selected = ft.use_state(None)

    def open_detail(item_id):
        set_selected(item_id)
        set_screen("detail")

    def close_detail():
        set_selected(None)
        set_screen("list")

    if screen == "settings":
        return SettingsView(on_back=lambda: set_screen("list"))
    if screen == "detail" and selected is not None:
        return DetailView(item_id=selected, on_back=close_detail)
    return ListView(on_open=open_detail,
                    on_settings=lambda: set_screen("settings"))
```

- 各画面には **`on_back` などのコールバックを渡す**。子は「戻る」と言うだけ、
  実際に画面を替えるのは App。これで子は自分の外を知らずに済む
- 選択中のIDのような「遷移に付随する状態」も App の `use_state` に置く

## 起動時の初期化（設定済みかで初期画面を変える）

初回ロードで「設定済みか」を判定し、未設定なら設定画面へ:

```python
@ft.component
def App():
    ready, set_ready = ft.use_state(False)
    configured, set_configured = ft.use_state(False)

    async def startup():
        conn = open_db(await data_dir(page))
        set_configured(has_config(conn))
        set_ready(True)

    ft.use_effect(startup, dependencies=[])

    if not ready:
        return ft.Column([ft.ProgressRing()],
                         alignment=ft.MainAxisAlignment.CENTER, expand=True)
    if not configured:
        return SettingsView(is_initial=True, on_saved=lambda: set_configured(True))
    return ListView(...)
```

!!! tip "命令的スタイルなら"
    `@ft.component` を使わない小さなアプリでは、`page.controls.clear()` →
    目的の画面を `page.add(...)` → `page.update()` でも同じことができる。
    どちらでもよい。状態が絡むほど component＋use_state が楽になる。

次: [2-4 テーマとフォント](04_theming.md)
