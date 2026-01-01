import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/questions_data.dart';
import '../data/intelligences_data.dart';
import '../models/intelligence.dart';
import 'result_screen.dart';

/// クイズ画面（知性ごとに4問表示）
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIntelligenceIndex = 0;
  final Map<String, List<int>> _answers = {};

  Intelligence get _currentIntelligence =>
      intelligences[_currentIntelligenceIndex];

  List<Question> get _currentQuestions =>
      questions.where((q) => q.intelligenceId == _currentIntelligence.id).toList();

  int get _totalIntelligences => intelligences.length;
  double get _progress => (_currentIntelligenceIndex + 1) / _totalIntelligences;

  @override
  void initState() {
    super.initState();
    // 各知性のスコアを初期化
    for (final intel in intelligences) {
      _answers[intel.id] = List.filled(4, 2); // デフォルト値2
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getIntelligenceColor(_currentIntelligence.id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            _Header(
              currentIndex: _currentIntelligenceIndex,
              total: _totalIntelligences,
              onBack: _handleBack,
            ),

            // プログレスバー
            _ProgressBar(progress: _progress, color: color),

            // コンテンツ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // 知性ヘッダー
                    _IntelligenceHeader(
                      intelligence: _currentIntelligence,
                      color: color,
                    ),

                    const SizedBox(height: 24),

                    // 4つの質問
                    ..._currentQuestions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return _QuestionItem(
                        index: index + 1,
                        question: question.text,
                        value: _answers[_currentIntelligence.id]![index],
                        color: color,
                        onChanged: (value) {
                          setState(() {
                            _answers[_currentIntelligence.id]![index] = value;
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 32),

                    // ナビゲーションボタン
                    _NavigationButtons(
                      isFirst: _currentIntelligenceIndex == 0,
                      isLast: _currentIntelligenceIndex == _totalIntelligences - 1,
                      color: color,
                      onPrevious: _handlePrevious,
                      onNext: _handleNext,
                    ),

                    const SizedBox(height: 24),
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
    if (_currentIntelligenceIndex > 0) {
      setState(() => _currentIntelligenceIndex--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handlePrevious() {
    if (_currentIntelligenceIndex > 0) {
      setState(() => _currentIntelligenceIndex--);
    }
  }

  void _handleNext() {
    if (_currentIntelligenceIndex < _totalIntelligences - 1) {
      setState(() => _currentIntelligenceIndex++);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final scores = _calculateScores();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(scores: scores),
      ),
    );
  }

  Map<String, double> _calculateScores() {
    final normalizedScores = <String, double>{};

    for (final entry in _answers.entries) {
      final intelligenceId = entry.key;
      final scores = entry.value;
      final total = scores.reduce((a, b) => a + b);
      // 16点満点を100%に正規化
      normalizedScores[intelligenceId] = (total / 16) * 100;
    }

    return normalizedScores;
  }
}

/// ヘッダー
class _Header extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onBack;

  const _Header({
    required this.currentIndex,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              '${currentIndex + 1} / $total',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // バランス用
        ],
      ),
    );
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
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

/// 知性ヘッダー
class _IntelligenceHeader extends StatelessWidget {
  final Intelligence intelligence;
  final Color color;

  const _IntelligenceHeader({
    required this.intelligence,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            intelligence.icon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intelligence.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  intelligence.englishName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 質問アイテム
class _QuestionItem extends StatelessWidget {
  final int index;
  final String question;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _QuestionItem({
    required this.index,
    required this.question,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 質問番号と質問文
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: AppTextStyles.bodyLarge.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // スライダー
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.divider,
              thumbColor: Colors.white,
              overlayColor: color.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 3,
              ),
              trackHeight: 6,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),

          // ラベル
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('当てはまらない', style: AppTextStyles.label),
                Text('非常に当てはまる', style: AppTextStyles.label),
              ],
            ),
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
  final Color color;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationButtons({
    required this.isFirst,
    required this.isLast,
    required this.color,
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
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: color, width: 2),
                foregroundColor: color,
              ),
              child: const Text('前へ'),
            ),
          ),
        if (!isFirst) const SizedBox(width: 16),
        Expanded(
          flex: isFirst ? 1 : 1,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isLast ? '結果を見る' : '次の知性へ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
