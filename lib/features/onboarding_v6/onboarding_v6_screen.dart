import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/features/onboarding_v6/onboarding_v6_slide.dart';
import 'package:edu_verse/features/onboarding_v6/onboarding_v6_tokens.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_cta_button.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_dot_rail.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_glass.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_hero_scene.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_preferences_card.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_story_card.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/services/onboarding_completion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingV6Screen extends StatefulWidget {
  const OnboardingV6Screen({
    super.key,
    this.onboardingCompletionService = const OnboardingCompletionService(),
  });

  final OnboardingCompletionService onboardingCompletionService;

  @override
  State<OnboardingV6Screen> createState() => _OnboardingV6ScreenState();
}

class _OnboardingV6ScreenState extends State<OnboardingV6Screen>
    with TickerProviderStateMixin {
  static const Duration _heroDuration = Duration(milliseconds: 1100);
  static const Duration _pillDuration = Duration(milliseconds: 300);
  static const Duration _contentDuration = Duration(milliseconds: 350);
  static const Curve _motionCurve = Cubic(0.25, 0.1, 0.25, 1);

  late final AnimationController _heroController;
  late final AnimationController _pillController;
  late final AnimationController _contentController;

  int _currentIndex = 0;
  int? _previousIndex;

  OnboardingV6Slide get _slide => onboardingV6Slides[_currentIndex];
  OnboardingV6Slide? get _previousSlide =>
      _previousIndex == null ? null : onboardingV6Slides[_previousIndex!];

  bool get _isLastSlide => _currentIndex == onboardingV6Slides.length - 1;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(vsync: this, duration: _heroDuration)
      ..value = 0;
    _pillController = AnimationController(vsync: this, duration: _pillDuration)
      ..value = 0;
    _contentController = AnimationController(
      vsync: this,
      duration: _contentDuration,
    )..value = 0;

    _heroController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _previousIndex = null);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _heroController.forward();
      _pillController.forward();
      _contentController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final slide in onboardingV6Slides) {
      precacheImage(AssetImage(slide.imageAsset), context);
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _pillController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _setSlide(int index) {
    if (index == _currentIndex ||
        index < 0 ||
        index >= onboardingV6Slides.length) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
    _heroController.forward(from: 0);
    _pillController.forward(from: 0);
    _contentController.forward(from: 0);
  }

  Future<void> _next() async {
    if (_isLastSlide) {
      await widget.onboardingCompletionService.markOnboardingCompleted();
      if (!mounted) {
        return;
      }
      context.go('/login');
      return;
    }
    _setSlide(_currentIndex + 1);
  }

  void _skipToPreferences() {
    _setSlide(onboardingV6Slides.length - 1);
  }

  void _changeLanguage(String languageCode) {
    HapticFeedback.selectionClick();
    context.read<LanguageCubit>().changeLanguage(languageCode);
  }

  void _changeThemeMode(AppThemeMode mode) {
    HapticFeedback.selectionClick();
    context.read<ThemeBloc>().add(SetThemeModeEvent(mode));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LanguageCubit>().state;
    final themeState = context.watch<ThemeBloc>().state;
    final tokens = OnboardingV6Tokens.fromBrightness(isDark: themeState.isDark);
    final textDirection = Directionality.of(context);
    final isRtl = textDirection == TextDirection.rtl;
    final overlayStyle = tokens.isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: tokens.rootBackground,
        body: Directionality(
          textDirection: textDirection,
          child: Stack(
            key: const Key('onboarding-v6-root'),
            fit: StackFit.expand,
            children: <Widget>[
              OnboardingV6HeroScene(
                slide: _slide,
                previousSlide: _previousSlide,
                animation: _heroController,
                tokens: tokens,
                isRtl: isRtl,
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _TopSkipBar(
                      onSkip: _skipToPreferences,
                      l10n: l10n,
                      tokens: tokens,
                      controller: _pillController,
                      slide: _slide,
                      showSkip: !_isLastSlide,
                    ),
                    const Spacer(),
                    _BottomContent(
                      controller: _contentController,
                      slide: _slide,
                      l10n: l10n,
                      locale: locale,
                      themeState: themeState,
                      tokens: tokens,
                      isRtl: isRtl,
                      isLastSlide: _isLastSlide,
                      currentIndex: _currentIndex,
                      onLanguageChanged: _changeLanguage,
                      onThemeModeChanged: _changeThemeMode,
                      onDotPressed: _setSlide,
                      onCtaPressed: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopSkipBar extends StatelessWidget {
  const _TopSkipBar({
    required this.onSkip,
    required this.l10n,
    required this.tokens,
    required this.controller,
    required this.slide,
    required this.showSkip,
  });

  final VoidCallback onSkip;
  final AppLocalizations l10n;
  final OnboardingV6Tokens tokens;
  final AnimationController controller;
  final OnboardingV6Slide slide;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: _AnimatedPill(
                  controller: controller,
                  slide: slide,
                  l10n: l10n,
                  tokens: tokens,
                ),
              ),
            ),
            if (showSkip) ...<Widget>[
              const SizedBox(width: 12),
              _SkipButton(onSkip: onSkip, l10n: l10n, tokens: tokens),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.onSkip,
    required this.l10n,
    required this.tokens,
  });

  final VoidCallback onSkip;
  final AppLocalizations l10n;
  final OnboardingV6Tokens tokens;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = tokens.isDark
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = tokens.isDark
        ? Colors.white.withValues(alpha: 0.28)
        : Colors.black.withValues(alpha: 0.16);
    final textColor = tokens.isDark ? Colors.white : Colors.black;

    return OnboardingV6Glass(
      borderRadius: BorderRadius.circular(999),
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      blurSigma: 18,
      child: TextButton(
        key: const Key('onboarding-v6-skip'),
        onPressed: onSkip,
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          minimumSize: const Size(52, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          l10n.skip,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
            color: textColor,
            shadows: tokens.isDark
                ? <Shadow>[
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _AnimatedPill extends StatelessWidget {
  const _AnimatedPill({
    required this.controller,
    required this.slide,
    required this.l10n,
    required this.tokens,
  });

  final AnimationController controller;
  final OnboardingV6Slide slide;
  final AppLocalizations l10n;
  final OnboardingV6Tokens tokens;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.35),
          end: Offset.zero,
        ).animate(animation),
        child: OnboardingV6Glass(
          borderRadius: BorderRadius.circular(999),
          backgroundColor: tokens.pillBackground,
          borderColor: tokens.pillBorder,
          blurSigma: 20,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: slide.tint,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: slide.tint,
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  slide.label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomContent extends StatelessWidget {
  const _BottomContent({
    required this.controller,
    required this.slide,
    required this.l10n,
    required this.locale,
    required this.themeState,
    required this.tokens,
    required this.isRtl,
    required this.isLastSlide,
    required this.currentIndex,
    required this.onLanguageChanged,
    required this.onThemeModeChanged,
    required this.onDotPressed,
    required this.onCtaPressed,
  });

  final AnimationController controller;
  final OnboardingV6Slide slide;
  final AppLocalizations l10n;
  final Locale locale;
  final ThemeState themeState;
  final OnboardingV6Tokens tokens;
  final bool isRtl;
  final bool isLastSlide;
  final int currentIndex;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<int> onDotPressed;
  final VoidCallback onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final contentAnimation = CurvedAnimation(
      parent: controller,
      curve: _OnboardingV6ScreenState._motionCurve,
    );
    final dx = isRtl ? 20.0 : -20.0;

    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 24,
            end: 24,
            bottom: 12 + MediaQuery.paddingOf(context).bottom * 0.20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeTransition(
                opacity: contentAnimation,
                child: AnimatedBuilder(
                  animation: contentAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(dx * (1 - contentAnimation.value), 0),
                      child: child,
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(currentIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        slide.title(l10n),
                        key: const Key('onboarding-v6-title'),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          letterSpacing: -1.2,
                          shadows: tokens.isDark
                              ? <Shadow>[
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.60),
                                    blurRadius: 18,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (slide.isPreferences)
                        OnboardingV6PreferencesCard(
                          slide: slide,
                          tokens: tokens,
                          l10n: l10n,
                          locale: locale,
                          themeMode: themeState.themeMode,
                          onLanguageChanged: onLanguageChanged,
                          onThemeModeChanged: onThemeModeChanged,
                        )
                      else
                        OnboardingV6StoryCard(
                          slide: slide,
                          tokens: tokens,
                          l10n: l10n,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  OnboardingV6DotRail(
                    count: onboardingV6Slides.length,
                    currentIndex: currentIndex,
                    activeColor: slide.tint,
                    inactiveColor: tokens.inactiveDot,
                    onDotPressed: onDotPressed,
                  ),
                  const SizedBox(width: 12),
                  OnboardingV6CtaButton(
                    label: isLastSlide ? l10n.getStarted : l10n.continueButton,
                    tint: slide.tint,
                    isRtl: isRtl,
                    onPressed: onCtaPressed,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: tokens.homeIndicator.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
