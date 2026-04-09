import 'dart:async';

import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../bloc/chat/chat_models.dart';
import '../api_service.dart';
import '../storage_service.dart';

enum ChatConnectionStatus { connected, disconnected, reconnecting }

abstract class IChatSocketService {
  Stream<ChatConnectionStatus> get connectionStatus;

  Stream<ChatMessageModel> get newMessageStream;

  Stream<Set<int>> get onlineUsersListStream;

  Stream<ChatMessageModel> get newMessageNotificationStream;

  Stream<UserTypingEvent> get typingStream;

  Stream<int> get messageDeletedStream;

  Stream<ChatMessageModel> get messageEditedStream;

  Stream<Map<String, dynamic>> get userStatusStream;

  Stream<int> get deleteConfirmedStream;

  Stream<MessageReadEvent> get messageReadStream;

  void connect(String jwtToken);

  void requestOnlineUsers();

  void disconnect();

  void joinConversation(int conversationId);

  void leaveConversation(int conversationId);

  void sendMessage(
    int conversationId,
    String text, {
    int? fileId,
    int? replyToId,
  });

  void emitTyping(int conversationId, bool isTyping);

  void markRead(int conversationId);

  void editMessage(int messageId, String text);

  void deleteMessage(int messageId, {bool forEveryone = false});
}

abstract class ChatSocketClient {
  bool get connected;

  void connect();

  void disconnect();

  void dispose();

  void emit(String event, dynamic data);

  void on(String event, void Function(dynamic data) handler);

  void onConnect(void Function(dynamic data) handler);

  void onDisconnect(void Function(dynamic data) handler);

  void onConnectError(void Function(dynamic data) handler);

  void off(String event);
}

typedef SocketClientFactory =
    ChatSocketClient Function({
      required String url,
      required String token,
      required int reconnectionAttempts,
      required int reconnectionDelayMs,
    });

class SocketIoChatSocketClient implements ChatSocketClient {
  final io.Socket _socket;

  SocketIoChatSocketClient({
    required String url,
    required String token,
    required int reconnectionAttempts,
    required int reconnectionDelayMs,
  }) : _socket = io.io(
         url,
         io.OptionBuilder()
             .setTransports(['websocket', 'polling'])
             .disableAutoConnect()
             .setReconnectionAttempts(reconnectionAttempts)
             .setReconnectionDelay(reconnectionDelayMs)
             .setAuth({'token': token})
             .setQuery({'token': token})
             .build(),
       );

  @override
  bool get connected => _socket.connected;

  @override
  void connect() => _socket.connect();

  @override
  void disconnect() => _socket.disconnect();

  @override
  void dispose() => _socket.dispose();

  @override
  void emit(String event, dynamic data) => _socket.emit(event, data);

  @override
  void on(String event, void Function(dynamic data) handler) {
    _socket.on(event, handler);
  }

  @override
  void onConnect(void Function(dynamic data) handler) {
    _socket.onConnect(handler);
  }

  @override
  void onDisconnect(void Function(dynamic data) handler) {
    _socket.onDisconnect(handler);
  }

  @override
  void onConnectError(void Function(dynamic data) handler) {
    _socket.onConnectError(handler);
  }

  @override
  void off(String event) => _socket.off(event);
}

class ChatSocketService implements IChatSocketService {
  static ChatSocketService? _instance;

  final StorageService _storageService;
  final SocketClientFactory _socketClientFactory;

  ChatSocketClient? _socket;
  bool _isRefreshingToken = false;

  final StreamController<ChatConnectionStatus> _connectionStatusController =
      StreamController<ChatConnectionStatus>.broadcast();
  final StreamController<ChatMessageModel> _newMessageController =
      StreamController<ChatMessageModel>.broadcast();
  final StreamController<Set<int>> _onlineUsersListController =
      StreamController<Set<int>>.broadcast();
  final StreamController<ChatMessageModel> _newMessageNotificationController =
      StreamController<ChatMessageModel>.broadcast();
  final StreamController<UserTypingEvent> _typingController =
      StreamController<UserTypingEvent>.broadcast();
  final StreamController<int> _messageDeletedController =
      StreamController<int>.broadcast();
  final StreamController<ChatMessageModel> _messageEditedController =
      StreamController<ChatMessageModel>.broadcast();
  final StreamController<Map<String, dynamic>> _userStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<int> _deleteConfirmedController =
      StreamController<int>.broadcast();
  final StreamController<MessageReadEvent> _messageReadController =
      StreamController<MessageReadEvent>.broadcast();

  ChatConnectionStatus _currentStatus = ChatConnectionStatus.disconnected;

  factory ChatSocketService({
    StorageService? storageService,
    SocketClientFactory? socketClientFactory,
  }) {
    _instance ??= ChatSocketService._internal(
      storageService: storageService ?? StorageService(),
      socketClientFactory: socketClientFactory ?? _defaultSocketClientFactory,
    );

    return _instance!;
  }

