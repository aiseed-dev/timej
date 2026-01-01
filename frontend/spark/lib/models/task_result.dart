/// Part2のタスク結果を表すモデル
class TaskResult {
  final String taskId;
  final String taskName;
  final double score; // 0-100
  final int correctCount;
  final int totalCount;
  final Duration? duration;

  const TaskResult({
    required this.taskId,
    required this.taskName,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'taskName': taskName,
    'score': score,
    'correctCount': correctCount,
    'totalCount': totalCount,
    'durationMs': duration?.inMilliseconds,
  };
}

/// Part2全体の結果
class Part2Result {
  final Map<String, TaskResult> taskResults;
  final DateTime completedAt;

  Part2Result({
    required this.taskResults,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  /// 知性IDごとのスコアを計算
  Map<String, double> get scoresByIntelligence {
    final mapping = {
      'sequence': 'logical',
      'memory': 'linguistic',
      'spatial': 'spatial',
      'rhythm': 'musical',
      'reaction': 'bodily',
      'emotion': 'interpersonal',
      'reflection': 'intrapersonal',
      'classify': 'naturalistic',
    };

    final scores = <String, double>{};
    for (final entry in taskResults.entries) {
      final intelligenceId = mapping[entry.key];
      if (intelligenceId != null) {
        scores[intelligenceId] = entry.value.score;
      }
    }
    return scores;
  }

  Map<String, dynamic> toJson() => {
    'taskResults': taskResults.map((k, v) => MapEntry(k, v.toJson())),
    'completedAt': completedAt.toIso8601String(),
  };
}
