import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/ai_assistant_models.dart';
import 'ai_provider_defaults.dart';

abstract class AiProviderAdapter {
  const AiProviderAdapter();

  Future<AiGenerationResponse> generate(
    AiGenerationRequest request, {
    CancelToken? cancelToken,
  });

  Future<List<AiModelDescriptor>> listModels(String apiKey) async {
    return defaultModelsForProvider(providerId);
  }

  AiProviderId get providerId;
}

class AiProviderService {
  AiProviderService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 30),
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
            ),
          ),
      _adapters = <AiProviderId, AiProviderAdapter>{};

  final Dio _dio;
  final Map<AiProviderId, AiProviderAdapter> _adapters;

  AiProviderAdapter adapterFor(AiProviderId providerId) {
    return _adapters.putIfAbsent(providerId, () {
      switch (providerId) {
        case AiProviderId.gemini:
          return _GeminiProviderAdapter(_dio);
        case AiProviderId.groq:
          return _OpenAiCompatibleProviderAdapter(
            dio: _dio,
            providerId: AiProviderId.groq,
            endpoint: 'https://api.groq.com/openai/v1/chat/completions',
          );
        case AiProviderId.openRouter:
          return _OpenRouterProviderAdapter(_dio);
      }
    });
  }

  Future<AiGenerationResponse> generate(
    AiGenerationRequest request, {
    CancelToken? cancelToken,
  }) {
    return adapterFor(
      request.providerId,
    ).generate(request, cancelToken: cancelToken);
  }

  Future<List<AiModelDescriptor>> listModelsForProvider(
    AiProviderId providerId,
    String apiKey,
  ) async {
    try {
      final models = await adapterFor(providerId).listModels(apiKey);
      if (models.isEmpty) {
        return defaultModelsForProvider(providerId);
      }
      return _mergeWithDefaults(providerId, models);
    } on AiProviderError {
      rethrow;
    } catch (_) {
      return defaultModelsForProvider(providerId);
    }
  }

  List<AiModelDescriptor> _mergeWithDefaults(
    AiProviderId providerId,
    List<AiModelDescriptor> remoteModels,
  ) {
    final merged = <String, AiModelDescriptor>{
      for (final model in defaultModelsForProvider(providerId))
        model.modelId: model,
    };
    for (final model in remoteModels) {
      merged[model.modelId] = model;
    }
    return merged.values.toList(growable: false)
      ..sort((left, right) => left.label.compareTo(right.label));
  }
}

class _GeminiProviderAdapter extends AiProviderAdapter {
  const _GeminiProviderAdapter(this._dio);

  final Dio _dio;

  @override
  AiProviderId get providerId => AiProviderId.gemini;

  @override
  Future<AiGenerationResponse> generate(
    AiGenerationRequest request, {
    CancelToken? cancelToken,
  }) async {
    final promptMessages = request.messages
        .where((message) => message.author != AiMessageAuthorType.system)
        .map(
          (message) => <String, dynamic>{
            'role': message.author == AiMessageAuthorType.assistant
                ? 'model'
                : 'user',
            'parts': <Map<String, String>>[
              <String, String>{'text': message.content},
            ],
          },
        )
        .toList(growable: false);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://generativelanguage.googleapis.com/v1beta/models/${request.modelId}:generateContent',
        queryParameters: <String, dynamic>{'key': request.apiKey},
        cancelToken: cancelToken,
        data: <String, dynamic>{
          'systemInstruction': <String, dynamic>{
            'parts': <Map<String, String>>[
              <String, String>{'text': request.systemPrompt},
            ],
          },
          'contents': promptMessages,
          'generationConfig': <String, dynamic>{
            'temperature': _temperatureForStyle(request.responseStyle),
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        },
      );

      final data = response.data ?? const <String, dynamic>{};
      final candidates = (data['candidates'] as List<dynamic>? ?? const []);
      if (candidates.isEmpty) {
        throw const AiProviderError(
          type: AiProviderErrorType.unknown,
          message: 'Gemini returned an empty response.',
          isRetryable: true,
        );
      }

      final firstCandidate = candidates.first as Map<dynamic, dynamic>;
      final content =
          firstCandidate['content'] as Map<dynamic, dynamic>? ??
          const <dynamic, dynamic>{};
      final parts = (content['parts'] as List<dynamic>? ?? const []);
      final buffer = StringBuffer();
      for (final part in parts) {
        if (part is Map && part['text'] != null) {
          buffer.writeln(part['text'].toString().trim());
        }
      }
      final text = buffer.toString().trim();
      if (text.isEmpty) {
        throw const AiProviderError(
          type: AiProviderErrorType.unknown,
          message: 'Gemini returned no text content.',
          isRetryable: true,
        );
      }

      return AiGenerationResponse(
        content: text,
        providerMetadata: <String, dynamic>{
          'usageMetadata': data['usageMetadata'],
        },
      );
    } on DioException catch (error) {
      throw _mapDioError(error, providerLabel: 'Gemini');
    }
  }
}

