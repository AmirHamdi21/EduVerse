import 'dart:ui' show lerpDouble;

import 'package:edu_verse/features/onboarding_v6/onboarding_v6_slide.dart';
import 'package:edu_verse/features/onboarding_v6/onboarding_v6_tokens.dart';
import 'package:flutter/material.dart';

class OnboardingV6HeroScene extends StatelessWidget {
  const OnboardingV6HeroScene({
    super.key,
    required this.slide,
    required this.previousSlide,
    required this.animation,
    required this.tokens,
    required this.isRtl,
  });

  final OnboardingV6Slide slide;
  final OnboardingV6Slide? previousSlide;
  final Animation<double> animation;
  final OnboardingV6Tokens tokens;
  final bool isRtl;

  static const Curve _curve = Cubic(0.25, 0.1, 0.25, 1);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final rawT = animation.value.clamp(0.0, 1.0);
          final t = _curve.transform(rawT);
          final direction = isRtl ? -1.0 : 1.0;

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (previousSlide != null && rawT < 1)
                _HeroImageLayer(
                  slide: previousSlide!,
                  opacity: 1 - t,
                  scale: lerpDouble(1, 1.05, t)!,
                  dx: lerpDouble(0, -30 * direction, t)!,
                ),
              _HeroImageLayer(
                slide: slide,
                opacity: t,
                scale: lerpDouble(1.18, 1, t)!,
                dx: lerpDouble(30 * direction, 0, t)!,
              ),
              _DirectionalScrims(
                tokens: tokens,
                tint: slide.tint,
                isRtl: isRtl,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroImageLayer extends StatelessWidget {
  const _HeroImageLayer({
    required this.slide,
    required this.opacity,
    required this.scale,
    required this.dx,
  });

  final OnboardingV6Slide slide;
  final double opacity;
  final double scale;
  final double dx;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            slide.imageAsset,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

class _DirectionalScrims extends StatelessWidget {
  const _DirectionalScrims({
    required this.tokens,
    required this.tint,
    required this.isRtl,
  });

  final OnboardingV6Tokens tokens;
  final Color tint;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                colors: <Color>[
                  tokens.horizontalScrimStart,
                  tokens.horizontalScrimMiddle,
                  Colors.transparent,
                ],
                stops: const <double>[0, 0.50, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.transparent,
                  tokens.verticalScrimMiddle,
                  tokens.verticalScrimBottom,
                ],
                stops: const <double>[0, 0.40, 0.75],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: isRtl ? Alignment.bottomRight : Alignment.bottomLeft,
                radius: 0.82,
                colors: <Color>[
                  tint.withValues(alpha: 0.33),
                  Colors.transparent,
                ],
                stops: const <double>[0, 0.65],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
