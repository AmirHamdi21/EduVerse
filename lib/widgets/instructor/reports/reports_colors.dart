import 'package:flutter/material.dart';

/// Reports & Analytics color constants matching instructor theme
class ReportsColors {
  ReportsColors._();

  // Primary blues - matching instructor theme
  static const Color primary = Color(0xFF155CFB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEEF5FF);

  // Grade colors
  static const Color gradeA = Color(0xFF10B981); // Excellent - Green
  static const Color gradeALight = Color(0xFFD1FAE5);
  static const Color gradeB = Color(0xFF3B82F6); // Good - Blue
  static const Color gradeBLight = Color(0xFFDBEAFE);
  static const Color gradeC = Color(0xFFF59E0B); // Satisfactory - Amber
  static const Color gradeCLight = Color(0xFFFEF3C7);
  static const Color gradeD = Color(0xFFF97316); // Needs Improvement - Orange
  static const Color gradeDLight = Color(0xFFFFEDD5);
  static const Color gradeF = Color(0xFFEF4444); // Failing - Red
  static const Color gradeFLight = Color(0xFFFEE2E2);

  // Attendance colors
  static const Color present = Color(0xFF10B981);
  static const Color presentLight = Color(0xFFD1FAE5);
  static const Color absent = Color(0xFFEF4444);
  static const Color absentLight = Color(0xFFFEE2E2);
  static const Color late = Color(0xFFF59E0B);
  static const Color lateLight = Color(0xFFFEF3C7);

  // Trend colors
  static const Color trendUp = Color(0xFF10B981);
  static const Color trendStable = Color(0xFF64748B);
  static const Color trendDown = Color(0xFFEF4444);

  // Risk indicator
  static const Color atRisk = Color(0xFFEF4444);
  static const Color atRiskLight = Color(0xFFFEE2E2);

  // Accent colors
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFEDE9FE);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFFCFFAFE);

  // Neutrals
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color lightBackground = Color(0xFFFAFAFA);

  // Dark mode colors
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkBackground = Color(0xFF0F172A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF155CFB), Color(0xFF3B82F6), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF2D4A6F), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFEEF5FF), Color(0xFFF0F9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme-aware color getters
  static Color background(bool isDark) => isDark ? darkBg : lightBackground;
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) =>
      isDark ? darkTextTertiary : textTertiary;

  // Grade color helpers
  static Color getGradeColor(double percentage) {
    if (percentage >= 90) return gradeA;
    if (percentage >= 80) return gradeB;
    if (percentage >= 70) return gradeC;
    if (percentage >= 60) return gradeD;
    return gradeF;
  }

  static Color getGradeLightColor(double percentage) {
    if (percentage >= 90) return gradeALight;
    if (percentage >= 80) return gradeBLight;
    if (percentage >= 70) return gradeCLight;
    if (percentage >= 60) return gradeDLight;
    return gradeFLight;
  }

  // Attendance color helpers
  static Color getAttendanceColor(double rate) {
    if (rate >= 85) return present;
    if (rate >= 70) return late;
    return absent;
  }

  // Trend icon and color
  static Color getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return trendUp;
      case 'declining':
        return trendDown;
      default:
        return trendStable;
    }
  }

  static IconData getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return Icons.trending_up_rounded;
      case 'declining':
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }
}
