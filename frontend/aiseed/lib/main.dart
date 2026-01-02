import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'screens/spark/part3_intro_screen.dart';
import 'screens/grow/grow_intro_screen.dart';
import 'screens/learn/learn_intro_screen.dart';
import 'screens/create/create_intro_screen.dart';

void main() {
  runApp(const AIseedApp());
}

/// AIseed - AIと人が共に成長するプラットフォーム
class AIseedApp extends StatelessWidget {
  const AIseedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIseed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.buttonLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// ホーム画面
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ロゴ
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.warmGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 48)),
                ),
              ),

              const SizedBox(height: 24),

              // タイトル
              Text(
                'AIseed',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'AIと一緒に、可能性の種を育てよう',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // サービス一覧
              _buildServiceCard(
                context,
                icon: '✨',
                title: 'Spark',
                subtitle: '強みを発見',
                description: '対話から能力と「らしさ」を見つける',
                color: AppColors.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Part3IntroScreen(previousScores: {}),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildServiceCard(
                context,
                icon: '🌱',
                title: 'Grow',
                subtitle: '栽培・料理',
                description: '伝統野菜を育て、料理する',
                color: AppColors.naturalistic,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GrowIntroScreen()),
                ),
              ),

              const SizedBox(height: 12),

              _buildServiceCard(
                context,
                icon: '💻',
                title: 'Learn',
                subtitle: 'プログラミング',
                description: 'AIと一緒にコードを学ぶ',
                color: AppColors.logical,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LearnIntroScreen()),
                ),
              ),

              const SizedBox(height: 12),

              _buildServiceCard(
                context,
                icon: '🎨',
                title: 'Create',
                subtitle: 'Web制作',
                description: '会話だけでサイトを作る',
                color: AppColors.spatial,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateIntroScreen()),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subtitle,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
