import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/auth_models.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _darkModeKey = 'dark_mode';

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
}
