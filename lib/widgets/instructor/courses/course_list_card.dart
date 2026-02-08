import 'package:flutter/material.dart';
import '../../../models/instructor/extended_course_model.dart';
import 'instructor_theme_colors.dart';
import 'custom_painters.dart';

/// List view card for displaying course information in full width
class CourseListCard extends StatelessWidget {
  final ExtendedCourse course;
  final bool isDark;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(String) onQuickAction;

  const CourseListCard({
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
                  ? InstructorColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (isSelectionMode)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? InstructorColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? InstructorColors.primary
                            : (isDark
                                ? Colors.white24
                                : InstructorColors.border),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(course.course.colorValue),
                        Color(course.course.colorValue).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      course.course.code.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.course.name,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : InstructorColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.status,
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course.course.code} • ${course.category}',
                        style: TextStyle(
                          color: isDark
                              ? InstructorColors.darkTextSecondary
                              : InstructorColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMiniStat(Icons.people_rounded,
                              '${course.course.totalStudents} students'),
                          const SizedBox(width: 16),
                          _buildMiniStat(Icons.trending_up_rounded,
                              '${course.engagementScore}% engagement'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isSelectionMode) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Completion Rate',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white60
                                    : InstructorColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${(course.completionRate * 100).toInt()}%',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : InstructorColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: course.completionRate,
                            minHeight: 8,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : InstructorColors.border,
                            valueColor: AlwaysStoppedAnimation(
                                Color(course.course.colorValue)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMiniTrendChart(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionButton(Icons.edit_rounded, 'Edit', 'edit'),
                  const SizedBox(width: 8),
                  _buildActionButton(
                      Icons.analytics_rounded, 'Analytics', 'analytics'),
                  const SizedBox(width: 8),
                  _buildActionButton(
                      Icons.copy_rounded, 'Duplicate', 'duplicate'),
                  const SizedBox(width: 8),
                  _buildActionButton(Icons.share_rounded, 'Share', 'share'),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: InstructorColors.error.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    onPressed: () => onQuickAction('delete'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
            if (course.hasMilestone) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      InstructorColors.warning.withValues(alpha: 0.1),
                      InstructorColors.accentOrange.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: InstructorColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      course.milestoneText ?? '',
                      style: const TextStyle(
                        color: InstructorColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildMiniStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: isDark
                ? InstructorColors.darkTextSecondary
                : InstructorColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isDark
                ? InstructorColors.darkTextSecondary
                : InstructorColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniTrendChart() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : InstructorColors.primaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: TrendChartPainter(
          data: course.enrollmentTrend,
          color: Color(course.course.colorValue),
        ),
        size: const Size(double.infinity, 32),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, String action) {
    return GestureDetector(
      onTap: () => onQuickAction(action),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : InstructorColors.primaryBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: InstructorColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    isDark ? Colors.white70 : InstructorColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
