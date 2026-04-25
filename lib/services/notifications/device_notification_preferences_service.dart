import 'package:shared_preferences/shared_preferences.dart';

import '../../models/notifications/device_notification_preferences.dart';

class DeviceNotificationPreferencesService {
  static const String _foregroundAlertsKey =
      'notification_foreground_alerts_enabled';
  static const String _soundEnabledKey = 'notification_sound_enabled';
  static const String _vibrationEnabledKey = 'notification_vibration_enabled';
  static const String _showPreviewKey = 'notification_show_preview';

  Future<DeviceNotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DeviceNotificationPreferences(
      foregroundAlertsEnabled:
          prefs.getBool(_foregroundAlertsKey) ?? true,
      soundEnabled: prefs.getBool(_soundEnabledKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationEnabledKey) ?? true,
      showPreview: prefs.getBool(_showPreviewKey) ?? true,
    );
  }

  Future<void> save(DeviceNotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _foregroundAlertsKey,
      preferences.foregroundAlertsEnabled,
    );
    await prefs.setBool(_soundEnabledKey, preferences.soundEnabled);
    await prefs.setBool(_vibrationEnabledKey, preferences.vibrationEnabled);
    await prefs.setBool(_showPreviewKey, preferences.showPreview);
  }
}
