import 'package:edu_verse/common/classes/role_feature.dart';
import 'package:edu_verse/widgets/onBoarding/background_stars.dart';
import 'package:edu_verse/widgets/onBoarding/decorative_circles.dart';
import 'package:edu_verse/widgets/onBoarding/feature_card.dart';
import 'package:edu_verse/widgets/onBoarding/gradient_overlay.dart';
import 'package:edu_verse/widgets/onBoarding/navigation_buttons.dart';
import 'package:edu_verse/widgets/onBoarding/onboarding_header.dart';
import 'package:edu_verse/widgets/onBoarding/page_indicator.dart';
import 'package:edu_verse/widgets/onBoarding/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/config/app_theme.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            BackgroundStars(),
            DecorativeCircles(),
            GradientOverlay(),
            SafeArea(
              child: Column(
                children: [
                  OnboardingHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildIntroSection(),
                          const SizedBox(height: 32),
                          Column(
                            children: [
                              FeatureCard(
                                title: 'AI for Students',
                                badgeColor: AppTheme.onBoardingcyanLight,
                                borderColor: AppTheme.onBoardingborderCyan,
                                gradientColors: [
                                  AppTheme.onBoardingbackgroundCyan,
                                  AppTheme.onBoardingbackgroundLight,
                                ],
                                decorGradient: [
                                  Color(0xFF00B8DA),
                                  AppTheme.onBoardingprimary,
                                ],
                                features: const [
                                  RoleFeature(
                                    emoji: '🧠',
                                    text:
                                        'Smart Summaries of lectures and PDFs',
                                  ),
                                  RoleFeature(
                                    emoji: '📊',
                                    text: 'AI-based Performance Analytics',
                                  ),
                                  RoleFeature(
                                    emoji: '🎯',
                                    text:
                                        'Personalized Study Plans & Flashcards',
                                  ),
                                ],
                                tagline:
                                    'Your 24/7 personal learning assistant.',
                                taglineColor: AppTheme.onBoardingcyanLight,
                              ),
                              const SizedBox(height: 20),
                              FeatureCard(
                                title: 'AI for Instructors',
                                badgeColor: AppTheme.onBoardingprimary,
                                borderColor: AppTheme.onBoardingborderBlue,
                                gradientColors: const [
                                  AppTheme.onBoardingbackgroundLight,
                                  Color(0xFFEEF2FF),
                                ],
                                decorGradient: [
                                  AppTheme.onBoardingprimaryLight,
                                  AppTheme.onBoardingpurple,
                                ],
                                features: const [
                                  RoleFeature(
                                    emoji: '📄',
                                    text: 'AI-Assisted Assignment Evaluation',
                                  ),
                                  RoleFeature(
                                    emoji: '💬',
                                    text: 'Student Progress Insights & Alerts',
                                  ),
                                  RoleFeature(
                                    emoji: '📘',
                                    text:
                                        'Auto-Generated Teaching Recommendations',
                                  ),
                                ],
                                tagline:
                                    'Simplify grading and focus on teaching impact.',
                                taglineColor: AppTheme.onBoardingprimary,
                              ),
                              const SizedBox(height: 20),
                              FeatureCard(
                                title: 'AI for Admins',
                                badgeColor: AppTheme.onBoardingpurple,
                                borderColor: AppTheme.onBoardingborderPurple,
                                gradientColors: const [
                                  Color(0xFFEEF2FF),
                                  Color(0xFFFAF5FE),
                                ],
                                decorGradient: [
                                  Color(0xFF615EFF),
                                  Color(0xFF980FFA),
                                ],
                                features: const [
                                  RoleFeature(
                                    emoji: '📈',
                                    text: 'Real-Time Institution Analytics',
                                  ),
                                  RoleFeature(
                                    emoji: '⚙️',
                                    text:
                                        'Automated Attendance & Report Generation',
                                  ),
                                  RoleFeature(
                                    emoji: '🔒',
                                    text:
                                        'AI-Based Performance Monitoring & Insights',
                                  ),
                                ],
                                tagline:
                                    'Streamline EduVerse management with real-time intelligence.',
                                taglineColor: AppTheme.onBoardingpurple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SummaryCard(),
                          const SizedBox(height: 32),
                          NavigationButtons(
                            backOnPressed: () {
                              context.go('/onboarding2');
                            },
                            nextOnPressed: () {
                              context.go('/login');
                            },
                          ),
                          const SizedBox(height: 24),
                          PageIndicator(
                            isActive_1: false,
                            isActive_2: false,
                            isActive_3: true,
                            isActive_4: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.onBoardingprimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: AppTheme.onBoardingprimary,
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.onBoardingcyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.onBoardingcyan,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24,
              color: AppTheme.onBoardingtextDark,
              height: 1.25,
            ),
            children: [
              TextSpan(text: 'Powered by '),
              TextSpan(
                text: 'Intelligence.\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onBoardingprimary,
                ),
              ),
              TextSpan(text: 'Designed for Education.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'EduVerse\'s AI engine transforms learning, teaching, and management through automation, insights, and personalization.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.onBoardingtextLight,
            height: 1.62,
          ),
        ),
      ],
    );
  }
}
