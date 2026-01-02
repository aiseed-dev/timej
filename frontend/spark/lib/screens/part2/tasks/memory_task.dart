import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 単語記憶タスク（言語的知性）
class MemoryTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const MemoryTask({super.key, required this.onComplete});

  @override
  State<MemoryTask> createState() => _MemoryTaskState();
}

class _MemoryTaskState extends State<MemoryTask> {
  _TaskPhase _phase = _TaskPhase.instruction;
  int _currentWordIndex = 0;
  Set<String> _selectedWords = {};
  late DateTime _startTime;
  Timer? _wordTimer;

  // 練習モード
  bool _isPractice = true;

  // 練習用の単語（3つ）
  final List<String> _practiceTargetWords = ['ねこ', '空', 'くるま'];

  // 練習用の選択肢（ターゲット3つ + ダミー2つ）
  final List<String> _practiceAllWords = ['ねこ', '空', 'くるま', 'いぬ', '海'];

  // 本番用の記憶する単語（8つ）
  final List<String> _targetWords = [
    'りんご',
    '電車',
    '太陽',
    'ピアノ',
    '山',
    '時計',
    '本',
    '花',
  ];

  // 本番用の選択肢（12つ：ターゲット8つ + ダミー4つ）
  final List<String> _allWords = [
    'りんご',
    '電車',
    '太陽',
    'ピアノ',
    '山',
    '時計',
    '本',
    '花',
    'みかん',
    '飛行機',
    '月',
    'ギター',
  ];

  // 現在使用する単語リスト
  List<String> get _currentTargetWords =>
      _isPractice ? _practiceTargetWords : _targetWords;
  List<String> get _currentAllWords =>
      _isPractice ? _practiceAllWords : _allWords;
  int get _requiredSelections => _isPractice ? 3 : 8;

  @override
  void initState() {
    super.initState();
    // シャッフル
    _practiceAllWords.shuffle();
    _allWords.shuffle();
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語記憶'),
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
      case _TaskPhase.memorizing:
        return _buildMemorizing();
      case _TaskPhase.selecting:
        return _buildSelecting();
      case _TaskPhase.result:
        return _buildResult();
    }
  }

  Widget _buildInstruction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📝', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text('単語記憶テスト', style: AppTextStyles.headline),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildInstructionStep(
                '1',
                '${_isPractice ? 3 : 8}つの単語が順番に表示されます',
              ),
              const SizedBox(height: 12),
              _buildInstructionStep('2', '各単語は2秒間表示されます'),
              const SizedBox(height: 12),
              _buildInstructionStep('3', '全て表示後、見た単語を選んでください'),
            ],
          ),
        ),
        if (_isPractice) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'まずは3単語で練習です（スコアには含まれません）',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startMemorizing,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.linguistic,
            ),
            child: Text(_isPractice ? '練習スタート' : '本番スタート'),
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
            color: AppColors.linguistic,
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

  Widget _buildMemorizing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 練習表示
        if (_isPractice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
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
                  '練習',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),

        // プログレス
        Text(
          '${_currentWordIndex + 1} / ${_currentTargetWords.length}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentWordIndex + 1) / _currentTargetWords.length,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              _isPractice ? AppColors.warning : AppColors.linguistic,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 60),

        // 単語表示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          decoration: BoxDecoration(
            color: (_isPractice ? AppColors.warning : AppColors.linguistic)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (_isPractice ? AppColors.warning : AppColors.linguistic)
                  .withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Text(
            _currentTargetWords[_currentWordIndex],
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _isPractice ? AppColors.warning : AppColors.linguistic,
            ),
          ),
        ),

        const SizedBox(height: 40),
        Text(
          'しっかり覚えてください',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (_isPractice) ...[
          const SizedBox(height: 8),
          Text(
            '（練習：スコアには含まれません）',
            style: AppTextStyles.label.copyWith(color: AppColors.warning),
          ),
        ],
      ],
    );
  }

  Widget _buildSelecting() {
    return Column(
      children: [
        // 練習表示
        if (_isPractice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
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
                  '練習',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (_isPractice ? AppColors.warning : AppColors.linguistic)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                _isPractice ? '🎯' : '📝',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isPractice
                      ? '練習：さきほど見た単語を選んでください（$_requiredSelections つ）'
                      : 'さきほど見た単語を選んでください（$_requiredSelections つ）',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '選択中: ${_selectedWords.length} / $_requiredSelections',
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // 単語グリッド
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _isPractice ? 2 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: _currentAllWords.length,
            itemBuilder: (context, index) {
              final word = _currentAllWords[index];
              final isSelected = _selectedWords.contains(word);

              return GestureDetector(
                onTap: () => _toggleWord(word),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.linguistic
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.linguistic
                          : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 16,
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

        // 確定ボタン
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedWords.length == _requiredSelections
                ? _submitSelection
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.linguistic,
            ),
            child: const Text('決定'),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final correctCount = _selectedWords
        .where((w) => _currentTargetWords.contains(w))
        .length;
    final score = (correctCount / _currentTargetWords.length) * 100;

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
              '練習の結果',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Text(
          correctCount >= (_isPractice ? 2 : 6)
              ? '🎉'
              : correctCount >= (_isPractice ? 1 : 4)
              ? '👍'
              : '💪',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 24),
        Text(
          '$correctCount / ${_currentTargetWords.length} 正解',
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: 8),
        Text(
          'スコア: ${score.round()}%',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.linguistic,
          ),
        ),
        const SizedBox(height: 32),

        // 結果詳細
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('表示された単語:', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentTargetWords.map((word) {
                  final wasSelected = _selectedWords.contains(word);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: wasSelected
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: wasSelected
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          wasSelected ? Icons.check : Icons.close,
                          size: 16,
                          color: wasSelected
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(word),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isPractice ? _startMainTest : _complete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.linguistic,
            ),
            child: Text(_isPractice ? '本番へ進む' : '次へ'),
          ),
        ),
      ],
    );
  }

  void _startMemorizing() {
    if (!_isPractice) {
      _startTime = DateTime.now();
    }
    setState(() {
      _phase = _TaskPhase.memorizing;
    });
    _showNextWord();
  }

  void _showNextWord() {
    _wordTimer = Timer(const Duration(seconds: 2), () {
      if (_currentWordIndex < _currentTargetWords.length - 1) {
        setState(() {
          _currentWordIndex++;
        });
        _showNextWord();
      } else {
        setState(() {
          _phase = _TaskPhase.selecting;
        });
      }
    });
  }

  void _toggleWord(String word) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
      } else if (_selectedWords.length < _requiredSelections) {
        _selectedWords.add(word);
      }
    });
  }

  void _submitSelection() {
    setState(() {
      _phase = _TaskPhase.result;
    });
  }

  void _startMainTest() {
    // 練習終了、本番へ
    setState(() {
      _isPractice = false;
      _phase = _TaskPhase.instruction;
      _currentWordIndex = 0;
      _selectedWords = {};
    });
  }

  void _complete() {
    final duration = DateTime.now().difference(_startTime);
    final correctCount = _selectedWords
        .where((w) => _targetWords.contains(w))
        .length;
    final score = (correctCount / _targetWords.length) * 100;

    widget.onComplete(
      TaskResult(
        taskId: 'memory',
        taskName: '単語記憶',
        score: score,
        correctCount: correctCount,
        totalCount: _targetWords.length,
        duration: duration,
      ),
    );
  }
}

enum _TaskPhase { instruction, memorizing, selecting, result }
