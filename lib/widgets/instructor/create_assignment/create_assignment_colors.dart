import 'package:flutter/material.dart';

/// Create Assignment/Lab color constants matching instructor theme
class CreateAssignmentColors {
  CreateAssignmentColors._();

  // Primary blues - matching instructor theme
  static const Color primary = Color(0xFF155CFB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEEF5FF);

  // Assignment type colors
  static const Color assignment = Color(0xFF155CFB);
  static const Color lab = Color(0xFF10B981);
  static const Color project = Color(0xFF8B5CF6);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Difficulty colors
  static const Color easy = Color(0xFF10B981);
  static const Color medium = Color(0xFF3B82F6);
  static const Color hard = Color(0xFFF59E0B);
  static const Color veryHard = Color(0xFFEF4444);

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

  // Background colors
  static const Color darkBackground = darkBg;
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient assignmentGradient = LinearGradient(
    colors: [assignment, Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient labGradient = LinearGradient(
    colors: [lab, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient projectGradient = LinearGradient(
    colors: [project, Color(0xFFA78BFA)],
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

  // Difficulty color helpers
  static Color getDifficultyColor(double value) {
    if (value <= 0.16) return easy;
    if (value <= 0.5) return medium;
    if (value <= 0.83) return hard;
    return veryHard;
  }

  // Type color helpers
  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return assignment;
      case 'lab':
        return lab;
      case 'project':
        return project;
      default:
        return primary;
    }
  }

  static LinearGradient getTypeGradient(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return assignmentGradient;
      case 'lab':
        return labGradient;
      case 'project':
        return projectGradient;
      default:
        return primaryGradient;
    }
  }
}
