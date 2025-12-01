import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/widgets/onBoarding/background_stars.dart';
import 'package:edu_verse/widgets/onBoarding/decorative_circles.dart';
import 'package:edu_verse/widgets/onBoarding/gradient_overlay.dart';
import 'package:edu_verse/widgets/onBoarding/navigation_buttons.dart';
import 'package:edu_verse/widgets/onBoarding/onboarding_header.dart';
import 'package:edu_verse/widgets/onBoarding/page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/screens/onBoarding/onboarding2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
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
            width: double.infinity,
            height: double.infinity,
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
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              // Image card
                              Container(
                                width: double.infinity,
                                height: 298,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x3300D2F2),
                                      Color(0x332B7FFF),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1.01,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : const Color(0x33FFFEFE),
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x5100C2FF),
                                      blurRadius: 71.60,
                                      offset: Offset(0, 10),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: -17,
                                      top: -39,
                                      child: Opacity(
                                        opacity: 0.37,
                                        child: Container(
                                          width: 213.02,
                                          height: 213.02,
                                          decoration: ShapeDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFF00D2F2),
                                                Color(0xFF2B7FFF),
                                              ],
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    34017000,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(25),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          "assets/images/panda.png",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF1E3A8A,
                                                        ),
                                                      ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Title
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.onboarding1MainTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 30,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Description
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.onboarding1Description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textSecondaryColor,
                                  fontSize: 16,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.62,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Tagline
                              Text(
                                AppLocalizations.of(context)!.poweredByAI,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.onBoardingcyan
                                      : const Color(0xFF53E9FC),
                                  fontSize: 14,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                ),
                              ),
                              const SizedBox(height: 16),
                              NavigationButtons(
                                nextOnPressed: () {
                                  context.go('/onboarding2');
                                },
                              ),
                              const SizedBox(height: 24),
                              PageIndicator(
                                isActive_1: true,
                                isActive_2: false,
                                isActive_3: false,
                                isActive_4: false,
                              ),
                              // const SizedBox(height: 32),
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
