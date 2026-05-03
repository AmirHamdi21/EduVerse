import 'dart:convert';

enum AiAssistantRole { student, instructor, ta }

enum AiProviderId { gemini, groq, openRouter }

enum AiCredentialSource { appDefault, userProvided, unavailable }

enum AiResponseStyle { concise, balanced, detailed }

enum AiContextScope { general, study, drafting, grading }

enum AiMessageAuthorType { user, assistant, system }

enum AiMessageStatus { ready, generating, error, cancelled }

enum AiProviderErrorType {
  missingCredentials,
  invalidCredentials,
  quotaExceeded,
  rateLimited,
  network,
  timeout,
  ssl,
  server,
  unsupportedModel,
  cancelled,
  storage,
  unknown,
}

class AiProviderCapabilities {
  const AiProviderCapabilities({
    this.supportsVision = false,
    this.supportsReasoning = false,
    this.supportsToolCalling = false,
    this.dynamicCatalog = false,
  });

  final bool supportsVision;
  final bool supportsReasoning;
  final bool supportsToolCalling;
  final bool dynamicCatalog;
}

class AiModelDescriptor {
  const AiModelDescriptor({
    required this.providerId,
    required this.modelId,
    required this.label,
    required this.isFreeTier,
    required this.status,
    this.capabilities = const AiProviderCapabilities(),
    this.description,
  });

