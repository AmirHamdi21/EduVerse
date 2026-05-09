import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../domain/ai_assistant_models.dart';

class AiAssistantRoleTheme {
  const AiAssistantRoleTheme({
    required this.role,
    required this.primary,
    required this.secondary,
    required this.surfaceTint,
    required this.headerGradient,
    required this.softGradient,
  });

  final AiAssistantRole role;
  final Color primary;
  final Color secondary;
  final Color surfaceTint;
  final LinearGradient headerGradient;
  final LinearGradient softGradient;

  static AiAssistantRoleTheme fromRole(AiAssistantRole role) {
    switch (role) {
      case AiAssistantRole.student:
        return const AiAssistantRoleTheme(
          role: AiAssistantRole.student,
          primary: StudentCoursesTheme.brandBlue,
          secondary: StudentCoursesTheme.brandBlueLight,
          surfaceTint: StudentCoursesTheme.brandBluePale,
          headerGradient: LinearGradient(
            colors: <Color>[
              StudentCoursesTheme.brandBlue,
              StudentCoursesTheme.brandBlueLight,
              Color(0xFF00B8DB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          softGradient: LinearGradient(
            colors: <Color>[Color(0xFFEAF2FF), Colors.white, Color(0xFFF5FAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case AiAssistantRole.instructor:
        return const AiAssistantRoleTheme(
          role: AiAssistantRole.instructor,
          primary: InstructorColors.primary,
          secondary: InstructorColors.info,
          surfaceTint: InstructorColors.primarySurface,
          headerGradient: InstructorColors.headerGradient,
          softGradient: LinearGradient(
            colors: <Color>[Color(0xFFF1F6FF), Colors.white, Color(0xFFF3FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case AiAssistantRole.ta:
        return const AiAssistantRoleTheme(
          role: AiAssistantRole.ta,
          primary: TAColors.primary,
          secondary: TAColors.secondary,
          surfaceTint: TAColors.primarySurface,
          headerGradient: TAColors.headerGradient,
          softGradient: LinearGradient(
            colors: <Color>[Color(0xFFF8F5FF), Colors.white, Color(0xFFF3F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}
