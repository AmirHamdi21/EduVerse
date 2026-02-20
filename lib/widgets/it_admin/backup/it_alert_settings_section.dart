import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITAlertSettingsSection extends StatelessWidget {
  final bool isDark;
  final AlertSettings settings;
  final Function(AlertSettings) onSettingsChanged;

  const ITAlertSettingsSection({
    super.key,
    required this.isDark,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Alert Settings',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Email Alerts
          _buildSettingRow(
            icon: Icons.email_outlined,
            title: 'Email Alerts',
            description: 'Receive backup alerts via email',
            value: settings.emailAlerts,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(emailAlerts: value));
            },
          ),
          const Divider(height: 24),
          // Slack Notifications
          _buildSettingRow(
            icon: Icons.tag_rounded,
            title: 'Slack Notifications',
            description: 'Send alerts to Slack channel',
            value: settings.slackNotifications,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(slackNotifications: value));
            },
          ),
          const Divider(height: 24),
          // Critical Only
          _buildSettingRow(
            icon: Icons.warning_amber_rounded,
            title: 'Critical Only',
            description: 'Only notify for critical failures',
            value: settings.criticalOnly,
            onChanged: (value) {
              onSettingsChanged(settings.copyWith(criticalOnly: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ITColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: ITColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: ITColors.textTertiaryColor(isDark),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: ITColors.primary,
          activeTrackColor: ITColors.primary.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
