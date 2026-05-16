import 'package:flutter/material.dart';

class OnboardingV6Tokens {
  const OnboardingV6Tokens._({
    required this.isDark,
    required this.rootBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.glassBackground,
    required this.glassBorder,
    required this.pillBackground,
    required this.pillBorder,
    required this.segmentTrack,
    required this.segmentBorder,
    required this.inactiveDot,
    required this.homeIndicator,
    required this.horizontalScrimStart,
    required this.horizontalScrimMiddle,
    required this.verticalScrimMiddle,
    required this.verticalScrimBottom,
  });

  factory OnboardingV6Tokens.fromBrightness({required bool isDark}) {
    return OnboardingV6Tokens._(
      isDark: isDark,
      rootBackground: isDark ? Colors.black : const Color(0xFFF2F2F7),
      textPrimary: isDark ? Colors.white : Colors.black.withValues(alpha: 0.92),
      textSecondary: isDark
          ? Colors.white.withValues(alpha: 0.85)
          : Colors.black.withValues(alpha: 0.70),
      textMuted: isDark
          ? Colors.white.withValues(alpha: 0.60)
          : Colors.black.withValues(alpha: 0.50),
      glassBackground: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.55),
      glassBorder: isDark
          ? Colors.white.withValues(alpha: 0.22)
          : Colors.white.withValues(alpha: 0.70),
      pillBackground: isDark
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.55),
      pillBorder: isDark
          ? Colors.white.withValues(alpha: 0.30)
          : Colors.white.withValues(alpha: 0.70),
      segmentTrack: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.06),
      segmentBorder: isDark
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.black.withValues(alpha: 0.08),
      inactiveDot: isDark
          ? Colors.white.withValues(alpha: 0.30)
          : Colors.black.withValues(alpha: 0.22),
      homeIndicator: isDark ? Colors.white : Colors.black,
      horizontalScrimStart: isDark
          ? Colors.black.withValues(alpha: 0.70)
          : Colors.black.withValues(alpha: 0.25),
      horizontalScrimMiddle: Colors.black.withValues(alpha: 0.20),
      verticalScrimMiddle: isDark
          ? Colors.black.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.10),
      verticalScrimBottom: isDark
          ? Colors.black.withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.55),
    );
  }

  final bool isDark;
  final Color rootBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color glassBackground;
  final Color glassBorder;
  final Color pillBackground;
  final Color pillBorder;
  final Color segmentTrack;
  final Color segmentBorder;
  final Color inactiveDot;
  final Color homeIndicator;
  final Color horizontalScrimStart;
  final Color horizontalScrimMiddle;
  final Color verticalScrimMiddle;
  final Color verticalScrimBottom;
}
