import 'package:flutter/material.dart';

/// Instructor theme colors - Modern colorful palette based on deep blue
class InstructorColors {
  // Primary Blue Spectrum
  static const Color primary = Color(0xFF0D47A1);           // Deep Blue
  static const Color primaryMedium = Color(0xFF1565C0);     // Medium Blue
  static const Color primaryLight = Color(0xFF42A5F5);      // Light Blue
  static const Color primaryLighter = Color(0xFF90CAF9);    // Lighter Blue
  static const Color primaryBackground = Color(0xFFF0F7FF); // Very Light Blue tint

  // Secondary Accent Colors
  static const Color accentOrange = Color(0xFFFF6D00);      // Vibrant Orange
  static const Color accentPurple = Color(0xFF7C4DFF);      // Vibrant Purple
  static const Color accentTeal = Color(0xFF00BFA5);        // Vibrant Teal
  static const Color accentPink = Color(0xFFE91E63);        // Modern Pink
  static const Color accentIndigo = Color(0xFF536DFE);      // Indigo accent

  // Status Colors
  static const Color success = Color(0xFF00C853);           // Vibrant Green
  static const Color successLight = Color(0xFFB9F6CA);      // Light Green
  static const Color warning = Color(0xFFFFAB00);           // Amber
  static const Color warningLight = Color(0xFFFFE57F);      // Light Amber
  static const Color error = Color(0xFFFF1744);             // Modern Red
  static const Color errorLight = Color(0xFFFF8A80);        // Light Red

  // Neutral Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0A1929);
  static const Color darkSurface = Color(0xFF0F2744);
  static const Color darkCard = Color(0xFF132F4C);
  static const Color darkBorder = Color(0xFF1E4976);
  static const Color darkTextPrimary = Color(0xFFE3F2FD);
  static const Color darkTextSecondary = Color(0xFF90CAF9);

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

  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Course card color options
  static const List<Color> courseColors = [
    Color(0xFF0D47A1),  // Deep Blue
    Color(0xFF7C4DFF),  // Purple
    Color(0xFFFF6D00),  // Orange
    Color(0xFF00BFA5),  // Teal
    Color(0xFFE91E63),  // Pink
    Color(0xFF00C853),  // Green
    Color(0xFF536DFE),  // Indigo
    Color(0xFFFFAB00),  // Amber
  ];
}
