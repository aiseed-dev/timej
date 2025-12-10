# Gemini 画像生成自動化スクリプト マニュアル

このスクリプトは、ブラウザ（Chrome）を自動操作して、Gemini Web版で画像を生成するためのツールです。
お客様のGoogleアカウント（Gemini Advanced等）の権限で動作するため、API課金なしで高品質な画像生成が可能です。

## 1. 準備（初回のみ）

### ライブラリのインストール
ターミナルで以下のコマンドを実行して、必要なツールをインストールします。

```bash
pip install playwright
playwright install chromium
```

## 2. ブラウザの起動

スクリプトを実行する前に、**デバッグモード**でChromeを起動しておく必要があります。
これにより、普段のログイン状態をスクリプトから利用できるようになります。

### 手順
1.  現在開いているChromeをすべて閉じます（推奨）。
    *   ※ 閉じたくない場合は、別のプロファイル（`--user-data-dir`）を指定すれば共存可能です。
2.  以下のコマンドでChromeを起動します。

```bash
# 現在のディレクトリにプロファイルを作成して起動する場合（推奨）
google-chrome --remote-debugging-port=9222 --user-data-dir=./chrome-profile
```

3.  起動したChromeで [https://gemini.google.com](https://gemini.google.com) にアクセスし、**Googleアカウントにログイン**してください。

## 3. 画像生成の実行

Chromeが起動した状態で、別のターミナルを開き、スクリプトを実行します。

```bash
# 基本的な使い方
python scripts/generate_images_playwright.py "プロンプト（生成したい画像の説明）"

# 例：サイバーパンクな都市の画像
python scripts/generate_images_playwright.py "A cyberpunk city with neon lights, high quality, 4k"
```

### 動作の流れ
1.  スクリプトが起動中のChromeに接続します。
2.  Geminiのタブを探し（なければ開きます）、プロンプトを入力します。
3.  画像の生成を待ちます（約20秒）。
4.  結果の確認用スクリーンショットを `generated_images` フォルダに保存します。
5.  ブラウザで生成された画像を確認し、気に入れば手動でダウンロードしてください。

## トラブルシューティング

*   **エラー: `Connection refused`**
    *   Chromeがデバッグモード（ポート9222）で起動していません。手順2のコマンドでChromeを起動しているか確認してください。
*   **入力欄が見つからない**
    *   Geminiにログインしていない可能性があります。起動したChromeでログインしているか確認してください。
