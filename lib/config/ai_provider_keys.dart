import '../features/ai_assistant/domain/ai_assistant_models.dart';
import 'ai_provider_keys.local.dart';

class AiProviderKeys {
  const AiProviderKeys._();

  static String _normalize(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed;
  }

  static String? appOwnedKeyFor(AiProviderId providerId) {
    final localValue = switch (providerId) {
      AiProviderId.gemini => _normalize(LocalAiProviderKeys.geminiApiKey),
      AiProviderId.groq => _normalize(LocalAiProviderKeys.groqApiKey),
      AiProviderId.openRouter => _normalize(
        LocalAiProviderKeys.openRouterApiKey,
      ),
    };
    if (localValue.isNotEmpty) {
      return localValue;
    }

    final fromEnvironment = switch (providerId) {
      AiProviderId.gemini => _normalize(
        const String.fromEnvironment('AI_GEMINI_API_KEY'),
      ),
      AiProviderId.groq => _normalize(
        const String.fromEnvironment('AI_GROQ_API_KEY'),
      ),
      AiProviderId.openRouter => _normalize(
        const String.fromEnvironment('AI_OPENROUTER_API_KEY'),
      ),
    };

    return fromEnvironment.isEmpty ? null : fromEnvironment;
  }

  static bool hasAppOwnedKey(AiProviderId providerId) {
    return (appOwnedKeyFor(providerId) ?? '').isNotEmpty;
  }
}
