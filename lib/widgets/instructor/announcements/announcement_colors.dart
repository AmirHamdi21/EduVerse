import 'package:flutter/material.dart';

/// Announcement Manager color constants matching instructor theme
class AnnouncementColors {
  AnnouncementColors._();

  // Primary blues - matching instructor theme
  static const Color primary = Color(0xFF155CFB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEEF5FF);

  // Status colors
  static const Color published = Color(0xFF10B981);
  static const Color publishedLight = Color(0xFFD1FAE5);
  static const Color publishedDark = Color(0xFF059669);

  static const Color scheduled = Color(0xFFF59E0B);
  static const Color scheduledLight = Color(0xFFFEF3C7);
  static const Color scheduledDark = Color(0xFFD97706);

  static const Color draft = Color(0xFF64748B);
  static const Color draftLight = Color(0xFFF1F5F9);
  static const Color draftDark = Color(0xFF475569);

  // Action colors
  static const Color delete = Color(0xFFEF4444);
  static const Color deleteLight = Color(0xFFFEE2E2);
  static const Color deleteDark = Color(0xFFDC2626);

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

  static const LinearGradient publishedGradient = LinearGradient(
    colors: [published, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scheduledGradient = LinearGradient(
    colors: [scheduled, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient draftGradient = LinearGradient(
    colors: [draft, Color(0xFF94A3B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, Color(0xFF2563EB)],
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
      case 'published':
        return published;
      case 'scheduled':
        return scheduled;
      case 'draft':
        return draft;
      default:
        return textSecondary;
    }
  }

  static Color getStatusLightColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return publishedLight;
      case 'scheduled':
        return scheduledLight;
      case 'draft':
        return draftLight;
      default:
        return surface;
    }
  }

  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return publishedGradient;
      case 'scheduled':
        return scheduledGradient;
      case 'draft':
        return draftGradient;
      default:
        return primaryGradient;
    }
  }

  // Theme-aware color getters
  static Color background(bool isDark) =>
      isDark ? darkBg : const Color(0xFFFAFAFA);
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) =>
      isDark ? darkTextTertiary : textTertiary;

  static Color chipBgColor(bool isDark, bool isSelected) {
    if (isSelected) return primary;
    return isDark ? darkSurface : Colors.white;
  }

  static Color chipTextColor(bool isDark, bool isSelected) {
    if (isSelected) return Colors.white;
    return isDark ? darkTextSecondary : textSecondary;
  }

  static Color chipBorderColor(bool isDark, bool isSelected) {
    if (isSelected) return primary;
    return isDark ? darkBorder : border;
  }
}
