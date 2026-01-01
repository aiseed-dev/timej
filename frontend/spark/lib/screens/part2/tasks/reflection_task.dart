import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 感情一致度タスク（内省的知性）
/// 状況に対する自分の感情を選択し、一貫性を測定
class ReflectionTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const ReflectionTask({
    super.key,
    required this.onComplete,
  });

  @override
  State<ReflectionTask> createState() => _ReflectionTaskState();
}

class _ReflectionTaskState extends State<ReflectionTask> {
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  late DateTime _startTime;

  // 状況と感情の選択肢
  final List<_SituationQuestion> _questions = [
    _SituationQuestion(
      situation: '友人が約束の時間に30分遅れてきた',
      category: 'frustration',
      options: ['イライラする', '心配になる', '気にしない', '悲しくなる'],
    ),
    _SituationQuestion(
      situation: '自分の意見が会議で採用された',
      category: 'achievement',
      options: ['嬉しい', '恥ずかしい', '緊張する', '特に何も感じない'],
    ),
    _SituationQuestion(
      situation: '誰もいない静かな部屋で一人で過ごす',
      category: 'solitude',
      options: ['落ち着く', '寂しい', '退屈', '自由を感じる'],
    ),
    _SituationQuestion(
      situation: '予期せぬ予定変更があった',
      category: 'change',
      options: ['ストレスを感じる', 'ワクワクする', '柔軟に対応できる', '困惑する'],
    ),
    _SituationQuestion(
      situation: '大勢の前でスピーチをする',
      category: 'performance',
      options: ['緊張する', '楽しい', '逃げ出したい', '集中できる'],
    ),
    _SituationQuestion(
      situation: '他人から批判された',
      category: 'criticism',
      options: ['傷つく', '改善の機会と捉える', '怒りを感じる', '無視する'],
    ),
    _SituationQuestion(
      situation: '大切な決断を迫られている',
      category: 'decision',
      options: ['慎重に考える', '直感で決める', '不安を感じる', '人に相談したい'],
    ),
    _SituationQuestion(
      situation: '自分の失敗を振り返る',
      category: 'reflection',
      options: ['学びとして捉える', '後悔する', '忘れようとする', '自分を責める'],
    ),
  ];

