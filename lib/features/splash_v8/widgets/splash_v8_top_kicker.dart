import 'dart:ui' as ui;

import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SplashV8TopKicker extends StatelessWidget {
  const SplashV8TopKicker({
    super.key,
    required this.animation,
    required this.tokens,
    required this.l10n,
    required this.isRtl,
    required this.reduceMotion,
  });

  final Animation<double> animation;
  final SplashV8Tokens tokens;
  final AppLocalizations l10n;
  final bool isRtl;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 24, end: 24, top: 16),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = reduceMotion ? 1.0 : _progress(animation.value);
          final eased = Curves.easeOut.transform(progress);
          final leadingOffset = isRtl ? 20.0 : -20.0;

          return Opacity(
            opacity: eased,
            child: Transform.translate(
              offset: Offset(leadingOffset * (1 - eased), 0),
              child: child,
            ),
          );
        },
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.glassBackground,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: tokens.glassBorder, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  child: Row(
                    key: const Key('splash-v8-kicker'),
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: SplashV8Tokens.brandGreen,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: SplashV8Tokens.brandGreen.withValues(
                                alpha: 0.45,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.splashV8Kicker,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.kickerText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            shadows: <Shadow>[
                              Shadow(
                                color: tokens.isDark
                                    ? Colors.black.withValues(alpha: 0.60)
                                    : Colors.white.withValues(alpha: 0.65),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _progress(double progress) {
    final timelineMs = progress * SplashV8Timing.timelineMs;
    return ((timelineMs - 500) / 600).clamp(0.0, 1.0);
  }
}
