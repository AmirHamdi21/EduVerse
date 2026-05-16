import 'dart:ui' as ui;

import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:flutter/material.dart';

class SplashV8HeroBackdrop extends StatelessWidget {
  const SplashV8HeroBackdrop({
    super.key,
    required this.animation,
    required this.tokens,
    required this.isRtl,
    required this.reduceMotion,
  });

  static const String imageAsset = 'assets/images/splash_screen.jpg';
  final Animation<double> animation;
  final SplashV8Tokens tokens;
  final bool isRtl;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: tokens.rootBackground,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final rawProgress = reduceMotion
                  ? 1.0
                  : (animation.value * SplashV8Timing.timelineMs / 2200).clamp(
                      0.0,
                      1.0,
                    );
              final progress = SplashV8Timing.motionCurve.transform(
                rawProgress,
              );
              final scale = 1.4 - (0.4 * progress);
              final blur = 20.0 * (1 - progress);

              return Opacity(
                opacity: progress,
                child: Transform.scale(
                  scale: scale,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: blur,
                      sigmaY: blur,
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: Image.asset(
              imageAsset,
              key: const Key('splash-v8-hero-image'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        tokens.isDark
                            ? const Color(0xFF030712)
                            : const Color(0xFFE5E7EB),
                        tokens.isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF8FAFC),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  tokens.overlayTop,
                  tokens.overlayMiddle,
                  tokens.overlayBottom,
                ],
                stops: const <double>[0, 0.48, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomCenter,
                radius: 0.75,
                colors: <Color>[
                  SplashV8Tokens.brandGreen.withValues(alpha: 0.40),
                  Colors.transparent,
                ],
                stops: const <double>[0, 0.60],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: isRtl ? Alignment.topLeft : Alignment.topRight,
                radius: 0.65,
                colors: <Color>[
                  SplashV8Tokens.brandBlue.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                stops: const <double>[0, 0.60],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
