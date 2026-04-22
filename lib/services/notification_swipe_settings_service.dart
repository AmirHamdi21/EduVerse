import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notifications/swipe_action_model.dart';

class NotificationSwipeSettingsService {
  static const String _swipeSettingsKey = 'notification_swipe_settings';
  static NotificationSwipeSettingsService? _instance;
  NotificationSwipeSettings? _cachedSettings;

  NotificationSwipeSettingsService._();

  static NotificationSwipeSettingsService get instance {
    _instance ??= NotificationSwipeSettingsService._();
    return _instance!;
  }

  Future<NotificationSwipeSettings> getSwipeSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_swipeSettingsKey);

    if (settingsJson != null) {
      try {
        final map = json.decode(settingsJson) as Map<String, dynamic>;
        _cachedSettings = NotificationSwipeSettings.fromMap(map);
        return _cachedSettings!;
      } catch (_) {
        _cachedSettings = const NotificationSwipeSettings();
        return _cachedSettings!;
      }
    }

    _cachedSettings = const NotificationSwipeSettings();
    return _cachedSettings!;
  }

  Future<void> saveSwipeSettings(NotificationSwipeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toMap());
    await prefs.setString(_swipeSettingsKey, settingsJson);
    _cachedSettings = settings;
  }

  Future<void> setLeftAction(SwipeAction action) async {
    final settings = await getSwipeSettings();
    await saveSwipeSettings(settings.copyWith(leftAction: action));
  }

  Future<void> setRightAction(SwipeAction action) async {
    final settings = await getSwipeSettings();
    await saveSwipeSettings(settings.copyWith(rightAction: action));
  }

  Future<void> setConfirmBeforeAction(bool confirm) async {
    final settings = await getSwipeSettings();
    await saveSwipeSettings(settings.copyWith(confirmBeforeAction: confirm));
  }

  Future<void> setSwipeSensitivity(double sensitivity) async {
    final settings = await getSwipeSettings();
    await saveSwipeSettings(settings.copyWith(swipeSensitivity: sensitivity));
  }

  void clearCache() {
    _cachedSettings = null;
  }
}
