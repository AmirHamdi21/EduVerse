import 'package:flutter/material.dart';

/// Grading Center color constants based on darker #155CFB palette
class GradingColors {
  GradingColors._();

  // Primary blues - darker variant of #155CFB
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryLighter = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0A3A8A);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // Status colors
  static const Color pending = Color(0xFFF59E0B);
  static const Color pendingLight = Color(0xFFFEF3C7);
  static const Color pendingDark = Color(0xFFD97706);

  static const Color graded = Color(0xFF10B981);
  static const Color gradedLight = Color(0xFFD1FAE5);
  static const Color gradedDark = Color(0xFF059669);

  static const Color late = Color(0xFFEF4444);
  static const Color lateLight = Color(0xFFFEE2E2);
  static const Color lateDark = Color(0xFFDC2626);

  // Accent colors
  static const Color accent = Color(0xFF7C4DFF);
  static const Color accentLight = Color(0xFFEDE7FF);
  static const Color teal = Color(0xFF00BFA5);
  static const Color tealLight = Color(0xFFE0F7FA);
  static const Color orange = Color(0xFFFF6D00);
  static const Color orangeLight = Color(0xFFFFF3E0);

  // Neutrals
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;

  // Dark mode colors
  static const Color darkBg = Color(0xFF0A1929);
  static const Color darkCard = Color(0xFF132F4C);
  static const Color darkSurface = Color(0xFF1A3A5C);
  static const Color darkBorder = Color(0xFF234E70);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
  static const Color darkTextTertiary = Color(0xFF78909C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pendingGradient = LinearGradient(
    colors: [pending, Color(0xFFFFB84D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradedGradient = LinearGradient(
    colors: [graded, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lateGradient = LinearGradient(
    colors: [late, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, Color(0xFF1976D2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient darkHeaderGradient = LinearGradient(
    colors: [darkBg, darkCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Helper methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'graded':
        return graded;
      case 'late':
        return late;
      default:
        return textSecondary;
    }
  }

  static Color getStatusLightColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingLight;
      case 'graded':
        return gradedLight;
      case 'late':
        return lateLight;
      default:
        return surface;
    }
  }

  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingGradient;
      case 'graded':
        return gradedGradient;
      case 'late':
        return lateGradient;
      default:
        return primaryGradient;
    }
  }

  static Color getGradeColor(double percentage) {
    if (percentage >= 90) return graded;
    if (percentage >= 80) return teal;
    if (percentage >= 70) return pending;
    if (percentage >= 60) return orange;
    return late;
  }

  // Theme-aware color getters
  static Color background(bool isDark) => isDark ? darkBg : surface;
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) =>
      isDark ? darkTextTertiary : textTertiary;
}
