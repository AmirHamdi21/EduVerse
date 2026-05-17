import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/instructor/announcements/announcement_manager_screen.dart';

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({
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
    return AnnouncementManagerScreen(embedded: true, initialCourseId: courseId);
  }
}
