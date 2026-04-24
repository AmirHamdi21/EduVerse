import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../common/utils/student_registration_filters.dart';
import '../../../generated_l10n/app_localizations.dart';

class RegistrationStatsRow extends StatelessWidget {
  const RegistrationStatsRow({
    super.key,
    required this.stats,
    required this.isDark,
  });

  final StudentRegistrationStats stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            icon: Icons.school_rounded,
            label: l10n.creditsEnrolled,
            value: stats.enrolledCredits.toString(),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            label: l10n.coursesRegistered,
            value: stats.registeredCoursesCount.toString(),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.hourglass_bottom_rounded,
            label: l10n.onWaitlist,
            value: stats.waitlistCount.toString(),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StudentCoursesTheme.cardBackground(isDark),
        borderRadius: StudentCoursesTheme.controlRadius,
        border: Border.all(color: StudentCoursesTheme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: const Color(0xFF155DFC), size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: StudentCoursesTheme.mutedText(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
