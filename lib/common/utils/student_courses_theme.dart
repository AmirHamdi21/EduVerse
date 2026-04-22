import 'package:flutter/material.dart';

/// Shared design tokens for the student courses Phase 1 shell.
class StudentCoursesTheme {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[Color(0xFF2B7FFF), Color(0xFF155DFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: <Color>[Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BorderRadius shellRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(24));
  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(14),
  );

  static const Duration cardAnimationDuration = Duration(milliseconds: 600);
  static const Duration controlAnimationDuration = Duration(milliseconds: 220);

  static Color scaffoldBackground(bool isDark) {
    return isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA);
  }

  static Color cardBackground(bool isDark) {
    return isDark ? const Color(0xFF16213E) : Colors.white;
  }

  static Color mutedText(bool isDark) {
    return isDark ? Colors.white54 : const Color(0xFF667085);
  }

  static Color borderColor(bool isDark) {
    return isDark ? Colors.white.withOpacity(0.10) : const Color(0xFFD1D5DC);
  }
}
