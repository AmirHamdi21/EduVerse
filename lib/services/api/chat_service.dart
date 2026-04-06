import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/chat/chat_models.dart';
import 'core_api_client.dart';

abstract class IChatService {
  Future<List<ConversationModel>> listConversations();

  Future<List<ChatMessageModel>> getConversationMessages(
    int conversationId, {
    int? page,
    int? limit,
  });

  Future<ChatMessageModel> sendMessage(
    int conversationId,
    String text, {
    int? fileId,
    int? replyToId,
  });

  Future<ConversationModel> startConversation({
    required List<int> participantIds,
    required String type,
    String? text,
    String? groupName,
    int? fileId,
  });

  Future<List<ChatUserModel>> searchUsers(String query, {int limit = 20});

  Future<void> markRead(int messageId);

  Future<ChatMessageModel> editMessage(int messageId, String text);

  Future<bool> deleteForMe(int messageId);

  Future<bool> deleteForEveryone(int messageId);
}

class ChatService implements IChatService {
  static const String retryQueueStorageKey = 'chat_service_retry_queue';

  final CoreApiClient _client;

  Timer? _retryTimer;
  bool _isProcessingQueue = false;

  ChatService({required CoreApiClient coreApiClient}) : _client = coreApiClient;

  @override
  Future<List<ConversationModel>> listConversations() async {
    final response = await _request(
      method: 'GET',
      path: '/messages/conversations',
    );

    final items = _extractList(response.data);
    return items.map(ConversationModel.fromJson).toList();
  }

