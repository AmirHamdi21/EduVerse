import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/roster/roster_cubit.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/shared/roster/shared_roster_screen.dart';

class InstructorRosterScreen extends StatelessWidget {
  const InstructorRosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RosterCubit>(
      create: (_) =>
          RosterCubit(enrollmentService: context.read<EnrollmentService>())
            ..loadCourses(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          return SharedRosterScreen(
            isDark: isDark,
            theme: SharedRosterTheme(
              title: 'Roster',
              emptyCoursesTitle: 'No Courses Found',
              emptyCoursesSubtitle: 'You are not assigned to any courses yet.',
              headerTitle: 'Student Roster',
              headerSubtitle:
                  'Manage enrolled students, view grades, and track roster details',
              primary: InstructorColors.primary,
              accent: InstructorColors.accent,
              teal: InstructorColors.teal,
              orange: InstructorColors.orange,
              pink: InstructorColors.pink,
              headerGradient: isDark
                  ? InstructorColors.darkHeaderGradient
                  : InstructorColors.headerGradient,
              background: InstructorColors.background,
              cardColor: InstructorColors.cardColor,
              borderColor: InstructorColors.borderColor,
              textPrimary: InstructorColors.textPrimaryColor,
              textSecondary: InstructorColors.textSecondaryColor,
              textTertiary: InstructorColors.textTertiaryColor,
            ),
          );
        },
      ),
    );
  }
}
