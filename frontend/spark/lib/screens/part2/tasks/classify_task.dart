import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/task_result.dart';

/// 分類タスク（博物的知性）
class ClassifyTask extends StatefulWidget {
  final void Function(TaskResult result) onComplete;

  const ClassifyTask({super.key, required this.onComplete});

  @override
  State<ClassifyTask> createState() => _ClassifyTaskState();
}

class _ClassifyTaskState extends State<ClassifyTask> {
  int _currentQuestion = 0;
  int _correctCount = 0;
  bool _showingResult = false;
  String? _selectedCategory;
  late DateTime _startTime;

  // 練習問題かどうか
  bool get _isPractice => _currentQuestion == 0;

  // 本番の問題数（練習問題を除く）
  int get _actualQuestionCount => _questions.length - 1;

  // 現在の本番問題番号（練習問題を除く）
  int get _actualQuestionNumber => _currentQuestion - 1;

  // 分類問題データ（最初の1問は練習問題）
  final List<_ClassifyQuestion> _questions = [
    // 練習問題
    _ClassifyQuestion(
      item: '🐋 クジラ',
      correctCategory: '哺乳類',
      options: ['魚類', '哺乳類', '爬虫類', '両生類'],
      hint: '水中に住んでいますが、肺で呼吸します',
    ),
    // 本番問題
    _ClassifyQuestion(
      item: '🦇 コウモリ',
      correctCategory: '哺乳類',
      options: ['鳥類', '昆虫', '哺乳類', '爬虫類'],
      hint: '翼がありますが、毛皮があり子供に乳を与えます',
    ),
    _ClassifyQuestion(
      item: '🍅 トマト',
      correctCategory: '果物',
      options: ['野菜', '果物', '穀物', 'きのこ'],
      hint: '植物学的には種子を含む部分です',
    ),
    _ClassifyQuestion(
      item: '🐧 ペンギン',
      correctCategory: '鳥類',
      options: ['魚類', '哺乳類', '鳥類', '爬虫類'],
      hint: '飛べませんが、羽毛があり卵を産みます',
    ),
    _ClassifyQuestion(
      item: '🕷️ クモ',
      correctCategory: '節足動物',
      options: ['昆虫', '節足動物', '軟体動物', '爬虫類'],
      hint: '脚が8本あります（昆虫は6本）',
    ),
    _ClassifyQuestion(
      item: '🌵 サボテン',
      correctCategory: '多肉植物',
      options: ['樹木', '多肉植物', '草', 'つる植物'],
      hint: '水分を蓄える特殊な組織を持っています',
    ),
    _ClassifyQuestion(
      item: '🐬 イルカ',
      correctCategory: '哺乳類',
      options: ['魚類', '哺乳類', '爬虫類', '鳥類'],
      hint: '水中に住みますが、空気を吸って呼吸します',
    ),
    _ClassifyQuestion(
      item: '🍄 シイタケ',
      correctCategory: '菌類',
      options: ['野菜', '植物', '菌類', '細菌'],
      hint: '光合成をせず、胞子で増えます',
    ),
    _ClassifyQuestion(
      item: '🦑 イカ',
      correctCategory: '軟体動物',
      options: ['魚類', '甲殻類', '軟体動物', '節足動物'],
      hint: '骨がなく、タコと同じ仲間です',
    ),
    _ClassifyQuestion(
      item: '🐊 ワニ',
      correctCategory: '爬虫類',
      options: ['両生類', '哺乳類', '爬虫類', '魚類'],
      hint: '水辺に住みますが、肺で呼吸し鱗があります',
    ),
    _ClassifyQuestion(
      item: '🦀 カニ',
      correctCategory: '甲殻類',
      options: ['魚類', '軟体動物', '甲殻類', '昆虫'],
      hint: '硬い殻と10本の脚を持ちます',
    ),
    _ClassifyQuestion(
      item: '🐸 カエル',
      correctCategory: '両生類',
      options: ['爬虫類', '両生類', '魚類', '哺乳類'],
      hint: '幼生時はエラ呼吸、成体は肺呼吸します',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    // 練習問題（最初の1問）を除いてシャッフル
    final practiceQuestion = _questions.removeAt(0);
    _questions.shuffle();
    _questions.insert(0, practiceQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分類'),
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
                AppColors.naturalistic,
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
            color: AppColors.naturalistic.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text('これは何の仲間でしょうか？', style: AppTextStyles.bodyMedium),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // アイテム表示
        Container(
          width: double.infinity,
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
          child: Column(
            children: [
              Text(
                question.item.split(' ')[0], // 絵文字部分
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 12),
              Text(
                question.item.split(' ')[1], // 名前部分
                style: AppTextStyles.titleLarge,
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
              childAspectRatio: 2,
            ),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = _selectedCategory == option;

              return GestureDetector(
                onTap: () => _selectCategory(option),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.naturalistic
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.naturalistic
                          : AppColors.divider,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
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

        // 決定ボタン
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedCategory != null ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.naturalistic,
            ),
            child: const Text('決定'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultFeedback() {
    final question = _questions[_currentQuestion];
    final isCorrect = _selectedCategory == question.correctCategory;

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
        Text(question.item.split(' ')[0], style: const TextStyle(fontSize: 48)),
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
        Text(
          '正解: ${question.correctCategory}',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.naturalistic.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.naturalistic,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(question.hint, style: AppTextStyles.bodyMedium),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.naturalistic,
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

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
  }

  void _submitAnswer() {
    final question = _questions[_currentQuestion];
    // 練習問題はスコアに含めない
    if (!_isPractice && _selectedCategory == question.correctCategory) {
      _correctCount++;
    }
    setState(() => _showingResult = true);
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedCategory = null;
        _showingResult = false;
      });
    } else {
      final duration = DateTime.now().difference(_startTime);
      final score = (_correctCount / _actualQuestionCount) * 100;

      widget.onComplete(
        TaskResult(
          taskId: 'classify',
          taskName: '分類',
          score: score,
          correctCount: _correctCount,
          totalCount: _actualQuestionCount,
          duration: duration,
        ),
      );
    }
  }
}

class _ClassifyQuestion {
  final String item;
  final String correctCategory;
  final List<String> options;
  final String hint;

  const _ClassifyQuestion({
    required this.item,
    required this.correctCategory,
    required this.options,
    required this.hint,
  });
}
