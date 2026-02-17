import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// AI User Alerts section
class AIUserAlerts extends StatelessWidget {
  final bool isDark;

  const AIUserAlerts({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.purpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.aiUserAlerts,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAlertItem(
            icon: Icons.warning_amber_rounded,
            iconColor: AdminColors.warning,
            title: l10n.studentsFailingCourses,
            actionLabel: l10n.review,
            onAction: () {},
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            icon: Icons.security_rounded,
            iconColor: AdminColors.error,
            title: l10n.accountsFlaggedFailedLogins,
            actionLabel: l10n.investigate,
            onAction: () {},
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            icon: Icons.access_time_rounded,
            iconColor: AdminColors.accent,
            title: l10n.studentsInactiveDays,
            actionLabel: l10n.sendReminder,
            onAction: () {},
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.reviewAllAlerts),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.getTextColor(isDark),
                side: BorderSide(
                  color:
                      isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
