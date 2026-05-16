import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:edu_verse/features/splash_v8/widgets/splash_v8_bottom_content.dart';
import 'package:edu_verse/features/splash_v8/widgets/splash_v8_floating_glyphs.dart';
import 'package:edu_verse/features/splash_v8/widgets/splash_v8_grid.dart';
import 'package:edu_verse/features/splash_v8/widgets/splash_v8_hero_backdrop.dart';
import 'package:edu_verse/features/splash_v8/widgets/splash_v8_top_kicker.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/services/auth_role_resolver.dart';
import 'package:edu_verse/services/onboarding_completion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashV8Screen extends StatefulWidget {
  const SplashV8Screen({
    super.key,
    this.onboardingCompletionService = const OnboardingCompletionService(),
    this.minimumDisplayDuration = const Duration(milliseconds: 6500),
  });

  final OnboardingCompletionService onboardingCompletionService;
  final Duration minimumDisplayDuration;

  @override
  State<SplashV8Screen> createState() => _SplashV8ScreenState();
}

class _SplashV8ScreenState extends State<SplashV8Screen>
    with TickerProviderStateMixin {
  late final AnimationController _timelineController;
  late final AnimationController _dotController;
  late final AnimationController _loaderController;

  bool _minimumElapsed = false;
  bool _didRoute = false;
  bool _didReadInitialAuth = false;
  bool _didPrecacheImage = false;
  bool _didStartAnimations = false;
  AuthState? _resolvedAuthState;

  @override
  void initState() {
    super.initState();
    _timelineController = AnimationController(
      vsync: this,
      duration: SplashV8Timing.timelineDuration,
    );
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _waitForMinimumDisplay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didPrecacheImage) {
      _didPrecacheImage = true;
      precacheImage(
        const AssetImage(SplashV8HeroBackdrop.imageAsset),
        context,
        onError: (_, __) {},
      );
    }

    if (!_didReadInitialAuth) {
      _didReadInitialAuth = true;
      _handleAuthState(context.read<AuthBloc>().state);
    }

    _configureAnimations(MediaQuery.of(context).disableAnimations);
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _dotController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  Future<void> _waitForMinimumDisplay() async {
    await Future<void>.delayed(widget.minimumDisplayDuration);
    if (!mounted) {
      return;
    }
    _minimumElapsed = true;
    await _maybeRoute();
  }

  void _configureAnimations(bool reduceMotion) {
    if (reduceMotion) {
      _timelineController.value = 1;
      _dotController.value = 0;
      _loaderController.value = 0.5;
      _dotController.stop();
      _loaderController.stop();
      return;
    }

    if (_didStartAnimations) {
      if (!_dotController.isAnimating) {
        _dotController.repeat();
      }
      if (!_loaderController.isAnimating) {
        _loaderController.repeat();
      }
      return;
    }

    _didStartAnimations = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _timelineController.forward();
      _dotController.repeat();
      _loaderController.repeat();
    });
  }

  void _handleAuthState(AuthState state) {
    if (state is! AuthAuthenticated && state is! AuthUnauthenticated) {
      return;
    }
    _resolvedAuthState = state;
    _maybeRoute();
  }

  Future<void> _maybeRoute() async {
    if (_didRoute || !_minimumElapsed || _resolvedAuthState == null) {
      return;
    }

    _didRoute = true;
    final targetRoute = await _targetRouteFor(_resolvedAuthState!);
    if (!mounted) {
      return;
    }
    context.go(targetRoute);
  }

  Future<String> _targetRouteFor(AuthState state) async {
    if (state is AuthAuthenticated) {
      return AuthRoleResolver.dashboardRouteForUser(state.user);
    }

    final hasCompletedOnboarding = await widget.onboardingCompletionService
        .hasCompletedOnboarding();
    return hasCompletedOnboarding ? '/login' : '/onboarding';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textDirection = Directionality.of(context);
    final isRtl = textDirection == TextDirection.rtl;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _handleAuthState(state),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final tokens = SplashV8Tokens.fromBrightness(
            isDark: themeState.isDark,
          );
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
                  key: const Key('splash-v8-root'),
                  fit: StackFit.expand,
                  children: <Widget>[
                    SplashV8HeroBackdrop(
                      animation: _timelineController,
                      tokens: tokens,
                      isRtl: isRtl,
                      reduceMotion: reduceMotion,
                    ),
                    SplashV8Grid(
                      animation: _timelineController,
                      tokens: tokens,
                      reduceMotion: reduceMotion,
                    ),
                    SplashV8FloatingGlyphs(
                      animation: _timelineController,
                      tokens: tokens,
                      isRtl: isRtl,
                      reduceMotion: reduceMotion,
                    ),
                    SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SplashV8TopKicker(
                            animation: _timelineController,
                            tokens: tokens,
                            l10n: l10n,
                            isRtl: isRtl,
                            reduceMotion: reduceMotion,
                          ),
                          const Spacer(),
                          SplashV8BottomContent(
                            timelineAnimation: _timelineController,
                            dotAnimation: _dotController,
                            loaderAnimation: _loaderController,
                            tokens: tokens,
                            l10n: l10n,
                            reduceMotion: reduceMotion,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
