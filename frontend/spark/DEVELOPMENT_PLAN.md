# Spark - 開発計画書

## アプリ概要

**Spark - 8つの才能を発見**

ガードナーの多重知能理論に基づき、8つの知性領域でユーザーの強みを可視化するネイティブアプリ。

- **パッケージ名**: net.timej.spark
- **対応プラットフォーム**: iOS, Android
- **言語**: 日本語（将来的に多言語対応）

---

## 機能要件

### 1. ホーム画面
- アプリの説明
- 「診断を始める」ボタン
- 8つの知性の簡単な紹介

### 2. クイズ画面
- 32問の質問（各知性4問）
- スライダーで0-4の5段階評価
- プログレスバーで進捗表示
- カテゴリごとにグループ化

### 3. 結果画面
- レーダーチャートで8つの知性を可視化
- TOP3の強みをカード表示
- 各知性の詳細説明
- 才能を活かすヒント
- 結果の保存・共有機能

---

## 8つの知性

| ID | 日本語名 | 英語名 | アイコン | カラー |
|----|---------|--------|---------|--------|
| linguistic | 言語的知性 | Linguistic | 📝 | #3b82f6 |
| logical | 論理・数学的知性 | Logical-Mathematical | 🔢 | #8b5cf6 |
| spatial | 空間的知性 | Spatial-Visual | 🎨 | #ec4899 |
| musical | 音楽的知性 | Musical | 🎵 | #f59e0b |
| bodily | 身体・運動的知性 | Bodily-Kinesthetic | ⚽ | #10b981 |
| interpersonal | 対人的知性 | Interpersonal | 🤝 | #f97316 |
| intrapersonal | 内省的知性 | Intrapersonal | 🧘 | #6366f1 |
| naturalistic | 博物的知性 | Naturalistic | 🌿 | #14b8a6 |

---

## ファイル構成

```
lib/
├── main.dart                    # アプリのエントリーポイント
├── app.dart                     # MaterialApp設定
│
├── models/                      # データモデル
│   ├── intelligence.dart        # 知性モデル
│   ├── question.dart            # 質問モデル
│   └── quiz_result.dart         # 結果モデル
│
├── data/                        # 静的データ
│   ├── intelligences_data.dart  # 8つの知性データ
│   └── questions_data.dart      # 32問の質問データ
│
├── screens/                     # 画面
│   ├── home_screen.dart         # ホーム画面
│   ├── quiz_screen.dart         # クイズ画面
│   └── result_screen.dart       # 結果画面
│
├── widgets/                     # 再利用可能なウィジェット
│   ├── intelligence_card.dart   # 知性カード
│   ├── question_item.dart       # 質問アイテム
│   ├── progress_indicator.dart  # プログレスバー
│   └── radar_chart.dart         # レーダーチャート
│
└── theme/                       # テーマ
    └── app_theme.dart           # アプリテーマ設定
```

---

## 開発フェーズ

### Phase 1: 基盤構築 ✅
- [x] Flutterプロジェクト作成
- [ ] テーマ設定（カラー、フォント）
- [ ] 基本的なナビゲーション構造

### Phase 2: データ層
- [ ] 知性モデル作成
- [ ] 質問モデル作成
- [ ] 結果モデル作成
- [ ] 静的データ定義（8知性、32問）

### Phase 3: UI実装
- [ ] ホーム画面
- [ ] クイズ画面（質問表示、スライダー）
- [ ] 結果画面（レーダーチャート、TOP3）

### Phase 4: 機能実装
- [ ] スコア計算ロジック
- [ ] レーダーチャート描画
- [ ] 結果の保存（SharedPreferences）

### Phase 5: 仕上げ
- [ ] アニメーション追加
- [ ] アプリアイコン作成
- [ ] スプラッシュ画面
- [ ] ストア申請準備

---

## 依存パッケージ

```yaml
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.69.0          # レーダーチャート
  shared_preferences: ^2.2.0  # ローカル保存
  provider: ^6.1.0            # 状態管理（必要に応じて）
```

---

## デザイン方針

### カラーパレット
- **プライマリ**: #f59e0b（ゴールド/オレンジ）
- **セカンダリ**: #667eea（紫）
- **背景**: #f7fafc
- **テキスト**: #1a202c

### UI原則
- シンプルで直感的
- 明るくポジティブな印象
- アクセシビリティ考慮

---

## 次のステップ

1. **Phase 2を開始**: データモデルと静的データの作成
2. テーマ設定の実装
3. ホーム画面の作成

---

## 注意事項

- 診断ではなく自己理解のためのツール
- 発達障害を前面に出さない
- ポジティブな表現を使用
