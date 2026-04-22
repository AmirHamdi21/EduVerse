import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/instructor/grading_center/grading_center_screen.dart';

class GradingTab extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final int? courseId;

  const GradingTab({
    super.key,
    required this.isDark,
    required this.l10n,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return GradingCenterScreen(courseId: courseId, embedded: true);
  }
}
