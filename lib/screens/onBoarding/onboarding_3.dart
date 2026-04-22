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

class Onboarding3 extends StatefulWidget {
  const Onboarding3({super.key});

  @override
  State<Onboarding3> createState() => _Onboarding3State();
}

class _Onboarding3State extends State<Onboarding3>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _card1Controller;
  late AnimationController _card2Controller;
  late AnimationController _card3Controller;
  late AnimationController _summaryController;

  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _card1Visible = false;
  bool _card2Visible = false;
  bool _card3Visible = false;

  @override
  void initState() {
    super.initState();

    // Header animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Card controllers
    _card1Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _card2Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _card3Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Start header animation
    _headerController.forward();

    // Start first two cards immediately with staggered delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _card1Visible = true);
        _card1Controller.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _card2Visible = true);
        _card2Controller.forward();
      }
    });

    // Scroll listener for remaining card animations
    _scrollController.addListener(_onScroll);

    // Trigger initial check after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  void _onScroll() {
    if (!mounted) return;

    final scrollOffset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;

    // Trigger animations based on scroll position for remaining cards
    if (scrollOffset > screenHeight * 0.2 && !_card3Visible) {
      setState(() => _card3Visible = true);
      _card3Controller.forward();
    }

    // Summary card appears after scrolling
    if (scrollOffset > screenHeight * 0.35) {
      _summaryController.forward();
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _card1Controller.dispose();
    _card2Controller.dispose();
    _card3Controller.dispose();
    _summaryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
                          controller: _scrollController,
                          padding: EdgeInsets.all(responsive.p24),
                          child: Column(
                            children: [
                              SizedBox(height: responsive.p16),
                              FadeTransition(
                                opacity: _headerFadeAnimation,
                                child: SlideTransition(
                                  position: _headerSlideAnimation,
                                  child: _buildIntroSection(
                                    context,
                                    textColor,
                                    textSecondaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: responsive.p32),
                              Column(
                                children: [
                                  _buildAnimatedCard(
                                    controller: _card1Controller,
                                    delay: 0,
                                    child: FeatureCard(
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
                                              AppTheme
                                                  .onBoardingbackgroundLight,
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
                                      taglineColor:
                                          AppTheme.onBoardingcyanLight,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnimatedCard(
                                    controller: _card2Controller,
                                    delay: 150,
                                    child: FeatureCard(
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
                                              AppTheme
                                                  .onBoardingbackgroundLight,
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
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnimatedCard(
                                    controller: _card3Controller,
                                    delay: 300,
                                    child: FeatureCard(
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
                                              AppTheme
                                                  .onBoardingbackgroundLight,
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
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              FadeTransition(
                                opacity: Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: _summaryController,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.2),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _summaryController,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.9, end: 1.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: _summaryController,
                                            curve: Curves.easeOutBack,
                                          ),
                                        ),
                                    child: SummaryCard(),
                                  ),
                                ),
                              ),
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

  Widget _buildAnimatedCard({
    required AnimationController controller,
    required int delay,
    required Widget child,
  }) {
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    final scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(scale: scaleAnimation, child: child),
      ),
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
            style: TextStyle(
              fontSize: responsive.fontSize24,
              color: textColor,
              height: 1.25,
            ),
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
