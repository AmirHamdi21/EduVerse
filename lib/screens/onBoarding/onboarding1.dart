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
import 'package:edu_verse/common/utils/responsive.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _titleController;
  late AnimationController _descriptionController;
  late AnimationController _taglineController;
  late AnimationController _buttonsController;

  late Animation<double> _imageFadeAnimation;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<double> _imageScaleAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late Animation<double> _descriptionFadeAnimation;
  late Animation<Offset> _descriptionSlideAnimation;

  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;

  late Animation<double> _buttonsFadeAnimation;
  late Animation<Offset> _buttonsSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Image card animation
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _imageFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeOut));

    _imageSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero).animate(
          CurvedAnimation(parent: _imageController, curve: Curves.easeOutCubic),
        );

    _imageScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeOutBack),
    );

    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );

    // Description animation
    _descriptionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _descriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _descriptionController, curve: Curves.easeOut),
    );

    _descriptionSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _descriptionController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Tagline animation
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Buttons animation
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut),
    );

    _buttonsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonsController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start cascading animations
    _imageController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _titleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _descriptionController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _taglineController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _buttonsController.forward();
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _taglineController.dispose();
    _buttonsController.dispose();
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
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.p24,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: responsive.p16),
                              // Image card
                              FadeTransition(
                                opacity: _imageFadeAnimation,
                                child: SlideTransition(
                                  position: _imageSlideAnimation,
                                  child: ScaleTransition(
                                    scale: _imageScaleAnimation,
                                    child: Container(
                                      width: double.infinity,
                                      height: responsive.responsiveHeight(30),
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
                                          borderRadius: BorderRadius.circular(
                                            responsive.radius24,
                                          ),
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
                                                width: responsive
                                                    .aspectRatioWidth(213.02),
                                                height: responsive
                                                    .aspectRatioHeight(213.02),
                                                decoration: ShapeDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
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
                                            padding: EdgeInsets.all(
                                              responsive.p24,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    responsive.radius16,
                                                  ),
                                              child: Image.asset(
                                                "assets/images/panda.png",
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
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
                                  ),
                                ),
                              ),
                              SizedBox(height: responsive.p24),
                              // Title
                              FadeTransition(
                                opacity: _titleFadeAnimation,
                                child: SlideTransition(
                                  position: _titleSlideAnimation,
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.onboarding1MainTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: responsive.fontSize28,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: responsive.p24),
                              // Description
                              FadeTransition(
                                opacity: _descriptionFadeAnimation,
                                child: SlideTransition(
                                  position: _descriptionSlideAnimation,
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.onboarding1Description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textSecondaryColor,
                                      fontSize: responsive.fontSize16,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.62,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: responsive.p20),
                              // Tagline
                              FadeTransition(
                                opacity: _taglineFadeAnimation,
                                child: SlideTransition(
                                  position: _taglineSlideAnimation,
                                  child: Text(
                                    AppLocalizations.of(context)!.poweredByAI,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDark
                                          ? AppTheme.onBoardingcyan
                                          : const Color(0xFF53E9FC),
                                      fontSize: responsive.fontSize14,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: responsive.p32),
                              FadeTransition(
                                opacity: _buttonsFadeAnimation,
                                child: SlideTransition(
                                  position: _buttonsSlideAnimation,
                                  child: Column(
                                    children: [
                                      NavigationButtons(
                                        nextOnPressed: () {
                                          context.go('/onboarding2');
                                        },
                                      ),
                                      SizedBox(height: responsive.p16),
                                      PageIndicator(
                                        isActive_1: true,
                                        isActive_2: false,
                                        isActive_3: false,
                                        isActive_4: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // SizedBox(height: responsive.p32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: responsive.p16,
                  top: responsive.safeAreaTop + responsive.p16,
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
                      SizedBox(width: responsive.p12),
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
    final responsive = context.responsive;
    return Container(
      width: responsive.aspectRatioWidth(50),
      height: responsive.aspectRatioHeight(50),
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
                  SizedBox(width: responsive.p8),
                  Text(
                    'English',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: currentLanguage == 'en'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'en'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'en')
                    Padding(
                      padding: EdgeInsets.only(left: responsive.p8),
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF2B7FFF),
                        size: responsive.iconSmall,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  SizedBox(width: responsive.p8),
                  Text(
                    'العربية',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: currentLanguage == 'ar'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'ar'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'ar')
                    Padding(
                      padding: EdgeInsets.only(left: responsive.p8),
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF2B7FFF),
                        size: responsive.iconSmall,
                      ),
                    ),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.language,
            size: responsive.iconSmall,
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
    final responsive = context.responsive;
    return Container(
      width: responsive.aspectRatioWidth(50),
      height: responsive.aspectRatioHeight(50),
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
            size: responsive.iconSmall,
            color: themeIsDark
                ? AppTheme.darkTextPrimary
                : const Color(0xFF354152),
          ),
        ),
      ),
    );
  }
}
