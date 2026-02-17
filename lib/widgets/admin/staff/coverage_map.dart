import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Coverage map widget showing course assignments
class CoverageMap extends StatelessWidget {
  final bool isDark;
  final List<CourseAssignment> courses;
  final Function(CourseAssignment, String) onAssignInstructor;
  final Function(CourseAssignment) onAssignTA;

  const CoverageMap({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.coverageMap,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (courses.isEmpty)
            _buildEmptyState(l10n)
          else
            ...courses.map((course) => _buildCourseRow(course, l10n)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
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

  Widget _buildCourseRow(CourseAssignment course, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: course.hasIssue
              ? AdminColors.warning.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  course.code,
                  style: TextStyle(
                    color: AdminColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course.name,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            course.studentCount > 0
                ? '${course.studentCount} ${l10n.students}'
                : l10n.noStudentsYet,
            style: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInstructorSection(course, l10n),
              ),
              const SizedBox(width: 12),
              _buildTASection(course, l10n),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorSection(CourseAssignment course, AppLocalizations l10n) {
    final hasInstructor = course.instructorName != null;

    return InkWell(
      onTap: () => onAssignInstructor(course, 'instructor'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasInstructor
              ? AdminColors.secondary.withValues(alpha: 0.1)
              : AdminColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasInstructor
                ? AdminColors.secondary.withValues(alpha: 0.3)
                : AdminColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: hasInstructor
                  ? AdminColors.secondary
                  : AdminColors.error.withValues(alpha: 0.2),
              child: hasInstructor
                  ? Text(
                      course.instructorInitials ?? 'NA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(
                      Icons.person_add_rounded,
                      size: 16,
                      color: AdminColors.error,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.instructor,
                    style: TextStyle(
                      color: AdminColors.getTextTertiaryColor(isDark),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    hasInstructor ? course.instructorName! : l10n.notAssigned,
                    style: TextStyle(
                      color: hasInstructor
                          ? AdminColors.getTextColor(isDark)
                          : AdminColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTASection(CourseAssignment course, AppLocalizations l10n) {
    return InkWell(
      onTap: () => onAssignTA(course),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: course.taCount > 0
              ? AdminColors.accent.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: course.taCount > 0
                ? AdminColors.accent.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              l10n.tas,
              style: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
                fontSize: 10,
              ),
            ),
            Text(
              course.taCount > 0 ? '${course.taCount}' : l10n.none,
              style: TextStyle(
                color: course.taCount > 0
                    ? AdminColors.accent
                    : AdminColors.getTextSecondaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseAssignment {
  final String id;
  final String code;
  final String name;
  final String? instructorName;
  final String? instructorInitials;
  final int taCount;
  final int studentCount;
  final bool hasIssue;
  final String? issueType;

  CourseAssignment({
    required this.id,
    required this.code,
    required this.name,
    this.instructorName,
    this.instructorInitials,
    this.taCount = 0,
    this.studentCount = 0,
    this.hasIssue = false,
    this.issueType,
  });
}
