import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ai_assistant/domain/ai_assistant_models.dart';
import '../../../config/ai_provider_keys.dart';

class AiUserProviderKey {
  const AiUserProviderKey({
    required this.providerId,
    required this.useUserKey,
    this.value,
  });

  final AiProviderId providerId;
  final String? value;
  final bool useUserKey;
}

class AiAssistantPreferences {
  const AiAssistantPreferences({
    required this.defaultProvider,
    required this.defaultModelId,
    required this.responseStyle,
  });

  final AiProviderId defaultProvider;
  final String defaultModelId;
  final AiResponseStyle responseStyle;
}

class AiSettingsRepository {
  AiSettingsRepository({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const String _prefsKey = 'ai_assistant_preferences_v1';
  static const String _userKeyPrefix = 'ai_assistant_provider_key_';
  static const String _userKeyEnabledPrefix =
      'ai_assistant_provider_key_enabled_';

  Future<AiAssistantPreferences> loadPreferences({
    required AiProviderId fallbackProvider,
    required String fallbackModelId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.trim().isEmpty) {
      return AiAssistantPreferences(
        defaultProvider: fallbackProvider,
        defaultModelId: fallbackModelId,
        responseStyle: AiResponseStyle.balanced,
      );
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AiAssistantPreferences(
        defaultProvider: AiProviderId.values.firstWhere(
          (value) => value.name == json['defaultProvider'],
          orElse: () => fallbackProvider,
        ),
        defaultModelId: json['defaultModelId']?.toString() ?? fallbackModelId,
        responseStyle: AiResponseStyle.values.firstWhere(
          (value) => value.name == json['responseStyle'],
          orElse: () => AiResponseStyle.balanced,
        ),
      );
    } catch (_) {
      return AiAssistantPreferences(
        defaultProvider: fallbackProvider,
        defaultModelId: fallbackModelId,
        responseStyle: AiResponseStyle.balanced,
      );
    }
  }

  Future<void> savePreferences(AiAssistantPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(<String, dynamic>{
        'defaultProvider': preferences.defaultProvider.name,
        'defaultModelId': preferences.defaultModelId,
        'responseStyle': preferences.responseStyle.name,
      }),
    );
  }

  Future<AiUserProviderKey> loadUserProviderKey(AiProviderId providerId) async {
    final prefs = await SharedPreferences.getInstance();
    final useUserKey =
        prefs.getBool('$_userKeyEnabledPrefix${providerId.name}') ?? false;
    final value = await _secureStorage.read(
      key: '$_userKeyPrefix${providerId.name}',
    );
    return AiUserProviderKey(
      providerId: providerId,
      value: value?.trim().isEmpty == true ? null : value?.trim(),
      useUserKey: useUserKey,
    );
  }

  Future<void> saveUserProviderKey(
    AiProviderId providerId,
    String key, {
    bool enable = true,
  }) async {
    final trimmed = key.trim();
    await _secureStorage.write(
      key: '$_userKeyPrefix${providerId.name}',
      value: trimmed,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_userKeyEnabledPrefix${providerId.name}', enable);
  }

  Future<void> setUseUserProviderKey(
    AiProviderId providerId,
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_userKeyEnabledPrefix${providerId.name}', enabled);
  }

  Future<void> removeUserProviderKey(AiProviderId providerId) async {
    await _secureStorage.delete(key: '$_userKeyPrefix${providerId.name}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_userKeyEnabledPrefix${providerId.name}');
  }

  Future<AiProviderCredentialState> loadCredentialState(
    AiProviderId providerId,
  ) async {
    final userKey = await loadUserProviderKey(providerId);
    final hasAppDefault = AiProviderKeys.hasAppOwnedKey(providerId);
    final hasUserKey = (userKey.value ?? '').trim().isNotEmpty;
    final source = userKey.useUserKey && hasUserKey
        ? AiCredentialSource.userProvided
        : hasAppDefault
        ? AiCredentialSource.appDefault
        : AiCredentialSource.unavailable;

    return AiProviderCredentialState(
      providerId: providerId,
      source: source,
      hasAppDefault: hasAppDefault,
      hasUserKey: hasUserKey,
      useUserKey: userKey.useUserKey,
    );
  }

  Future<String?> resolveEffectiveApiKey(AiProviderId providerId) async {
    final userKey = await loadUserProviderKey(providerId);
    if (userKey.useUserKey && (userKey.value ?? '').trim().isNotEmpty) {
      return userKey.value!.trim();
    }
    return AiProviderKeys.appOwnedKeyFor(providerId);
  }
}
