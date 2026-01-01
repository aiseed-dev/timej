import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/questions_data.dart';
import '../data/intelligences_data.dart';
import '../models/intelligence.dart';
import 'result_screen.dart';

/// クイズ画面
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  Question get _currentQuestion => questions[_currentIndex];
  int get _totalQuestions => questions.length;
  double get _progress => (_currentIndex + 1) / _totalQuestions;

  @override
  Widget build(BuildContext context) {
    final intelligence = getIntelligenceById(_currentQuestion.intelligenceId);
    final color = AppColors.getIntelligenceColor(_currentQuestion.intelligenceId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _handleBack(),
        ),
        title: Text(
          '${_currentIndex + 1} / $_totalQuestions',
          style: AppTextStyles.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // プログレスバー
            _ProgressBar(progress: _progress, color: color),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // カテゴリ表示
                    _CategoryBadge(
                      icon: intelligence.icon,
                      name: intelligence.name,
                      color: color,
                    ),

                    const SizedBox(height: 32),

                    // 質問カード
                    _QuestionCard(
                      question: _currentQuestion.text,
                      value: _answers[_currentIndex] ?? 2,
                      onChanged: (value) {
                        setState(() {
                          _answers[_currentIndex] = value;
                        });
                      },
                    ),

                    const SizedBox(height: 40),

                    // ナビゲーションボタン
                    _NavigationButtons(
                      isFirst: _currentIndex == 0,
                      isLast: _currentIndex == _totalQuestions - 1,
                      onPrevious: _handlePrevious,
                      onNext: _handleNext,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handlePrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _handleNext() {
    // 現在の質問に回答がなければデフォルト値を設定
    _answers.putIfAbsent(_currentIndex, () => 2);

    if (_currentIndex < _totalQuestions - 1) {
      setState(() => _currentIndex++);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    // スコア計算
    final scores = _calculateScores();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(scores: scores),
      ),
    );
  }

  Map<String, double> _calculateScores() {
    final scoresByIntelligence = <String, List<int>>{};

    // 知性ごとにスコアを集計
    for (var i = 0; i < questions.length; i++) {
      final intelligenceId = questions[i].intelligenceId;
      final score = _answers[i] ?? 2;
      scoresByIntelligence.putIfAbsent(intelligenceId, () => []).add(score);
    }

    // 平均を計算して正規化（0-100%）
    final normalizedScores = <String, double>{};
    for (final entry in scoresByIntelligence.entries) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      normalizedScores[entry.key] = (average / 4) * 100;
    }

    return normalizedScores;
  }
}

/// プログレスバー
class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ProgressBar({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// カテゴリバッジ
class _CategoryBadge extends StatelessWidget {
  final String icon;
  final String name;
  final Color color;

  const _CategoryBadge({
    required this.icon,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// 質問カード
class _QuestionCard extends StatelessWidget {
  final String question;
  final int value;
  final ValueChanged<int> onChanged;

  const _QuestionCard({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // 質問テキスト
          Text(
            question,
            style: AppTextStyles.titleLarge.copyWith(
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // スライダー
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: Colors.white,
              overlayColor: AppColors.primary.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 4,
              ),
              trackHeight: 8,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),

          const SizedBox(height: 8),

          // ラベル
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '当てはまらない',
                style: AppTextStyles.label,
              ),
              Text(
                '非常に当てはまる',
                style: AppTextStyles.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ナビゲーションボタン
class _NavigationButtons extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationButtons({
    required this.isFirst,
    required this.isLast,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isFirst)
          Expanded(
            child: OutlinedButton(
              onPressed: onPrevious,
              child: const Text('戻る'),
            ),
          ),
        if (!isFirst) const SizedBox(width: 16),
        Expanded(
          flex: isFirst ? 1 : 1,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Text(isLast ? '結果を見る' : '次へ'),
            ),
          ),
        ),
      ],
    );
  }
}
