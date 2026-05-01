import 'package:flutter/material.dart';

import '../../widgets/ta/shared/ta_colors.dart';

/// Shared design tokens for the refreshed TA courses shell.
class TACoursesTheme {
  static const Color brandPrimary = TAColors.primary;
  static const Color brandPrimaryLight = TAColors.primaryLight;
  static const Color brandPrimarySoft = TAColors.primaryLighter;
  static const Color accentBlue = TAColors.secondary;
  static const Color accentTeal = TAColors.teal;
  static const Color successGreen = TAColors.success;
  static const Color warningAmber = TAColors.warning;
  static const Color errorRed = TAColors.error;
  static const Color heroInk = Color(0xFF261D47);
  static const Color heroDeep = Color(0xFF3A2A67);
  static const Color darkScaffold = TAColors.darkBackground;
  static const Color darkSurface = TAColors.darkSurface;
  static const Color darkSurfaceRaised = TAColors.darkCard;
  static const Color lightScaffold = TAColors.lightBackground;
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceMuted = Color(0xFFF7F3FF);
  static const Color lightBorder = TAColors.border;
  static const Color lightText = TAColors.textPrimary;
  static const Color darkText = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[TAColors.primaryLight, TAColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: <Color>[heroDeep, heroInk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientLight = LinearGradient(
    colors: <Color>[TAColors.primary, TAColors.primaryLight, TAColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: <Color>[
      Color(0xFFF6F2FF),
      Color(0xFFFFFFFF),
      Color(0xFFF3F7FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BorderRadius shellRadius = BorderRadius.all(Radius.circular(28));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(28));
  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(18),
  );
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(999));

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
    return isDark ? Colors.white54 : TAColors.textTertiary;
  }

  static Color secondaryText(bool isDark) {
    return isDark ? Colors.white70 : TAColors.textSecondary;
  }

  static Color primaryText(bool isDark) {
    return isDark ? darkText : lightText;
  }

  static Color borderColor(bool isDark) {
    return isDark ? Colors.white.withValues(alpha: 0.10) : lightBorder;
  }

  static Color chipBackground(bool isDark) {
    return isDark ? Colors.white.withValues(alpha: 0.06) : lightSurfaceMuted;
  }

  static Color chipSelectedBackground(bool isDark) {
    return isDark ? const Color(0xFF463467) : const Color(0xFFF0E8FF);
  }

  static Color statusColor(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'draft':
        return warningAmber;
      case 'archived':
        return errorRed;
      case 'active':
      default:
        return successGreen;
    }
  }

  static double maxContentWidth(double screenWidth) {
    if (screenWidth >= 1440) {
      return 1180;
    }
    if (screenWidth >= 1024) {
      return 1080;
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
