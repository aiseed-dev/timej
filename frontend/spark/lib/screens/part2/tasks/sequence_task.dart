import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 数列完成タスク（論理・数学的知性）
class SequenceTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const SequenceTask({super.key, required this.onComplete});

  @override
  State<SequenceTask> createState() => _SequenceTaskState();
}

class _SequenceTaskState extends State<SequenceTask> {
  int _currentQuestion = 0;
  int _correctCount = 0;
  bool _showingResult = false;
  int? _selectedAnswer;
  late DateTime _startTime;

  // 練習問題かどうか
  bool get _isPractice => _currentQuestion == 0;

  // 本番の問題数（練習問題を除く）
  int get _actualQuestionCount => _questions.length - 1;

  // 現在の本番問題番号（練習問題を除く）
  int get _actualQuestionNumber => _currentQuestion - 1;

  // 数列問題データ（最初の1問は練習問題）
  final List<_SequenceQuestion> _questions = [
    // 練習問題
    _SequenceQuestion(
      sequence: [2, 4, 6, 8],
      correctAnswer: 10,
      options: [9, 10, 11, 12],
      hint: '+2ずつ増加',
    ),
    // 本番問題
    _SequenceQuestion(
      sequence: [1, 2, 4, 8],
      correctAnswer: 16,
      options: [12, 14, 16, 20],
      hint: '×2ずつ増加',
    ),
    _SequenceQuestion(
      sequence: [1, 1, 2, 3, 5],
      correctAnswer: 8,
      options: [6, 7, 8, 10],
      hint: 'フィボナッチ数列',
    ),
    _SequenceQuestion(
      sequence: [3, 6, 9, 12],
      correctAnswer: 15,
      options: [14, 15, 16, 18],
      hint: '+3ずつ増加',
    ),
    _SequenceQuestion(
      sequence: [1, 4, 9, 16],
      correctAnswer: 25,
      options: [20, 23, 25, 27],
      hint: '平方数（1², 2², 3², 4²...）',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数列完成'),
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
              // プログレス
              _buildProgress(),
              const SizedBox(height: 32),

              // 問題
              Expanded(
                child: _showingResult
                    ? _buildResultFeedback()
                    : _buildQuestion(),
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
            if (_isPractice)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '練習問題',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                '問題 ${_actualQuestionNumber + 1} / $_actualQuestionCount',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_correctCount正解',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isPractice)
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_actualQuestionNumber + 1) / _actualQuestionCount,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.logical,
              ),
              minHeight: 8,
            ),
          ),
      ],
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_currentQuestion];

    return Column(
      children: [
        // 練習表示
        if (_isPractice)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Text(
              '🎯 これは練習です（スコアには含まれません）',
              style: AppTextStyles.label.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // 説明
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.logical.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🔢', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '数列の規則を見つけて、次に来る数を選んでください',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // 数列表示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...question.sequence.map(
                (num) => _buildNumberBox(num.toString()),
              ),
              _buildNumberBox('?', isQuestion: true),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // 選択肢
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: question.options.map((option) {
            final isSelected = _selectedAnswer == option;
            return GestureDetector(
              onTap: () => _selectAnswer(option),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.logical : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.logical : AppColors.divider,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.logical.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    option.toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const Spacer(),

        // 確定ボタン
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedAnswer != null ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.logical),
            child: const Text('決定'),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberBox(String text, {bool isQuestion = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isQuestion
            ? AppColors.logical.withOpacity(0.2)
            : AppColors.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: isQuestion
            ? Border.all(color: AppColors.logical, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isQuestion ? AppColors.logical : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildResultFeedback() {
    final question = _questions[_currentQuestion];
    final isCorrect = _selectedAnswer == question.correctAnswer;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isPractice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '練習問題の結果',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Text(isCorrect ? '⭕' : '❌', style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        Text(
          isCorrect ? '正解！' : '不正解',
          style: AppTextStyles.headline.copyWith(
            color: isCorrect ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text('正解: ${question.correctAnswer}', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Text(
          'ヒント: ${question.hint}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.logical),
            child: Text(
              _isPractice
                  ? '本番へ進む'
                  : (_currentQuestion < _questions.length - 1 ? '次へ' : '結果を見る'),
            ),
          ),
        ),
      ],
    );
  }

  void _selectAnswer(int answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    final question = _questions[_currentQuestion];
    final isCorrect = _selectedAnswer == question.correctAnswer;

    // 練習問題はスコアに含めない
    if (!_isPractice && isCorrect) {
      _correctCount++;
    }

    setState(() {
      _showingResult = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showingResult = false;
      });
    } else {
      // 完了
      final duration = DateTime.now().difference(_startTime);
      final score = (_correctCount / _actualQuestionCount) * 100;

      widget.onComplete(
        TaskResult(
          taskId: 'sequence',
          taskName: '数列完成',
          score: score,
          correctCount: _correctCount,
          totalCount: _actualQuestionCount,
          duration: duration,
        ),
      );
    }
  }
}

/// 数列問題データクラス
class _SequenceQuestion {
  final List<int> sequence;
  final int correctAnswer;
  final List<int> options;
  final String hint;

  const _SequenceQuestion({
    required this.sequence,
    required this.correctAnswer,
    required this.options,
    required this.hint,
  });
}
