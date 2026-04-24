import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/roster/roster_cubit.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/shared/roster/shared_roster_screen.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class TARosterScreen extends StatelessWidget {
  const TARosterScreen({super.key});

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
              title: 'Student Roster',
              emptyCoursesTitle: 'No Courses Assigned',
              emptyCoursesSubtitle: 'You are not assigned to any sections yet.',
              headerTitle: 'TA Student Roster',
              headerSubtitle:
                  'Review your section students, grades, and course roster details',
              primary: TAColors.primary,
              accent: TAColors.accent,
              teal: TAColors.teal,
              orange: TAColors.orange,
              pink: TAColors.pink,
              headerGradient: isDark
                  ? TAColors.darkHeaderGradient
                  : TAColors.headerGradient,
              background: TAColors.background,
              cardColor: TAColors.cardColor,
              borderColor: TAColors.borderColor,
              textPrimary: TAColors.textPrimaryColor,
              textSecondary: TAColors.textSecondaryColor,
              textTertiary: TAColors.textTertiaryColor,
            ),
          );
        },
      ),
    );
  }
}
