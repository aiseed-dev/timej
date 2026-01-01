import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../data/intelligences_data.dart';
import '../result_screen.dart';
import 'part2_flow_screen.dart';

/// Part2開始画面
class Part2IntroScreen extends StatelessWidget {
  final Map<String, double> part1Scores;

  const Part2IntroScreen({
    super.key,
    required this.part1Scores,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ヘッダー
              const Text(
                '🎯',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 24),

              Text(
                'Part 2: 作業検査',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),

              Text(
                '実際のミニタスクで\nあなたの能力を測定します',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // タスク一覧
              _TaskListCard(),

              const SizedBox(height: 32),

              // 所要時間
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '所要時間: 約5〜10分',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 開始ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _startPart2(context),
                  child: const Text('作業検査を始める'),
                ),
              ),

              const SizedBox(height: 16),

              // スキップボタン
              TextButton(
                onPressed: () => _skipToResult(context),
                child: Text(
                  'スキップして結果を見る',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _startPart2(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Part2FlowScreen(part1Scores: part1Scores),
      ),
    );
  }

  void _skipToResult(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(scores: part1Scores),
      ),
    );
  }
}

/// タスク一覧カード
class _TaskListCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = [
      ('sequence', '🔢', '数列完成', '規則を見つけて次の数を予測'),
      ('memory', '📝', '単語記憶', '表示された単語を記憶'),
      ('spatial', '🎨', '図形回転', '回転した図形を選択'),
      ('rhythm', '🎵', 'リズム', 'パターンを再現'),
      ('reaction', '⚽', '反応速度', 'すばやくタップ'),
      ('emotion', '🤝', '表情認識', '感情を読み取る'),
      ('reflection', '🧘', '状況判断', '自分の感情を選択'),
      ('classify', '🌿', '分類', 'カテゴリに分類'),
    ];

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
            '8つのミニタスク',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          ...tasks.map((task) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.getIntelligenceColor(
                      _getIntelligenceId(task.$1),
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      task.$2,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.$3,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        task.$4,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getIntelligenceId(String taskId) {
    final mapping = {
      'sequence': 'logical',
      'memory': 'linguistic',
      'spatial': 'spatial',
      'rhythm': 'musical',
      'reaction': 'bodily',
      'emotion': 'interpersonal',
      'reflection': 'intrapersonal',
      'classify': 'naturalistic',
    };
    return mapping[taskId] ?? 'logical';
  }
}
