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
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/common/utils/responsive.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final textColor = isDark
            ? AppTheme.darkTextPrimary
            : const Color(0xFF1E293B);
        final textSecondaryColor = isDark
            ? AppTheme.darkTextSecondary
            : const Color(0xFF697282);

        return Scaffold(
          backgroundColor: isDark
              ? AppTheme.darkSurfaceColor
              : const Color(0xFFF8FAFC),
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff020618),
                        Color(0xff162456),
                        Color(0xff0F172B),
                      ],
                    )
                  : const LinearGradient(
                      colors: [
                        AppTheme.onBoardingbackgroundLight,
                        Colors.white,
                        AppTheme.onBoardingbackgroundCyan,
                      ],
                    ),
            ),
            child: Stack(
              children: [
                // BackgroundStars(),
                // DecorativeCircles(),
                // GradientOverlay(),
                SafeArea(
                  child: Column(
                    children: [
                      OnboardingHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(responsive.p24),
                          child: Column(
                            children: [
                              SizedBox(height: responsive.p16),
                              _buildIntroSection(
                                context,
                                textColor,
                                textSecondaryColor,
                              ),
                              SizedBox(height: responsive.p32),
                              Column(
                                children: [
                                  FeatureCard(
                                    title: AppLocalizations.of(
                                      context,
                                    )!.aiForStudents,
                                    badgeColor: AppTheme.onBoardingcyanLight,
                                    borderColor: isDark
                                        ? AppTheme.onBoardingcyan
                                        : AppTheme.onBoardingborderCyan,
                                    gradientColors: isDark
                                        ? [
                                            AppTheme.onBoardingCardCyanDark,
                                            AppTheme.onBoardingCardCyanDark
                                                .withOpacity(0.6),
                                          ]
                                        : [
                                            AppTheme.onBoardingbackgroundCyan,
                                            AppTheme.onBoardingbackgroundLight,
                                          ],
                                    decorGradient: [
                                      Color(0xFF00B8DA),
                                      AppTheme.onBoardingprimary,
                                    ],
                                    features: [
                                      RoleFeature(
                                        emoji: '🧠',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.studentSummaries,
                                      ),
                                      RoleFeature(
                                        emoji: '📊',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.studentAnalytics,
                                      ),
                                      RoleFeature(
                                        emoji: '🎯',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.studentPlans,
                                      ),
                                    ],
                                    tagline: AppLocalizations.of(
                                      context,
                                    )!.studentAssistant,
                                    taglineColor: AppTheme.onBoardingcyanLight,
                                  ),
                                  const SizedBox(height: 20),
                                  FeatureCard(
                                    title: AppLocalizations.of(
                                      context,
                                    )!.aiForInstructors,
                                    badgeColor: AppTheme.onBoardingprimary,
                                    borderColor: isDark
                                        ? AppTheme.onBoardingprimary
                                        : AppTheme.onBoardingborderBlue,
                                    gradientColors: isDark
                                        ? [
                                            AppTheme.onBoardingCardBlueDark,
                                            AppTheme.onBoardingCardBlueDark
                                                .withOpacity(0.6),
                                          ]
                                        : const [
                                            AppTheme.onBoardingbackgroundLight,
                                            Color(0xFFEEF2FF),
                                          ],
                                    decorGradient: [
                                      AppTheme.onBoardingprimaryLight,
                                      AppTheme.onBoardingpurple,
                                    ],
                                    features: [
                                      RoleFeature(
                                        emoji: '📄',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.instructorAssignment,
                                      ),
                                      RoleFeature(
                                        emoji: '💬',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.instructorInsights,
                                      ),
                                      RoleFeature(
                                        emoji: '📘',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.instructorRecommendations,
                                      ),
                                    ],
                                    tagline: AppLocalizations.of(
                                      context,
                                    )!.instructorGrading,
                                    taglineColor: AppTheme.onBoardingprimary,
                                  ),
                                  const SizedBox(height: 20),
                                  FeatureCard(
                                    title: AppLocalizations.of(
                                      context,
                                    )!.aiForAdmins,
                                    badgeColor: AppTheme.onBoardingpurple,
                                    borderColor: isDark
                                        ? AppTheme.onBoardingpurple
                                        : AppTheme.onBoardingborderPurple,
                                    gradientColors: isDark
                                        ? [
                                            AppTheme.onBoardingCardPurpleDark,
                                            AppTheme.onBoardingCardPurpleDark
                                                .withOpacity(0.6),
                                          ]
                                        : const [
                                            AppTheme.onBoardingbackgroundLight,
                                            Color(0xFFF3EFFF),
                                          ],
                                    decorGradient: [
                                      AppTheme.onBoardingprimaryLight,
                                      AppTheme.onBoardingpurple,
                                    ],
                                    features: [
                                      RoleFeature(
                                        emoji: '📊',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.adminAnalytics,
                                      ),
                                      RoleFeature(
                                        emoji: '🔔',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.adminAttendance,
                                      ),
                                      RoleFeature(
                                        emoji: '🔒',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.adminMonitoring,
                                      ),
                                    ],
                                    tagline: AppLocalizations.of(
                                      context,
                                    )!.adminManagement,
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
                Positioned(
                  right: 16,
                  top: 120,
                  child: Row(
                    children: [
                      BlocBuilder<LanguageCubit, Locale>(
                        builder: (context, locale) {
                          return _buildLanguageSwitchIcon(
                            context,
                            locale.languageCode,
                            isDark,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, state) {
                          return _buildThemeToggleIcon(
                            context,
                            state.isDark,
                            isDark,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntroSection(
    BuildContext context,
    Color textColor,
    Color textSecondaryColor,
  ) {
    final responsive = context.responsive;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.p8),
              decoration: BoxDecoration(
                color: AppTheme.onBoardingprimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.radius12),
              ),
              child: Icon(
                Icons.psychology,
                color: AppTheme.onBoardingprimary,
                size: responsive.iconLarge,
              ),
            ),
            SizedBox(width: responsive.p8),
            Container(
              padding: EdgeInsets.all(responsive.p8),
              decoration: BoxDecoration(
                color: AppTheme.onBoardingcyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.radius12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppTheme.onBoardingcyan,
                size: responsive.iconMedium,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: responsive.fontSize24, color: textColor, height: 1.25),
            children: [
              TextSpan(
                text: AppLocalizations.of(context)!.poweredByIntelligence,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onBoardingprimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.p16),
        Text(
          AppLocalizations.of(context)!.aiDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.fontSize14,
            color: textSecondaryColor,
            height: 1.62,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSwitchIcon(
    BuildContext context,
    String currentLanguage,
    bool isDark,
  ) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(
          color: isDark ? const Color(0xFF404756) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<String>(
          onSelected: (String langCode) {
            context.read<LanguageCubit>().changeLanguage(langCode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'English',
                    style: TextStyle(
                      color: currentLanguage == 'en'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'en'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'en')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: Color(0xFF2B7FFF)),
                    ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'العربية',
                    style: TextStyle(
                      color: currentLanguage == 'ar'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'ar'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'ar')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: Color(0xFF2B7FFF)),
                    ),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.language,
            size: 20,
            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF354152),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleIcon(
    BuildContext context,
    bool isDark,
    bool themeIsDark,
  ) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: themeIsDark
            ? AppTheme.darkCardColor
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(
          color: themeIsDark
              ? const Color(0xFF404756)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          borderRadius: BorderRadius.circular(1000),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 20,
            color: themeIsDark
                ? AppTheme.darkTextPrimary
                : const Color(0xFF354152),
          ),
        ),
      ),
    );
  }
}
