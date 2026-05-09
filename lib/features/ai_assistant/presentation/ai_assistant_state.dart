import '../domain/ai_assistant_models.dart';

class AiAssistantState {
  const AiAssistantState({
    required this.role,
    this.userId,
    this.userDisplayName,
    this.isBootstrapping = true,
    this.isSending = false,
    this.isLoadingModels = false,
    this.history = const <AiConversationIndexEntry>[],
    this.activeConversation,
    this.availableModels = const <AiModelDescriptor>[],
    this.credentialStates = const <AiProviderId, AiProviderCredentialState>{},
    this.settings = const AiConversationSettings(
      providerId: AiProviderId.gemini,
      modelId: 'gemini-2.5-flash',
    ),
    this.defaultResponseStyle = AiResponseStyle.balanced,
    this.infoMessage,
    this.errorMessage,
    this.draftSeed,
    this.isOffline = false,
  });

  final AiAssistantRole role;
  final int? userId;
  final String? userDisplayName;
  final bool isBootstrapping;
  final bool isSending;
  final bool isLoadingModels;
  final List<AiConversationIndexEntry> history;
  final AiConversation? activeConversation;
  final List<AiModelDescriptor> availableModels;
  final Map<AiProviderId, AiProviderCredentialState> credentialStates;
  final AiConversationSettings settings;
  final AiResponseStyle defaultResponseStyle;
  final String? infoMessage;
  final String? errorMessage;
  final String? draftSeed;
  final bool isOffline;

  bool get hasConversation => activeConversation != null;

  List<AiModelDescriptor> modelsForProvider(AiProviderId providerId) {
    return availableModels
        .where((model) => model.providerId == providerId)
        .toList(growable: false);
  }

  AiProviderCredentialState credentialStateFor(AiProviderId providerId) {
    return credentialStates[providerId] ??
        AiProviderCredentialState(
          providerId: providerId,
          source: AiCredentialSource.unavailable,
        );
  }

  AiAssistantState copyWith({
    AiAssistantRole? role,
    int? userId,
    String? userDisplayName,
    bool? isBootstrapping,
    bool? isSending,
    bool? isLoadingModels,
    List<AiConversationIndexEntry>? history,
    AiConversation? activeConversation,
    bool clearConversation = false,
    List<AiModelDescriptor>? availableModels,
    Map<AiProviderId, AiProviderCredentialState>? credentialStates,
    AiConversationSettings? settings,
    AiResponseStyle? defaultResponseStyle,
    String? infoMessage,
    bool clearInfoMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? draftSeed,
    bool clearDraftSeed = false,
    bool? isOffline,
  }) {
    return AiAssistantState(
      role: role ?? this.role,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isSending: isSending ?? this.isSending,
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
      history: history ?? this.history,
      activeConversation: clearConversation
          ? null
          : activeConversation ?? this.activeConversation,
      availableModels: availableModels ?? this.availableModels,
      credentialStates: credentialStates ?? this.credentialStates,
      settings: settings ?? this.settings,
      defaultResponseStyle: defaultResponseStyle ?? this.defaultResponseStyle,
      infoMessage: clearInfoMessage ? null : infoMessage ?? this.infoMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      draftSeed: clearDraftSeed ? null : draftSeed ?? this.draftSeed,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
