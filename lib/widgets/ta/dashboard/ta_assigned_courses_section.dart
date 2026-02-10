import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TAAssignedCoursesSection extends StatelessWidget {
  final bool isDark;
  final List<TACourseModel> courses;
  final Function(TACourseModel course)? onCourseTap;
  final Function(TACourseModel course)? onViewTasks;
  final VoidCallback? onViewAll;

  const TAAssignedCoursesSection({
    super.key,
    required this.isDark,
    required this.courses,
    this.onCourseTap,
    this.onViewTasks,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.taAssignedCourses,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final course = courses[index];
            return _buildCourseCard(course, l10n);
          },
        ),
      ],
    );
  }

  Widget _buildCourseCard(TACourseModel course, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCourseTap?.call(course),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [course.color, course.color.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        course.code.substring(0, 2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${course.code} — ${course.name}',
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course.instructorName,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.people_rounded,
                    label: '${course.studentsCount} ${l10n.students}',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    icon: Icons.schedule_rounded,
                    label: course.schedule,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: l10n.open,
                      icon: Icons.open_in_new_rounded,
                      isPrimary: false,
                      onTap: () => onCourseTap?.call(course),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: '${l10n.taTasks} ${course.pendingTasks > 0 ? "(${course.pendingTasks})" : ""}',
                      icon: Icons.task_alt_rounded,
                      isPrimary: true,
                      onTap: () => onViewTasks?.call(course),
                      badgeCount: course.pendingTasks,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: TAColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback? onTap,
    int badgeCount = 0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary
                ? TAColors.primary
                : (isDark
                    ? TAColors.darkSurface
                    : TAColors.surfaceColor(isDark)),
            borderRadius: BorderRadius.circular(10),
            border: isPrimary
                ? null
                : Border.all(
                    color: TAColors.borderColor(isDark),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary
                    ? Colors.white
                    : TAColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : TAColors.textPrimaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TACourseModel {
  final String id;
  final String code;
  final String name;
  final String instructorName;
  final int studentsCount;
  final String schedule;
  final int pendingTasks;
  final Color color;

  TACourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.instructorName,
    required this.studentsCount,
    required this.schedule,
    this.pendingTasks = 0,
    required this.color,
  });
}
