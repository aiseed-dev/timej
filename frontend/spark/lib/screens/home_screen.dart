import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/intelligences_data.dart';
import 'quiz_screen.dart';
import 'part2/part2_intro_screen.dart';
import 'part3/part3_intro_screen.dart';

/// ホーム画面
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ロゴ・タイトル
              const _HeaderSection(),

              const SizedBox(height: 40),

              // 3つのパート
              _buildPartCard(
                context,
                icon: '📝',
                title: 'Part 1: 自己診断',
                description: '32問の質問に答えて、8つの知性を可視化',
                color: AppColors.primary,
                onTap: () => _navigateToPart1(context),
              ),

              const SizedBox(height: 16),

              _buildPartCard(
                context,
                icon: '🎯',
                title: 'Part 2: 作業検査',
                description: '8つのミニタスクで能力を測定',
                color: AppColors.secondary,
                onTap: () => _navigateToPart2(context),
              ),

              const SizedBox(height: 16),

              _buildPartCard(
                context,
                icon: '💬',
                title: 'Part 3: 対話で発見',
                description: '自然な会話から強みを見つける',
                color: AppColors.interpersonal,
                onTap: () => _navigateToPart3(context),
              ),

              const SizedBox(height: 32),

              // 8つの知性について
              TextButton(
                onPressed: () => _showIntelligencesInfo(context),
                child: const Text(
                  '8つの知性について →',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  void _navigateToPart1(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
  }

  void _navigateToPart2(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Part2IntroScreen(part1Scores: {}),
      ),
    );
  }

  void _navigateToPart3(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Part3IntroScreen(previousScores: {}),
      ),
    );
  }

  void _showIntelligencesInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _IntelligencesBottomSheet(),
    );
  }
}

/// ヘッダーセクション
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // アイコン
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.warmGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(child: Text('✨', style: TextStyle(fontSize: 48))),
        ),

        const SizedBox(height: 24),

        // タイトル
        const Text('Spark', style: AppTextStyles.displayLarge),

        const SizedBox(height: 8),

        // サブタイトル
        Text(
          '8つの才能を発見',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 8つの知性の説明ボトムシート
class _IntelligencesBottomSheet extends StatelessWidget {
  const _IntelligencesBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ハンドル
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // タイトル
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('8つの知性', style: AppTextStyles.headline),
              ),

              // リスト
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: intelligences.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final intel = intelligences[index];
                    return _IntelligenceListItem(intelligence: intel);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 知性リストアイテム
class _IntelligenceListItem extends StatelessWidget {
  final intelligence;

  const _IntelligenceListItem({required this.intelligence});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getIntelligenceColor(intelligence.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(intelligence.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intelligence.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(intelligence.description, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
