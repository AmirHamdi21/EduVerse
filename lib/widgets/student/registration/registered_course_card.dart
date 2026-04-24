import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/enrollment_model.dart';

class RegisteredCourseCard extends StatelessWidget {
  const RegisteredCourseCard({
    super.key,
    required this.enrollment,
    required this.isDark,
    required this.isDropping,
    required this.onDropPressed,
  });

  final CourseEnrollmentModel enrollment;
  final bool isDark;
  final bool isDropping;
  final VoidCallback onDropPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudentCoursesTheme.cardBackground(isDark),
        borderRadius: StudentCoursesTheme.controlRadius,
        border: Border.all(color: StudentCoursesTheme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      enrollment.course?.courseCode ?? '',
                      style: const TextStyle(
                        color: Color(0xFF155DFC),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      enrollment.course?.courseName ?? '',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _metaChip('Section ${enrollment.section?.sectionNumber ?? '-'}'),
              _metaChip(enrollment.semester?.name ?? '-'),
              _metaChip('${enrollment.course?.credits ?? 0} ${l10n.credits}'),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: enrollment.canDrop
                ? OutlinedButton.icon(
                    onPressed: isDropping ? null : onDropPressed,
                    icon: isDropping
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.remove_circle_outline_rounded,
                            size: 16,
                          ),
                    label: Text(isDropping ? l10n.droppingCourse : l10n.drop),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      side: const BorderSide(color: Color(0xFFFECDCA)),
                    ),
                  )
                : Text(
                    l10n.registrationClosed,
                    style: TextStyle(
                      color: StudentCoursesTheme.mutedText(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        enrollment.status.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF047857),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _metaChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
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
}
