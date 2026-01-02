import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 反応速度タスク（身体・運動的知性）
class ReactionTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const ReactionTask({super.key, required this.onComplete});

  @override
  State<ReactionTask> createState() => _ReactionTaskState();
}

class _ReactionTaskState extends State<ReactionTask> {
  _TaskPhase _phase = _TaskPhase.instruction;
  int _currentRound = 0;
  final int _totalRounds = 10; // 本番ラウンド数
  final int _practiceRounds = 1; // 練習ラウンド数
  final List<int> _reactionTimes = [];
  DateTime? _targetShowTime;
  Offset _targetPosition = Offset.zero;
  final Random _random = Random();
  Timer? _showTimer;
  late DateTime _startTime;
  bool _tooEarly = false;

  // 練習中かどうか
  bool get _isPractice => _currentRound < _practiceRounds;

  // 本番のラウンド番号（練習を除く）
  int get _actualRoundNumber => _currentRound - _practiceRounds;

  @override
  void dispose() {
    _showTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('反応速度'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    switch (_phase) {
      case _TaskPhase.instruction:
        return _buildInstruction();
      case _TaskPhase.waiting:
        return _buildWaiting();
      case _TaskPhase.target:
        return _buildTarget();
      case _TaskPhase.result:
        return _buildResult();
    }
  }

  Widget _buildInstruction() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚽', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text('反応速度テスト', style: AppTextStyles.headline),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInstructionStep('1', '緑の円が現れるまで待ちます'),
                const SizedBox(height: 12),
                _buildInstructionStep('2', '円が現れたらすぐにタップ！'),
                const SizedBox(height: 12),
                _buildInstructionStep('3', '10回測定して平均を計算します'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '注意：円が出る前にタップするとやり直しになります',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bodily,
              ),
              child: const Text('スタート'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.bodily,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Widget _buildWaiting() {
    return GestureDetector(
      onTap: _onTooEarlyTap,
      child: Container(
        color: _tooEarly
            ? AppColors.error.withOpacity(0.2)
            : AppColors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 練習表示または進捗表示
              if (_isPractice)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        '練習ラウンド',
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
                  '${_actualRoundNumber + 1} / $_totalRounds',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 40),
              if (_tooEarly) ...[
                const Text('⚠️', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  '早すぎました！',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text('円が出てからタップしてください', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retryRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bodily,
                  ),
                  child: const Text('もう一度'),
                ),
              ] else ...[
                const Text('👀', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('待ってください...', style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '緑の円が出たらタップ！',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_isPractice) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'これは練習です（スコアには含まれません）',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.warning,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _onTargetTap(details.globalPosition),
          child: Container(
            color: AppColors.background, // 背景色を変えない（ヒントを与えない）
            child: Stack(
              children: [
                Positioned(
                  left: _targetPosition.dx - 40,
                  top: _targetPosition.dy - 40,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.bodily,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bodily.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                // プログレス
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _isPractice
                        ? Container(
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
                                const Text(
                                  '🎯',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '練習',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            '${_actualRoundNumber + 1} / $_totalRounds',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult() {
    final avgTime = _reactionTimes.isEmpty
        ? 0
        : _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length;
    final minTime = _reactionTimes.isEmpty ? 0 : _reactionTimes.reduce(min);
    final maxTime = _reactionTimes.isEmpty ? 0 : _reactionTimes.reduce(max);

    // スコア計算（250ms以下=100点、500ms以上=0点）
    final score = _calculateScore(avgTime);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score >= 80
                ? '⚡'
                : score >= 50
                ? '👍'
                : '💪',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text('平均反応時間', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '${avgTime}ms',
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.bodily),
          ),
          const SizedBox(height: 8),
          Text(
            'スコア: ${score.round()}点',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.bodily),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('最速', '${minTime}ms'),
                Container(width: 1, height: 40, color: AppColors.divider),
                _buildStatColumn('最遅', '${maxTime}ms'),
                Container(width: 1, height: 40, color: AppColors.divider),
                _buildStatColumn('試行', '${_reactionTimes.length}回'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildScoreGuide(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bodily,
              ),
              child: const Text('次へ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleMedium),
      ],
    );
  }

  Widget _buildScoreGuide() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bodily.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('スコア目安', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGuideItem('〜250ms', '100点'),
              _buildGuideItem('300ms', '80点'),
              _buildGuideItem('400ms', '40点'),
              _buildGuideItem('500ms〜', '0点'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String time, String score) {
    return Column(
      children: [
        Text(time, style: AppTextStyles.label.copyWith(fontSize: 11)),
        Text(
          score,
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            color: AppColors.bodily,
          ),
        ),
      ],
    );
  }

  double _calculateScore(int avgTime) {
    if (avgTime <= 250) return 100;
    if (avgTime >= 500) return 0;
    // 線形補間
    return 100 - ((avgTime - 250) / 250) * 100;
  }

  void _startTest() {
    _startTime = DateTime.now();
    _scheduleNextTarget();
  }

  void _scheduleNextTarget() {
    setState(() {
      _phase = _TaskPhase.waiting;
      _tooEarly = false;
    });

    // 1〜3秒後にターゲット表示
    final delay = Duration(milliseconds: 1000 + _random.nextInt(2000));
    _showTimer = Timer(delay, _showTarget);
  }

  void _showTarget() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final padding = 100.0;

    setState(() {
      _phase = _TaskPhase.target;
      _targetShowTime = DateTime.now();
      _targetPosition = Offset(
        padding + _random.nextDouble() * (size.width - padding * 2),
        padding + _random.nextDouble() * (size.height - padding * 3),
      );
    });
  }

  void _onTooEarlyTap() {
    if (_phase == _TaskPhase.waiting && !_tooEarly) {
      _showTimer?.cancel();
      setState(() => _tooEarly = true);
    }
  }

  void _retryRound() {
    _scheduleNextTarget();
  }

  void _onTargetTap(Offset tapPosition) {
    if (_targetShowTime == null) return;

    final reactionTime = DateTime.now()
        .difference(_targetShowTime!)
        .inMilliseconds;

    // 練習ラウンドはスコアに含めない
    if (!_isPractice) {
      _reactionTimes.add(reactionTime);
    }

    _currentRound++;

    if (_currentRound < _practiceRounds + _totalRounds) {
      _scheduleNextTarget();
    } else {
      setState(() => _phase = _TaskPhase.result);
    }
  }

  void _complete() {
    final duration = DateTime.now().difference(_startTime);
    final avgTime = _reactionTimes.isEmpty
        ? 0
        : _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length;
    final score = _calculateScore(avgTime);

    widget.onComplete(
      TaskResult(
        taskId: 'reaction',
        taskName: '反応速度',
        score: score,
        correctCount: _reactionTimes.length,
        totalCount: _totalRounds,
        duration: duration,
      ),
    );
  }
}

enum _TaskPhase { instruction, waiting, target, result }
