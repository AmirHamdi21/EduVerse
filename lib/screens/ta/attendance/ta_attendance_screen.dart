import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/attendance/instructor_attendance_cubit.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../features/walkthrough/ta_walkthrough_registry.dart';
import '../../../features/walkthrough/walkthrough_target.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../services/api/attendance_service.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/shared/attendance/shared_attendance_manager_screen.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

const List<List<Color>> _kTaAttendanceGradients = <List<Color>>[
  <Color>[Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  <Color>[Color(0xFF3B82F6), Color(0xFF60A5FA)],
  <Color>[Color(0xFFEC4899), Color(0xFFF472B6)],
  <Color>[Color(0xFF06B6D4), Color(0xFF67E8F9)],
  <Color>[Color(0xFFF59E0B), Color(0xFFFBBF24)],
  <Color>[Color(0xFF10B981), Color(0xFF34D399)],
];

class TAAttendanceScreen extends StatelessWidget {
  const TAAttendanceScreen({
    super.key,
    this.embedded = false,
    this.initialSectionId,
  });

  final bool embedded;
  final int? initialSectionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstructorAttendanceCubit>(
      create: (context) => InstructorAttendanceCubit(
        attendanceService: context.read<AttendanceService>(),
        enrollmentService: context.read<EnrollmentService>(),
      )..loadTeachingSections(preferredSectionId: initialSectionId),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final l10n = AppLocalizations.of(context);
          return TAWalkthroughRouteMarker(
            segmentId: TAWalkthroughIds.attendance,
            child: SharedAttendanceManagerScreen(
              isDark: isDark,
              embedded: embedded,
              fallbackRoute: '/ta/dashboard',
              walkthroughTargets: const SharedAttendanceWalkthroughTargets(
                header: TAWalkthroughIds.attendanceHeader,
                controls: TAWalkthroughIds.attendanceControls,
                roster: TAWalkthroughIds.attendanceRoster,
              ),
              theme: SharedAttendanceTheme(
                title: l10n.attendanceManager,
                subtitle: l10n.trackStudentAttendance,
                heroIcon: Icons.fact_check_rounded,
                primary: TAColors.primary,
                primaryLight: TAColors.primaryLight,
                accent: TAColors.accent,
                success: TAColors.success,
                warning: TAColors.warning,
                error: TAColors.error,
                info: TAColors.info,
                headerGradient: TAColors.headerGradient,
                darkHeaderGradient: TAColors.darkHeaderGradient,
                sectionGradients: _kTaAttendanceGradients,
                background: TAColors.background,
                cardColor: TAColors.cardColor,
                surfaceColor: TAColors.surfaceColor,
                borderColor: TAColors.borderColor,
                textPrimary: TAColors.textPrimaryColor,
                textSecondary: TAColors.textSecondaryColor,
                textTertiary: TAColors.textTertiaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
