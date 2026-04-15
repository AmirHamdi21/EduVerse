import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class CourseAttendanceData {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String instructor;
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double attendanceRate;
  final String department;

  const CourseAttendanceData({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.instructor,
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.attendanceRate,
    required this.department,
  });
}

class AdminAttendanceCourseList extends StatelessWidget {
  final bool isDark;
  final List<CourseAttendanceData> courses;
  final Function(CourseAttendanceData) onCourseTap;
  final Function(CourseAttendanceData)? onExport;

  const AdminAttendanceCourseList({
    super.key,
    required this.isDark,
    required this.courses,
    required this.onCourseTap,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(context, courses[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: isDark
                ? AdminColors.darkTextTertiary
                : AdminColors.lightTextTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search criteria',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseAttendanceData course) {
    final rateColor = course.attendanceRate >= 0.9
        ? AdminColors.success
        : course.attendanceRate >= 0.75
        ? AdminColors.warning
        : AdminColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onCourseTap(course),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AdminColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
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
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AdminColors.darkText
                                  : AdminColors.lightText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  course.courseCode,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AdminColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  course.instructor,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AdminColors.darkTextSecondary
                                        : AdminColors.lightTextSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: rateColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(course.attendanceRate * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: rateColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildMiniStat(
                        Icons.groups_rounded,
                        course.totalStudents.toString(),
                        'Total',
                        AdminColors.primary,
                      ),
                      _buildDivider(),
                      _buildMiniStat(
                        Icons.check_circle_rounded,
                        course.presentToday.toString(),
                        'Present',
                        AdminColors.success,
                      ),
                      _buildDivider(),
                      _buildMiniStat(
                        Icons.cancel_rounded,
                        course.absentToday.toString(),
                        'Absent',
                        AdminColors.error,
                      ),
                      _buildDivider(),
                      _buildMiniStat(
                        Icons.schedule_rounded,
                        course.lateToday.toString(),
                        'Late',
                        AdminColors.warning,
                      ),
                    ],
                  ),
                ),
                if (onExport != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => onExport!(course),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Export'),
                        style: TextButton.styleFrom(
                          foregroundColor: AdminColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AdminColors.darkDivider : AdminColors.lightDivider,
    );
  }
}
