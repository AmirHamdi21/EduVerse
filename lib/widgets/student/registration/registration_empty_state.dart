import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';

class RegistrationEmptyState extends StatelessWidget {
  const RegistrationEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: StudentCoursesTheme.cardBackground(isDark),
        borderRadius: StudentCoursesTheme.cardRadius,
        border: Border.all(color: StudentCoursesTheme.borderColor(isDark)),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 42, color: StudentCoursesTheme.mutedText(isDark)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StudentCoursesTheme.mutedText(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
