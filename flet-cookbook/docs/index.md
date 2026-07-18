# 🍳 AI x Flet Cookbook

**Python から出ずにアプリを届ける。** AI をエージェントに、Flet で
iOS / Android / Web / デスクトップへ ── 一つの Python コードから。

[AI x Flutter Cookbook](../cookbook/) の姉妹編です。Flutter が
「Dart で書く外側の出口」なら、Flet は **「Python のまま人に届ける出口」**。
自分のための道具（Linux + Python + AI）を書いている人が、その延長で
アプリまで出せる ── 言語を切り替えず、同じ頭のまま。

---

## このCookbookの立ち位置

このCookbookは [AIネイティブな仕事の作法](https://aiseed.dev/ai-native-ways/)（構造）の、
**アプリ層**の実践レシピです。「人が何を作るか・誰に届けるかを決め、コードはAIが書く」を、
Fletで具体化します。

| レイヤー | 道具 | 役割 |
|---|---|---|
| 内側 — 自分のための道具 | Linux + Python + AI | 自動化・分析・データ処理 |
| 外側 — 人に届ける出口 | **Flet（Python）** / Flutter（Dart） | 解決策をアプリとして届ける |

Flet は Flutter の描画エンジンを Python から動かす。だから **UI も業務
ロジックも同じ Python・同じプロセス**で書ける。パイプライン（データ処理）を
そのまま呼べるのが強みで、実際このCookbookのレシピの多くは、青空文庫の
変換パイプライン（pybunko）を工作員アプリ（Flet）から直接叩いた実装から
生まれている。

!!! note "このCookbookの流儀"
    レシピは**実際に作って踏んだこと**だけを書く。特に「3. 実戦レシピ」は、
    公式ドキュメントにまだ無い一次情報（バージョン移行の破壊的変更・
    UIスレッドの罠・外部プロセス連携）を、動かして確かめた形で残している。

## 章立て

1. **台所の準備** — インストール・`flet run`・同梱Python/`flet build`・
   プロジェクト構成と自己完結コントロール
2. **Fletの重要概念** — page と control・状態(use_state/use_ref/use_effect)・
   画面遷移・テーマとフォント
3. **実戦レシピ** — 0.86 移行の落とし穴・UIスレッド・外部プロセス連携・
   ダイアログ・メニューとショートカット・SQLite・Pythonパイプライン直呼び・
   プル型同期とデータ保全・xlsx・配布
4. **救急箱** — 症状から引く詰まり集

## まず動かす

```bash
pip install "flet[all]"
flet create my_app && cd my_app
flet run                    # デスクトップ
flet run --web              # ブラウザ
```

次: [1-1 Flet をインストールする](01_the_kitchen/01_install.md)。
