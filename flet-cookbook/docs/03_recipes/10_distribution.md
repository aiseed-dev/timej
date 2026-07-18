# レシピ#3-10: 配布する（flet build）

`flet build` で各プラットフォーム向けの実行物を作る。同梱の勘所は
[1-2](../01_the_kitchen/02_bundled_python.md) に、ここでは各OSの実際を。

## ビルドコマンド

```bash
flet build apk        # Android
flet build ipa        # iOS（要 macOS + Xcode）
flet build macos      # macOS .app
flet build windows    # Windows
flet build linux      # Linux
flet build web        # 静的Web（配信）
```

初回はビルド用のツールチェーン取得に時間がかかる。CI で回すのが楽。

## 事前チェック（これで大半のハマりが消える）

- [ ] `requirements.txt` に同梱依存を書いた（空だと flet だけ同梱→
      実行時 ModuleNotFoundError。[1-2](../01_the_kitchen/02_bundled_python.md)）
- [ ] 同梱の隣に書き込んでいない（0.86 は読み取り専用→
      `FLET_APP_STORAGE_DATA`）
- [ ] ネイティブwheelの無い依存があれば `--python-version 3.12`
- [ ] `assets_dir` を `ft.run(..., assets_dir="assets")` で指定した

## プラットフォーム別の実際

| OS | 署名・配布 |
|---|---|
| **Android** | APK直接配布 or Playストア。ストアは AAB（`flet build aab`）とアップロード鍵 |
| **iOS** | ストアのみ現実的。Apple Developer登録・証明書・プロビジョニング。macOS + Xcode 必須 |
| **Windows** | **コード署名が実質必須**（未署名は SmartScreen 警告）。証明書 or Microsoft Store 経由 |
| **macOS** | 配布するなら Apple の notarization（公証） |
| **Linux** | 直接配布（tar/AppImage 等）。署名の縛りは緩い |
| **Web** | 静的ファイルを any の静的ホスティングへ。Pythonは配信側で動く |

!!! note "ストアとライセンス"
    GPL系ライセンスは Apple App Store の規約と衝突するという通説がある
    （VLC の事例）。ストア配布するアプリのライセンスは早めに確認する。
    著作権者が自分の著作物を別条件で配布する（デュアルライセンス）のは
    可能。

## CI で各OSをビルドする

GitHub Actions の各OSランナーで `flet build` を回し、成果物を
アーティファクトに。iOS/macOS は `macos-latest`、Windows は
`windows-latest`。署名鍵はシークレットに置く。手元に全OSを揃えなくて
済むのが CI の利点。

次: [3-11 FilePicker](11_filepicker.md)
