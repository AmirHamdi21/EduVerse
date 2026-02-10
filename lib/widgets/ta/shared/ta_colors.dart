import 'package:flutter/material.dart';

/// Shared color constants for TA features
class TAColors {
  TAColors._();

  // Primary purple/violet - TA theme
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryLighter = Color(0xFFC4B5FD);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primarySurface = Color(0xFFF5F3FF);

  // Secondary blue
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Accent colors
  static const Color accent = Color(0xFF155CFB);
  static const Color accentLight = Color(0xFFEEF5FF);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFFCFFAFE);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFEDD5);
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFFCE7F3);

  // Neutrals - Light
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

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF3B2667), Color(0xFF1E293B), Color(0xFF1E1E3F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme-aware color getters
  static Color background(bool isDark) => isDark ? darkBg : lightBackground;
  static Color scaffoldColor(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) =>
      isDark ? darkTextTertiary : textTertiary;

  // Task priority colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return error;
      case 'medium':
        return warning;
      case 'low':
        return success;
      default:
        return textSecondary;
    }
  }

  static Color getPriorityLightColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return errorLight;
      case 'medium':
        return warningLight;
      case 'low':
        return successLight;
      default:
        return surface;
    }
  }

  // Task type colors
  static Color getTaskTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grading':
        return primary;
      case 'review':
        return secondary;
      case 'discussion':
        return teal;
      case 'office_hours':
        return orange;
      case 'attendance':
        return cyan;
      default:
        return textSecondary;
    }
  }

  static IconData getTaskTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'grading':
        return Icons.grading_rounded;
      case 'review':
        return Icons.rate_review_rounded;
      case 'discussion':
        return Icons.forum_rounded;
      case 'office_hours':
        return Icons.access_time_rounded;
      case 'attendance':
        return Icons.how_to_reg_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }
}
