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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  @override
  Widget build(BuildContext context) {
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
                        AppTheme.darkBg1,
                        AppTheme.darkBg2,
                        AppTheme.darkBg3,
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
                              _buildTitleSection(textColor, textSecondaryColor),
                              const SizedBox(height: 32),
                              Column(
                                children: [
                                  FeatureCard(
                                    title: AppLocalizations.of(
                                      context,
                                    )!.studentRole,
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
                                    features: [
                                      RoleFeature(
                                        emoji: '📘',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.studentFeature1,
                                      ),
                                      RoleFeature(
                                        emoji: '📊',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.studentFeature2,
                                      ),
                                      RoleFeature(
                                        emoji: '🧠',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.studentFeature3,
                                      ),
                                    ],
                                    tagline: AppLocalizations.of(
                                      context,
                                    )!.studentTagline,
                                    taglineColor: AppTheme.onBoardingcyanLight,
                                  ),
                                  const SizedBox(height: 20),
                                  FeatureCard(
                                    title: AppLocalizations.of(
                                      context,
                                    )!.instructorRole,
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
                                    features: [
                                      RoleFeature(
                                        emoji: '🧠',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.instructorFeature1,
                                      ),
                                      RoleFeature(
                                        emoji: '🗂️',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.instructorFeature2,
                                      ),
                                      RoleFeature(
                                        emoji: '📊',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.instructorFeature3,
                                      ),
                                    ],
                                    tagline: AppLocalizations.of(
                                      context,
                                    )!.instructorTagline,
                                    taglineColor: AppTheme.onBoardingprimary,
                                  ),
                                  const SizedBox(height: 20),
                                  FeatureCard(
                                    title: AppLocalizations.of(context)!.adminRole,
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
                                    features: [
                                      RoleFeature(
                                        emoji: '👥',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.adminFeature1,
                                      ),
                                      RoleFeature(
                                        emoji: '🔍',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.adminFeature2,
                                      ),
                                      RoleFeature(
                                        emoji: '📋',
                                        text: AppLocalizations.of(
                                          context,
                                        )!.adminFeature3,
                                      ),
                                    ],
                                    tagline: AppLocalizations.of(
                                      context,
                                    )!.adminTagline,
                                    taglineColor: AppTheme.onBoardingpurple,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              InfoCard(
                                text: AppLocalizations.of(
                                  context,
                                )!.onboarding2InfoText,
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
                Positioned(
                  right: 16,
                  top: 48,
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

  Widget _buildTitleSection(Color textColor, Color textSecondaryColor) {
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
        Text(
          AppLocalizations.of(context)!.onboarding2Title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: textColor,
            height: 1.25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.onboarding2Subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
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