  ChatSocketService._internal({
    required StorageService storageService,
    required SocketClientFactory socketClientFactory,
  }) : _storageService = storageService,
       _socketClientFactory = socketClientFactory;

  static ChatSocketClient _defaultSocketClientFactory({
    required String url,
    required String token,
    required int reconnectionAttempts,
    required int reconnectionDelayMs,
  }) {
    return SocketIoChatSocketClient(
      url: url,
      token: token,
      reconnectionAttempts: reconnectionAttempts,
      reconnectionDelayMs: reconnectionDelayMs,
    );
  }

  static void resetInstanceForTest() {
    _instance?._disposeInternal();
    _instance = null;
  }

  @override
  Stream<ChatConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  @override
  Stream<ChatMessageModel> get newMessageStream => _newMessageController.stream;

  @override
  Stream<Set<int>> get onlineUsersListStream =>
      _onlineUsersListController.stream;

  @override
  Stream<ChatMessageModel> get newMessageNotificationStream =>
      _newMessageNotificationController.stream;

  @override
  Stream<UserTypingEvent> get typingStream => _typingController.stream;

  @override
  Stream<int> get messageDeletedStream => _messageDeletedController.stream;

  @override
  Stream<ChatMessageModel> get messageEditedStream =>
      _messageEditedController.stream;

  @override
  Stream<Map<String, dynamic>> get userStatusStream =>
      _userStatusController.stream;

  @override
  Stream<int> get deleteConfirmedStream => _deleteConfirmedController.stream;

  @override
  Stream<MessageReadEvent> get messageReadStream =>
      _messageReadController.stream;

  @override
  void connect(String jwtToken) {
    unawaited(_connectInternal(jwtToken));
  }

  Future<void> _connectInternal(String jwtToken) async {
    final providedToken = jwtToken.trim();
    final token = providedToken.isNotEmpty
        ? providedToken
        : (await _storageService.getAccessToken() ?? '');

    if (token.isEmpty) {
      _setConnectionStatus(ChatConnectionStatus.disconnected);
      return;
    }

    if (_socket != null && _socket!.connected) {
      return;
    }

    _setConnectionStatus(ChatConnectionStatus.reconnecting);

    _socket?.dispose();
    _socket = _socketClientFactory(
      url: _buildSocketUrl(),
      token: token,
      reconnectionAttempts: 5,
      reconnectionDelayMs: 1200,
    );

    _registerCoreListeners(_socket!);
    _registerChatListeners(_socket!);

    _socket!.connect();
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _setConnectionStatus(ChatConnectionStatus.disconnected);
  }

  @override
  void requestOnlineUsers() {
    _emit('get_online_users', <String, dynamic>{});
  }

  @override
  void joinConversation(int conversationId) {
    _emit('join_conversation', {'conversationId': conversationId});
  }

  @override
  void leaveConversation(int conversationId) {
    _emit('leave_conversation', {'conversationId': conversationId});
  }

  @override
  void sendMessage(
    int conversationId,
    String text, {
    int? fileId,
    int? replyToId,
  }) {
    _emit('send_message', {
      'conversationId': conversationId,
      'text': text,
      'fileId': fileId,
      'replyToId': replyToId,
    });
  }

  @override
  void emitTyping(int conversationId, bool isTyping) {
    _emit('typing', {'conversationId': conversationId, 'isTyping': isTyping});
  }

  @override
  void markRead(int conversationId) {
    _emit('mark_read', {'conversationId': conversationId});
  }

  @override
  void editMessage(int messageId, String text) {
    _emit('edit_message', {'messageId': messageId, 'text': text});
  }

  @override
  void deleteMessage(int messageId, {bool forEveryone = false}) {
    _emit('delete_message', {
      'messageId': messageId,
      'forEveryone': forEveryone,
    });
  }

  void _registerCoreListeners(ChatSocketClient socket) {
    socket.onConnect((_) {
      _setConnectionStatus(ChatConnectionStatus.connected);
      requestOnlineUsers();
    });

    socket.onDisconnect((_) {
      _setConnectionStatus(ChatConnectionStatus.disconnected);
    });

    socket.onConnectError((error) {
      _setConnectionStatus(ChatConnectionStatus.reconnecting);
      _handleConnectError(error);
    });

    socket.on('connect_error', (error) {
      _setConnectionStatus(ChatConnectionStatus.reconnecting);
      _handleConnectError(error);
    });
  }