class _OpenAiCompatibleProviderAdapter extends AiProviderAdapter {
  const _OpenAiCompatibleProviderAdapter({
    required Dio dio,
    required this.providerId,
    required this.endpoint,
  }) : _dio = dio;

  final Dio _dio;
  @override
  final AiProviderId providerId;
  final String endpoint;

  @override
  Future<AiGenerationResponse> generate(
    AiGenerationRequest request, {
    CancelToken? cancelToken,
  }) async {
    final messages = <Map<String, dynamic>>[
      <String, dynamic>{'role': 'system', 'content': request.systemPrompt},
      ...request.messages
          .where((message) => message.author != AiMessageAuthorType.system)
          .map(
            (message) => <String, dynamic>{
              'role': message.author == AiMessageAuthorType.assistant
                  ? 'assistant'
                  : 'user',
              'content': message.content,
            },
          ),
    ];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        cancelToken: cancelToken,
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer ${request.apiKey}',
          },
        ),
        data: <String, dynamic>{
          'model': request.modelId,
          'messages': messages,
          'temperature': _temperatureForStyle(request.responseStyle),
        },
      );

      final data = response.data ?? const <String, dynamic>{};
      final choices = (data['choices'] as List<dynamic>? ?? const []);
      final firstChoice = choices.isNotEmpty
          ? choices.first as Map<dynamic, dynamic>
          : null;
      final message =
          firstChoice?['message'] as Map<dynamic, dynamic>? ??
          const <dynamic, dynamic>{};
      final content = message['content']?.toString().trim() ?? '';
      if (content.isEmpty) {
        throw AiProviderError(
          type: AiProviderErrorType.unknown,
          message: '${providerId.name} returned no text content.',
          isRetryable: true,
        );
      }

      return AiGenerationResponse(
        content: content,
        providerMetadata: <String, dynamic>{'usage': data['usage']},
      );
    } on DioException catch (error) {
      throw _mapDioError(error, providerLabel: _providerLabel(providerId));
    }
  }
}

class _OpenRouterProviderAdapter extends AiProviderAdapter {
  const _OpenRouterProviderAdapter(this._dio);

  final Dio _dio;

  @override
  AiProviderId get providerId => AiProviderId.openRouter;

  @override
  Future<AiGenerationResponse> generate(
    AiGenerationRequest request, {
    CancelToken? cancelToken,
  }) {
    return _OpenAiCompatibleProviderAdapter(
      dio: _dio,
      providerId: providerId,
      endpoint: 'https://openrouter.ai/api/v1/chat/completions',
    ).generate(request, cancelToken: cancelToken);
  }

  @override
  Future<List<AiModelDescriptor>> listModels(String apiKey) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://openrouter.ai/api/v1/models',
        options: Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $apiKey'},
        ),
      );
      final data = response.data ?? const <String, dynamic>{};
      final models = (data['data'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .where((item) {
            final id = item['id']?.toString() ?? '';
            return id.endsWith(':free') || id == 'openrouter/free';
          })
          .map(
            (item) => AiModelDescriptor(
              providerId: providerId,
              modelId: item['id']?.toString() ?? '',
              label: item['name']?.toString() ?? item['id']?.toString() ?? '',
              isFreeTier: true,
              status: 'dynamic',
              capabilities: AiProviderCapabilities(
                supportsVision: jsonEncode(
                  item,
                ).toLowerCase().contains('vision'),
                supportsReasoning: jsonEncode(
                  item,
                ).toLowerCase().contains('reason'),
                dynamicCatalog: true,
              ),
              description: item['description']?.toString(),
            ),
          )
          .where((model) => model.modelId.trim().isNotEmpty)
          .toList(growable: false);

      return models;
    } on DioException catch (error) {
      throw _mapDioError(error, providerLabel: 'OpenRouter');
    }
  }
}

