import 'dart:math' as math;

import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:flutter/material.dart';

class SplashV8FloatingGlyphs extends StatelessWidget {
  const SplashV8FloatingGlyphs({
    super.key,
    required this.animation,
    required this.tokens,
    required this.isRtl,
    required this.reduceMotion,
  });

  static const List<String> _glyphs = <String>['+', '·', '◦', '×', '+'];

  final Animation<double> animation;
  final SplashV8Tokens tokens;
  final bool isRtl;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Stack(
                children: List<Widget>.generate(_glyphs.length, (index) {
                  final xPercent = 15 + (index * 18);
                  final mirroredX = isRtl ? 100 - xPercent : xPercent;
                  final topPercent = 20 + ((index % 2) * 35);
                  final glyphProgress = reduceMotion
                      ? 1.0
                      : _glyphProgress(index, animation.value);
                  final opacity = _opacityAt(glyphProgress);
                  final scale =
                      0.6 +
                      (0.4 *
                          Curves.easeOut.transform(
                            glyphProgress.clamp(0.0, 1.0),
                          ));

                  return Positioned(
                    left: constraints.maxWidth * mirroredX / 100,
                    top: constraints.maxHeight * topPercent / 100,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: (math.pi / 2) * glyphProgress,
                        child: Transform.scale(
                          scale: scale,
                          child: Text(
                            _glyphs[index],
                            style: TextStyle(
                              color: tokens.glyphColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }

  double _glyphProgress(int index, double progress) {
    final startMs = 600 + (index * 200);
    final timelineMs = progress * SplashV8Timing.timelineMs;
    return ((timelineMs - startMs) / 2000).clamp(0.0, 1.0);
  }

  double _opacityAt(double progress) {
    if (progress <= 0) {
      return 0;
    }
    if (progress < 0.45) {
      return Curves.easeOut.transform(progress / 0.45) * 0.70;
    }
    final fadeProgress = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
    return 0.70 - (0.30 * Curves.easeOut.transform(fadeProgress));
  }
}
