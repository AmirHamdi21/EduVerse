import 'dart:ui' as ui;

import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SplashV8GlassPill extends StatelessWidget {
  const SplashV8GlassPill({
    super.key,
    required this.timelineAnimation,
    required this.dotAnimation,
    required this.tokens,
    required this.l10n,
    required this.reduceMotion,
  });

  final Animation<double> timelineAnimation;
  final Animation<double> dotAnimation;
  final SplashV8Tokens tokens;
  final AppLocalizations l10n;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        timelineAnimation,
        dotAnimation,
      ]),
      builder: (context, child) {
        final progress = reduceMotion
            ? 1.0
            : _entryProgress(timelineAnimation.value);
        final eased = Curves.easeOut.transform(progress);

        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, -10 * (1 - eased)),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.glassBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: tokens.glassBorder, width: 0.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: tokens.glassHighlight,
                  offset: const Offset(0, 1),
                  blurRadius: 0,
                  spreadRadius: -0.5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                key: const Key('splash-v8-pill'),
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _BreathingDot(
                    animation: dotAnimation,
                    reduceMotion: reduceMotion,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.splashV8PillLabel,
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
        ),
      ),
    );
  }

  double _entryProgress(double progress) {
    final timelineMs = progress * SplashV8Timing.timelineMs;
    return ((timelineMs - 1000) / 500).clamp(0.0, 1.0);
  }
}

class _BreathingDot extends StatelessWidget {
  const _BreathingDot({required this.animation, required this.reduceMotion});

  final Animation<double> animation;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final wave = reduceMotion
            ? 0.0
            : (1 - ((animation.value * 2 - 1).abs()));
        final scale = 1 + (0.6 * wave);
        final opacity = 1 - (0.6 * wave);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: SplashV8Tokens.brandGreen,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: SplashV8Tokens.brandGreen, blurRadius: 10),
          ],
        ),
      ),
    );
  }
}
