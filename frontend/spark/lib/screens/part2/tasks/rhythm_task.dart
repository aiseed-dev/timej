import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// リズムパターンタスク（音楽的知性）
class RhythmTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const RhythmTask({super.key, required this.onComplete});

  @override
  State<RhythmTask> createState() => _RhythmTaskState();
}

class _RhythmTaskState extends State<RhythmTask> {
  _TaskPhase _phase = _TaskPhase.instruction;
  int _currentPattern = 0;
  int _correctCount = 0;
  late DateTime _startTime;

  int _playingIndex = -1;
  List<int> _userTaps = [];
  Timer? _playTimer;
  bool _isPlaying = false;

  // 練習パターンかどうか
  bool get _isPractice => _currentPattern == 0;

  // 本番のパターン番号（練習を除く）
  int get _actualPatternNumber => _currentPattern - 1;

  // 本番のパターン数（練習を除く）
  int get _actualPatternCount => _patterns.length - 1;

  // リズムパターン（間隔をミリ秒で表現）- 最初の1つは練習
  final List<_RhythmPattern> _patterns = [
    // 練習パターン: 等間隔 ●●●●
    _RhythmPattern(
      name: '練習パターン',
      beats: [0, 400, 800, 1200],
      display: '● ● ● ●',
      difficulty: 1,
    ),
    // パターン1: タタ・タタ ●●・●●
    _RhythmPattern(
      name: 'パターン1',
      beats: [0, 200, 600, 800],
      display: '●● ・ ●●',
      difficulty: 2,
    ),
    // パターン2: タ・タタ・タ ●・●●・●
    _RhythmPattern(
      name: 'パターン2',
      beats: [0, 400, 600, 1000],
      display: '● ・ ●● ・ ●',
      difficulty: 2,
    ),
    // パターン3: タタタ・タ ●●●・●
    _RhythmPattern(
      name: 'パターン3',
      beats: [0, 200, 400, 800],
      display: '●●● ・ ●',
      difficulty: 3,
    ),
    // パターン4: 複雑なリズム
    _RhythmPattern(
      name: 'パターン4',
      beats: [0, 300, 450, 750, 1050],
      display: '●●・●・●●',
      difficulty: 3,
    ),
  ];

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('リズム'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_phase) {
      case _TaskPhase.instruction:
        return _buildInstruction();
      case _TaskPhase.playing:
        return _buildPlaying();
      case _TaskPhase.input:
        return _buildInput();
      case _TaskPhase.feedback:
        return _buildFeedback();
      case _TaskPhase.result:
        return _buildResult();
    }
  }

  Widget _buildInstruction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎵', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text('リズムテスト', style: AppTextStyles.headline),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildInstructionStep('1', 'リズムパターンが再生されます'),
              const SizedBox(height: 12),
              _buildInstructionStep('2', '再生後、同じリズムをタップで再現'),
              const SizedBox(height: 12),
              _buildInstructionStep('3', 'タイミングの正確さを測定します'),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startTest,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.musical),
            child: const Text('スタート'),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.musical,
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

  Widget _buildPlaying() {
    final pattern = _patterns[_currentPattern];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 練習表示または進捗表示
        if (_isPractice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  '練習パターン',
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
            '${_actualPatternNumber + 1} / $_actualPatternCount',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: 40),

        // ビジュアルインジケーター
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pattern.beats.length, (index) {
            final isActive = index == _playingIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: isActive ? 50 : 40,
                height: isActive ? 50 : 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.musical
                      : AppColors.musical.withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.musical.withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 60),

        Text(
          _isPlaying ? '聞いてください...' : '再生中',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.musical),
        ),

        const SizedBox(height: 16),

        Text(pattern.display, style: AppTextStyles.headline),

        if (_isPractice) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'これは練習です（スコアには含まれません）',
              style: AppTextStyles.label.copyWith(color: AppColors.warning),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInput() {
    final pattern = _patterns[_currentPattern];

    return Column(
      children: [
        // 練習表示または進捗表示
        if (_isPractice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  '練習パターン',
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
            '${_actualPatternNumber + 1} / $_actualPatternCount',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isPractice
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.musical.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                _isPractice ? '🎯' : '🎵',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isPractice ? '練習：同じリズムでタップしてください' : '同じリズムでタップしてください',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // タップ進捗
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pattern.beats.length, (index) {
            final isTapped = index < _userTaps.length;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isTapped ? AppColors.musical : AppColors.divider,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),

        const Spacer(),

        // タップエリア
        GestureDetector(
          onTapDown: (_) => _onTap(),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.musical,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.musical.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text(
                  'タップ',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // もう一度聞くボタン
        TextButton.icon(
          onPressed: _playPattern,
          icon: const Icon(Icons.replay),
          label: const Text('もう一度聞く'),
          style: TextButton.styleFrom(foregroundColor: AppColors.musical),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    final pattern = _patterns[_currentPattern];
    final score = _calculatePatternScore();
    final isGood = score >= 70;

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
              '練習パターンの結果',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Text(isGood ? '🎉' : '💪', style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text(
          isGood ? 'よくできました！' : 'もう少し！',
          style: AppTextStyles.headline.copyWith(
            color: isGood ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'スコア: ${score.round()}%',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.musical),
        ),
        const SizedBox(height: 32),

        // タイミング比較
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text('お手本', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Text(pattern.display, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              Text('あなたのタップ', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Text(
                _userTaps.length == pattern.beats.length
                    ? pattern.display
                    : '● × ${_userTaps.length}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _nextPattern,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.musical),
            child: Text(
              _isPractice
                  ? '本番へ進む'
                  : (_currentPattern < _patterns.length - 1 ? '次へ' : '結果を見る'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final score = (_correctCount / _actualPatternCount) * 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          score >= 80
              ? '🎼'
              : score >= 50
              ? '🎵'
              : '🎶',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 24),
        Text('リズム感スコア', style: AppTextStyles.headline),
        const SizedBox(height: 16),
        Text(
          '${score.round()}%',
          style: AppTextStyles.displayLarge.copyWith(color: AppColors.musical),
        ),
        const SizedBox(height: 8),
        Text(
          '$_correctCount / $_actualPatternCount パターン成功',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.musical.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getResultMessage(score),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.musical),
            child: const Text('次へ'),
          ),
        ),
      ],
    );
  }

  String _getResultMessage(double score) {
    if (score >= 80) {
      return 'リズム感が非常に優れています！\n音楽的な才能を持っています。';
    } else if (score >= 60) {
      return 'リズム感が良好です。\n練習でさらに伸ばせます。';
    } else if (score >= 40) {
      return '標準的なリズム感です。\n音楽に触れる機会を増やしましょう。';
    } else {
      return 'リズムを意識して聞いてみましょう。\n練習で必ず上達します！';
    }
  }

  void _startTest() {
    _startTime = DateTime.now();
    _playPattern();
  }

  void _playPattern() {
    final pattern = _patterns[_currentPattern];
    _userTaps = [];
    _isPlaying = true;

    setState(() => _phase = _TaskPhase.playing);

    // パターン再生
    for (int i = 0; i < pattern.beats.length; i++) {
      Timer(Duration(milliseconds: pattern.beats[i]), () {
        if (!mounted) return;

        setState(() => _playingIndex = i);
        HapticFeedback.mediumImpact();

        // ビートの視覚効果をリセット
        Timer(const Duration(milliseconds: 150), () {
          if (mounted && _playingIndex == i) {
            setState(() => _playingIndex = -1);
          }
        });
      });
    }

    // 再生終了後、入力フェーズへ
    final lastBeat = pattern.beats.last;
    Timer(Duration(milliseconds: lastBeat + 500), () {
      if (mounted) {
        setState(() {
          _phase = _TaskPhase.input;
          _isPlaying = false;
          _playingIndex = -1;
        });
      }
    });
  }

  DateTime? _firstTapTime;

  void _onTap() {
    final pattern = _patterns[_currentPattern];

    HapticFeedback.lightImpact();

    if (_userTaps.isEmpty) {
      _firstTapTime = DateTime.now();
      _userTaps.add(0);
    } else if (_firstTapTime != null) {
      final elapsed = DateTime.now().difference(_firstTapTime!).inMilliseconds;
      _userTaps.add(elapsed);
    }

    setState(() {});

    // 必要なタップ数に達したら評価
    if (_userTaps.length >= pattern.beats.length) {
      final score = _calculatePatternScore();
      // 練習パターンはスコアに含めない
      if (!_isPractice && score >= 60) {
        _correctCount++;
      }

      Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _phase = _TaskPhase.feedback);
        }
      });
    }
  }

  double _calculatePatternScore() {
    final pattern = _patterns[_currentPattern];

    if (_userTaps.length != pattern.beats.length) {
      return 0;
    }

    // 各タップのタイミング誤差を計算
    double totalError = 0;
    for (int i = 1; i < pattern.beats.length; i++) {
      final expectedInterval = pattern.beats[i] - pattern.beats[i - 1];
      final actualInterval = _userTaps[i] - _userTaps[i - 1];
      final error = (actualInterval - expectedInterval).abs();
      totalError += error;
    }

    // 許容誤差（150ms以内なら完璧、300ms以上なら0点）
    final avgError = totalError / (pattern.beats.length - 1);
    if (avgError <= 100) return 100;
    if (avgError >= 300) return 0;

    return 100 - ((avgError - 100) / 200) * 100;
  }

  void _nextPattern() {
    if (_currentPattern < _patterns.length - 1) {
      setState(() {
        _currentPattern++;
        _userTaps = [];
        _firstTapTime = null;
      });
      _playPattern();
    } else {
      setState(() => _phase = _TaskPhase.result);
    }
  }

  void _complete() {
    final duration = DateTime.now().difference(_startTime);
    final score = (_correctCount / _actualPatternCount) * 100;

    widget.onComplete(
      TaskResult(
        taskId: 'rhythm',
        taskName: 'リズム',
        score: score,
        correctCount: _correctCount,
        totalCount: _actualPatternCount,
        duration: duration,
      ),
    );
  }
}

enum _TaskPhase { instruction, playing, input, feedback, result }

class _RhythmPattern {
  final String name;
  final List<int> beats; // ミリ秒単位のタイミング
  final String display;
  final int difficulty;

  const _RhythmPattern({
    required this.name,
    required this.beats,
    required this.display,
    required this.difficulty,
  });
}
