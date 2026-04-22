import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

enum StudentAttendanceStatus { present, absent, late, excused, unmarked }

class StudentAttendanceInfo {
  final String id;
  final String studentId;
  final String name;
  final String course;
  final StudentAttendanceStatus status;
  final int totalClasses;
  final int attendedClasses;
  final double overallRate;
  final DateTime? lastAttended;

  const StudentAttendanceInfo({
    required this.id,
    required this.studentId,
    required this.name,
    required this.course,
    required this.status,
    required this.totalClasses,
    required this.attendedClasses,
    required this.overallRate,
    this.lastAttended,
  });
}

class AdminAttendanceStudentCard extends StatelessWidget {
  final bool isDark;
  final StudentAttendanceInfo student;
  final VoidCallback? onTap;
  final Function(StudentAttendanceStatus)? onStatusChange;

  const AdminAttendanceStudentCard({
    super.key,
    required this.isDark,
    required this.student,
    this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AdminColors.darkText
                              : AdminColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            student.studentId,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AdminColors.darkTextSecondary
                                  : AdminColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AdminColors.darkTextTertiary
                                  : AdminColors.lightTextTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              student.course,
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
                      const SizedBox(height: 8),
                      _buildMiniStat(
                        '${student.attendedClasses}/${student.totalClasses}',
                        'Classes',
                      ),
                      const SizedBox(height: 8),
                      _buildMiniStat(
                        '${(student.overallRate * 100).toStringAsFixed(0)}%',
                        'Rate',
                        color: _getRateColor(student.overallRate),
                      ),
                    ],
                  ),
                ),
                _buildStatusDropdown(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = student.name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color:
                color ??
                (isDark ? AdminColors.darkText : AdminColors.lightText),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AdminColors.darkTextTertiary
                : AdminColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return PopupMenuButton<StudentAttendanceStatus>(
      initialValue: student.status,
      onSelected: onStatusChange,
      enabled: onStatusChange != null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(student.status).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(student.status).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(student.status),
              size: 16,
              color: _getStatusColor(student.status),
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusLabel(student.status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(student.status),
              ),
            ),
            if (onStatusChange != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: _getStatusColor(student.status),
              ),
            ],
          ],
        ),
      ),
      itemBuilder: (context) => StudentAttendanceStatus.values.map((status) {
        return PopupMenuItem<StudentAttendanceStatus>(
          value: status,
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                size: 18,
                color: _getStatusColor(status),
              ),
              const SizedBox(width: 12),
              Text(
                _getStatusLabel(status),
                style: TextStyle(
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(StudentAttendanceStatus status) {
    switch (status) {
      case StudentAttendanceStatus.present:
        return AdminColors.success;
      case StudentAttendanceStatus.absent:
        return AdminColors.error;
      case StudentAttendanceStatus.late:
        return AdminColors.warning;
      case StudentAttendanceStatus.excused:
        return AdminColors.secondary;
      case StudentAttendanceStatus.unmarked:
        return isDark
            ? AdminColors.darkTextTertiary
            : AdminColors.lightTextTertiary;
    }
  }

  IconData _getStatusIcon(StudentAttendanceStatus status) {
    switch (status) {
      case StudentAttendanceStatus.present:
        return Icons.check_circle_rounded;
      case StudentAttendanceStatus.absent:
        return Icons.cancel_rounded;
      case StudentAttendanceStatus.late:
        return Icons.schedule_rounded;
      case StudentAttendanceStatus.excused:
        return Icons.assignment_late_rounded;
      case StudentAttendanceStatus.unmarked:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusLabel(StudentAttendanceStatus status) {
    switch (status) {
      case StudentAttendanceStatus.present:
        return 'Present';
      case StudentAttendanceStatus.absent:
        return 'Absent';
      case StudentAttendanceStatus.late:
        return 'Late';
      case StudentAttendanceStatus.excused:
        return 'Excused';
      case StudentAttendanceStatus.unmarked:
        return 'Unmarked';
    }
  }

  Color _getRateColor(double rate) {
    if (rate >= 0.9) return AdminColors.success;
    if (rate >= 0.75) return AdminColors.warning;
    return AdminColors.error;
  }
}
