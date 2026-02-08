import 'package:flutter/material.dart';
import '../../../models/instructor/extended_course_model.dart';
import 'instructor_theme_colors.dart';

/// Compact card for displaying course in minimal row format
class CourseCompactCard extends StatelessWidget {
  final ExtendedCourse course;
  final bool isDark;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CourseCompactCard({
    super.key,
    required this.course,
    required this.isDark,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? InstructorColors.primary
                : (isDark
                    ? InstructorColors.darkBorder
                    : InstructorColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isSelectionMode)
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? InstructorColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? InstructorColors.primary
                        : (isDark ? Colors.white24 : InstructorColors.border),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Color(course.course.colorValue),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.course.name,
                    style: TextStyle(
                      color:
                          isDark ? Colors.white : InstructorColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.course.code} • ${course.course.totalStudents} students',
                    style: TextStyle(
                      color: isDark
                          ? InstructorColors.darkTextSecondary
                          : InstructorColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    course.status,
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(course.completionRate * 100).toInt()}%',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : InstructorColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white24 : InstructorColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (course.status) {
      case 'published':
        return InstructorColors.success;
      case 'draft':
        return InstructorColors.warning;
      case 'archived':
        return InstructorColors.textMuted;
      default:
        return InstructorColors.primary;
    }
  }
}
