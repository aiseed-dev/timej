import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 表情認識タスク（対人的知性）
class EmotionTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const EmotionTask({super.key, required this.onComplete});

  @override
  State<EmotionTask> createState() => _EmotionTaskState();
}

class _EmotionTaskState extends State<EmotionTask> {
  int _currentQuestion = 0;
  int _correctCount = 0;
  bool _showingResult = false;
  String? _selectedAnswer;
  late DateTime _startTime;

  // 練習問題かどうか
  bool get _isPractice => _currentQuestion == 0;

  // 本番の問題数（練習問題を除く）
  int get _actualQuestionCount => _questions.length - 1;

  // 現在の本番問題番号（練習問題を除く）
  int get _actualQuestionNumber => _currentQuestion - 1;

  // 表情問題データ（最初の1問は練習問題）
  final List<_EmotionQuestion> _questions = [
    // 練習問題
    _EmotionQuestion(
      emoji: '😊',
      correctAnswer: '喜び',
      options: ['喜び', '驚き', '悲しみ', '怒り'],
    ),
    // 本番問題
    _EmotionQuestion(
      emoji: '😢',
      correctAnswer: '悲しみ',
      options: ['喜び', '悲しみ', '怒り', '恐れ'],
    ),
    _EmotionQuestion(
      emoji: '😠',
      correctAnswer: '怒り',
      options: ['嫌悪', '怒り', '悲しみ', '驚き'],
    ),
    _EmotionQuestion(
      emoji: '😲',
      correctAnswer: '驚き',
      options: ['恐れ', '喜び', '驚き', '嫌悪'],
    ),
    _EmotionQuestion(
      emoji: '😨',
      correctAnswer: '恐れ',
      options: ['驚き', '悲しみ', '恐れ', '怒り'],
    ),
    _EmotionQuestion(
      emoji: '🤢',
      correctAnswer: '嫌悪',
      options: ['怒り', '悲しみ', '嫌悪', '恐れ'],
    ),
    _EmotionQuestion(
      emoji: '😏',
      correctAnswer: '軽蔑',
      options: ['喜び', '軽蔑', '驚き', '悲しみ'],
    ),
    _EmotionQuestion(
      emoji: '😌',
      correctAnswer: '安心',
      options: ['悲しみ', '喜び', '安心', '驚き'],
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
        title: const Text('表情認識'),
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
                AppColors.interpersonal,
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
            color: AppColors.interpersonal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🤝', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'この表情が表している感情はどれですか？',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // 表情表示
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(question.emoji, style: const TextStyle(fontSize: 96)),
        ),

        const SizedBox(height: 40),

        // 選択肢
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = _selectedAnswer == option;

              return GestureDetector(
                onTap: () => _selectAnswer(option),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.interpersonal
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.interpersonal
                          : AppColors.divider,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 決定ボタン
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedAnswer != null ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.interpersonal,
            ),
            child: const Text('決定'),
          ),
        ),
      ],
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
        Text(question.emoji, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(isCorrect ? '⭕' : '❌', style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(
          isCorrect ? '正解！' : '不正解',
          style: AppTextStyles.headline.copyWith(
            color: isCorrect ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text('正解: ${question.correctAnswer}', style: AppTextStyles.titleMedium),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.interpersonal,
            ),
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

  void _selectAnswer(String answer) {
    setState(() => _selectedAnswer = answer);
  }

  void _submitAnswer() {
    final question = _questions[_currentQuestion];
    // 練習問題はスコアに含めない
    if (!_isPractice && _selectedAnswer == question.correctAnswer) {
      _correctCount++;
    }
    setState(() => _showingResult = true);
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showingResult = false;
      });
    } else {
      final duration = DateTime.now().difference(_startTime);
      final score = (_correctCount / _actualQuestionCount) * 100;

      widget.onComplete(
        TaskResult(
          taskId: 'emotion',
          taskName: '表情認識',
          score: score,
          correctCount: _correctCount,
          totalCount: _actualQuestionCount,
          duration: duration,
        ),
      );
    }
  }
}

class _EmotionQuestion {
  final String emoji;
  final String correctAnswer;
  final List<String> options;

  const _EmotionQuestion({
    required this.emoji,
    required this.correctAnswer,
    required this.options,
  });
}
