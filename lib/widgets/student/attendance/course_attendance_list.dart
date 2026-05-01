import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/attendance/attendance_cubit.dart';
import '../../../bloc/attendance/attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/student/attendance/course_attendance_detail_screen.dart';

class CourseAttendanceList extends StatelessWidget {
  const CourseAttendanceList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<AttendanceCubit, AttendanceState>(
          buildWhen: (previous, current) =>
              previous.courseAttendances != current.courseAttendances ||
              previous.selectedCourseId != current.selectedCourseId,
          builder: (context, state) {
            if (state.courseAttendances.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppLocalizations.of(context).courseAttendance,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...state.courseAttendances.map(
                  (course) => _CourseAttendanceCard(
                    course: course,
                    isDark: isDark,
                    isSelected: state.selectedCourseId == course.courseId,
                    onTap: () {
                      // Navigate to course detail screen
                      final courseRecords = state.filteredRecords
                          .where((r) => r.courseId == course.courseId)
                          .toList();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CourseAttendanceDetailScreen(
                            course: course,
                            records: courseRecords,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CourseAttendanceCard extends StatelessWidget {
  final CourseAttendance course;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourseAttendanceCard({
    required this.course,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percentage = course.attendancePercentage;
    final accent = Color(course.gradientColors[0]);
    final accentSoft = Color(course.gradientColors[1]);
    final statusLabel = percentage >= 90
        ? l10n.excellent
        : percentage >= 80
        ? l10n.good
        : l10n.warning;
    final statusColor = percentage >= 90
        ? const Color(0xFF10B981)
        : percentage >= 80
        ? const Color(0xFF3B82F6)
        : const Color(0xFFF59E0B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [accent, accentSoft])
              : null,
          color: isSelected
              ? null
              : isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accent.withValues(alpha: 0.28)
                  : isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            if (!isSelected)
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accent, accentSoft]),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.14)
                              : accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: isSelected ? Colors.white : accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.courseName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.courseCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.3)
                                : statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.08)
                          : isDark
                          ? const Color(0xFF172033)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          l10n.totalClasses,
                          course.totalClasses.toString(),
                          isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          isSelected,
                        ),
                        _buildStatItem(
                          l10n.present,
                          course.presentCount.toString(),
                          const Color(0xFF10B981),
                          isSelected,
                        ),
                        _buildStatItem(
                          l10n.absent,
                          course.absentCount.toString(),
                          const Color(0xFFEF4444),
                          isSelected,
                        ),
                        _buildStatItem(
                          l10n.late,
                          course.lateCount.toString(),
                          const Color(0xFFF59E0B),
                          isSelected,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildProgressBar(percentage, isSelected),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.15)
                              : statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : statusColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.7)
                                : isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          Text(
                            l10n.details,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double percentage, bool isSelected) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: percentage / 100,
        backgroundColor: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0),
        valueColor: AlwaysStoppedAnimation(
          isSelected
              ? Colors.white
              : percentage >= 75
              ? const Color(0xFF10B981)
              : percentage >= 50
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444),
        ),
        minHeight: 8,
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    bool isSelected,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected
                ? Colors.white.withValues(alpha: 0.8)
                : isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