  @override
  Future<List<ChatMessageModel>> getConversationMessages(
    int conversationId, {
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };

    final response = await _request(
      method: 'GET',
      path: '/messages/conversations/$conversationId',
      queryParameters: query.isEmpty ? null : query,
    );

    final messages = _extractMessageList(response.data);
    return messages.map(ChatMessageModel.fromJson).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(
    int conversationId,
    String text, {
    int? fileId,
    int? replyToId,
  }) async {
    final payload = <String, dynamic>{
      'text': text,
      if (fileId != null) 'fileId': fileId,
      if (replyToId != null) 'replyToId': replyToId,
    };

    final response = await _request(
      method: 'POST',
      path: '/messages/conversations/$conversationId',
      data: payload,
    );

    final messageMap = _extractChatMessageMap(response.data);
    return ChatMessageModel.fromJson(
      messageMap.isNotEmpty
          ? messageMap
          : {
              'id': 0,
              'conversationId': conversationId,
              'text': text,
              'senderId': 0,
              'sentAt': DateTime.now().toIso8601String(),
            },
    );
  }

  @override
  Future<ConversationModel> startConversation({
    required List<int> participantIds,
    required String type,
    String? text,
    String? groupName,
    int? fileId,
  }) async {
    final payload = <String, dynamic>{
      'participantIds': participantIds,
      'type': type,
      if (groupName != null) 'groupName': groupName,
      if (text != null) 'text': text,
      if (fileId != null) 'fileId': fileId,
    };

    final response = await _request(
      method: 'POST',
      path: '/messages/conversations',
      data: payload,
    );

    final conversationMap = _extractConversationMap(response.data);

    if (conversationMap.isNotEmpty) {
      final conversationId = _parseInt(
        conversationMap['conversationId'] ?? conversationMap['id'],
      );

      final normalizedMap = <String, dynamic>{
        ...conversationMap,
        'conversationId': conversationId,
        'type': conversationMap['type'] ?? type,
        'participants': conversationMap['participants'] ?? participantIds,
        'name': conversationMap['name'] ?? groupName,
      };

      return ConversationModel.fromJson(normalizedMap);
    }

    return ConversationModel(
      conversationId: 0,
      type: ConversationType.fromJsonValue(type),
      name: groupName,
      participants: participantIds,
      lastMessage: text,
      lastMessageAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<List<ChatUserModel>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    final response = await _request(
      method: 'GET',
      path: '/messages/users/search',
      queryParameters: {'query': query, 'limit': limit},
    );

    final users = _extractList(response.data);
    return users.map(ChatUserModel.fromJson).toList();
  }

  @override
  Future<void> markRead(int messageId) async {
    await _request(method: 'PATCH', path: '/messages/$messageId/read');
  }

  @override
  Future<ChatMessageModel> editMessage(int messageId, String text) async {
    final response = await _request(
      method: 'PATCH',
      path: '/messages/$messageId',
      data: {'text': text},
    );

    final messageMap = _extractChatMessageMap(response.data);
    return ChatMessageModel.fromJson(
      messageMap.isNotEmpty
          ? messageMap
          : {
              'id': messageId,
              'text': text,
              'senderId': 0,
              'conversationId': 0,
              'sentAt': DateTime.now().toIso8601String(),
            },
    );
  }

  @override
  Future<bool> deleteForMe(int messageId) async {
    final response = await _request(
      method: 'DELETE',
      path: '/messages/$messageId',
    );

    final statusCode = response.statusCode ?? 500;
    return statusCode >= 200 && statusCode < 300;
  }

  @override
  Future<bool> deleteForEveryone(int messageId) async {
    final response = await _request(
      method: 'DELETE',
      path: '/messages/$messageId/everyone',
    );

    final statusCode = response.statusCode ?? 500;
    return statusCode >= 200 && statusCode < 300;
  }

  Future<Response<dynamic>> _request({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool allowQueue = true,
  }) async {
    try {
      return await _client.dio.request(
        path,
        options: Options(method: method),
        queryParameters: queryParameters,
        data: data,
      );
    } on DioException catch (error) {
      if (allowQueue && _shouldQueueRequest(method, error)) {
        await _enqueueRetry(
          _RetryQueueEntry(
            method: method,
            path: path,
            data: data,
            queryParameters: queryParameters,
          ),
        );
        _scheduleQueueProcessing();
      }
      rethrow;
    }
  }

  bool _shouldQueueRequest(String method, DioException error) {
    final normalizedMethod = method.toUpperCase();
    if (normalizedMethod == 'GET') {
      return false;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 429) {
      return true;
    }

    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.unknown;
  }

  Future<void> _enqueueRetry(_RetryQueueEntry entry) async {
    final queue = await _readRetryQueue();
    queue.add(entry);
    await _saveRetryQueue(queue);
  }

  Future<List<_RetryQueueEntry>> _readRetryQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(retryQueueStorageKey);
    if (raw == null || raw.isEmpty) {
      return <_RetryQueueEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <_RetryQueueEntry>[];
      }
      return decoded
          .whereType<Map>()
          .map(
            (item) => _RetryQueueEntry.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <_RetryQueueEntry>[];
    }
  }

  Future<void> _saveRetryQueue(List<_RetryQueueEntry> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(queue.map((entry) => entry.toJson()).toList());
    await prefs.setString(retryQueueStorageKey, raw);
  }

  void _scheduleQueueProcessing() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 1), () {
      unawaited(_processRetryQueue());
    });
  }

  Future<void> _processRetryQueue() async {
    if (_isProcessingQueue) {
      return;
    }

    _isProcessingQueue = true;

    try {
      final queue = await _readRetryQueue();
      if (queue.isEmpty) {
        return;
      }

      while (queue.isNotEmpty) {
        final current = queue.first;

        try {
          await _request(
            method: current.method,
            path: current.path,
            queryParameters: current.queryParameters,
            data: current.data,
            allowQueue: false,
          );

          queue.removeAt(0);
          await _saveRetryQueue(queue);
        } on DioException catch (error) {
          if (!_shouldQueueRequest(current.method, error)) {
            queue.removeAt(0);
            await _saveRetryQueue(queue);
            continue;
          }

          final retryEntry = current.copyWith(attempt: current.attempt + 1);
          queue[0] = retryEntry;
          await _saveRetryQueue(queue);

          final delaySeconds = _backoffSeconds(retryEntry.attempt);
          _retryTimer?.cancel();
          _retryTimer = Timer(Duration(seconds: delaySeconds), () {
            unawaited(_processRetryQueue());
          });
          return;
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  int _backoffSeconds(int attempt) {
    if (attempt <= 0) {
      return 1;
    }
    var delay = 1;
    for (var index = 0; index < attempt; index++) {
      delay *= 2;
      if (delay >= 64) {
        return 64;
      }
    }
    return delay;
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is List) {
      return payload.map(_asMap).where((map) => map.isNotEmpty).toList();
    }

    final map = _asMap(payload);
    if (map['data'] is List) {
      return _extractList(map['data']);
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _extractMessageList(dynamic payload) {
    if (payload is List) {
      return _extractList(payload);
    }

    final root = _asMap(payload);

    if (root['messages'] is List || root['messages'] is Map) {
      final messages = root['messages'];
      if (messages is List) {
        return _extractList(messages);
      }
      final mapMessages = _asMap(messages);
      if (mapMessages['data'] is List) {
        return _extractList(mapMessages['data']);
      }
    }

    if (root['data'] is List) {
      return _extractList(root['data']);
    }

    if (root.isNotEmpty &&
        root['id'] != null &&
        root['conversationId'] != null) {
      return <Map<String, dynamic>>[root];
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractChatMessageMap(dynamic payload) {
    final root = _asMap(payload);

    if (root['data'] is Map) {
      final dataMap = _asMap(root['data']);
      if (dataMap.isNotEmpty) {
        return dataMap;
      }
    }

    if (root['message'] is Map) {
      final messageMap = _asMap(root['message']);
      if (messageMap.isNotEmpty) {
        return messageMap;
      }
    }

    return root;
  }

  Map<String, dynamic> _extractConversationMap(dynamic payload) {
    final root = _asMap(payload);
    if (root.isEmpty) {
      return const {};
    }

    if (root['data'] is Map) {
      final nested = _asMap(root['data']);
      if (nested.isNotEmpty) {
        return nested;
      }
    }

    return root;
  }

  Map<String, dynamic> _asMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }

    return const {};
  }

  int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }
}

class _RetryQueueEntry {
  final String method;
  final String path;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final int attempt;

  const _RetryQueueEntry({
    required this.method,
    required this.path,
    this.data,
    this.queryParameters,
    this.attempt = 0,
  });

  _RetryQueueEntry copyWith({
    String? method,
    String? path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    int? attempt,
  }) {
    return _RetryQueueEntry(
      method: method ?? this.method,
      path: path ?? this.path,
      data: data ?? this.data,
      queryParameters: queryParameters ?? this.queryParameters,
      attempt: attempt ?? this.attempt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'path': path,
      'data': data,
      'queryParameters': queryParameters,
      'attempt': attempt,
    };
  }

  factory _RetryQueueEntry.fromJson(Map<String, dynamic> json) {
    return _RetryQueueEntry(
      method: json['method']?.toString() ?? 'POST',
      path: json['path']?.toString() ?? '',
      data: json['data'],
      queryParameters: _asNullableMap(json['queryParameters']),
      attempt: json['attempt'] is int
          ? json['attempt'] as int
          : int.tryParse(json['attempt']?.toString() ?? '0') ?? 0,
    );
  }

  static Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}
