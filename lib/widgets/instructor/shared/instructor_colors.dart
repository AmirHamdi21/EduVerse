import 'package:flutter/material.dart';

/// Shared color constants for instructor features
class InstructorColors {
  InstructorColors._();

  // Primary blues - matching instructor theme
  static const Color primary = Color(0xFF155CFB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEEF5FF);

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
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFEDE9FE);
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

  // Theme-aware color getters
  static Color background(bool isDark) => isDark ? darkBg : lightBackground;
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) => isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) => isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) => isDark ? darkTextTertiary : textTertiary;

  // Notification type colors
  static Color getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
      case 'submission':
        return primary;
      case 'grade':
      case 'grading':
        return success;
      case 'announcement':
        return accent;
      case 'message':
      case 'chat':
        return cyan;
      case 'course':
        return teal;
      case 'attendance':
        return warning;
      case 'deadline':
      case 'urgent':
        return error;
      case 'system':
        return textSecondary;
      default:
        return primary;
    }
  }

  static Color getNotificationLightColor(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
      case 'submission':
        return primarySurface;
      case 'grade':
      case 'grading':
        return successLight;
      case 'announcement':
        return accentLight;
      case 'message':
      case 'chat':
        return cyanLight;
      case 'course':
        return tealLight;
      case 'attendance':
        return warningLight;
      case 'deadline':
      case 'urgent':
        return errorLight;
      default:
        return primarySurface;
    }
  }

  static IconData getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Icons.assignment_outlined;
      case 'submission':
        return Icons.upload_file_outlined;
      case 'grade':
      case 'grading':
        return Icons.grade_outlined;
      case 'announcement':
        return Icons.campaign_outlined;
      case 'message':
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'course':
        return Icons.school_outlined;
      case 'attendance':
        return Icons.how_to_reg_outlined;
      case 'deadline':
        return Icons.alarm_outlined;
      case 'urgent':
        return Icons.priority_high_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}
