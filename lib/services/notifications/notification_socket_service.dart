import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../models/notifications/api_notification_model.dart';
import '../../models/notifications/notification_model.dart';
import '../api_service.dart';
import '../storage_service.dart';

class NotificationSocketService {
  NotificationSocketService({StorageService? storageService})
    : _storageService = storageService ?? StorageService();

  final StorageService _storageService;
  io.Socket? _socket;

  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<NotificationModel> get notifications => _notificationController.stream;
  Stream<int> get unreadCounts => _unreadCountController.stream;
  Stream<bool> get connectionChanges => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected == true) {
      return;
    }

    final token = await _storageService.getAccessToken();
    final user = await _storageService.getUserData();
    final userId = user?.userId;
    if (token == null || token.isEmpty || userId == null || userId <= 0) {
      return;
    }

    final origin = _resolveServerOrigin(ApiService.baseUrl);
    final socket = io.io(
      '$origin/notifications',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .setQuery({'userId': userId.toString()})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1200)
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) => _connectionController.add(true));
    socket.onDisconnect((_) => _connectionController.add(false));
    socket.onConnectError((_) => _connectionController.add(false));
    socket.on('newNotification', _handleNewNotification);
    socket.on('unreadCountUpdate', _handleUnreadCountUpdate);
    socket.connect();
    _socket = socket;
  }

  void _handleNewNotification(dynamic payload) {
    if (payload is! Map) return;
    final model = ApiNotificationModel.fromJson(
      Map<String, dynamic>.from(payload),
    ).toNotificationModel();
    _notificationController.add(model);
  }

  void _handleUnreadCountUpdate(dynamic payload) {
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final value = map['unreadCount'] ?? map['count'];
      final count = _parseInt(value) ?? 0;
      _unreadCountController.add(count);
    }
  }

  Future<void> disconnect() async {
    _socket?.off('newNotification', _handleNewNotification);
    _socket?.off('unreadCountUpdate', _handleUnreadCountUpdate);
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionController.add(false);
  }

  Future<void> dispose() async {
    await disconnect();
    await _notificationController.close();
    await _unreadCountController.close();
    await _connectionController.close();
  }
}

String _resolveServerOrigin(String baseUrl) {
  final lower = baseUrl.toLowerCase();
  if (lower.endsWith('/api')) {
    return baseUrl.substring(0, baseUrl.length - 4);
  }
  if (lower.endsWith('/api/')) {
    return baseUrl.substring(0, baseUrl.length - 5);
  }
  return baseUrl;
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
