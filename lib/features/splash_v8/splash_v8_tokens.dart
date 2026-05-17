import 'package:flutter/material.dart';

class SplashV8Tokens {
  const SplashV8Tokens({
    required this.isDark,
    required this.rootBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.kickerText,
    required this.glassBackground,
    required this.glassBorder,
    required this.glassHighlight,
    required this.gridStroke,
    required this.gridOpacity,
    required this.glyphColor,
    required this.homeIndicator,
    required this.overlayTop,
    required this.overlayMiddle,
    required this.overlayBottom,
  });

  static const Color brandGreen = Color(0xFF30D158);
  static const Color brandBlue = Color(0xFF0A84FF);

  final bool isDark;
  final Color rootBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color kickerText;
  final Color glassBackground;
  final Color glassBorder;
  final Color glassHighlight;
  final Color gridStroke;
  final double gridOpacity;
  final Color glyphColor;
  final Color homeIndicator;
  final Color overlayTop;
  final Color overlayMiddle;
  final Color overlayBottom;

  static SplashV8Tokens fromBrightness({required bool isDark}) {
    if (isDark) {
      return SplashV8Tokens(
        isDark: true,
        rootBackground: Colors.black,
        textPrimary: Colors.white,
        textSecondary: Colors.white.withValues(alpha: 0.92),
        kickerText: Colors.white.withValues(alpha: 0.88),
        glassBackground: Colors.white.withValues(alpha: 0.15),
        glassBorder: Colors.white.withValues(alpha: 0.30),
        glassHighlight: Colors.white.withValues(alpha: 0.30),
        gridStroke: Colors.white.withValues(alpha: 0.18),
        gridOpacity: 0.40,
        glyphColor: Colors.white.withValues(alpha: 0.30),
        homeIndicator: Colors.white,
        overlayTop: Colors.black.withValues(alpha: 0.50),
        overlayMiddle: Colors.black.withValues(alpha: 0.20),
        overlayBottom: Colors.black.withValues(alpha: 0.95),
      );
    }

    return SplashV8Tokens(
      isDark: false,
      rootBackground: const Color(0xFFF2F2F7),
      textPrimary: Colors.black.withValues(alpha: 0.98),
      textSecondary: Colors.black.withValues(alpha: 0.88),
      kickerText: Colors.black.withValues(alpha: 0.92),
      glassBackground: Colors.white.withValues(alpha: 0.76),
      glassBorder: Colors.white.withValues(alpha: 0.86),
      glassHighlight: Colors.white.withValues(alpha: 0.60),
      gridStroke: Colors.black.withValues(alpha: 0.18),
      gridOpacity: 0.50,
      glyphColor: Colors.black.withValues(alpha: 0.25),
      homeIndicator: Colors.black,
      overlayTop: Colors.black.withValues(alpha: 0.12),
      overlayMiddle: Colors.white.withValues(alpha: 0.04),
      overlayBottom: Colors.white.withValues(alpha: 0.68),
    );
  }
}
