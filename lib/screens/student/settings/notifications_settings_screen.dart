import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../common/service_error.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/device_notification_preferences.dart';
import '../../../models/notifications/notification_preference_model.dart';
import '../../../services/api/notification_api_service.dart';
import '../../../services/notifications/device_notification_preferences_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  final DeviceNotificationPreferencesService _devicePreferencesService =
      DeviceNotificationPreferencesService();

  NotificationPreferenceModel _serverPreferences =
      const NotificationPreferenceModel();
  DeviceNotificationPreferences _devicePreferences =
      const DeviceNotificationPreferences();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final api = context.read<NotificationApiService>();

    try {
      final preferenceResult = await api.getPreferences();
      final devicePreferences = await _devicePreferencesService.load();

      if (!mounted) return;
      setState(() {
        if (preferenceResult.isSuccess && preferenceResult.data != null) {
          _serverPreferences = preferenceResult.data!;
        }
        _devicePreferences = devicePreferences;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final api = context.read<NotificationApiService>();
    final ServiceResult<NotificationPreferenceModel> saveResult = await api
        .updatePreferences(_serverPreferences);
    await _devicePreferencesService.save(_devicePreferences);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saveResult.isSuccess
              ? 'Notification settings saved'
              : 'Saved local settings, but server preferences failed to update',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => safeBack(context, '/dashboard'),
          icon: Icon(
            iosBackIcon(context),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.pushNotifications,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading || _isSaving ? null : _saveSettings,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader('Account Notification Preferences', isDark),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  isDark,
                  children: [
                    _buildToggleItem(
                      isDark,
                      title: 'Email Notifications',
                      subtitle:
                          'Allow email delivery for supported notification types',
                      value: _serverPreferences.emailEnabled,
                      onChanged: (value) => setState(
                        () => _serverPreferences = _serverPreferences.copyWith(
                          emailEnabled: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Push Preference',
                      subtitle:
                          'Store your push delivery preference on the server',
                      value: _serverPreferences.pushEnabled,
                      onChanged: (value) => setState(
                        () => _serverPreferences = _serverPreferences.copyWith(
                          pushEnabled: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'SMS Notifications',
                      subtitle: 'Allow SMS notifications when supported',
                      value: _serverPreferences.smsEnabled,
                      onChanged: (value) => setState(
                        () => _serverPreferences = _serverPreferences.copyWith(
                          smsEnabled: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Announcement Emails',
                      subtitle: 'Receive announcement notifications by email',
                      value: _serverPreferences.announcementEmail,
                      onChanged: (value) => setState(
                        () => _serverPreferences = _serverPreferences.copyWith(
                          announcementEmail: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Grade Emails',
                      subtitle: 'Receive grade and grading-related emails',
                      value: _serverPreferences.gradeEmail,
                      onChanged: (value) => setState(
                        () => _serverPreferences = _serverPreferences.copyWith(
                          gradeEmail: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Assignment Emails',
                      subtitle: 'Receive assignment and deadline emails',
                      value: _serverPreferences.assignmentEmail,
                      onChanged: (value) => setState(
                        () => _serverPreferences = _serverPreferences.copyWith(
                          assignmentEmail: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Message Emails',
                      subtitle: 'Receive message and discussion emails',
                      value: _serverPreferences.messageEmail,
                      onChanged: (value) => setState(
                        () => _serverPreferences = _serverPreferences.copyWith(
                          messageEmail: value,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Reminders & Quiet Hours', isDark),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  isDark,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deadline reminder days',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue:
                                _serverPreferences.deadlineReminderDays,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: const [0, 1, 2, 3, 5, 7]
                                .map(
                                  (days) => DropdownMenuItem<int>(
                                    value: days,
                                    child: Text('$days day(s)'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(
                                () => _serverPreferences = _serverPreferences
                                    .copyWith(deadlineReminderDays: value),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeField(
                                  isDark,
                                  title: 'Quiet hours start',
                                  value: _serverPreferences.quietHoursStart,
                                  onChanged: (value) => setState(
                                    () =>
                                        _serverPreferences = _serverPreferences
                                            .copyWith(quietHoursStart: value),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeField(
                                  isDark,
                                  title: 'Quiet hours end',
                                  value: _serverPreferences.quietHoursEnd,
                                  onChanged: (value) => setState(
                                    () =>
                                        _serverPreferences = _serverPreferences
                                            .copyWith(quietHoursEnd: value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('In-App Device Preferences', isDark),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  isDark,
                  children: [
                    _buildToggleItem(
                      isDark,
                      title: 'Foreground alerts',
                      subtitle:
                          'Show an in-app alert when new notifications arrive',
                      value: _devicePreferences.foregroundAlertsEnabled,
                      onChanged: (value) => setState(
                        () => _devicePreferences = _devicePreferences.copyWith(
                          foregroundAlertsEnabled: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Notification sound',
                      subtitle: 'Play an in-app sound when alerts arrive',
                      value: _devicePreferences.soundEnabled,
                      onChanged: (value) => setState(
                        () => _devicePreferences = _devicePreferences.copyWith(
                          soundEnabled: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Vibration / haptic feedback',
                      subtitle:
                          'Use haptic feedback for incoming in-app alerts',
                      value: _devicePreferences.vibrationEnabled,
                      onChanged: (value) => setState(
                        () => _devicePreferences = _devicePreferences.copyWith(
                          vibrationEnabled: value,
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildToggleItem(
                      isDark,
                      title: 'Show preview',
                      subtitle: 'Show notification body in foreground alerts',
                      value: _devicePreferences.showPreview,
                      onChanged: (value) => setState(
                        () => _devicePreferences = _devicePreferences.copyWith(
                          showPreview: value,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildTimeField(
    bool isDark, {
    required String title,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          decoration: const InputDecoration(
            hintText: 'HH:mm:ss',
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black54,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem(
    bool isDark, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
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
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            },
            activeThumbColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? Colors.white12 : Colors.black12,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
