/// 8つの知性を表すモデル
class Intelligence {
  final String id;
  final String name;
  final String englishName;
  final String icon;
  final String description;
  final String careers;

  const Intelligence({
    required this.id,
    required this.name,
    required this.englishName,
    required this.icon,
    required this.description,
    required this.careers,
  });
}

/// 質問を表すモデル
class Question {
  final String intelligenceId;
  final String text;

  const Question({
    required this.intelligenceId,
    required this.text,
  });
}

/// クイズ結果を表すモデル
class QuizResult {
  final Map<String, double> scores;
  final DateTime createdAt;

  const QuizResult({
    required this.scores,
    required this.createdAt,
  });

  /// スコアを降順でソートしたリストを取得
  List<MapEntry<String, double>> get sortedScores {
    final entries = scores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// TOP3の知性IDを取得
  List<String> get top3 {
    return sortedScores.take(3).map((e) => e.key).toList();
  }

  /// JSON形式に変換（サーバー送信用）
  Map<String, dynamic> toJson() {
    return {
      'scores': scores,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
