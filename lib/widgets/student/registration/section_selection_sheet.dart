import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/registration/registration_available_course_model.dart';
import '../../../models/registration/registration_available_section_model.dart';

class SectionSelectionSheet extends StatelessWidget {
  const SectionSelectionSheet({
    super.key,
    required this.course,
    required this.selectedSectionId,
    required this.isSubmitting,
    required this.onSectionSelected,
    required this.onConfirm,
  });

  final RegistrationAvailableCourseModel course;
  final int? selectedSectionId;
  final bool isSubmitting;
  final ValueChanged<int> onSectionSelected;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool hasSelected = selectedSectionId != null;
    RegistrationAvailableSectionModel? selectedSection;
    if (hasSelected) {
      for (final section in course.sections) {
        if (section.id == selectedSectionId) {
          selectedSection = section;
          break;
        }
      }
    }
    final bool canConfirm =
        hasSelected &&
        selectedSection != null &&
        !selectedSection.isFull &&
        !isSubmitting;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.selectSection,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${course.code} • ${course.name}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: course.sections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final section = course.sections[index];
                  final bool isSelected = section.id == selectedSectionId;
                  return InkWell(
                    onTap: section.isFull
                        ? null
                        : () => onSectionSelected(section.id),
                    borderRadius: StudentCoursesTheme.controlRadius,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: StudentCoursesTheme.controlRadius,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF155DFC)
                              : const Color(0xFFD0D5DD),
                        ),
                        color: section.isFull
                            ? const Color(0xFFF2F4F7)
                            : (isSelected
                                  ? const Color(0xFFEFF4FF)
                                  : Colors.white),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? const Color(0xFF155DFC)
                                : const Color(0xFF667085),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Section ${section.sectionNumber}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${section.semesterName} • ${section.location ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${section.availableSeats}/${section.maxCapacity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: section.isFull
                                  ? const Color(0xFFB42318)
                                  : const Color(0xFF027A48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canConfirm ? onConfirm : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF155DFC),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: StudentCoursesTheme.controlRadius,
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.confirmEnrollment),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
