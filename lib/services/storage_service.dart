import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_models.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _darkModeKey = 'dark_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _cachedConversationsKey = 'chat_cached_conversations';
  static const String _cachedMessagesPrefix = 'chat_cached_messages_';

  // Save tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Save user data
  Future<void> saveUserData(UserDto user) async {
    await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
  }

  // Get user data
  Future<UserDto?> getUserData() async {
    final userData = await _storage.read(key: _userDataKey);
    if (userData != null) {
      return UserDto.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<bool> hasStoredSession() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return (accessToken != null && accessToken.isNotEmpty) ||
        (refreshToken != null && refreshToken.isNotEmpty);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
  }

  // Delete specific key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Set dark mode preference
  Future<void> setDarkMode(bool isDark) async {
    await _storage.write(key: _darkModeKey, value: isDark.toString());
  }

  // Get dark mode preference
  Future<bool> getDarkMode() async {
    final isDark = await _storage.read(key: _darkModeKey);
    return isDark == 'true' ? true : false;
  }

  // Set font size preference (0: small, 1: medium, 2: large)
  Future<void> setFontSize(int sizeIndex) async {
    await _storage.write(key: _fontSizeKey, value: sizeIndex.toString());
  }

  // Get font size preference
  Future<int> getFontSize() async {
    final size = await _storage.read(key: _fontSizeKey);
    return size != null ? int.tryParse(size) ?? 1 : 1;
  }

  Future<bool> cacheConversations(String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(_cachedConversationsKey, jsonString);
    } catch (_) {
      return false;
    }
  }

  Future<String?> getCachedConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_cachedConversationsKey);
    } catch (_) {
      return null;
    }
  }

  Future<bool> cacheMessages(int conversationId, String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(
        '$_cachedMessagesPrefix$conversationId',
        jsonString,
      );
    } catch (_) {
      return false;
    }
  }

  Future<String?> getCachedMessages(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_cachedMessagesPrefix$conversationId');
    } catch (_) {
      return null;
    }
  }

  Future<void> clearChatCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = <String>{
        _cachedConversationsKey,
        'chat_pinned_conversation_ids',
        'chat_muted_conversation_ids',
        'chat_hidden_conversation_ids',
      };

      for (final key in prefs.getKeys()) {
        if (key.startsWith(_cachedMessagesPrefix)) {
          keysToRemove.add(key);
        }
      }

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (_) {
      // Intentionally ignored to avoid blocking logout or startup flows.
    }
  }
}
