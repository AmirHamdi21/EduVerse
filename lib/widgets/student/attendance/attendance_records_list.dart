import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/attendance/attendance_cubit.dart';
import '../../../bloc/attendance/attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/student/attendance/course_attendance_detail_screen.dart';

/// Records tab — shows course-level attendance cards (not individual sessions).
/// Each card shows: course name, code, stats grid, progress bar, status badge.
/// Tapping a card → opens the CourseAttendanceDetailScreen with day-by-day records.
class AttendanceRecordsList extends StatelessWidget {
  const AttendanceRecordsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<AttendanceCubit, AttendanceState>(
          buildWhen: (previous, current) =>
              previous.courseAttendances != current.courseAttendances ||
              previous.filteredRecords != current.filteredRecords,
          builder: (context, state) {
            if (state.courseAttendances.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    AppLocalizations.of(context).courseAttendance,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Detailed attendance breakdown by course',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...state.courseAttendances.map(
                  (course) => _CourseRecordCard(
                    course: course,
                    isDark: isDark,
                    onTap: () {
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

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRecordsFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noRecordsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  Course Card — matches the web's "Lecture Attendance" card design
// ════════════════════════════════════════════════════════════════════════

class _CourseRecordCard extends StatelessWidget {
  final CourseAttendance course;
  final bool isDark;
  final VoidCallback onTap;

  const _CourseRecordCard({
    required this.course,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percentage = course.attendancePercentage;
    final statusLabel = percentage >= 90
        ? 'Excellent'
        : percentage >= 80
            ? 'Good'
            : 'Warning';
    final statusColor = percentage >= 90
        ? const Color(0xFF10B981)
        : percentage >= 80
            ? const Color(0xFF3B82F6)
            : const Color(0xFFF59E0B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Colored top bar
            Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(course.gradientColors[0]),
                    Color(course.gradientColors[1]),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: name + code + badge
                  Row(
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
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              course.courseCode,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Percentage badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4-column stats grid
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                        bottom: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(
                          l10n.totalClasses,
                          course.totalClasses.toString(),
                          isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        _stat(
                          l10n.present,
                          course.presentCount.toString(),
                          const Color(0xFF10B981),
                        ),
                        _stat(
                          l10n.absent,
                          course.absentCount.toString(),
                          const Color(0xFFEF4444),
                        ),
                        _stat(
                          l10n.late,
                          course.lateCount.toString(),
                          const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation(
                        percentage >= 75
                            ? const Color(0xFF10B981)
                            : percentage >= 50
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Footer: status label + details arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'View Records',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
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

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
