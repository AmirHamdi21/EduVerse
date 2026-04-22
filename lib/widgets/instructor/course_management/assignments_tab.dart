import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/instructor/assignments/instructor_assignments_screen.dart';

class AssignmentsTab extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final int? courseId;

  const AssignmentsTab({
    super.key,
    required this.isDark,
    required this.l10n,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return InstructorAssignmentsScreen(
      initialCourseId: courseId,
      lockCourseSelection: courseId != null,
      embedded: true,
    );
  }
}