  final AiProviderId providerId;
  final String modelId;
  final String label;
  final bool isFreeTier;
  final String status;
  final AiProviderCapabilities capabilities;
  final String? description;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'providerId': providerId.name,
    'modelId': modelId,
    'label': label,
    'isFreeTier': isFreeTier,
    'status': status,
    'capabilities': <String, dynamic>{
      'supportsVision': capabilities.supportsVision,
      'supportsReasoning': capabilities.supportsReasoning,
      'supportsToolCalling': capabilities.supportsToolCalling,
      'dynamicCatalog': capabilities.dynamicCatalog,
    },
    'description': description,
  };

  factory AiModelDescriptor.fromJson(Map<String, dynamic> json) {
    final capabilitiesJson =
        (json['capabilities'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return AiModelDescriptor(
      providerId: AiProviderId.values.firstWhere(
        (value) => value.name == json['providerId'],
        orElse: () => AiProviderId.gemini,
      ),
      modelId: json['modelId']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      isFreeTier: json['isFreeTier'] == true,
      status: json['status']?.toString() ?? 'stable',
      capabilities: AiProviderCapabilities(
        supportsVision: capabilitiesJson['supportsVision'] == true,
        supportsReasoning: capabilitiesJson['supportsReasoning'] == true,
        supportsToolCalling: capabilitiesJson['supportsToolCalling'] == true,
        dynamicCatalog: capabilitiesJson['dynamicCatalog'] == true,
      ),
      description: json['description']?.toString(),
    );
  }
}

class AiProviderCredentialState {
  const AiProviderCredentialState({
    required this.providerId,
    required this.source,
    this.hasAppDefault = false,
    this.hasUserKey = false,
    this.useUserKey = false,
    this.error,
  });

  final AiProviderId providerId;
  final AiCredentialSource source;
  final bool hasAppDefault;
  final bool hasUserKey;
  final bool useUserKey;
  final String? error;

  bool get isAvailable => source != AiCredentialSource.unavailable;

  AiProviderCredentialState copyWith({
    AiCredentialSource? source,
    bool? hasAppDefault,
    bool? hasUserKey,
    bool? useUserKey,
    String? error,
    bool clearError = false,
  }) {
    return AiProviderCredentialState(
      providerId: providerId,
      source: source ?? this.source,
      hasAppDefault: hasAppDefault ?? this.hasAppDefault,
      hasUserKey: hasUserKey ?? this.hasUserKey,
      useUserKey: useUserKey ?? this.useUserKey,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AiProviderError implements Exception {
  const AiProviderError({
    required this.type,
    required this.message,
    this.statusCode,
    this.isRetryable = false,
  });

  final AiProviderErrorType type;
  final String message;
  final int? statusCode;
  final bool isRetryable;

  @override
  String toString() => message;
}

class AiGenerationRequest {
  const AiGenerationRequest({
    required this.providerId,
    required this.modelId,
    required this.messages,
    required this.systemPrompt,
    required this.responseStyle,
    required this.scope,
    required this.apiKey,
  });

  final AiProviderId providerId;
  final String modelId;
  final List<AiMessage> messages;
  final String systemPrompt;
  final AiResponseStyle responseStyle;
  final AiContextScope scope;
  final String apiKey;
}

class AiGenerationResponse {
  const AiGenerationResponse({required this.content, this.providerMetadata});

  final String content;
  final Map<String, dynamic>? providerMetadata;
}

class AiMessage {
  const AiMessage({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.status = AiMessageStatus.ready,
    this.error,
  });

  final String id;
  final AiMessageAuthorType author;
  final String content;
  final DateTime createdAt;
  final AiMessageStatus status;
  final AiProviderError? error;

  bool get isUser => author == AiMessageAuthorType.user;

  AiMessage copyWith({
    String? id,
    AiMessageAuthorType? author,
    String? content,
    DateTime? createdAt,
    AiMessageStatus? status,
    AiProviderError? error,
    bool clearError = false,
  }) {
    return AiMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'author': author.name,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'error': error == null
        ? null
        : <String, dynamic>{
            'type': error!.type.name,
            'message': error!.message,
            'statusCode': error!.statusCode,
            'isRetryable': error!.isRetryable,
          },
  };

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    final errorJson = (json['error'] as Map?)?.cast<String, dynamic>();
    return AiMessage(
      id: json['id']?.toString() ?? '',
      author: AiMessageAuthorType.values.firstWhere(
        (value) => value.name == json['author'],
        orElse: () => AiMessageAuthorType.user,
      ),
      content: json['content']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      status: AiMessageStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => AiMessageStatus.ready,
      ),
      error: errorJson == null
          ? null
          : AiProviderError(
              type: AiProviderErrorType.values.firstWhere(
                (value) => value.name == errorJson['type'],
                orElse: () => AiProviderErrorType.unknown,
              ),
              message: errorJson['message']?.toString() ?? '',
              statusCode: errorJson['statusCode'] is int
                  ? errorJson['statusCode'] as int
                  : int.tryParse(errorJson['statusCode']?.toString() ?? ''),
              isRetryable: errorJson['isRetryable'] == true,
            ),
    );
  }
}

class AiConversationSettings {
  const AiConversationSettings({
    required this.providerId,
    required this.modelId,
    this.responseStyle = AiResponseStyle.balanced,
    this.scope = AiContextScope.general,
  });

  final AiProviderId providerId;
  final String modelId;
  final AiResponseStyle responseStyle;
  final AiContextScope scope;

  AiConversationSettings copyWith({
    AiProviderId? providerId,
    String? modelId,
    AiResponseStyle? responseStyle,
    AiContextScope? scope,
  }) {
    return AiConversationSettings(
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      responseStyle: responseStyle ?? this.responseStyle,
      scope: scope ?? this.scope,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'providerId': providerId.name,
    'modelId': modelId,
    'responseStyle': responseStyle.name,
    'scope': scope.name,
  };

  factory AiConversationSettings.fromJson(Map<String, dynamic> json) =>
      AiConversationSettings(
        providerId: AiProviderId.values.firstWhere(
          (value) => value.name == json['providerId'],
          orElse: () => AiProviderId.gemini,
        ),
        modelId: json['modelId']?.toString() ?? '',
        responseStyle: AiResponseStyle.values.firstWhere(
          (value) => value.name == json['responseStyle'],
          orElse: () => AiResponseStyle.balanced,
        ),
        scope: AiContextScope.values.firstWhere(
          (value) => value.name == json['scope'],
          orElse: () => AiContextScope.general,
        ),
      );
}

class AiConversation {
  const AiConversation({
    required this.id,
    required this.userId,
    required this.role,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    required this.settings,
    this.isPinned = false,
    this.lastErrorSummary,
  });

  final String id;
  final int userId;
  final AiAssistantRole role;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AiMessage> messages;
  final AiConversationSettings settings;
  final bool isPinned;
  final String? lastErrorSummary;

  AiConversation copyWith({
    String? id,
    int? userId,
    AiAssistantRole? role,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AiMessage>? messages,
    AiConversationSettings? settings,
    bool? isPinned,
    String? lastErrorSummary,
    bool clearLastError = false,
  }) {
    return AiConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
      isPinned: isPinned ?? this.isPinned,
      lastErrorSummary: clearLastError
          ? null
          : lastErrorSummary ?? this.lastErrorSummary,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'role': role.name,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((message) => message.toJson()).toList(),
    'settings': settings.toJson(),
    'isPinned': isPinned,
    'lastErrorSummary': lastErrorSummary,
  };

  factory AiConversation.fromJson(Map<String, dynamic> json) => AiConversation(
    id: json['id']?.toString() ?? '',
    userId: json['userId'] is int
        ? json['userId'] as int
        : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
    role: AiAssistantRole.values.firstWhere(
      (value) => value.name == json['role'],
      orElse: () => AiAssistantRole.student,
    ),
    title: json['title']?.toString() ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.now(),
    messages: ((json['messages'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => AiMessage.fromJson(item.cast<String, dynamic>()))
        .toList(),
    settings: AiConversationSettings.fromJson(
      (json['settings'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    ),
    isPinned: json['isPinned'] == true,
    lastErrorSummary: json['lastErrorSummary']?.toString(),
  );

  String encode() => jsonEncode(toJson());

  factory AiConversation.decode(String source) =>
      AiConversation.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class AiConversationIndexEntry {
  const AiConversationIndexEntry({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.role,
    required this.userId,
    required this.providerId,
    required this.modelId,
    this.preview,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final DateTime updatedAt;
  final AiAssistantRole role;
  final int userId;
  final AiProviderId providerId;
  final String modelId;
  final String? preview;
  final bool isPinned;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'updatedAt': updatedAt.toIso8601String(),
    'role': role.name,
    'userId': userId,
    'providerId': providerId.name,
    'modelId': modelId,
    'preview': preview,
    'isPinned': isPinned,
  };

  factory AiConversationIndexEntry.fromConversation(
    AiConversation conversation,
  ) {
    final preview = conversation.messages.reversed
        .firstWhere(
          (message) => message.content.trim().isNotEmpty,
          orElse: () => AiMessage(
            id: '',
            author: AiMessageAuthorType.system,
            content: '',
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .content;
    return AiConversationIndexEntry(
      id: conversation.id,
      title: conversation.title,
      updatedAt: conversation.updatedAt,
      role: conversation.role,
      userId: conversation.userId,
      providerId: conversation.settings.providerId,
      modelId: conversation.settings.modelId,
      preview: preview.isEmpty ? null : preview,
      isPinned: conversation.isPinned,
    );
  }

  factory AiConversationIndexEntry.fromJson(Map<String, dynamic> json) =>
      AiConversationIndexEntry(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        updatedAt:
            DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        role: AiAssistantRole.values.firstWhere(
          (value) => value.name == json['role'],
          orElse: () => AiAssistantRole.student,
        ),
        userId: json['userId'] is int
            ? json['userId'] as int
            : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
        providerId: AiProviderId.values.firstWhere(
          (value) => value.name == json['providerId'],
          orElse: () => AiProviderId.gemini,
        ),
        modelId: json['modelId']?.toString() ?? '',
        preview: json['preview']?.toString(),
        isPinned: json['isPinned'] == true,
      );
}
