import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';
import 'coverage_map.dart';

/// List view widget for course staff assignments
class StaffListView extends StatelessWidget {
  final bool isDark;
  final List<CourseAssignment> courses;
  final Function(CourseAssignment, String) onAssignInstructor;
  final Function(CourseAssignment) onAssignTA;

  const StaffListView({
    super.key,
    required this.isDark,
    required this.courses,
    required this.onAssignInstructor,
    required this.onAssignTA,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        children: [
          _buildHeader(l10n),
          if (courses.isEmpty)
            _buildEmptyState(l10n)
          else
            ...courses.asMap().entries.map((entry) {
              final index = entry.key;
              final course = entry.value;
              return _buildRow(
                course,
                l10n,
                isLast: index == courses.length - 1,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              l10n.course,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              l10n.instructor,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.tas,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    CourseAssignment course,
    AppLocalizations l10n, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark
                      ? AdminColors.darkCardBorder.withValues(alpha: 0.5)
                      : Colors.grey[200]!,
                ),
              ),
      ),
      child: Row(
        children: [
          // Course column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.code} • ${course.studentCount} ${l10n.students}',
                  style: TextStyle(
                    color: AdminColors.getTextTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Instructor column
          Expanded(flex: 3, child: _buildInstructorCell(course, l10n)),
          // TAs column
          Expanded(flex: 2, child: _buildTACell(course, l10n)),
        ],
      ),
    );
  }

  Widget _buildInstructorCell(CourseAssignment course, AppLocalizations l10n) {
    final hasInstructor = course.instructorName != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAssignInstructor(course, 'instructor'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              if (hasInstructor) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AdminColors.secondary.withValues(alpha: 0.2),
                  child: Text(
                    course.instructorInitials ?? 'NA',
                    style: TextStyle(
                      color: AdminColors.secondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    course.instructorName!,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AdminColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        size: 14,
                        color: AdminColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.notAssigned,
                        style: TextStyle(
                          color: AdminColors.error,
                          fontSize: 11,
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
      ),
    );
  }

  Widget _buildTACell(CourseAssignment course, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAssignTA(course),
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: course.taCount > 0
                  ? AdminColors.accent.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              course.taCount > 0 ? '${course.taCount} TAs' : l10n.noTAs,
              style: TextStyle(
                color: course.taCount > 0
                    ? AdminColors.accent
                    : AdminColors.getTextSecondaryColor(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AdminColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.allCoursesAssigned,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
