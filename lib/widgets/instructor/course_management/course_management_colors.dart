import 'package:flutter/material.dart';

/// Course Management theme colors - consistent with InstructorColors palette
class CMColors {
  CMColors._();

  // Primary
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryMedium = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryLighter = Color(0xFF90CAF9);
  static const Color primaryBg = Color(0xFFF0F7FF);

  // Accent
  static const Color accent = Color(0xFF7C4DFF);
  static const Color accentLight = Color(0xFFEDE7FF);
  static const Color orange = Color(0xFFFF6D00);
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color teal = Color(0xFF00BFA5);
  static const Color tealLight = Color(0xFFE0F7FA);
  static const Color pink = Color(0xFFE91E63);

  // Status
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Neutrals
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;

  // Dark
  static const Color darkBg = Color(0xFF0A1929);
  static const Color darkSurface = Color(0xFF0F2744);
  static const Color darkCard = Color(0xFF132F4C);
  static const Color darkBorder = Color(0xFF1E4976);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6D00), Color(0xFFFFAB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme-aware helpers
  static Color bg(bool d) => d ? darkBg : primaryBg;
  static Color cardColor(bool d) => d ? darkCard : card;
  static Color surfaceColor(bool d) => d ? darkSurface : surface;
  static Color borderColor(bool d) => d ? darkBorder : border;
  static Color text(bool d) => d ? Colors.white : textPrimary;
  static Color textSub(bool d) => d ? const Color(0xFF90CAF9) : textSecondary;
  static Color textMutedColor(bool d) =>
      d ? const Color(0xFF64748B) : textMuted;
}
