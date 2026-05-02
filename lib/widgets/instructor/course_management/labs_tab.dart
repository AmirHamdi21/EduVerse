import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/instructor/labs/instructor_labs_screen.dart';

class LabsTab extends StatelessWidget {
  const LabsTab({
    super.key,
    required this.isDark,
    required this.l10n,
    required this.courseId,
  });

  final bool isDark;
  final AppLocalizations l10n;
  final int? courseId;

  @override
  Widget build(BuildContext context) {
    return InstructorLabsScreen(
      initialCourseId: courseId,
      embedded: true,
    );
  }
}
