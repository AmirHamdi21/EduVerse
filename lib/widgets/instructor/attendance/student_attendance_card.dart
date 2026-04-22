import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/instructor/attendance_model.dart';
import 'attendance_colors.dart';

class StudentAttendanceCard extends StatelessWidget {
  final StudentAttendance student;
  final bool isDark;
  final Function(AttendanceStatus) onStatusChanged;
  final VoidCallback onTap;
  final VoidCallback? onNoteTap;

  const StudentAttendanceCard({
    super.key,
    required this.student,
    required this.isDark,
    required this.onStatusChanged,
    required this.onTap,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AttendanceColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AttendanceColors.darkBorder.withValues(alpha: 0.3)
              : AttendanceColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : AttendanceColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.studentName,
                            style: TextStyle(
                              color: AttendanceColors.textPrimaryColor(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student.studentId,
                            style: TextStyle(
                              color: AttendanceColors.textTertiaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                          if (student.note != null &&
                              student.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.sticky_note_2_outlined,
                                  size: 12,
                                  color: AttendanceColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    student.note!,
                                    style: TextStyle(
                                      color: AttendanceColors.accent,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildAttendanceProgress(),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatusSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = student.studentName
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join();
    final colors = [
      AttendanceColors.primary,
      AttendanceColors.present,
      AttendanceColors.accent,
      AttendanceColors.late,
      AttendanceColors.teal,
    ];
    final color = colors[student.studentName.hashCode % colors.length];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceProgress() {
    final rate = student.overallAttendanceRate;
    final color = AttendanceColors.getProgressColor(rate);

    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: rate,
                strokeWidth: 4,
                backgroundColor: isDark
                    ? AttendanceColors.darkSurface
                    : AttendanceColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '${(rate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AttendanceColors.textPrimaryColor(isDark),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: [
        _buildStatusButton(
          AttendanceStatus.present,
          Icons.check_rounded,
          'Present',
          AttendanceColors.present,
        ),
        const SizedBox(width: 8),
        _buildStatusButton(
          AttendanceStatus.late,
          Icons.schedule_rounded,
          'Late',
          AttendanceColors.late,
        ),
        const SizedBox(width: 8),
        _buildStatusButton(
          AttendanceStatus.absent,
          Icons.close_rounded,
          'Absent',
          AttendanceColors.absent,
        ),
        const Spacer(),
        IconButton(
          onPressed: onNoteTap,
          icon: Icon(
            Icons.edit_note_rounded,
            color: student.note != null && student.note!.isNotEmpty
                ? AttendanceColors.accent
                : AttendanceColors.textTertiaryColor(isDark),
            size: 22,
          ),
          tooltip: 'Add Note',
          style: IconButton.styleFrom(
            backgroundColor: isDark
                ? AttendanceColors.darkSurface
                : AttendanceColors.surface,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    AttendanceStatus status,
    IconData icon,
    String label,
    Color color,
  ) {
    final isSelected = student.status == status;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onStatusChanged(status);
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : (isDark
                        ? AttendanceColors.darkSurface
                        : AttendanceColors.surface),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark
                          ? AttendanceColors.darkBorder.withValues(alpha: 0.5)
                          : AttendanceColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? Colors.white
                      : AttendanceColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AttendanceColors.textSecondaryColor(isDark),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
