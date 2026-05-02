import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../screens/instructor/discussions/instructor_course_discussions_screen.dart';

class DiscussionsTab extends StatelessWidget {
  const DiscussionsTab({
    super.key,
    required this.isDark,
    required this.l10n,
    required this.courseId,
    this.initialCourse,
  });

  final bool isDark;
  final AppLocalizations l10n;
  final int? courseId;
  final TeachingCourseModel? initialCourse;

  @override
  Widget build(BuildContext context) {
    if (courseId == null || courseId! <= 0) {
      return const SizedBox.shrink();
    }

    return InstructorCourseDiscussionsScreen(
      courseId: courseId!,
      initialCourse: initialCourse,
      embedded: true,
    );
  }
}
