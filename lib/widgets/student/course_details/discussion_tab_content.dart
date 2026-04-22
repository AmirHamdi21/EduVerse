import 'package:flutter/material.dart';

import '../../../screens/shared/discussion_screen.dart';

class DiscussionTabContent extends StatelessWidget {
  final bool isDark;
  final int? courseId;

  const DiscussionTabContent({
    super.key,
    required this.isDark,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    if (courseId == null || courseId! <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE4E7EC),
          ),
        ),
        child: Text(
          'Discussion is unavailable because the active course ID is missing.',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF667085),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SizedBox(
      height: 680,
      child: DiscussionScreen(
        courseId: courseId,
        accentColor: const Color(0xFF3B82F6),
        title: 'Course Discussions',
        embedMode: true,
      ),
    );
  }
}
