import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/task_result.dart';
import '../../data/intelligences_data.dart';
import '../result_screen.dart';

/// Part2結果画面
class Part2ResultScreen extends StatelessWidget {
  final Map<String, double> part1Scores;
  final Part2Result part2Result;

  const Part2ResultScreen({
    super.key,
    required this.part1Scores,
    required this.part2Result,
  });

  Map<String, double> get _combinedScores {
    final combined = <String, double>{};
    final part2Scores = part2Result.scoresByIntelligence;

    for (final intel in intelligences) {
      final part1 = part1Scores[intel.id] ?? 0;
      final part2 = part2Scores[intel.id] ?? 0;

      // Part1とPart2の重み付け平均（Part2がある場合は50:50、ない場合はPart1のみ）
      if (part2 > 0) {
        combined[intel.id] = (part1 * 0.5 + part2 * 0.5);
      } else {
        combined[intel.id] = part1;
      }
    }

    return combined;
  }

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
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Part 2 完了！',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 8),
              Text(
                '作業検査の結果',
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 32),

              // タスク別結果
              _TaskResultsCard(results: part2Result.taskResults),

              const SizedBox(height: 24),

              // スコア比較
              _ScoreComparisonCard(
                part1Scores: part1Scores,
                part2Scores: part2Result.scoresByIntelligence,
              ),

              const SizedBox(height: 32),

              // 総合結果を見るボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showFinalResult(context),
                  child: const Text('総合結果を見る'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showFinalResult(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ResultScreen(scores: _combinedScores),
      ),
      (route) => false,
    );
  }
}

/// タスク別結果カード
class _TaskResultsCard extends StatelessWidget {
  final Map<String, TaskResult> results;

  const _TaskResultsCard({required this.results});

  @override
  Widget build(BuildContext context) {
    final taskOrder = [
      'sequence',
      'memory',
      'spatial',
      'rhythm',
      'reaction',
      'emotion',
      'reflection',
      'classify',
    ];

    final taskInfo = {
      'sequence': ('🔢', 'logical'),
      'memory': ('📝', 'linguistic'),
      'spatial': ('🎨', 'spatial'),
      'rhythm': ('🎵', 'musical'),
      'reaction': ('⚽', 'bodily'),
      'emotion': ('🤝', 'interpersonal'),
      'reflection': ('🧘', 'intrapersonal'),
      'classify': ('🌿', 'naturalistic'),
    };

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'タスク別スコア',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          ...taskOrder.map((taskId) {
            final result = results[taskId];
            final info = taskInfo[taskId]!;
            final color = AppColors.getIntelligenceColor(info.$2);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(info.$1, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              result?.taskName ?? taskId,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              result != null ? '${result.score.round()}%' : '-',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (result?.score ?? 0) / 100,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
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

/// スコア比較カード
class _ScoreComparisonCard extends StatelessWidget {
  final Map<String, double> part1Scores;
  final Map<String, double> part2Scores;

  const _ScoreComparisonCard({
    required this.part1Scores,
    required this.part2Scores,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Part1 vs Part2',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '自己評価（Part1）と実際のパフォーマンス（Part2）を比較しました。\n違いがあるのは自然なことです。',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildComparisonSummary(),
        ],
      ),
    );
  }

  Widget _buildComparisonSummary() {
    // 最も差が大きい知性を見つける
    String? maxDiffIntel;
    double maxDiff = 0;
    bool part2Higher = false;

    for (final intel in intelligences) {
      final p1 = part1Scores[intel.id] ?? 0;
      final p2 = part2Scores[intel.id] ?? 0;
      final diff = (p2 - p1).abs();

      if (diff > maxDiff) {
        maxDiff = diff;
        maxDiffIntel = intel.id;
        part2Higher = p2 > p1;
      }
    }

    if (maxDiffIntel == null || maxDiff < 10) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              '自己評価と実力がよく一致しています！',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    final intel = getIntelligenceById(maxDiffIntel);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${intel.icon} ${intel.name}',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            part2Higher
                ? '実際のパフォーマンスが自己評価より高いです！\n隠れた才能かもしれません。'
                : '自己評価より実際のスコアが低めでした。\n練習で伸ばせる分野です。',
            style: AppTextStyles.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