  // 一貫性チェック用のペア（同じカテゴリで似た状況）
  final List<_SituationQuestion> _consistencyQuestions = [
    _SituationQuestion(
      situation: '友人が連絡なく約束をキャンセルした',
      category: 'frustration',
      options: ['イライラする', '心配になる', '仕方ないと思う', '悲しくなる'],
    ),
    _SituationQuestion(
      situation: '自分の提案したアイデアが褒められた',
      category: 'achievement',
      options: ['嬉しい', '照れる', '緊張する', '特に何も感じない'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  List<_SituationQuestion> get _allQuestions => [..._questions, ..._consistencyQuestions];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('状況判断'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProgress(),
              const SizedBox(height: 24),
              Expanded(
                child: _currentQuestion < _allQuestions.length
                    ? _buildQuestion()
                    : _buildResult(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '質問 ${_currentQuestion + 1} / ${_allQuestions.length}',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '回答済み: ${_answers.length}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentQuestion + 1) / _allQuestions.length,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.intrapersonal),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    final question = _allQuestions[_currentQuestion];

    return Column(
      children: [
        // 説明
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.intrapersonal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🧘', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'この状況で、あなたはどう感じますか？',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 状況表示
        Container(
          width: double.infinity,
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
              const Text('💭', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              Text(
                question.situation,
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 選択肢
        Expanded(
          child: ListView.builder(
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = _answers[_currentQuestion] == option;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _selectAnswer(option),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.intrapersonal : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.intrapersonal : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 次へボタン
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _answers.containsKey(_currentQuestion) ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.intrapersonal),
            child: Text(_currentQuestion < _allQuestions.length - 1 ? '次へ' : '結果を見る'),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final consistencyScore = _calculateConsistencyScore();
    final responsePatternScore = _calculateResponsePatternScore();
    final totalScore = (consistencyScore + responsePatternScore) / 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🧘', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text('自己認識スコア', style: AppTextStyles.headline),
        const SizedBox(height: 16),
        Text(
          '${totalScore.round()}%',
          style: AppTextStyles.displayLarge.copyWith(color: AppColors.intrapersonal),
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildScoreRow('回答の一貫性', consistencyScore),
              const SizedBox(height: 16),
              _buildScoreRow('自己分析力', responsePatternScore),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.intrapersonal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getResultMessage(totalScore),
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _complete,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.intrapersonal),
            child: const Text('次へ'),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.intrapersonal.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${score.round()}%',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.intrapersonal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getResultMessage(double score) {
    if (score >= 80) {
      return '自己認識が非常に高いです。\n自分の感情を深く理解しています。';
    } else if (score >= 60) {
      return '自己認識が良好です。\n自分の感情パターンを把握しています。';
    } else if (score >= 40) {
      return '自己認識は標準的です。\n時々自分の感情を振り返ると良いでしょう。';
    } else {
      return '自己認識を高めるチャンスがあります。\n日記をつけてみるのはいかがでしょう。';
    }
  }

  double _calculateConsistencyScore() {
    // 一貫性チェック：同じカテゴリの質問に対する回答の類似性
    int consistentPairs = 0;
    int totalPairs = 0;

    // frustrationカテゴリの一貫性
    if (_answers.containsKey(0) && _answers.containsKey(8)) {
      totalPairs++;
      final first = _answers[0]!;
      final second = _answers[8]!;
      // 同じ系統の回答かチェック
      if (_isSimilarResponse(first, second)) {
        consistentPairs++;
      }
    }

    // achievementカテゴリの一貫性
    if (_answers.containsKey(1) && _answers.containsKey(9)) {
      totalPairs++;
      final first = _answers[1]!;
      final second = _answers[9]!;
      if (_isSimilarResponse(first, second)) {
        consistentPairs++;
      }
    }

    if (totalPairs == 0) return 75; // デフォルト値
    return (consistentPairs / totalPairs) * 100;
  }

  bool _isSimilarResponse(String first, String second) {
    // 類似の感情グループ
    final negativeEmotions = ['イライラする', '悲しくなる', '傷つく', '怒りを感じる', 'ストレスを感じる', '困惑する', '緊張する', '不安を感じる', '自分を責める', '後悔する'];
    final neutralEmotions = ['気にしない', '特に何も感じない', '仕方ないと思う', '無視する', '忘れようとする'];
    final positiveEmotions = ['嬉しい', '楽しい', 'ワクワクする', '自由を感じる', '落ち着く', '学びとして捉える', '改善の機会と捉える'];
    final adaptiveEmotions = ['心配になる', '柔軟に対応できる', '人に相談したい', '慎重に考える', '直感で決める', '集中できる'];

    bool inSameGroup(String emotion, List<String> group) {
      return group.any((e) => emotion.contains(e) || e.contains(emotion));
    }

    if (inSameGroup(first, negativeEmotions) && inSameGroup(second, negativeEmotions)) return true;
    if (inSameGroup(first, neutralEmotions) && inSameGroup(second, neutralEmotions)) return true;
    if (inSameGroup(first, positiveEmotions) && inSameGroup(second, positiveEmotions)) return true;
    if (inSameGroup(first, adaptiveEmotions) && inSameGroup(second, adaptiveEmotions)) return true;

    return false;
  }

  double _calculateResponsePatternScore() {
    // 回答の多様性（極端に同じ回答ばかりでないか）
    final answerCounts = <String, int>{};
    for (final answer in _answers.values) {
      answerCounts[answer] = (answerCounts[answer] ?? 0) + 1;
    }

    if (answerCounts.isEmpty) return 50;

    // 最も多い回答の割合
    final maxCount = answerCounts.values.reduce((a, b) => a > b ? a : b);
    final diversity = 1 - (maxCount / _answers.length);

    // 全質問に回答したかどうか
    final completeness = _answers.length / _allQuestions.length;

    return (diversity * 0.5 + completeness * 0.5) * 100;
  }

  void _selectAnswer(String answer) {
    setState(() => _answers[_currentQuestion] = answer);
  }

  void _nextQuestion() {
    if (_currentQuestion < _allQuestions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      setState(() => _currentQuestion = _allQuestions.length); // 結果表示
    }
  }

  void _complete() {
    final duration = DateTime.now().difference(_startTime);
    final consistencyScore = _calculateConsistencyScore();
    final responsePatternScore = _calculateResponsePatternScore();
    final totalScore = (consistencyScore + responsePatternScore) / 2;

    widget.onComplete(TaskResult(
      taskId: 'reflection',
      taskName: '状況判断',
      score: totalScore,
      correctCount: _answers.length,
      totalCount: _allQuestions.length,
      duration: duration,
    ));
  }
}

class _SituationQuestion {
  final String situation;
  final String category;
  final List<String> options;

  const _SituationQuestion({
    required this.situation,
    required this.category,
    required this.options,
  });
}
