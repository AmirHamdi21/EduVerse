import 'package:flutter/material.dart';
import '../../../models/instructor/extended_course_model.dart';
import 'instructor_theme_colors.dart';
import 'custom_painters.dart';

/// Grid view card for displaying course information
class CourseGridCard extends StatelessWidget {
  final ExtendedCourse course;
  final bool isDark;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(String) onQuickAction;

  const CourseGridCard({
    super.key,
    required this.course,
    required this.isDark,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? InstructorColors.primary
                : (isDark
                    ? InstructorColors.darkBorder
                    : InstructorColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? InstructorColors.primary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: isSelected ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
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
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Color(course.course.colorValue)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.course.code,
                            style: TextStyle(
                              color: Color(course.course.colorValue),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildMiniStat(
                            Icons.people_rounded, '${course.course.totalStudents}'),
                        const SizedBox(width: 12),
                        _buildMiniStat(
                            Icons.trending_up_rounded, '${course.engagementScore}%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildProgressBar(),
                    const SizedBox(height: 10),
                    if (!isSelectionMode) _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(course.course.colorValue),
            Color(course.course.colorValue).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: PatternPainter(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                course.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          if (course.hasMilestone)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  course.milestoneText ?? '',
                  style: TextStyle(
                    color: Color(course.course.colorValue),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (isSelectionMode)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? InstructorColors.primary
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? InstructorColors.primary : Colors.white,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : null,
              ),
            ),
        ],
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

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark
              ? InstructorColors.darkTextSecondary
              : InstructorColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark
                ? InstructorColors.darkTextSecondary
                : InstructorColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completion',
              style: TextStyle(
                color: isDark ? Colors.white60 : InstructorColors.textMuted,
                fontSize: 10,
              ),
            ),
            Text(
              '${(course.completionRate * 100).toInt()}%',
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: course.completionRate,
            minHeight: 6,
            backgroundColor:
                isDark ? Colors.white.withValues(alpha: 0.1) : InstructorColors.border,
            valueColor:
                AlwaysStoppedAnimation(Color(course.course.colorValue)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionButton(Icons.edit_rounded, 'edit'),
        _buildQuickActionButton(Icons.analytics_rounded, 'analytics'),
        _buildQuickActionButton(Icons.copy_rounded, 'duplicate'),
        _buildQuickActionButton(Icons.share_rounded, 'share'),
      ],
    );
  }

  Widget _buildQuickActionButton(IconData icon, String action) {
    return GestureDetector(
      onTap: () => onQuickAction(action),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : InstructorColors.primaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white60 : InstructorColors.textSecondary,
        ),
      ),
    );
  }
}
