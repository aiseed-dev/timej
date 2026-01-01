import '../models/intelligence.dart';

/// 32問の質問データ（各知性4問）
const List<Question> questions = [
  // ========== 言語的知性 (linguistic) ==========
  Question(
    intelligenceId: 'linguistic',
    text: '本を読んだり、物語を聞いたりするのが好きだ',
  ),
  Question(
    intelligenceId: 'linguistic',
    text: '言葉で自分の考えを説明するのが得意だ',
  ),
  Question(
    intelligenceId: 'linguistic',
    text: '新しい言葉や表現を覚えるのが楽しい',
  ),
  Question(
    intelligenceId: 'linguistic',
    text: '詩や歌詞、キャッチコピーなどに心を動かされる',
  ),

  // ========== 論理・数学的知性 (logical) ==========
  Question(
    intelligenceId: 'logical',
    text: '物事の「なぜ」を考えるのが好きだ',
  ),
  Question(
    intelligenceId: 'logical',
    text: 'パズルやロジックゲームに夢中になれる',
  ),
  Question(
    intelligenceId: 'logical',
    text: '数字やデータを見ると何かパターンを見つけようとする',
  ),
  Question(
    intelligenceId: 'logical',
    text: '問題を分解して順序立てて解決するのが得意だ',
  ),

  // ========== 空間的知性 (spatial) ==========
  Question(
    intelligenceId: 'spatial',
    text: '絵を描いたり、何かをデザインするのが好きだ',
  ),
  Question(
    intelligenceId: 'spatial',
    text: '地図を読んだり、道順を覚えるのが得意だ',
  ),
  Question(
    intelligenceId: 'spatial',
    text: '頭の中で物の形や配置をイメージできる',
  ),
  Question(
    intelligenceId: 'spatial',
    text: '色や形の組み合わせに敏感だ',
  ),

  // ========== 音楽的知性 (musical) ==========
  Question(
    intelligenceId: 'musical',
    text: '音楽を聴くと自然に体が動いたり、感情が揺さぶられる',
  ),
  Question(
    intelligenceId: 'musical',
    text: '一度聴いたメロディをすぐに覚えられる',
  ),
  Question(
    intelligenceId: 'musical',
    text: '音のズレや不協和音に気づきやすい',
  ),
  Question(
    intelligenceId: 'musical',
    text: '何かをするとき、頭の中で音楽が流れていることが多い',
  ),

  // ========== 身体・運動的知性 (bodily) ==========
  Question(
    intelligenceId: 'bodily',
    text: '体を動かすことが好きで、じっとしているのが苦手だ',
  ),
  Question(
    intelligenceId: 'bodily',
    text: '新しい動きやスポーツを覚えるのが早い',
  ),
  Question(
    intelligenceId: 'bodily',
    text: '手先が器用で、細かい作業が得意だ',
  ),
  Question(
    intelligenceId: 'bodily',
    text: '実際に触ったり動かしたりして学ぶ方が理解しやすい',
  ),

  // ========== 対人的知性 (interpersonal) ==========
  Question(
    intelligenceId: 'interpersonal',
    text: '人の気持ちや考えを察するのが得意だ',
  ),
  Question(
    intelligenceId: 'interpersonal',
    text: 'グループのまとめ役になることが多い',
  ),
  Question(
    intelligenceId: 'interpersonal',
    text: '困っている人を見ると自然と助けたくなる',
  ),
  Question(
    intelligenceId: 'interpersonal',
    text: '異なる意見の人同士をつなげるのが上手だ',
  ),

  // ========== 内省的知性 (intrapersonal) ==========
  Question(
    intelligenceId: 'intrapersonal',
    text: '自分の感情や考えを分析するのが好きだ',
  ),
  Question(
    intelligenceId: 'intrapersonal',
    text: '一人で過ごす時間が大切だと感じる',
  ),
  Question(
    intelligenceId: 'intrapersonal',
    text: '自分の強みと弱みをよく理解している',
  ),
  Question(
    intelligenceId: 'intrapersonal',
    text: '自分なりの信念や価値観を持っている',
  ),

  // ========== 博物的知性 (naturalistic) ==========
  Question(
    intelligenceId: 'naturalistic',
    text: '動物や植物に強い興味がある',
  ),
  Question(
    intelligenceId: 'naturalistic',
    text: '自然の中にいると落ち着く、または元気になる',
  ),
  Question(
    intelligenceId: 'naturalistic',
    text: '物事を分類したり、コレクションしたりするのが好きだ',
  ),
  Question(
    intelligenceId: 'naturalistic',
    text: '天気や季節の変化に敏感だ',
  ),
];

/// 知性IDでグループ化された質問を取得
Map<String, List<Question>> get questionsByIntelligence {
  final map = <String, List<Question>>{};
  for (final question in questions) {
    map.putIfAbsent(question.intelligenceId, () => []).add(question);
  }
  return map;
}
