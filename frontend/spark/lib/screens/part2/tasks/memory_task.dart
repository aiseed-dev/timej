import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 単語記憶タスク（言語的知性）
class MemoryTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const MemoryTask({
    super.key,
    required this.onComplete,
  });

  @override
  State<MemoryTask> createState() => _MemoryTaskState();
}

class _MemoryTaskState extends State<MemoryTask> {
  _TaskPhase _phase = _TaskPhase.instruction;
  int _currentWordIndex = 0;
  Set<String> _selectedWords = {};
  late DateTime _startTime;
  Timer? _wordTimer;

  // 記憶する単語（8つ）
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

  // 選択肢（12つ：ターゲット8つ + ダミー4つ）
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

  @override
  void initState() {
    super.initState();
    // シャッフル
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
        Text(
          '単語記憶テスト',
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildInstructionStep('1', '8つの単語が順番に表示されます'),
              const SizedBox(height: 12),
              _buildInstructionStep('2', '各単語は2秒間表示されます'),
              const SizedBox(height: 12),
              _buildInstructionStep('3', '全て表示後、見た単語を選んでください'),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startMemorizing,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.linguistic,
            ),
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
        Expanded(
          child: Text(text, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildMemorizing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // プログレス
        Text(
          '${_currentWordIndex + 1} / ${_targetWords.length}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentWordIndex + 1) / _targetWords.length,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.linguistic),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 60),

        // 単語表示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.linguistic.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.linguistic.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Text(
            _targetWords[_currentWordIndex],
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.linguistic,
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
      ],
    );
  }

  Widget _buildSelecting() {
    final correctSelected = _selectedWords.where((w) => _targetWords.contains(w)).length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.linguistic.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'さきほど見た単語を選んでください（8つ）',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '選択中: ${_selectedWords.length} / 8',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // 単語グリッド
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: _allWords.length,
            itemBuilder: (context, index) {
              final word = _allWords[index];
              final isSelected = _selectedWords.contains(word);

              return GestureDetector(
                onTap: () => _toggleWord(word),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.linguistic : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.linguistic : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
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
            onPressed: _selectedWords.length == 8 ? _submitSelection : null,
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
    final correctCount = _selectedWords.where((w) => _targetWords.contains(w)).length;
    final score = (correctCount / _targetWords.length) * 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          correctCount >= 6 ? '🎉' : correctCount >= 4 ? '👍' : '💪',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 24),
        Text(
          '$correctCount / ${_targetWords.length} 正解',
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
                children: _targetWords.map((word) {
                  final wasSelected = _selectedWords.contains(word);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: wasSelected
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: wasSelected ? AppColors.success : AppColors.error,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          wasSelected ? Icons.check : Icons.close,
                          size: 16,
                          color: wasSelected ? AppColors.success : AppColors.error,
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
            onPressed: _complete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.linguistic,
            ),
            child: const Text('次へ'),
          ),
        ),
      ],
    );
  }

  void _startMemorizing() {
    _startTime = DateTime.now();
    setState(() {
      _phase = _TaskPhase.memorizing;
    });
    _showNextWord();
  }

  void _showNextWord() {
    _wordTimer = Timer(const Duration(seconds: 2), () {
      if (_currentWordIndex < _targetWords.length - 1) {
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
      } else if (_selectedWords.length < 8) {
        _selectedWords.add(word);
      }
    });
  }

  void _submitSelection() {
    setState(() {
      _phase = _TaskPhase.result;
    });
  }

  void _complete() {
    final duration = DateTime.now().difference(_startTime);
    final correctCount = _selectedWords.where((w) => _targetWords.contains(w)).length;
    final score = (correctCount / _targetWords.length) * 100;

    widget.onComplete(TaskResult(
      taskId: 'memory',
      taskName: '単語記憶',
      score: score,
      correctCount: correctCount,
      totalCount: _targetWords.length,
      duration: duration,
    ));
  }
}

enum _TaskPhase {
  instruction,
  memorizing,
  selecting,
  result,
}
