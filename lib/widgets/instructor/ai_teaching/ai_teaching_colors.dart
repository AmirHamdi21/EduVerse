import 'package:flutter/material.dart';

/// AI Teaching Assistant color constants matching instructor theme
class AITeachingColors {
  AITeachingColors._();

  // Primary blues - matching instructor theme
  static const Color primary = Color(0xFF155CFB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEEF5FF);

  // AI accent colors
  static const Color aiBlue = Color(0xFF0EA5E9);
  static const Color aiCyan = Color(0xFF06B6D4);
  static const Color aiTeal = Color(0xFF14B8A6);
  static const Color aiPurple = Color(0xFF8B5CF6);

  // Mode colors
  static const Color createContent = Color(0xFF155CFB);
  static const Color analyzeData = Color(0xFF0EA5E9);
  static const Color rewriteEnhance = Color(0xFF8B5CF6);
  static const Color courseInsights = Color(0xFFF59E0B);
  static const Color communication = Color(0xFF10B981);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);

  // Message bubble colors
  static const Color userBubble = Color(0xFF155CFB);
  static const Color aiBubbleLight = Color(0xFFF1F5F9);
  static const Color aiBubbleDark = Color(0xFF1E293B);

  // Neutrals
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFF8FAFC);

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
    colors: [Color(0xFF155CFB), Color(0xFF0EA5E9), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEEF5FF),
      Color(0xFFF5F3FF),
      Color(0xFFECFEFF),
    ],
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient sendButtonGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Quick action gradient
  static LinearGradient quickActionGradient(bool isDark) => LinearGradient(
    colors: isDark
        ? [darkCard, darkCard]
        : [Colors.white, Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme-aware color getters
  static Color backgroundColor(bool isDark) => isDark ? darkBg : lightBackground;
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) => isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) => isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) => isDark ? darkTextTertiary : textTertiary;
  static Color messageBubbleColor(bool isDark) => isDark ? aiBubbleDark : aiBubbleLight;

  // Get mode color
  static Color getModeColor(int index) {
    switch (index) {
      case 0:
        return createContent;
      case 1:
        return analyzeData;
      case 2:
        return rewriteEnhance;
      case 3:
        return courseInsights;
      case 4:
        return communication;
      default:
        return primary;
    }
  }

  // Get mode icon
  static IconData getModeIcon(int index) {
    switch (index) {
      case 0:
        return Icons.auto_awesome_rounded;
      case 1:
        return Icons.bar_chart_rounded;
      case 2:
        return Icons.edit_note_rounded;
      case 3:
        return Icons.school_rounded;
      case 4:
        return Icons.notifications_rounded;
      default:
        return Icons.smart_toy_rounded;
    }
  }
}
