import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../data/ai_conversation_repository.dart';
import '../data/ai_provider_defaults.dart';
import '../data/ai_provider_service.dart';
import '../data/ai_settings_repository.dart';
import '../domain/ai_assistant_models.dart';
import 'ai_assistant_state.dart';

class AiAssistantCubit extends Cubit<AiAssistantState> {
  AiAssistantCubit({
    required AiAssistantRole role,
    required int userId,
    required String userDisplayName,
    AiSettingsRepository? settingsRepository,
    AiConversationRepository? conversationRepository,
    AiProviderService? providerService,
  }) : _settingsRepository = settingsRepository ?? AiSettingsRepository(),
       _conversationRepository =
           conversationRepository ?? AiConversationRepository(),
       _providerService = providerService ?? AiProviderService(),
       super(
         AiAssistantState(
           role: role,
           userId: userId,
           userDisplayName: userDisplayName,
         ),
       );

  static const String untitledConversationTitle = '__untitled__';

  final AiSettingsRepository _settingsRepository;
  final AiConversationRepository _conversationRepository;
  final AiProviderService _providerService;
  final Uuid _uuid = const Uuid();

  CancelToken? _cancelToken;
  int _requestEpoch = 0;

  @override
  void emit(AiAssistantState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> initialize() async {
    emit(state.copyWith(isBootstrapping: true, clearErrorMessage: true));
    try {
      final fallbackProvider = _bestAvailableDefaultProvider();
      final fallbackModel = defaultModelsForProvider(
        fallbackProvider,
      ).first.modelId;
      final preferences = await _settingsRepository.loadPreferences(
        fallbackProvider: fallbackProvider,
        fallbackModelId: fallbackModel,
      );
      final credentialStates = await _loadAllCredentialStates();
      final availableModels = await _loadModelsForAllProviders(
        credentialStates,
      );
      final resolvedSettings = _resolveSettingsFallback(
        preferredProvider: preferences.defaultProvider,
        preferredModelId: preferences.defaultModelId,
        preferredStyle: preferences.responseStyle,
        availableModels: availableModels,
      );
      final history = await _conversationRepository.loadIndex(
        userId: state.userId!,
        role: state.role,
      );
      final activeConversation = await _loadPreferredConversation(
        history: history,
        settings: resolvedSettings,
      );

      emit(
        state.copyWith(
          isBootstrapping: false,
          history: history,
          activeConversation: activeConversation,
          availableModels: availableModels,
          credentialStates: credentialStates,
          settings: resolvedSettings,
          defaultResponseStyle: preferences.responseStyle,
          clearErrorMessage: true,
          clearInfoMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(isBootstrapping: false, errorMessage: error.toString()),
      );
    }
  }

  Future<void> refreshModels() async {
    emit(state.copyWith(isLoadingModels: true, clearErrorMessage: true));
    try {
      final credentials = await _loadAllCredentialStates();
      final models = await _loadModelsForAllProviders(credentials);
      final nextSettings = _resolveSettingsFallback(
        preferredProvider: state.settings.providerId,
        preferredModelId: state.settings.modelId,
        preferredStyle: state.settings.responseStyle,
        availableModels: models,
      );
      await _persistPreferences(nextSettings);
      await _updateActiveConversationSettings(nextSettings);
      emit(
        state.copyWith(
          isLoadingModels: false,
          credentialStates: credentials,
          availableModels: models,
          settings: nextSettings,
          infoMessage: 'Models refreshed.',
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(isLoadingModels: false, errorMessage: error.toString()),
      );
    }
  }

  Future<void> createNewConversation({AiContextScope? scope}) async {
    final nextSettings = scope == null
        ? state.settings
        : state.settings.copyWith(scope: scope);
    final next = _buildEmptyConversation(settings: nextSettings);
    await _conversationRepository.saveConversation(next);
    final history = await _conversationRepository.loadIndex(
      userId: state.userId!,
      role: state.role,
    );
    emit(
      state.copyWith(
        activeConversation: next,
        history: history,
        settings: nextSettings,
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> selectConversation(String conversationId) async {
    final conversation = await _conversationRepository.loadConversation(
      userId: state.userId!,
      role: state.role,
      conversationId: conversationId,
    );
    if (conversation == null) {
      emit(state.copyWith(errorMessage: 'This conversation is unavailable.'));
      return;
    }

    final nextSettings = _resolveSettingsFallback(
      preferredProvider: conversation.settings.providerId,
      preferredModelId: conversation.settings.modelId,
      preferredStyle: conversation.settings.responseStyle,
      availableModels: state.availableModels,
    );
    final nextConversation = conversation.copyWith(settings: nextSettings);
    emit(
      state.copyWith(
        activeConversation: nextConversation,
        settings: nextSettings,
        clearErrorMessage: true,
        clearInfoMessage: true,
      ),
    );
  }

  Future<void> sendMessage(String rawText) async {
    if (state.isSending) {
      return;
    }
    final content = rawText.trim();
    if (content.isEmpty) {
      emit(state.copyWith(errorMessage: 'Write a message before sending.'));
      return;
    }

    final conversation =
        state.activeConversation ??
        _buildEmptyConversation(settings: state.settings);
    final nextMessages = <AiMessage>[
      ...conversation.messages,
      AiMessage(
        id: _uuid.v4(),
        author: AiMessageAuthorType.user,
        content: content,
        createdAt: DateTime.now(),
      ),
      AiMessage(
        id: _uuid.v4(),
        author: AiMessageAuthorType.assistant,
        content: '',
        createdAt: DateTime.now(),
        status: AiMessageStatus.generating,
      ),
    ];

    final titledConversation = conversation.copyWith(
      title: _titleForConversation(conversation.title, content),
      updatedAt: DateTime.now(),
      messages: nextMessages,
      settings: state.settings.copyWith(
        responseStyle: state.defaultResponseStyle,
      ),
      clearLastError: true,
    );

    await _persistAndEmitConversation(
      titledConversation,
      isSending: true,
      clearError: true,
      clearInfo: true,
    );
    await _generateAssistantTurn(
      conversation: titledConversation,
      assistantMessageId: nextMessages.last.id,
    );
  }

  Future<void> stopGenerating() async {
    if (!state.isSending || _cancelToken == null) {
      return;
    }
    _cancelToken!.cancel('user_cancelled');
  }

  Future<void> regenerateResponse(String assistantMessageId) async {
    if (state.isSending) {
      return;
    }
    final conversation = state.activeConversation;
    if (conversation == null) {
      return;
    }

    final assistantIndex = conversation.messages.indexWhere(
      (message) => message.id == assistantMessageId,
    );
    if (assistantIndex <= 0) {
      return;
    }

    final previousUserIndex = _findPreviousUserIndex(
      conversation.messages,
      assistantIndex,
    );
    if (previousUserIndex == null) {
      return;
    }

    final preservedMessages =
        conversation.messages.take(previousUserIndex + 1).toList(growable: true)
          ..add(
            AiMessage(
              id: _uuid.v4(),
              author: AiMessageAuthorType.assistant,
              content: '',
              createdAt: DateTime.now(),
              status: AiMessageStatus.generating,
            ),
          );

    final nextConversation = conversation.copyWith(
      updatedAt: DateTime.now(),
      messages: preservedMessages,
      clearLastError: true,
    );
    await _persistAndEmitConversation(
      nextConversation,
      isSending: true,
      clearError: true,
      clearInfo: true,
    );
    await _generateAssistantTurn(
      conversation: nextConversation,
      assistantMessageId: preservedMessages.last.id,
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final conversation = state.activeConversation;
    if (conversation == null) {
      return;
    }
    final nextMessages = conversation.messages
        .where((message) => message.id != messageId)
        .toList(growable: false);
    final nextConversation = conversation.copyWith(
      messages: nextMessages,
      updatedAt: DateTime.now(),
    );
    await _persistAndEmitConversation(nextConversation);
  }

  Future<void> deleteFromMessage(String messageId) async {
    if (state.isSending) {
      await stopGenerating();
    }
    final conversation = state.activeConversation;
    if (conversation == null) {
      return;
    }
    final index = conversation.messages.indexWhere(
      (message) => message.id == messageId,
    );
    if (index < 0) {
      return;
    }
    final nextMessages = conversation.messages
        .take(index)
        .toList(growable: false);
    final nextConversation = conversation.copyWith(
      messages: nextMessages,
      updatedAt: DateTime.now(),
    );
    await _persistAndEmitConversation(nextConversation);
  }

  Future<void> editAndResendFromMessage(String messageId) async {
    final conversation = state.activeConversation;
    if (conversation == null) {
      return;
    }
    final index = conversation.messages.indexWhere(
      (message) => message.id == messageId,
    );
    if (index < 0) {
      return;
    }
    final target = conversation.messages[index];
    final nextConversation = conversation.copyWith(
      messages: conversation.messages.take(index).toList(growable: false),
      updatedAt: DateTime.now(),
    );
    await _persistAndEmitConversation(nextConversation);
    emit(state.copyWith(draftSeed: target.content, clearErrorMessage: true));
  }

  Future<void> setContextScope(AiContextScope scope) async {
    final nextSettings = state.settings.copyWith(scope: scope);
    await _persistPreferences(nextSettings);
    await _updateActiveConversationSettings(nextSettings);
    emit(
      state.copyWith(
        settings: nextSettings,
        infoMessage: 'Conversation scope updated.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> setResponseStyle(AiResponseStyle style) async {
    final nextSettings = state.settings.copyWith(responseStyle: style);
    await _persistPreferences(nextSettings);
    await _updateActiveConversationSettings(nextSettings);
    emit(
      state.copyWith(
        settings: nextSettings,
        defaultResponseStyle: style,
        infoMessage: 'Response style updated.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> selectModel({
    required AiProviderId providerId,
    required String modelId,
  }) async {
    final nextSettings = state.settings.copyWith(
      providerId: providerId,
      modelId: modelId,
    );
    await _persistPreferences(nextSettings);
    await _updateActiveConversationSettings(nextSettings);
    emit(
      state.copyWith(
        settings: nextSettings,
        infoMessage: 'Model changed for this conversation.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> togglePinned(String conversationId) async {
    final conversation = await _conversationRepository.loadConversation(
      userId: state.userId!,
      role: state.role,
      conversationId: conversationId,
    );
    if (conversation == null) {
      return;
    }
    final next = conversation.copyWith(
      isPinned: !conversation.isPinned,
      updatedAt: DateTime.now(),
    );
    await _conversationRepository.saveConversation(next);
    final history = await _conversationRepository.loadIndex(
      userId: state.userId!,
      role: state.role,
    );
    emit(
      state.copyWith(
        history: history,
        activeConversation: state.activeConversation?.id == next.id
            ? next
            : state.activeConversation,
      ),
    );
  }

  Future<void> renameConversation(String conversationId, String title) async {
    final conversation = await _conversationRepository.loadConversation(
      userId: state.userId!,
      role: state.role,
      conversationId: conversationId,
    );
    if (conversation == null) {
      return;
    }
    final next = conversation.copyWith(
      title: title.trim().isEmpty ? untitledConversationTitle : title.trim(),
      updatedAt: DateTime.now(),
    );
    await _conversationRepository.saveConversation(next);
    final history = await _conversationRepository.loadIndex(
      userId: state.userId!,
      role: state.role,
    );
    emit(
      state.copyWith(
        history: history,
        activeConversation: state.activeConversation?.id == next.id
            ? next
            : state.activeConversation,
      ),
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    if (state.activeConversation?.id == conversationId && state.isSending) {
      await stopGenerating();
    }
    await _conversationRepository.deleteConversation(
      userId: state.userId!,
      role: state.role,
      conversationId: conversationId,
    );
    final history = await _conversationRepository.loadIndex(
      userId: state.userId!,
      role: state.role,
    );
    AiConversation? nextConversation = state.activeConversation;
    if (state.activeConversation?.id == conversationId) {
      nextConversation = history.isNotEmpty
          ? await _conversationRepository.loadConversation(
              userId: state.userId!,
              role: state.role,
              conversationId: history.first.id,
            )
          : _buildEmptyConversation(settings: state.settings);
    }
    emit(
      state.copyWith(
        history: history,
        activeConversation: nextConversation,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> clearAllHistory() async {
    if (state.isSending) {
      await stopGenerating();
    }
    await _conversationRepository.clearAll(
      userId: state.userId!,
      role: state.role,
    );
    final nextConversation = _buildEmptyConversation(settings: state.settings);
    await _conversationRepository.saveConversation(nextConversation);
    final history = await _conversationRepository.loadIndex(
      userId: state.userId!,
      role: state.role,
    );
    emit(
      state.copyWith(
        history: history,
        activeConversation: nextConversation,
        infoMessage: 'Conversation history cleared.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> saveExternalKey(
    AiProviderId providerId,
    String key, {
    bool enable = true,
  }) async {
    await _settingsRepository.saveUserProviderKey(
      providerId,
      key,
      enable: enable,
    );
    final credentials = await _loadAllCredentialStates();
    emit(
      state.copyWith(
        credentialStates: credentials,
        infoMessage: 'Personal API key saved.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> removeExternalKey(AiProviderId providerId) async {
    await _settingsRepository.removeUserProviderKey(providerId);
    final credentials = await _loadAllCredentialStates();
    emit(
      state.copyWith(
        credentialStates: credentials,
        infoMessage: 'Personal API key removed.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> setUseExternalKey(AiProviderId providerId, bool enabled) async {
    await _settingsRepository.setUseUserProviderKey(providerId, enabled);
    final credentials = await _loadAllCredentialStates();
    emit(
      state.copyWith(
        credentialStates: credentials,
        infoMessage: enabled
            ? 'Personal API key enabled.'
            : 'Switched back to app default access.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> exportConversation() async {
    final conversation = state.activeConversation;
    if (conversation == null || conversation.messages.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'There is no conversation content to export yet.',
        ),
      );
      return;
    }
    final content = await _conversationRepository.exportConversation(
      conversation,
    );
    if (content.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'There is no conversation content to export yet.',
        ),
      );
      return;
    }
    await Share.share(
      content,
      subject: _visibleConversationTitle(conversation),
    );
    emit(
      state.copyWith(
        infoMessage: 'Conversation exported.',
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> exportConversationById(String conversationId) async {
    final conversation = await _conversationRepository.loadConversation(
      userId: state.userId!,
      role: state.role,
      conversationId: conversationId,
    );
    if (conversation == null || conversation.messages.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'There is no conversation content to export yet.',
        ),
      );
      return;
    }
    final content = await _conversationRepository.exportConversation(
      conversation,
    );
    if (content.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'There is no conversation content to export yet.',
        ),
      );
      return;
    }
    await Share.share(
      content,
      subject: _visibleConversationTitle(conversation),
    );
    emit(
      state.copyWith(
        infoMessage: 'Conversation exported.',
        clearErrorMessage: true,
      ),
    );
  }

  void clearDraftSeed() {
    emit(state.copyWith(clearDraftSeed: true));
  }

  void clearTransientMessages() {
    emit(state.copyWith(clearErrorMessage: true, clearInfoMessage: true));
  }

  Future<void> _generateAssistantTurn({
    required AiConversation conversation,
    required String assistantMessageId,
  }) async {
    _requestEpoch += 1;
    final requestEpoch = _requestEpoch;
    _cancelToken?.cancel('new_request_started');
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    final effectiveKey = await _settingsRepository.resolveEffectiveApiKey(
      conversation.settings.providerId,
    );
    if (effectiveKey == null || effectiveKey.trim().isEmpty) {
      final nextConversation = _markAssistantMessageError(
        conversation,
        assistantMessageId,
        const AiProviderError(
          type: AiProviderErrorType.missingCredentials,
          message: 'No API key is available for this provider.',
        ),
      );
      await _persistAndEmitConversation(
        nextConversation,
        isSending: false,
        errorMessage: 'Set up access for this provider before sending.',
      );
      return;
    }

    try {
      final response = await _providerService.generate(
        AiGenerationRequest(
          providerId: conversation.settings.providerId,
          modelId: conversation.settings.modelId,
          messages: _messagesForProviderRequest(
            conversation.messages
                .where((message) => message.id != assistantMessageId)
                .toList(growable: false),
          ),
          systemPrompt: _systemPromptFor(
            role: conversation.role,
            userName: state.userDisplayName ?? 'User',
            settings: conversation.settings,
          ),
          responseStyle: conversation.settings.responseStyle,
          scope: conversation.settings.scope,
          apiKey: effectiveKey,
        ),
        cancelToken: cancelToken,
      );

      if (requestEpoch != _requestEpoch || isClosed) {
        return;
      }

      final nextConversation = conversation.copyWith(
        updatedAt: DateTime.now(),
        messages: conversation.messages
            .map(
              (message) => message.id == assistantMessageId
                  ? message.copyWith(
                      content: response.content,
                      status: AiMessageStatus.ready,
                      clearError: true,
                    )
                  : message,
            )
            .toList(growable: false),
        clearLastError: true,
      );
      await _persistAndEmitConversation(
        nextConversation,
        isSending: false,
        clearError: true,
        clearInfo: true,
        isOffline: false,
      );
    } on AiProviderError catch (error) {
      if (requestEpoch != _requestEpoch || isClosed) {
        return;
      }
      final nextConversation = _markAssistantMessageError(
        conversation,
        assistantMessageId,
        error,
      );
      await _persistAndEmitConversation(
        nextConversation,
        isSending: false,
        errorMessage: _userFacingErrorMessage(error),
        isOffline:
            error.type == AiProviderErrorType.network ||
            error.type == AiProviderErrorType.timeout ||
            error.type == AiProviderErrorType.ssl,
      );
    } catch (error) {
      if (requestEpoch != _requestEpoch || isClosed) {
        return;
      }
      const providerError = AiProviderError(
        type: AiProviderErrorType.unknown,
        message: 'The assistant could not complete this response.',
        isRetryable: true,
      );
      final nextConversation = _markAssistantMessageError(
        conversation,
        assistantMessageId,
        providerError,
      );
      await _persistAndEmitConversation(
        nextConversation,
        isSending: false,
        errorMessage: providerError.message,
      );
    } finally {
      if (identical(_cancelToken, cancelToken)) {
        _cancelToken = null;
      }
    }
  }

  AiConversation _markAssistantMessageError(
    AiConversation conversation,
    String assistantMessageId,
    AiProviderError error,
  ) {
    return conversation.copyWith(
      updatedAt: DateTime.now(),
      lastErrorSummary: error.message,
      messages: conversation.messages
          .map(
            (message) => message.id == assistantMessageId
                ? message.copyWith(
                    status: error.type == AiProviderErrorType.cancelled
                        ? AiMessageStatus.cancelled
                        : AiMessageStatus.error,
                    error: error,
                  )
                : message,
          )
          .toList(growable: false),
    );
  }

  Future<Map<AiProviderId, AiProviderCredentialState>>
  _loadAllCredentialStates() async {
    final map = <AiProviderId, AiProviderCredentialState>{};
    for (final provider in AiProviderId.values) {
      map[provider] = await _settingsRepository.loadCredentialState(provider);
    }
    return map;
  }

  Future<List<AiModelDescriptor>> _loadModelsForAllProviders(
    Map<AiProviderId, AiProviderCredentialState> credentials,
  ) async {
    final models = <AiModelDescriptor>[];
    for (final provider in AiProviderId.values) {
      final credential = credentials[provider];
      final apiKey = await _settingsRepository.resolveEffectiveApiKey(provider);
      if (credential?.isAvailable == true &&
          apiKey != null &&
          apiKey.isNotEmpty) {
        try {
          models.addAll(
            await _providerService.listModelsForProvider(provider, apiKey),
          );
          continue;
        } catch (_) {}
      }
      models.addAll(defaultModelsForProvider(provider));
    }
    final deduped = <String, AiModelDescriptor>{};
    for (final model in models) {
      deduped['${model.providerId.name}:${model.modelId}'] = model;
    }
    return deduped.values.toList(growable: false);
  }

  AiConversationSettings _resolveSettingsFallback({
    required AiProviderId preferredProvider,
    required String preferredModelId,
    required AiResponseStyle preferredStyle,
    required List<AiModelDescriptor> availableModels,
  }) {
    final providerModels = availableModels
        .where((model) => model.providerId == preferredProvider)
        .toList(growable: false);
    if (providerModels.any((model) => model.modelId == preferredModelId)) {
      return AiConversationSettings(
        providerId: preferredProvider,
        modelId: preferredModelId,
        responseStyle: preferredStyle,
        scope: state.settings.scope,
      );
    }

    if (providerModels.isNotEmpty) {
      return AiConversationSettings(
        providerId: preferredProvider,
        modelId: providerModels.first.modelId,
        responseStyle: preferredStyle,
        scope: state.settings.scope,
      );
    }

    final fallbackProvider = _bestAvailableDefaultProvider();
    return AiConversationSettings(
      providerId: fallbackProvider,
      modelId: defaultModelsForProvider(fallbackProvider).first.modelId,
      responseStyle: preferredStyle,
      scope: state.settings.scope,
    );
  }

  Future<AiConversation?> _loadPreferredConversation({
    required List<AiConversationIndexEntry> history,
    required AiConversationSettings settings,
  }) async {
    if (history.isEmpty) {
      final next = _buildEmptyConversation(settings: settings);
      await _conversationRepository.saveConversation(next);
      return next;
    }

    for (final entry in history) {
      final conversation = await _conversationRepository.loadConversation(
        userId: state.userId!,
        role: state.role,
        conversationId: entry.id,
      );
      if (conversation != null) {
        return conversation;
      }
    }

    final fallback = _buildEmptyConversation(settings: settings);
    await _conversationRepository.saveConversation(fallback);
    return fallback;
  }

  AiConversation _buildEmptyConversation({
    required AiConversationSettings settings,
  }) {
    final now = DateTime.now();
    return AiConversation(
      id: _uuid.v4(),
      userId: state.userId!,
      role: state.role,
      title: untitledConversationTitle,
      createdAt: now,
      updatedAt: now,
      messages: const <AiMessage>[],
      settings: settings,
    );
  }

  String _titleForConversation(String existingTitle, String firstPrompt) {
    if (existingTitle != untitledConversationTitle &&
        existingTitle.trim().isNotEmpty) {
      return existingTitle;
    }
    return firstPrompt.length <= 42
        ? firstPrompt
        : '${firstPrompt.substring(0, 42).trim()}...';
  }

  String _visibleConversationTitle(AiConversation conversation) {
    return conversation.title == untitledConversationTitle
        ? 'AI Assistant'
        : conversation.title;
  }

  String _systemPromptFor({
    required AiAssistantRole role,
    required String userName,
    required AiConversationSettings settings,
  }) {
    final rolePrompt = switch (role) {
      AiAssistantRole.student =>
        'You are EduVerse AI, a supportive study assistant for students. Help $userName understand concepts, plan learning, summarize academic material, and practice effectively.',
      AiAssistantRole.instructor =>
        'You are EduVerse AI, a teaching copilot for instructors. Help $userName draft teaching content, explain classroom decisions, support rubric and feedback writing, and stay concise and actionable.',
      AiAssistantRole.ta =>
        'You are EduVerse AI, a teaching assistant copilot. Help $userName support students, explain course material, draft clarifications, and assist with grading-oriented reasoning.',
    };

    final scopePrompt = switch (settings.scope) {
      AiContextScope.general =>
        'General assistance mode. Keep answers practical and easy to scan.',
      AiContextScope.study =>
        'Study mode. Favor explanation, examples, and step-by-step guidance.',
      AiContextScope.drafting =>
        'Drafting mode. Produce polished, reusable wording and structured output.',
      AiContextScope.grading =>
        'Grading mode. Focus on balanced academic feedback, rubric alignment, and clarity.',
    };

    final stylePrompt = switch (settings.responseStyle) {
      AiResponseStyle.concise =>
        'Respond concisely with short sections and minimal filler.',
      AiResponseStyle.balanced => 'Respond with a balanced level of detail.',
      AiResponseStyle.detailed =>
        'Respond with fuller detail while staying structured and readable.',
    };

    return '$rolePrompt $scopePrompt $stylePrompt Avoid claiming access to private data or hidden app state. If information is missing, say so clearly.';
  }

  String _userFacingErrorMessage(AiProviderError error) {
    switch (error.type) {
      case AiProviderErrorType.missingCredentials:
        return 'No API access is configured for this provider.';
      case AiProviderErrorType.invalidCredentials:
        return 'The selected provider rejected the current API key.';
      case AiProviderErrorType.quotaExceeded:
        return 'This provider has reached its quota or free-tier limit.';
      case AiProviderErrorType.rateLimited:
        return 'This provider is rate limiting requests right now.';
      case AiProviderErrorType.network:
        return 'No internet connection. Check your network and try again.';
      case AiProviderErrorType.timeout:
        return 'The provider took too long to respond.';
      case AiProviderErrorType.ssl:
        return 'A secure connection could not be established.';
      case AiProviderErrorType.server:
        return 'The provider is temporarily unavailable.';
      case AiProviderErrorType.unsupportedModel:
        return 'The selected model is not available anymore.';
      case AiProviderErrorType.cancelled:
        return 'Generation stopped.';
      case AiProviderErrorType.storage:
        return 'Local AI data could not be saved safely.';
      case AiProviderErrorType.unknown:
        return error.message;
    }
  }

  List<AiMessage> _messagesForProviderRequest(List<AiMessage> messages) {
    const maxTurns = 18;
    if (messages.length <= maxTurns) {
      return messages;
    }
    return messages.sublist(messages.length - maxTurns);
  }

  int? _findPreviousUserIndex(List<AiMessage> messages, int fromIndex) {
    for (var i = fromIndex - 1; i >= 0; i -= 1) {
      if (messages[i].author == AiMessageAuthorType.user) {
        return i;
      }
    }
    return null;
  }

  AiProviderId _bestAvailableDefaultProvider() {
    for (final provider in AiProviderId.values) {
      if (defaultModelsForProvider(provider).isNotEmpty) {
        return provider;
      }
    }
    return AiProviderId.gemini;
  }

  Future<void> _persistPreferences(AiConversationSettings settings) async {
    await _settingsRepository.savePreferences(
      AiAssistantPreferences(
        defaultProvider: settings.providerId,
        defaultModelId: settings.modelId,
        responseStyle: settings.responseStyle,
      ),
    );
  }

  Future<void> _updateActiveConversationSettings(
    AiConversationSettings settings,
  ) async {
    final conversation = state.activeConversation;
    if (conversation == null) {
      return;
    }
    final nextConversation = conversation.copyWith(
      settings: settings,
      updatedAt: DateTime.now(),
    );
    await _conversationRepository.saveConversation(nextConversation);
    final history = await _conversationRepository.loadIndex(
      userId: state.userId!,
      role: state.role,
    );
    emit(
      state.copyWith(activeConversation: nextConversation, history: history),
    );
  }

  Future<void> _persistAndEmitConversation(
    AiConversation conversation, {
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    bool? isOffline,
  }) async {
    await _conversationRepository.saveConversation(conversation);
    final history = await _conversationRepository.loadIndex(
      userId: state.userId!,
      role: state.role,
    );
    emit(
      state.copyWith(
        activeConversation: conversation,
        history: history,
        isSending: isSending ?? state.isSending,
        errorMessage: errorMessage,
        clearErrorMessage: clearError,
        infoMessage: infoMessage,
        clearInfoMessage: clearInfo,
        isOffline: isOffline ?? state.isOffline,
      ),
    );
  }

  @override
  Future<void> close() {
    _requestEpoch += 1;
    _cancelToken?.cancel('cubit_closed');
    return super.close();
  }
}