  void _registerChatListeners(ChatSocketClient socket) {
    socket.on('new_message', (data) {
      final messageMap = _unwrapPayload(data);
      if (messageMap.isNotEmpty) {
        _newMessageController.add(ChatMessageModel.fromJson(messageMap));
      }
    });

    socket.on('message_sent', (data) {
      final messageMap = _unwrapPayload(data);
      if (messageMap.isNotEmpty) {
        _newMessageController.add(ChatMessageModel.fromJson(messageMap));
      }
    });

    socket.on('new_message_notification', (data) {
      final map = _asMap(data);
      final messageMap = _asMap(map['message']);
      final normalized = messageMap.isNotEmpty
          ? messageMap
          : _unwrapPayload(data);
      if (normalized.isNotEmpty) {
        _newMessageNotificationController.add(
          ChatMessageModel.fromJson(normalized),
        );
      }
    });

    socket.on('user_typing', (data) {
      final map = _unwrapPayload(data);
      if (map.isNotEmpty) {
        _typingController.add(UserTypingEvent.fromJson(map));
      }
    });

    socket.on('message_deleted', (data) {
      final messageId = _extractMessageId(data);
      if (messageId > 0) {
        _messageDeletedController.add(messageId);
      }
    });

    socket.on('delete_confirmed', (data) {
      final messageId = _extractMessageId(data);
      if (messageId > 0) {
        _deleteConfirmedController.add(messageId);
      }
    });

    socket.on('message_edited', (data) {
      final map = _unwrapPayload(data);
      if (map.isNotEmpty) {
        _messageEditedController.add(ChatMessageModel.fromJson(map));
      }
    });

    socket.on('user_status', (data) {
      final map = _unwrapPayload(data);
      if (map.isNotEmpty) {
        _userStatusController.add(map);
      }
    });

    socket.on('online_users_list', (data) {
      final normalized = _extractOnlineUsers(data);
      _onlineUsersListController.add(normalized);
    });

    socket.on('message_read', (data) {
      final map = _unwrapPayload(data);
      if (map.isNotEmpty) {
        _messageReadController.add(MessageReadEvent.fromJson(map));
      }
    });
  }

  void _setConnectionStatus(ChatConnectionStatus status) {
    if (_currentStatus == status) {
      return;
    }
    _currentStatus = status;
    _connectionStatusController.add(status);
  }

  void _emit(String event, Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null) {
      return;
    }
    socket.emit(event, payload);
  }

  String _buildSocketUrl() {
    final apiBaseUrl = ApiService.baseUrl;
    final baseWithoutApi = apiBaseUrl.endsWith('/api')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 4)
        : apiBaseUrl;
    return '$baseWithoutApi/messaging';
  }

  void _handleConnectError(dynamic error) {
    final message = error?.toString().toLowerCase() ?? '';

    if (message.contains('token') ||
        message.contains('unauthorized') ||
        message.contains('jwt')) {
      unawaited(_refreshTokenAndReconnect());
    }
  }

  Future<void> _refreshTokenAndReconnect() async {
    if (_isRefreshingToken) {
      return;
    }

    _isRefreshingToken = true;

    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        disconnect();
        return;
      }

      final refreshClient = Dio(
        BaseOptions(
          baseUrl: ApiService.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshClient.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final data = _asMap(response.data);
      final accessToken = data['accessToken']?.toString();
      final nextRefreshToken = data['refreshToken']?.toString() ?? refreshToken;

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      await _storageService.saveTokens(accessToken, nextRefreshToken);
      disconnect();
      connect(accessToken);
    } catch (_) {
      // Ignore and keep socket in reconnecting/disconnected state.
    } finally {
      _isRefreshingToken = false;
    }
  }

  int _extractMessageId(dynamic payload) {
    final map = _unwrapPayload(payload);
    return _parseInt(map['messageId'] ?? map['id']);
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

  Set<int> _extractOnlineUsers(dynamic payload) {
    dynamic data = payload;
    final payloadMap = _asMap(payload);
    if (payloadMap['data'] is List) {
      data = payloadMap['data'];
    } else if (payloadMap['onlineUsers'] is List) {
      data = payloadMap['onlineUsers'];
    } else if (payloadMap['users'] is List) {
      data = payloadMap['users'];
    }

    if (data is! List) {
      return <int>{};
    }

    final ids = <int>{};
    for (final entry in data) {
      if (entry is Map || entry is Map<String, dynamic>) {
        final map = _asMap(entry);
        final id = _parseInt(map['userId'] ?? map['id']);
        if (id > 0) {
          ids.add(id);
        }
      } else {
        final id = _parseInt(entry);
        if (id > 0) {
          ids.add(id);
        }
      }
    }

    return ids;
  }

  Map<String, dynamic> _unwrapPayload(dynamic payload) {
    final map = _asMap(payload);
    if (map['data'] is Map) {
      return _asMap(map['data']);
    }
    return map;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    return const {};
  }

  void _disposeInternal() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    _connectionStatusController.close();
    _newMessageController.close();
    _onlineUsersListController.close();
    _newMessageNotificationController.close();
    _typingController.close();
    _messageDeletedController.close();
    _messageEditedController.close();
    _userStatusController.close();
    _deleteConfirmedController.close();
    _messageReadController.close();
  }
}
