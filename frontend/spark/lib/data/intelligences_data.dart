import '../models/intelligence.dart';

/// 8つの知性データ
const List<Intelligence> intelligences = [
  Intelligence(
    id: 'linguistic',
    name: '言語的知性',
    englishName: 'Linguistic Intelligence',
    icon: '📝',
    description: '言葉を使って考え、表現する力。読書、執筆、言葉遊びが得意。',
    careers: '作家、弁護士、教師、ジャーナリスト、翻訳者',
  ),
  Intelligence(
    id: 'logical',
    name: '論理・数学的知性',
    englishName: 'Logical-Mathematical',
    icon: '🔢',
    description: '論理的に考え、パターンや法則を見つける力。分析や問題解決が得意。',
    careers: 'エンジニア、科学者、プログラマー、会計士',
  ),
  Intelligence(
    id: 'spatial',
    name: '空間的知性',
    englishName: 'Spatial-Visual',
    icon: '🎨',
    description: '立体や空間を把握し、視覚的にイメージする力。絵やデザインが得意。',
    careers: '建築家、デザイナー、アーティスト、パイロット',
  ),
  Intelligence(
    id: 'musical',
    name: '音楽的知性',
    englishName: 'Musical Intelligence',
    icon: '🎵',
    description: '音やリズムを感じ取り、音楽を理解・創造する力。',
    careers: '音楽家、作曲家、DJ、音響エンジニア',
  ),
  Intelligence(
    id: 'bodily',
    name: '身体・運動的知性',
    englishName: 'Bodily-Kinesthetic',
    icon: '⚽',
    description: '体を使って表現したり、手先を器用に使う力。',
    careers: 'アスリート、ダンサー、職人、外科医、料理人',
  ),
  Intelligence(
    id: 'interpersonal',
    name: '対人的知性',
    englishName: 'Interpersonal',
    icon: '🤝',
    description: '他者の気持ちを理解し、人と協力する力。リーダーシップが得意。',
    careers: '教師、カウンセラー、営業、マネージャー',
  ),
  Intelligence(
    id: 'intrapersonal',
    name: '内省的知性',
    englishName: 'Intrapersonal',
    icon: '🧘',
    description: '自分自身を深く理解する力。自己分析や独自の価値観を持つ。',
    careers: '哲学者、起業家、心理学者、作家',
  ),
  Intelligence(
    id: 'naturalistic',
    name: '博物的知性',
    englishName: 'Naturalistic',
    icon: '🌿',
    description: '自然界のパターンを認識し、分類する力。動植物への深い興味。',
    careers: '生物学者、獣医、農家、環境活動家',
  ),
];

/// IDから知性を取得
Intelligence getIntelligenceById(String id) {
  return intelligences.firstWhere(
    (i) => i.id == id,
    orElse: () => intelligences.first,
  );
}
