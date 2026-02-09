import 'package:flutter/material.dart';

/// Upload Materials color constants matching instructor theme
class UploadMaterialsColors {
  UploadMaterialsColors._();

  // Primary colors - matching instructor theme
  static const Color primary = Color(0xFF155CFB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEEF5FF);

  // Upload colors (green theme for upload action)
  static const Color uploadGreen = Color(0xFF05DF72);
  static const Color uploadGreenDark = Color(0xFF00A63D);
  static const Color uploadGreenLight = Color(0xFF10B981);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
  static const Color pending = Color(0xFF6B7280);

  // File type colors
  static const Color document = Color(0xFF3B82F6);
  static const Color video = Color(0xFFEF4444);
  static const Color audio = Color(0xFF8B5CF6);
  static const Color image = Color(0xFF10B981);
  static const Color link = Color(0xFF0EA5E9);
  static const Color archive = Color(0xFFF59E0B);
  static const Color presentation = Color(0xFFEC4899);
  static const Color spreadsheet = Color(0xFF22C55E);

  // Neutrals
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
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
  static const LinearGradient uploadGradient = LinearGradient(
    colors: [uploadGreen, uploadGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Drop zone colors
  static Color dropZoneColor(bool isDark, bool isDragOver) {
    if (isDragOver) {
      return isDark
          ? uploadGreen.withValues(alpha: 0.2)
          : uploadGreen.withValues(alpha: 0.1);
    }
    return isDark ? darkSurface : surface;
  }

  static Color dropZoneBorder(bool isDark, bool isDragOver) {
    if (isDragOver) {
      return uploadGreen;
    }
    return isDark ? darkBorder : border;
  }

  // Theme-aware color getters
  static Color backgroundColor(bool isDark) => isDark ? darkBg : background;
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) =>
      isDark ? darkTextTertiary : textTertiary;

  // Progress bar colors
  static Color progressBackground(bool isDark) =>
      isDark ? darkSurface : const Color(0xFFE2E8F0);
  static Color progressForeground(UploadStatusType status) {
    switch (status) {
      case UploadStatusType.uploading:
        return primary;
      case UploadStatusType.processing:
        return warning;
      case UploadStatusType.completed:
        return success;
      case UploadStatusType.failed:
        return error;
      case UploadStatusType.pending:
        return pending;
    }
  }
}

enum UploadStatusType {
  pending,
  uploading,
  processing,
  completed,
  failed,
}
