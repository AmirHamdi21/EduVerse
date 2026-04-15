import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_profile_barrel.dart';

class ITProfileNotificationsTab extends StatefulWidget {
  final bool isDark;
  final NotificationPreferences preferences;
  final Function(NotificationPreferences) onSave;

  const ITProfileNotificationsTab({
    super.key,
    required this.isDark,
    required this.preferences,
    required this.onSave,
  });

  @override
  State<ITProfileNotificationsTab> createState() =>
      _ITProfileNotificationsTabState();
}

class _ITProfileNotificationsTabState extends State<ITProfileNotificationsTab> {
  late NotificationPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.preferences;
  }

  void _updatePrefs(NotificationPreferences newPrefs) {
    setState(() => _prefs = newPrefs);
  }

  void _savePreferences() {
    widget.onSave(_prefs);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification preferences saved'),
        backgroundColor: ITColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Alerts section
          Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                size: 18,
                color: ITColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'System Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(widget.isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildToggleTile(
            icon: Icons.warning_rounded,
            iconColor: ITColors.error,
            title: 'Security Alerts',
            subtitle: 'Get notified about security threats',
            value: _prefs.securityAlerts,
            onChanged: (val) =>
                _updatePrefs(_prefs.copyWith(securityAlerts: val)),
          ),
          _buildToggleTile(
            icon: Icons.power_off_rounded,
            iconColor: ITColors.warning,
            title: 'System Outage Updates',
            subtitle: 'Receive outage and recovery alerts',
            value: _prefs.systemOutageUpdates,
            onChanged: (val) =>
                _updatePrefs(_prefs.copyWith(systemOutageUpdates: val)),
          ),
          _buildToggleTile(
            icon: Icons.integration_instructions_rounded,
            iconColor: ITColors.info,
            title: 'Integration Warnings',
            subtitle: 'API and integration status changes',
            value: _prefs.integrationWarnings,
            onChanged: (val) =>
                _updatePrefs(_prefs.copyWith(integrationWarnings: val)),
          ),
          _buildToggleTile(
            icon: Icons.smart_toy_rounded,
            iconColor: ITColors.purple,
            title: 'AI Anomaly Notifications',
            subtitle: 'AI-detected unusual patterns',
            value: _prefs.aiAnomalyNotifications,
            onChanged: (val) =>
                _updatePrefs(_prefs.copyWith(aiAnomalyNotifications: val)),
          ),

          const SizedBox(height: 24),

          // Delivery Methods section
          Row(
            children: [
              Icon(Icons.send_rounded, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                'Delivery Methods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(widget.isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildDeliveryMethodTile(
            icon: Icons.email_rounded,
            title: 'Email',
            subtitle: 'Receive alerts via email',
            value: _prefs.emailDelivery,
            onChanged: (val) =>
                _updatePrefs(_prefs.copyWith(emailDelivery: val)),
          ),
          _buildDeliveryMethodTile(
            icon: Icons.sms_rounded,
            title: 'SMS',
            subtitle: 'Get text messages for critical alerts',
            value: _prefs.smsDelivery,
            onChanged: (val) => _updatePrefs(_prefs.copyWith(smsDelivery: val)),
          ),
          _buildDeliveryMethodTile(
            icon: Icons.phone_iphone_rounded,
            title: 'In-App',
            subtitle: 'Push notifications in the app',
            value: _prefs.inAppDelivery,
            onChanged: (val) =>
                _updatePrefs(_prefs.copyWith(inAppDelivery: val)),
          ),
          _buildDeliveryMethodTile(
            icon: Icons.tag_rounded,
            title: 'Slack',
            subtitle: 'Send alerts to Slack channel',
            value: _prefs.slackDelivery,
            onChanged: (val) =>
                _updatePrefs(_prefs.copyWith(slackDelivery: val)),
            badge: 'Connected',
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savePreferences,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Preferences'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ITColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
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
                    color: ITColors.textPrimaryColor(widget.isDark),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: ITColors.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ITColors.success.withValues(alpha: 0.5),
            activeThumbColor: ITColors.success,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              return Colors.transparent;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ITColors.textPrimaryColor(widget.isDark),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ITColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ITColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: ITColors.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ITColors.success.withValues(alpha: 0.5),
            activeThumbColor: ITColors.success,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              return Colors.transparent;
            }),
          ),
        ],
      ),
    );
  }
}
