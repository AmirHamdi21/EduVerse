import 'package:edu_verse/common/classes/role_feature.dart';
import 'package:edu_verse/widgets/onBoarding/background_stars.dart';
import 'package:edu_verse/widgets/onBoarding/decorative_circles.dart';
import 'package:edu_verse/widgets/onBoarding/feature_card.dart';
import 'package:edu_verse/widgets/onBoarding/gradient_overlay.dart';
import 'package:edu_verse/widgets/onBoarding/info_card.dart';
import 'package:edu_verse/widgets/onBoarding/navigation_buttons.dart';
import 'package:edu_verse/widgets/onBoarding/onboarding_header.dart';
import 'package:edu_verse/widgets/onBoarding/page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/config/app_theme.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildTitleSection(),
                          const SizedBox(height: 32),
                          Column(
                            children: [
                              FeatureCard(
                                title: 'Student',
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
                                    emoji: '📘',
                                    text: 'Personalized Learning & Flashcards',
                                  ),
                                  RoleFeature(
                                    emoji: '📊',
                                    text: 'Smart Analytics & Grades Tracking',
                                  ),
                                  RoleFeature(
                                    emoji: '🧠',
                                    text: 'AI Summaries & Study Plans',
                                  ),
                                ],
                                tagline: 'Learn smarter with EduVerse AI.',
                                taglineColor: AppTheme.onBoardingcyanLight,
                              ),
                              const SizedBox(height: 20),
                              FeatureCard(
                                title: 'Instructor',
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
                                    emoji: '🧠',
                                    text: 'AI-Generated Feedback & Grading',
                                  ),
                                  RoleFeature(
                                    emoji: '🗂️',
                                    text: 'Lab & Assignment Management',
                                  ),
                                  RoleFeature(
                                    emoji: '💬',
                                    text: 'Course Discussions & Insights',
                                  ),
                                ],
                                tagline:
                                    'Teach efficiently with intelligent support.',
                                taglineColor: AppTheme.onBoardingprimary,
                              ),
                              const SizedBox(height: 20),
                              FeatureCard(
                                title: 'Admin',
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
                                    emoji: '🫱',
                                    text: 'EduVerse-Wide Analytics & Reporting',
                                  ),
                                  RoleFeature(
                                    emoji: '⚙️',
                                    text: 'Access & User Management',
                                  ),
                                  RoleFeature(
                                    emoji: '📋',
                                    text: 'Attendance & System Oversight',
                                  ),
                                ],
                                tagline:
                                    'Manage effortlessly through data intelligence.',
                                taglineColor: AppTheme.onBoardingpurple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          InfoCard(
                            text:
                                'Your role has been detected automatically based on your verified email — EduVerse will personalize your dashboard accordingly.',
                          ),
                          const SizedBox(height: 40),
                          NavigationButtons(
                            backOnPressed: () {
                              context.go('/onboarding1');
                            },
                            nextOnPressed: () {
                              context.go('/onboarding3');
                            },
                          ),
                          const SizedBox(height: 24),
                          PageIndicator(
                            isActive_1: false,
                            isActive_2: true,
                            isActive_3: false,
                            isActive_4: false,
                          ),
                          const SizedBox(height: 32),
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

  Widget _buildTitleSection() {
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
              TextSpan(text: 'One Platform. Three Roles.\n'),
              TextSpan(
                text: 'Infinite Possibilities.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onBoardingprimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'EduVerse unites Students, Instructors, and Admins in a seamless AI-powered learning environment.',
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
