import 'package:flutter/material.dart';

import '../../widgets/instructor/courses/instructor_theme_colors.dart';

/// Shared design tokens for the refreshed instructor courses shell.
class InstructorCoursesTheme {
  static const Color brandBlue = InstructorColors.primary;
  static const Color brandBlueLight = InstructorColors.primaryMedium;
  static const Color brandBlueSoft = InstructorColors.primaryLight;
  static const Color accentPurple = InstructorColors.accentPurple;
  static const Color accentTeal = InstructorColors.accentTeal;
  static const Color successGreen = InstructorColors.success;
  static const Color warningAmber = InstructorColors.warning;
  static const Color errorRed = InstructorColors.error;
  static const Color heroInk = Color(0xFF10213F);
  static const Color heroNavy = Color(0xFF173E7A);
  static const Color darkScaffold = InstructorColors.darkBackground;
  static const Color darkSurface = InstructorColors.darkSurface;
  static const Color darkSurfaceRaised = InstructorColors.darkCard;
  static const Color lightScaffold = InstructorColors.primaryBackground;
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceMuted = Color(0xFFF3F7FD);
  static const Color lightBorder = InstructorColors.border;
  static const Color lightText = InstructorColors.textPrimary;
  static const Color darkText = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[InstructorColors.primaryMedium, InstructorColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: <Color>[Color(0xFF1E2E53), heroInk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientLight = LinearGradient(
    colors: <Color>[
      InstructorColors.primary,
      InstructorColors.primaryMedium,
      InstructorColors.accentPurple,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: <Color>[
      Color(0xFFF2F7FF),
      Color(0xFFFFFFFF),
      Color(0xFFF6F2FF),
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
    return isDark ? Colors.white54 : InstructorColors.textMuted;
  }

  static Color secondaryText(bool isDark) {
    return isDark ? Colors.white70 : InstructorColors.textSecondary;
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
    return isDark ? const Color(0xFF223A67) : const Color(0xFFE8F1FF);
  }

  static Color statusColor(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'draft':
        return warningAmber;
      case 'archived':
        return errorRed;
      case 'published':
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
