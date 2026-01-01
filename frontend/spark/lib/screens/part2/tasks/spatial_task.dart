import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 図形回転タスク（空間的知性）
class SpatialTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const SpatialTask({
    super.key,
    required this.onComplete,
  });

  @override
  State<SpatialTask> createState() => _SpatialTaskState();
}

class _SpatialTaskState extends State<SpatialTask> {
  int _currentQuestion = 0;
  int _correctCount = 0;
  bool _showingResult = false;
  int? _selectedAnswer;
  late DateTime _startTime;

  // 問題データ
  final List<_SpatialQuestion> _questions = [
    _SpatialQuestion(shape: _ShapeType.L, rotations: [0, 90, 180, 270], correctIndex: 1),
    _SpatialQuestion(shape: _ShapeType.T, rotations: [0, 90, 180, 270], correctIndex: 2),
    _SpatialQuestion(shape: _ShapeType.arrow, rotations: [0, 90, 180, 270], correctIndex: 0),
    _SpatialQuestion(shape: _ShapeType.plus, rotations: [0, 45, 90, 135], correctIndex: 2),
    _SpatialQuestion(shape: _ShapeType.house, rotations: [0, 90, 180, 270], correctIndex: 3),
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
        title: const Text('図形回転'),
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
                child: _showingResult ? _buildResultFeedback() : _buildQuestion(),
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
              '問題 ${_currentQuestion + 1} / ${_questions.length}',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_correctCount正解',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.spatial),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_currentQuestion];
    final targetRotation = question.rotations[question.correctIndex];

    return Column(
      children: [
        // 説明
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.spatial.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🎨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '左の図形を ${targetRotation}° 回転させると、どれになりますか？',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 基準図形
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '基準図形',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _ShapePainter(question.shape, 0, AppColors.spatial),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 選択肢
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final isSelected = _selectedAnswer == index;
              // シャッフルされた回転角度
              final displayRotation = (index * 90) % 360;

              return GestureDetector(
                onTap: () => _selectAnswer(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.spatial.withOpacity(0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.spatial : AppColors.divider,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${String.fromCharCode(65 + index)}',
                        style: AppTextStyles.label.copyWith(
                          color: isSelected ? AppColors.spatial : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CustomPaint(
                          painter: _ShapePainter(
                            question.shape,
                            question.rotations[index].toDouble(),
                            isSelected ? AppColors.spatial : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.spatial),
            child: const Text('決定'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultFeedback() {
    final question = _questions[_currentQuestion];
    final isCorrect = _selectedAnswer == question.correctIndex;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isCorrect ? '⭕' : '❌',
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        Text(
          isCorrect ? '正解！' : '不正解',
          style: AppTextStyles.headline.copyWith(
            color: isCorrect ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '正解は ${String.fromCharCode(65 + question.correctIndex)} でした',
          style: AppTextStyles.bodyMedium,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.spatial),
            child: Text(_currentQuestion < _questions.length - 1 ? '次へ' : '結果を見る'),
          ),
        ),
      ],
    );
  }

  void _selectAnswer(int index) {
    setState(() => _selectedAnswer = index);
  }

  void _submitAnswer() {
    final question = _questions[_currentQuestion];
    if (_selectedAnswer == question.correctIndex) {
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
      final score = (_correctCount / _questions.length) * 100;

      widget.onComplete(TaskResult(
        taskId: 'spatial',
        taskName: '図形回転',
        score: score,
        correctCount: _correctCount,
        totalCount: _questions.length,
        duration: duration,
      ));
    }
  }
}

enum _ShapeType { L, T, arrow, plus, house }

class _SpatialQuestion {
  final _ShapeType shape;
  final List<int> rotations;
  final int correctIndex;

  const _SpatialQuestion({
    required this.shape,
    required this.rotations,
    required this.correctIndex,
  });
}

class _ShapePainter extends CustomPainter {
  final _ShapeType shape;
  final double rotation;
  final Color color;

  _ShapePainter(this.shape, this.rotation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * pi / 180);
    canvas.translate(-center.dx, -center.dy);

    final path = Path();
    final unit = size.width / 4;

    switch (shape) {
      case _ShapeType.L:
        path.addRect(Rect.fromLTWH(unit, unit, unit, unit * 2));
        path.addRect(Rect.fromLTWH(unit * 2, unit * 2, unit, unit));
        break;
      case _ShapeType.T:
        path.addRect(Rect.fromLTWH(unit * 0.5, unit, unit * 3, unit));
        path.addRect(Rect.fromLTWH(unit * 1.5, unit * 2, unit, unit));
        break;
      case _ShapeType.arrow:
        path.moveTo(size.width / 2, unit * 0.5);
        path.lineTo(unit * 3, unit * 2);
        path.lineTo(unit * 2.2, unit * 2);
        path.lineTo(unit * 2.2, unit * 3.5);
        path.lineTo(unit * 1.8, unit * 3.5);
        path.lineTo(unit * 1.8, unit * 2);
        path.lineTo(unit, unit * 2);
        path.close();
        break;
      case _ShapeType.plus:
        path.addRect(Rect.fromLTWH(unit * 1.5, unit * 0.5, unit, unit * 3));
        path.addRect(Rect.fromLTWH(unit * 0.5, unit * 1.5, unit * 3, unit));
        break;
      case _ShapeType.house:
        // 三角形の屋根
        path.moveTo(size.width / 2, unit * 0.5);
        path.lineTo(unit * 3.2, unit * 2);
        path.lineTo(unit * 0.8, unit * 2);
        path.close();
        // 四角い本体
        path.addRect(Rect.fromLTWH(unit * 1.2, unit * 2, unit * 1.6, unit * 1.5));
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.color != color;
  }
}
