import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/attendance/instructor_attendance_cubit.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../features/walkthrough/instructor_walkthrough_registry.dart';
import '../../../features/walkthrough/walkthrough_target.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../services/api/attendance_service.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/shared/attendance/shared_attendance_manager_screen.dart';

const List<List<Color>> _kInstructorAttendanceGradients = <List<Color>>[
  <Color>[Color(0xFF3B82F6), Color(0xFF06B6D4)],
  <Color>[Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  <Color>[Color(0xFFF59E0B), Color(0xFFFBBF24)],
  <Color>[Color(0xFF10B981), Color(0xFF34D399)],
  <Color>[Color(0xFFEF4444), Color(0xFFF87171)],
  <Color>[Color(0xFFEC4899), Color(0xFFF472B6)],
];

class AttendanceManagerScreen extends StatelessWidget {
  const AttendanceManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstructorAttendanceCubit>(
      create: (context) => InstructorAttendanceCubit(
        attendanceService: context.read<AttendanceService>(),
        enrollmentService: context.read<EnrollmentService>(),
      )..loadTeachingSections(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final l10n = AppLocalizations.of(context);
          return InstructorWalkthroughRouteMarker(
            segmentId: InstructorWalkthroughIds.attendance,
            child: SharedAttendanceManagerScreen(
              isDark: isDark,
              fallbackRoute: '/instructor/dashboard',
              walkthroughTargets: const SharedAttendanceWalkthroughTargets(
                header: InstructorWalkthroughIds.attendanceHeader,
                controls: InstructorWalkthroughIds.attendanceControls,
                roster: InstructorWalkthroughIds.attendanceRoster,
              ),
              theme: SharedAttendanceTheme(
                title: l10n.attendanceManager,
                subtitle: l10n.trackStudentAttendance,
                heroIcon: Icons.how_to_reg_rounded,
                primary: InstructorColors.primary,
                primaryLight: InstructorColors.primaryLight,
                accent: InstructorColors.accent,
                success: InstructorColors.success,
                warning: InstructorColors.warning,
                error: InstructorColors.error,
                info: InstructorColors.info,
                headerGradient: InstructorColors.headerGradient,
                darkHeaderGradient: InstructorColors.darkHeaderGradient,
                sectionGradients: _kInstructorAttendanceGradients,
                background: InstructorColors.background,
                cardColor: InstructorColors.cardColor,
                surfaceColor: InstructorColors.surfaceColor,
                borderColor: InstructorColors.borderColor,
                textPrimary: InstructorColors.textPrimaryColor,
                textSecondary: InstructorColors.textSecondaryColor,
                textTertiary: InstructorColors.textTertiaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
