import 'package:flutter/material.dart';

/// Admin color scheme following the same pattern as student/instructor/TA
class AdminColors {
  // Primary colors
  static const Color primary = Color(0xFF155DFC);
  static const Color primaryLight = Color(0xFF2B7FFF);
  static const Color primaryDark = Color(0xFF1447E6);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF00B8DB);

  // Gradient colors
  static const Color gradientStart = Color(0xFF2B7FFF);
  static const Color gradientEnd = Color(0xFF4F39F6);
  static const Color cyanGradientStart = Color(0xFF00B8DB);
  static const Color cyanGradientEnd = Color(0xFF155DFC);

  // Status colors
  static const Color success = Color(0xFF00C950);
  static const Color successLight = Color(0xFF10B981);
  static const Color warning = Color(0xFFF0B100);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color error = Color(0xFFFB2C36);
  static const Color errorLight = Color(0xFFEF4444);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFBEDBFF);
  static const Color lightPurpleBorder = Color(0xFFE9D4FF);
  static const Color lightText = Color(0xFF101828);
  static const Color lightTextSecondary = Color(0xFF4A5565);
  static const Color lightTextTertiary = Color(0xFF6A7282);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF1A2847);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0AEC0);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF334155);

  // Chart colors
  static const Color chartBlue = Color(0xFF2B7FFF);
  static const Color chartPurple = Color(0xFFAD46FF);
  static const Color chartPink = Color(0xFFF6339A);
  static const Color chartCyan = Color(0xFF00B8DB);
  static const Color chartGreen = Color(0xFF00C950);
  static const Color chartOrange = Color(0xFFF0B100);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAD46FF), Color(0xFFE60076)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyanGradientStart, cyanGradientEnd],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C950), Color(0xFF009689)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFF7C3AED)],
  );

  static LinearGradient lightBackgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEFF6FF), // Light blue
      Colors.white,
      Color(0xFFFAF5FF), // Light purple
    ],
  );

  static LinearGradient darkBackgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1A1A2E),
    ],
  );

  // Helper methods
  static Color getBackgroundColor(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color getSurfaceColor(bool isDark) =>
      isDark ? darkSurface : lightSurface;

  static Color getCardColor(bool isDark) => isDark ? darkCard : lightCard;

  static Color getCardBorderColor(bool isDark) =>
      isDark ? darkCardBorder : lightCardBorder;

  static Color getTextColor(bool isDark) => isDark ? darkText : lightText;

  static Color getTextSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color getTextTertiaryColor(bool isDark) =>
      isDark ? darkTextTertiary : lightTextTertiary;

  static Color getDividerColor(bool isDark) =>
      isDark ? darkDivider : lightDivider;

  static LinearGradient getBackgroundGradient(bool isDark) =>
      isDark ? darkBackgroundGradient : lightBackgroundGradient;
}
