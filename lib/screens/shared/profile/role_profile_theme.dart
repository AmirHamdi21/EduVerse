import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

typedef RoleColorResolver = Color Function(bool isDark);

class RoleProfileTheme {
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final LinearGradient headerGradient;
  final LinearGradient darkHeaderGradient;
  final RoleColorResolver background;
  final RoleColorResolver card;
  final RoleColorResolver surface;
  final RoleColorResolver border;
  final RoleColorResolver textPrimary;
  final RoleColorResolver textSecondary;
  final RoleColorResolver textTertiary;

  RoleProfileTheme({
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.headerGradient,
    required this.darkHeaderGradient,
    required this.background,
    required this.card,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  factory RoleProfileTheme.student() {
    return RoleProfileTheme(
      primary: const Color(0xFF155DFC),
      primaryLight: const Color(0xFF2B7FFF),
      accent: const Color(0xFF00B8DB),
      success: const Color(0xFF10B981),
      warning: const Color(0xFFF59E0B),
      error: const Color(0xFFEF4444),
      headerGradient: const LinearGradient(
        colors: [Color(0xFF155DFC), Color(0xFF2B7FFF), Color(0xFF00B8DB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      darkHeaderGradient: const LinearGradient(
        colors: [Color(0xFF16213E), Color(0xFF1A1A2E), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      background: StudentCoursesTheme.scaffoldBackground,
      card: StudentCoursesTheme.cardBackground,
      surface: (isDark) =>
          isDark ? const Color(0xFF1E2A47) : const Color(0xFFF8FBFF),
      border: StudentCoursesTheme.borderColor,
      textPrimary: (isDark) => isDark ? Colors.white : const Color(0xFF1E293B),
      textSecondary: StudentCoursesTheme.mutedText,
      textTertiary: (isDark) =>
          isDark ? Colors.white38 : const Color(0xFF94A3B8),
    );
  }

  factory RoleProfileTheme.instructor() {
    return RoleProfileTheme(
      primary: InstructorColors.primary,
      primaryLight: InstructorColors.primaryLight,
      accent: InstructorColors.accent,
      success: InstructorColors.success,
      warning: InstructorColors.warning,
      error: InstructorColors.error,
      headerGradient: InstructorColors.headerGradient,
      darkHeaderGradient: InstructorColors.darkHeaderGradient,
      background: InstructorColors.background,
      card: InstructorColors.cardColor,
      surface: InstructorColors.surfaceColor,
      border: InstructorColors.borderColor,
      textPrimary: InstructorColors.textPrimaryColor,
      textSecondary: InstructorColors.textSecondaryColor,
      textTertiary: InstructorColors.textTertiaryColor,
    );
  }

  factory RoleProfileTheme.ta() {
    return RoleProfileTheme(
      primary: TAColors.primary,
      primaryLight: TAColors.primaryLight,
      accent: TAColors.accent,
      success: TAColors.success,
      warning: TAColors.warning,
      error: TAColors.error,
      headerGradient: TAColors.headerGradient,
      darkHeaderGradient: TAColors.darkHeaderGradient,
      background: TAColors.background,
      card: TAColors.cardColor,
      surface: TAColors.surfaceColor,
      border: TAColors.borderColor,
      textPrimary: TAColors.textPrimaryColor,
      textSecondary: TAColors.textSecondaryColor,
      textTertiary: TAColors.textTertiaryColor,
    );
  }

  factory RoleProfileTheme.admin() {
    return RoleProfileTheme(
      primary: AdminColors.primary,
      primaryLight: AdminColors.primaryLight,
      accent: AdminColors.accent,
      success: AdminColors.successLight,
      warning: AdminColors.warningLight,
      error: AdminColors.errorLight,
      headerGradient: const LinearGradient(
        colors: [
          AdminColors.primary,
          AdminColors.primaryLight,
          AdminColors.secondary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      darkHeaderGradient: const LinearGradient(
        colors: [Color(0xFF1A2847), Color(0xFF1A1A2E), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      background: AdminColors.getBackgroundColor,
      card: AdminColors.getCardColor,
      surface: AdminColors.getSurfaceColor,
      border: AdminColors.getCardBorderColor,
      textPrimary: AdminColors.getTextColor,
      textSecondary: AdminColors.getTextSecondaryColor,
      textTertiary: AdminColors.getTextTertiaryColor,
    );
  }
}
