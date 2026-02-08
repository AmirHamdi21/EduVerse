import 'package:flutter/material.dart';

/// Attendance Manager color constants matching instructor theme
class AttendanceColors {
  AttendanceColors._();

  // Primary blues - matching instructor theme
  static const Color primary = Color(0xFF155CFB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEEF5FF);

  // Attendance status colors
  static const Color present = Color(0xFF10B981);
  static const Color presentLight = Color(0xFFD1FAE5);
  static const Color presentDark = Color(0xFF059669);

  static const Color absent = Color(0xFFEF4444);
  static const Color absentLight = Color(0xFFFEE2E2);
  static const Color absentDark = Color(0xFFDC2626);

  static const Color late = Color(0xFFF59E0B);
  static const Color lateLight = Color(0xFFFEF3C7);
  static const Color lateDark = Color(0xFFD97706);

  static const Color excused = Color(0xFF8B5CF6);
  static const Color excusedLight = Color(0xFFEDE9FE);
  static const Color excusedDark = Color(0xFF7C3AED);

  static const Color unmarked = Color(0xFF64748B);
  static const Color unmarkedLight = Color(0xFFF1F5F9);
  static const Color unmarkedDark = Color(0xFF475569);

  // Progress colors
  static const Color progressGood = Color(0xFF10B981);
  static const Color progressWarning = Color(0xFFF59E0B);
  static const Color progressDanger = Color(0xFFEF4444);

  // Accent colors
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFFEDE9FE);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFCCFBF1);

  // Neutrals
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;

  // Dark mode colors
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient presentGradient = LinearGradient(
    colors: [present, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient absentGradient = LinearGradient(
    colors: [absent, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lateGradient = LinearGradient(
    colors: [late, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme-aware color getters
  static Color background(bool isDark) => isDark ? darkBg : const Color(0xFFFAFAFA);
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) => isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) => isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) => isDark ? darkTextTertiary : textTertiary;
  
  // Background color aliases for screen usage
  static const Color darkBackground = darkBg;
  static const Color lightBackground = Color(0xFFFAFAFA);

  // Status color helpers
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return present;
      case 'absent':
        return absent;
      case 'late':
        return late;
      case 'excused':
        return excused;
      case 'unmarked':
        return unmarked;
      default:
        return textSecondary;
    }
  }

  static Color getStatusLightColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return presentLight;
      case 'absent':
        return absentLight;
      case 'late':
        return lateLight;
      case 'excused':
        return excusedLight;
      case 'unmarked':
        return unmarkedLight;
      default:
        return surface;
    }
  }

  static Color getProgressColor(double rate) {
    if (rate >= 0.75) return progressGood;
    if (rate >= 0.5) return progressWarning;
    return progressDanger;
  }
}
