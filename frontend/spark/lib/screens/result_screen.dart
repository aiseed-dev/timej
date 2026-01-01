import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/intelligences_data.dart';
import 'home_screen.dart';

/// 結果画面
class ResultScreen extends StatelessWidget {
  final Map<String, double> scores;

  const ResultScreen({
    super.key,
    required this.scores,
  });

  List<MapEntry<String, double>> get _sortedScores {
    final entries = scores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  List<MapEntry<String, double>> get _top3 => _sortedScores.take(3).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ヘッダー
              const _ResultHeader(),

              const SizedBox(height: 32),

              // レーダーチャート（プレースホルダー）
              _RadarChartPlaceholder(scores: scores),

              const SizedBox(height: 40),

              // TOP3
              _Top3Section(top3: _top3),

              const SizedBox(height: 32),

              // 詳細分析CTA
              const _DetailAnalysisCTA(),

              const SizedBox(height: 24),

              // アクションボタン
              _ActionButtons(
                onRetry: () => _navigateToHome(context),
              ),

              const SizedBox(height: 40),

              // 免責事項
              const _Disclaimer(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
}

/// 結果ヘッダー
class _ResultHeader extends StatelessWidget {
  const _ResultHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🎉',
          style: TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 16),
        Text(
          'あなたの才能プロファイル',
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: 8),
        Text(
          '8つの知性領域におけるあなたの強み',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

/// レーダーチャート（プレースホルダー）
/// TODO: fl_chartパッケージを追加して実装
class _RadarChartPlaceholder extends StatelessWidget {
  final Map<String, double> scores;

  const _RadarChartPlaceholder({required this.scores});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 簡易的なバー表示
          ...intelligences.map((intel) {
            final score = scores[intel.id] ?? 0;
            final color = AppColors.getIntelligenceColor(intel.id);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(intel.icon, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${score.round()}%',
                      style: AppTextStyles.label,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// TOP3セクション
class _Top3Section extends StatelessWidget {
  final List<MapEntry<String, double>> top3;

  const _Top3Section({required this.top3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'あなたのTOP 3',
              style: AppTextStyles.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...top3.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final intelligence = getIntelligenceById(item.key);
          final color = AppColors.getIntelligenceColor(item.key);

          return _StrengthCard(
            rank: index + 1,
            intelligence: intelligence,
            score: item.value,
            color: color,
          );
        }),
      ],
    );
  }
}

/// 強みカード
class _StrengthCard extends StatelessWidget {
  final int rank;
  final dynamic intelligence;
  final double score;
  final Color color;

  const _StrengthCard({
    required this.rank,
    required this.intelligence,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ランクバッジ
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // アイコンと名前
          Text(
            intelligence.icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intelligence.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  intelligence.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // スコア
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${score.round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 詳細分析CTA
class _DetailAnalysisCTA extends StatelessWidget {
  const _DetailAnalysisCTA();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '📧',
            style: TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 12),
          const Text(
            'AIによる詳細分析を受け取る',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'あなたの才能の組み合わせを、AIがより深く分析してメールでお届けします（無料）',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                // TODO: メール入力ダイアログを表示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('この機能は近日公開予定です')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667eea),
                elevation: 0,
              ),
              child: const Text(
                'メールアドレスを入力',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// アクションボタン
class _ActionButtons extends StatelessWidget {
  final VoidCallback onRetry;

  const _ActionButtons({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('もう一度'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: 共有機能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('共有機能は近日公開予定です')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('共有'),
          ),
        ),
      ],
    );
  }
}

/// 免責事項
class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'このツールは自己理解のための参考情報です。\n医学的・心理学的な診断ではありません。',
      style: AppTextStyles.label.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
