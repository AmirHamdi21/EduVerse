import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/registration/registration_available_course_model.dart';

class AvailableCourseCard extends StatelessWidget {
  const AvailableCourseCard({
    super.key,
    required this.course,
    required this.isDark,
    required this.isSubmitting,
    required this.onEnrollPressed,
  });

  final RegistrationAvailableCourseModel course;
  final bool isDark;
  final bool isSubmitting;
  final VoidCallback onEnrollPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final section = course.primarySection;
    final bool canAttemptEnroll =
        course.canEnroll &&
        !course.isAlreadyEnrolled &&
        course.sections.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudentCoursesTheme.cardBackground(isDark),
        borderRadius: StudentCoursesTheme.cardRadius,
        border: Border.all(color: StudentCoursesTheme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.code,
                      style: const TextStyle(
                        color: Color(0xFF155DFC),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _safeDepartmentName(),
                      style: TextStyle(
                        color: StudentCoursesTheme.mutedText(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(context),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _detailChip('${course.credits} ${l10n.credits}'),
              _detailChip(course.level.isEmpty ? l10n.allLevels : course.level),
              _detailChip(
                section == null
                    ? l10n.selectSection
                    : 'Section ${section.sectionNumber}',
              ),
              _detailChip('${course.sections.length} sections'),
              if (section != null)
                _detailChip(
                  '${section.availableSeats}/${section.maxCapacity} seats',
                ),
              if (section?.semesterName.isNotEmpty == true)
                _detailChip(section!.semesterName),
              if (section?.location?.trim().isNotEmpty == true)
                _detailChip(section!.location!.trim()),
            ],
          ),
          const SizedBox(height: 14),
          if (course.description.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                course.description.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: StudentCoursesTheme.mutedText(isDark),
                  fontSize: 12,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionButton(context, canAttemptEnroll),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool canAttemptEnroll) {
    final l10n = AppLocalizations.of(context);

    if (course.isAlreadyEnrolled) {
      return _disabledAction(
        context,
        label: l10n.coursesRegistered,
        icon: Icons.check_circle_rounded,
      );
    }

    if (!course.canEnroll) {
      return _disabledAction(
        context,
        label: l10n.prerequisitesRequired,
        icon: Icons.lock_outline_rounded,
      );
    }

    if (!canAttemptEnroll) {
      return _disabledAction(
        context,
        label: l10n.selectSection,
        icon: Icons.info_outline_rounded,
      );
    }

    return FilledButton.icon(
      onPressed: isSubmitting ? null : onEnrollPressed,
      icon: isSubmitting
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.app_registration_rounded, size: 18),
      label: Text(isSubmitting ? l10n.enrollingCourse : l10n.enrollNow),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF155DFC),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: StudentCoursesTheme.controlRadius,
        ),
      ),
    );
  }

  Widget _disabledAction(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF4F4F5),
        borderRadius: StudentCoursesTheme.controlRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: StudentCoursesTheme.mutedText(isDark)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: StudentCoursesTheme.mutedText(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool enrolled = course.isAlreadyEnrolled;
    final Color textColor = enrolled
        ? const Color(0xFF047857)
        : const Color(0xFF475467);
    final Color bgColor = enrolled
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFE4E7EC);
    final String label = enrolled
        ? l10n.coursesRegistered
        : l10n.availableCourses;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _detailChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF344054),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _safeDepartmentName() {
    final String raw = course.departmentName.trim();
    if (raw.isEmpty) {
      return 'General';
    }
    return raw;
  }
}
