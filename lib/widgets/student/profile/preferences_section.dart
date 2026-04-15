import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../generated_l10n/app_localizations.dart';
import 'profile_section_card.dart';

class PreferencesSection extends StatelessWidget {
  final AppSettings settings;
  final bool isDark;

  const PreferencesSection({
    super.key,
    required this.settings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ProfileSectionCard(
      title: l10n.preferencesNotifications,
      icon: Icons.notifications_active_outlined,
      isDark: isDark,
      children: [
        _buildToggleRow(
          context,
          icon: Icons.notifications_outlined,
          title: l10n.pushNotifications,
          subtitle: l10n.pushNotificationsDesc,
          value: settings.pushNotifications,
          onChanged: (value) =>
              context.read<ProfileCubit>().togglePushNotifications(value),
        ),
        _buildDivider(),
        _buildToggleRow(
          context,
          icon: Icons.email_outlined,
          title: l10n.emailAlerts,
          subtitle: l10n.emailAlertsDesc,
          value: settings.emailAlerts,
          onChanged: (value) =>
              context.read<ProfileCubit>().toggleEmailAlerts(value),
        ),
        _buildDivider(),
        _buildToggleRow(
          context,
          icon: Icons.auto_awesome_outlined,
          title: l10n.aiSuggestions,
          subtitle: l10n.aiSuggestionsDesc,
          value: settings.aiSuggestions,
          onChanged: (value) =>
              context.read<ProfileCubit>().toggleAiSuggestions(value),
        ),
        _buildDivider(),
        _buildToggleRow(
          context,
          icon: Icons.dark_mode_outlined,
          title: l10n.autoDarkMode,
          subtitle: l10n.autoDarkModeDesc,
          value: settings.autoDarkMode,
          onChanged: (value) =>
              context.read<ProfileCubit>().toggleAutoDarkMode(value),
        ),
        _buildDivider(),
        _buildToggleRow(
          context,
          icon: Icons.bar_chart_rounded,
          title: l10n.weeklyPerformanceSummary,
          subtitle: l10n.weeklyPerformanceSummaryDesc,
          value: settings.weeklyPerformanceSummary,
          onChanged: (value) => context
              .read<ProfileCubit>()
              .toggleWeeklyPerformanceSummary(value),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1);
  }
}
