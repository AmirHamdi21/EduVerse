import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

enum SharedNotificationRole { student, instructor, ta }

class SharedNotificationRoleTheme {
  const SharedNotificationRoleTheme({
    required this.role,
    required this.rolePrefix,
    required this.backFallbackRoute,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.headerGradient,
    required this.darkHeaderGradient,
  });

  final SharedNotificationRole role;
  final String rolePrefix;
  final String backFallbackRoute;
  final Color primary;
  final Color secondary;
  final Color accent;
  final LinearGradient headerGradient;
  final LinearGradient darkHeaderGradient;

  static SharedNotificationRoleTheme fromRole(SharedNotificationRole role) {
    switch (role) {
      case SharedNotificationRole.student:
        return const SharedNotificationRoleTheme(
          role: SharedNotificationRole.student,
          rolePrefix: '/student',
          backFallbackRoute: '/dashboard',
          primary: StudentCoursesTheme.brandBlue,
          secondary: StudentCoursesTheme.brandBlueLight,
          accent: Color(0xFF00B8DA),
          headerGradient: LinearGradient(
            colors: <Color>[
              StudentCoursesTheme.brandBlue,
              StudentCoursesTheme.brandBlueLight,
              Color(0xFF00B8DA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          darkHeaderGradient: StudentCoursesTheme.headerGradientDark,
        );
      case SharedNotificationRole.instructor:
        return const SharedNotificationRoleTheme(
          role: SharedNotificationRole.instructor,
          rolePrefix: '/instructor',
          backFallbackRoute: '/instructor/dashboard',
          primary: InstructorColors.primary,
          secondary: InstructorColors.info,
          accent: InstructorColors.accent,
          headerGradient: InstructorColors.headerGradient,
          darkHeaderGradient: InstructorColors.darkHeaderGradient,
        );
      case SharedNotificationRole.ta:
        return const SharedNotificationRoleTheme(
          role: SharedNotificationRole.ta,
          rolePrefix: '/ta',
          backFallbackRoute: '/ta/dashboard',
          primary: TAColors.primary,
          secondary: TAColors.secondary,
          accent: TAColors.teal,
          headerGradient: TAColors.headerGradient,
          darkHeaderGradient: TAColors.darkHeaderGradient,
        );
    }
  }

  Color scaffoldColor(bool isDark) {
    return isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  }

  Color cardColor(bool isDark) {
    return isDark ? const Color(0xFF1E293B) : Colors.white;
  }

  Color surfaceColor(bool isDark) {
    return isDark ? const Color(0xFF24324A) : const Color(0xFFF1F5F9);
  }

  Color borderColor(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);
  }

  Color textPrimary(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF0F172A);
  }

  Color textSecondary(bool isDark) {
    return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
  }

  Color textTertiary(bool isDark) {
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
  }

  Color mutedTint(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.07)
        : primary.withValues(alpha: 0.08);
  }
}
