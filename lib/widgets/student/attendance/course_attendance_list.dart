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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Color(course.gradientColors[0]),
                    Color(course.gradientColors[1]),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                  ? Color(course.gradientColors[0]).withValues(alpha: 0.3)
                  : isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.courseName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                _buildPercentageIndicator(percentage, isSelected),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(percentage, isSelected),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  l10n.present,
                  course.presentCount.toString(),
                  const Color(0xFF10B981),
                  isSelected,
                ),
                _buildStatItem(
                  l10n.late,
                  course.lateCount.toString(),
                  const Color(0xFFF59E0B),
                  isSelected,
                ),
                _buildStatItem(
                  l10n.absent,
                  course.absentCount.toString(),
                  const Color(0xFFEF4444),
                  isSelected,
                ),
                _buildStatItem(
                  l10n.excused,
                  course.excusedCount.toString(),
                  const Color(0xFF6366F1),
                  isSelected,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageIndicator(double percentage, bool isSelected) {
    final color = percentage >= 75
        ? const Color(0xFF10B981)
        : percentage >= 50
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.15),
      ),
      child: Center(
        child: Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
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
