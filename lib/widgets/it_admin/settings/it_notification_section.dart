import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_settings_barrel.dart';

class ITNotificationSection extends StatelessWidget {
  final bool isDark;
  final List<NotificationSetting> settings;
  final Function(NotificationSetting, bool) onToggle;
  final Function(NotificationSetting) onConfigure;

  const ITNotificationSection({
    super.key,
    required this.isDark,
    required this.settings,
    required this.onToggle,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? ITColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? ITColors.darkBorder : const Color(0xFFFFE4C4),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...settings.map(
            (setting) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildNotificationItem(setting),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ITColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.notifications_rounded,
            color: ITColors.warning,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Notification Settings',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationSetting setting) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? ITColors.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getChannelColor(setting.channel).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              setting.icon,
              size: 18,
              color: _getChannelColor(setting.channel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        setting.title,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildChannelBadge(setting.channel),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  setting.description,
                  style: TextStyle(
                    color: ITColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: setting.isEnabled,
            onChanged: (value) => onToggle(setting, value),
            activeThumbColor: ITColors.success,
            activeTrackColor: ITColors.success.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelBadge(String channel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getChannelColor(channel).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        channel,
        style: TextStyle(
          color: _getChannelColor(channel),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getChannelColor(String channel) {
    switch (channel.toLowerCase()) {
      case 'email':
        return ITColors.info;
      case 'sms':
        return ITColors.success;
      case 'slack':
        return ITColors.purple;
      case 'webhook':
        return ITColors.orange;
      case 'push':
        return ITColors.warning;
      default:
        return ITColors.secondary;
    }
  }
}
