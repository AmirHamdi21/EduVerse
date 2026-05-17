import 'dart:math' as math;

import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:edu_verse/features/splash_v8/widgets/splash_v8_glass_pill.dart';
import 'package:edu_verse/features/splash_v8/widgets/splash_v8_wave_loader.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SplashV8BottomContent extends StatelessWidget {
  const SplashV8BottomContent({
    super.key,
    required this.timelineAnimation,
    required this.dotAnimation,
    required this.loaderAnimation,
    required this.tokens,
    required this.l10n,
    required this.reduceMotion,
  });

  final Animation<double> timelineAnimation;
  final Animation<double> dotAnimation;
  final Animation<double> loaderAnimation;
  final SplashV8Tokens tokens;
  final AppLocalizations l10n;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = 12 + (MediaQuery.paddingOf(context).bottom * 0.20);

    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SplashV8GlassPill(
                timelineAnimation: timelineAnimation,
                dotAnimation: dotAnimation,
                tokens: tokens,
                l10n: l10n,
                reduceMotion: reduceMotion,
              ),
              const SizedBox(height: 16),
              _FlipWordmark(
                animation: timelineAnimation,
                tokens: tokens,
                l10n: l10n,
                reduceMotion: reduceMotion,
              ),
              const SizedBox(height: 12),
              _AnimatedTagline(
                animation: timelineAnimation,
                tokens: tokens,
                l10n: l10n,
                reduceMotion: reduceMotion,
              ),
              const SizedBox(height: 32),
              SplashV8WaveLoader(
                animation: loaderAnimation,
                reduceMotion: reduceMotion,
              ),
              const SizedBox(height: 32),
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

class _FlipWordmark extends StatelessWidget {
  const _FlipWordmark({
    required this.animation,
    required this.tokens,
    required this.l10n,
    required this.reduceMotion,
  });

  final Animation<double> animation;
  final SplashV8Tokens tokens;
  final AppLocalizations l10n;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = reduceMotion ? 1.0 : _progress(animation.value);
        final eased = SplashV8Timing.motionCurve.transform(progress);
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.00125)
          ..rotateX((math.pi / 2) * (1 - eased));

        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - eased)),
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: matrix,
              child: child,
            ),
          ),
        );
      },
      child: FittedBox(
        key: const Key('splash-v8-wordmark'),
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          l10n.splashV8Wordmark,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 64,
            fontWeight: FontWeight.w800,
            height: 0.92,
            letterSpacing: 0,
            shadows: <Shadow>[
              Shadow(
                color: tokens.isDark
                    ? Colors.black.withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.75),
                blurRadius: 18,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _progress(double progress) {
    final timelineMs = progress * SplashV8Timing.timelineMs;
    return ((timelineMs - 1200) / 900).clamp(0.0, 1.0);
  }
}

class _AnimatedTagline extends StatelessWidget {
  const _AnimatedTagline({
    required this.animation,
    required this.tokens,
    required this.l10n,
    required this.reduceMotion,
  });

  final Animation<double> animation;
  final SplashV8Tokens tokens;
  final AppLocalizations l10n;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = reduceMotion ? 1.0 : _progress(animation.value);
        final eased = Curves.easeOut.transform(progress);

        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - eased)),
            child: child,
          ),
        );
      },
      child: Text(
        l10n.splashV8Tagline,
        key: const Key('splash-v8-tagline'),
        textAlign: TextAlign.start,
        style: TextStyle(
          color: tokens.textSecondary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.4,
          letterSpacing: 0,
          shadows: <Shadow>[
            Shadow(
              color: tokens.isDark
                  ? Colors.black.withValues(alpha: 0.70)
                  : Colors.white.withValues(alpha: 0.82),
              blurRadius: 12,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  double _progress(double progress) {
    final timelineMs = progress * SplashV8Timing.timelineMs;
    return ((timelineMs - 1800) / 600).clamp(0.0, 1.0);
  }
}