double _temperatureForStyle(AiResponseStyle style) {
  switch (style) {
    case AiResponseStyle.concise:
      return 0.35;
    case AiResponseStyle.balanced:
      return 0.6;
    case AiResponseStyle.detailed:
      return 0.8;
  }
}

AiProviderError _mapDioError(
  DioException error, {
  required String providerLabel,
}) {
  if (CancelToken.isCancel(error)) {
    return const AiProviderError(
      type: AiProviderErrorType.cancelled,
      message: 'Request cancelled.',
    );
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return AiProviderError(
        type: AiProviderErrorType.timeout,
        message: '$providerLabel took too long to respond.',
        isRetryable: true,
      );
    case DioExceptionType.connectionError:
      final message = error.message?.toLowerCase() ?? '';
      if (message.contains('certificate') || message.contains('ssl')) {
        return AiProviderError(
          type: AiProviderErrorType.ssl,
          message: 'Secure connection to $providerLabel failed.',
          isRetryable: true,
        );
      }
      return AiProviderError(
        type: AiProviderErrorType.network,
        message: 'No internet connection or network error.',
        isRetryable: true,
      );
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return AiProviderError(
          type: AiProviderErrorType.invalidCredentials,
          message: '$providerLabel rejected the API key.',
          statusCode: statusCode,
        );
      }
      if (statusCode == 404) {
        return AiProviderError(
          type: AiProviderErrorType.unsupportedModel,
          message: 'The selected model is not available on $providerLabel.',
          statusCode: statusCode,
        );
      }
      if (statusCode == 429) {
        final responseText = _responseText(error.response?.data).toLowerCase();
        final isQuota =
            responseText.contains('quota') ||
            responseText.contains('limit exceeded') ||
            responseText.contains('insufficient_quota');
        return AiProviderError(
          type: isQuota
              ? AiProviderErrorType.quotaExceeded
              : AiProviderErrorType.rateLimited,
          message: isQuota
              ? '$providerLabel quota or free-tier allowance has been reached.'
              : '$providerLabel is rate limiting requests right now.',
          statusCode: statusCode,
          isRetryable: true,
        );
      }
      if ((statusCode ?? 0) >= 500) {
        return AiProviderError(
          type: AiProviderErrorType.server,
          message: '$providerLabel is temporarily unavailable.',
          statusCode: statusCode,
          isRetryable: true,
        );
      }
      return AiProviderError(
        type: AiProviderErrorType.unknown,
        message: '$providerLabel returned an unexpected response.',
        statusCode: statusCode,
        isRetryable: true,
      );
    case DioExceptionType.cancel:
      return const AiProviderError(
        type: AiProviderErrorType.cancelled,
        message: 'Request cancelled.',
      );
    case DioExceptionType.badCertificate:
      return AiProviderError(
        type: AiProviderErrorType.ssl,
        message: 'Secure connection to $providerLabel failed.',
        isRetryable: true,
      );
    case DioExceptionType.unknown:
      return AiProviderError(
        type: AiProviderErrorType.network,
        message: 'Could not reach $providerLabel.',
        isRetryable: true,
      );
  }
}

String _providerLabel(AiProviderId providerId) {
  switch (providerId) {
    case AiProviderId.gemini:
      return 'Gemini';
    case AiProviderId.groq:
      return 'Groq';
    case AiProviderId.openRouter:
      return 'OpenRouter';
  }
}

String _responseText(dynamic responseData) {
  if (responseData == null) {
    return '';
  }
  if (responseData is String) {
    return responseData;
  }
  try {
    return jsonEncode(responseData);
  } catch (_) {
    return responseData.toString();
  }
}
