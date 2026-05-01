import 'package:flutter/material.dart';

/// Shared design tokens for the student courses Phase 1 shell.
class StudentCoursesTheme {
  static const Color brandBlue = Color(0xFF155DFC);
  static const Color brandBlueLight = Color(0xFF2B7FFF);
  static const Color brandBlueSoft = Color(0xFF8EC5FF);
  static const Color brandBluePale = Color(0xFFEAF2FF);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color heroInk = Color(0xFF0F172A);
  static const Color heroNavy = Color(0xFF172554);
  static const Color darkScaffold = Color(0xFF121A2B);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkSurfaceRaised = Color(0xFF1B2A4A);
  static const Color lightScaffold = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceMuted = Color(0xFFF5F7FB);
  static const Color lightBorder = Color(0xFFD7DFEA);
  static const Color lightText = Color(0xFF101828);
  static const Color darkText = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[brandBlueLight, brandBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: <Color>[Color(0xFF1E293B), heroInk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientLight = LinearGradient(
    colors: <Color>[heroInk, heroNavy, brandBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: <Color>[Color(0xFFF6FAFF), Color(0xFFFFFFFF), Color(0xFFF1F7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BorderRadius shellRadius = BorderRadius.all(Radius.circular(28));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(28));
  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(18),
  );
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(999));

  static const Duration cardAnimationDuration = Duration(milliseconds: 600);
  static const Duration controlAnimationDuration = Duration(milliseconds: 220);

  static Color scaffoldBackground(bool isDark) {
    return isDark ? darkScaffold : lightScaffold;
  }

  static Decoration scaffoldDecoration(bool isDark) {
    return BoxDecoration(
      color: scaffoldBackground(isDark),
      gradient: isDark ? null : backgroundGradientLight,
    );
  }

  static Color cardBackground(bool isDark) {
    return isDark ? darkSurface : lightSurface;
  }

  static Color elevatedCardBackground(bool isDark) {
    return isDark ? darkSurfaceRaised : lightSurface;
  }

  static Color mutedText(bool isDark) {
    return isDark ? Colors.white54 : const Color(0xFF667085);
  }

  static Color secondaryText(bool isDark) {
    return isDark ? Colors.white70 : const Color(0xFF475467);
  }

  static Color primaryText(bool isDark) {
    return isDark ? darkText : lightText;
  }

  static Color borderColor(bool isDark) {
    return isDark ? Colors.white.withValues(alpha: 0.10) : lightBorder;
  }

  static Color surfaceTint(bool isDark) {
    return isDark ? Colors.white.withValues(alpha: 0.05) : brandBluePale;
  }

  static Color chipBackground(bool isDark) {
    return isDark ? Colors.white.withValues(alpha: 0.06) : lightSurfaceMuted;
  }

  static Color chipSelectedBackground(bool isDark) {
    return isDark ? const Color(0xFF233559) : const Color(0xFFE8F1FF);
  }

  static Color statusColor(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'completed':
        return successGreen;
      case 'dropped':
        return errorRed;
      case 'waitlisted':
        return warningAmber;
      case 'active':
      default:
        return brandBlue;
    }
  }

  static double maxContentWidth(double screenWidth) {
    if (screenWidth >= 1280) {
      return 1120;
    }
    if (screenWidth >= 900) {
      return 1000;
    }
    return screenWidth;
  }

  static EdgeInsets screenPadding(double screenWidth) {
    if (screenWidth >= 1280) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    if (screenWidth >= 900) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 18);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }
}
