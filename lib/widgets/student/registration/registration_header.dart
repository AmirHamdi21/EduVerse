import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/admin/admin_periods_models.dart';

class RegistrationHeader extends StatelessWidget {
  const RegistrationHeader({
    super.key,
    required this.period,
    required this.isDark,
  });

  final EnrollmentPeriodModel? period;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String title = l10n.courseRegistration;
    final String subtitle = l10n.browseCourses;

    return Container(
      decoration: BoxDecoration(
        gradient: StudentCoursesTheme.primaryGradient,
        borderRadius: StudentCoursesTheme.cardRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF155DFC).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _periodStatusLabel(l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  period?.semester ?? l10n.registrationWindow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (period?.registrationStart != null ||
              period?.registrationEnd != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _registrationWindowLabel(l10n),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isDark ? 0.92 : 0.86),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _registrationWindowLabel(AppLocalizations l10n) {
    final DateTime? start = period?.registrationStart;
    final DateTime? end = period?.registrationEnd;
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    if (start != null && end != null) {
      return '${l10n.registrationWindow}: ${formatter.format(start)} - ${formatter.format(end)}';
    }
    if (start != null) {
      return '${l10n.registrationWindow}: ${formatter.format(start)}';
    }
    if (end != null) {
      return '${l10n.registrationWindow}: ${formatter.format(end)}';
    }
    return l10n.registrationWindow;
  }

  String _periodStatusLabel(AppLocalizations l10n) {
    final String status = period?.status.trim().toLowerCase() ?? '';
    if (status == 'active' || status == 'open') {
      return l10n.registrationOpen;
    }
    if (status == 'closed') {
      return l10n.registrationClosed;
    }
    return l10n.registrationUpcoming;
  }
}
