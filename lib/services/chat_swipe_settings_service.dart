import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat/chat_swipe_action_model.dart';

class ChatSwipeSettingsService {
  static const String _swipeSettingsKey = 'chat_swipe_settings';
  static ChatSwipeSettingsService? _instance;
  ChatSwipeSettings? _cachedSettings;

  ChatSwipeSettingsService._();

  static ChatSwipeSettingsService get instance {
    _instance ??= ChatSwipeSettingsService._();
    return _instance!;
  }

  Future<ChatSwipeSettings> getSwipeSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_swipeSettingsKey);

    if (settingsJson != null) {
      try {
        final map = json.decode(settingsJson) as Map<String, dynamic>;
        _cachedSettings = ChatSwipeSettings.fromMap(map);
        return _cachedSettings!;
      } catch (_) {
        _cachedSettings = const ChatSwipeSettings();
        return _cachedSettings!;
      }
    }

    _cachedSettings = const ChatSwipeSettings();
    return _cachedSettings!;
  }

  Future<void> saveSwipeSettings(ChatSwipeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toMap());
    await prefs.setString(_swipeSettingsKey, settingsJson);
    _cachedSettings = settings;
  }

  Future<void> setLeftAction(ChatSwipeAction action) async {
    final settings = await getSwipeSettings();
    await saveSwipeSettings(settings.copyWith(leftAction: action));
  }

  Future<void> setRightAction(ChatSwipeAction action) async {
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
