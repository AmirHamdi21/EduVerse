import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../bloc/notifications/notification_cubit.dart';
import '../../models/auth_models.dart';
import '../../models/notifications/notification_model.dart';
import '../../services/api/notification_api_service.dart';
import 'android_notification_permission_coordinator.dart';
import 'eduverse_local_notification_service.dart';
import 'notification_payload_mapper.dart';

typedef NotificationTapHandler =
    Future<void> Function(NotificationModel notification);

class AndroidPushNotificationCoordinator {
  AndroidPushNotificationCoordinator({
    required NotificationApiService notificationApiService,
    required NotificationCubit notificationCubit,
    AndroidNotificationPermissionCoordinator? permissionCoordinator,
  }) : _notificationApiService = notificationApiService,
       _notificationCubit = notificationCubit,
       _permissionCoordinator =
           permissionCoordinator ??
           const AndroidNotificationPermissionCoordinator();

  static const String _deviceIdKey = 'eduverse_android_push_device_id';
  static const String _registeredTokenKey =
      'eduverse_android_push_registered_token';

  final NotificationApiService _notificationApiService;
  final NotificationCubit _notificationCubit;
  final AndroidNotificationPermissionCoordinator _permissionCoordinator;

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<String>? _localTapSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  NotificationTapHandler? _onNotificationTap;
  UserDto? _currentUser;
  Locale? _currentLocale;
  NotificationModel? _pendingTapNotification;
  bool _initialized = false;

  Future<void> initialize({
    required NotificationTapHandler onNotificationTap,
  }) async {
    if (!Platform.isAndroid || _initialized) {
      _onNotificationTap = onNotificationTap;
      return;
    }

    _onNotificationTap = onNotificationTap;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    final launchPayload = await EduVerseLocalNotificationService.initialize();
    _localTapSubscription = EduVerseLocalNotificationService.notificationTaps
        .listen(_handleLocalNotificationTap);

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundRemoteMessage,
    );
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessageTap,
    );
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen(_handleTokenRefresh);

    final initialRemoteMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialRemoteMessage != null) {
      _pendingTapNotification = NotificationPayloadMapper.fromRemoteMessage(
        initialRemoteMessage,
      );
    }

    final launchedNotification = NotificationPayloadMapper.fromPayload(
      launchPayload,
    );
    if (launchedNotification != null) {
      _pendingTapNotification = launchedNotification;
    }

    _initialized = true;
  }

  Future<void> startForUser(UserDto user, Locale locale) async {
    if (!Platform.isAndroid) {
      return;
    }

    _currentUser = user;
    _currentLocale = locale;
    await _permissionCoordinator.request();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.trim().isNotEmpty) {
      await _registerToken(token, locale);
    }

    final pendingTap = _pendingTapNotification;
    if (pendingTap != null) {
      _pendingTapNotification = null;
      await _openNotification(pendingTap);
    }
  }

  Future<void> unregisterCurrentToken() async {
    if (!Platform.isAndroid) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(_registeredTokenKey) ??
        await FirebaseMessaging.instance.getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    await _notificationApiService.unregisterDeviceToken(token);
    await prefs.remove(_registeredTokenKey);
  }

  Future<void> dispose() async {
    await _foregroundMessageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
    await _localTapSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
  }

  Future<void> _handleForegroundRemoteMessage(RemoteMessage message) async {
    final notification = NotificationPayloadMapper.fromRemoteMessage(message);
    if (notification == null) {
      return;
    }

    _notificationCubit.ingestExternalNotification(notification);
  }

  Future<void> _handleRemoteMessageTap(RemoteMessage message) async {
    final notification = NotificationPayloadMapper.fromRemoteMessage(message);
    if (notification == null) {
      return;
    }
    await _openNotification(notification);
  }

  Future<void> _handleLocalNotificationTap(String payload) async {
    final notification = NotificationPayloadMapper.fromPayload(payload);
    if (notification == null) {
      return;
    }
    await _openNotification(notification);
  }

  Future<void> _handleTokenRefresh(String token) async {
    if (_currentUser == null || token.trim().isEmpty) {
      return;
    }
    await _registerToken(token, _currentLocale);
  }

  Future<void> _registerToken(String token, Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await _resolveDeviceId(prefs);
    final result = await _notificationApiService.registerDeviceToken(
      token: token,
      deviceId: deviceId,
      deviceName: _deviceName(),
      locale: locale?.toLanguageTag(),
    );

    if (result.isSuccess) {
      await prefs.setString(_registeredTokenKey, token);
    }
  }

  Future<String> _resolveDeviceId(SharedPreferences prefs) async {
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final created = const Uuid().v4();
    await prefs.setString(_deviceIdKey, created);
    return created;
  }

  String _deviceName() {
    final raw = Platform.operatingSystemVersion.trim();
    if (raw.isEmpty) {
      return 'Android device';
    }
    return raw.length > 255 ? raw.substring(0, 255) : raw;
  }

  Future<void> _openNotification(NotificationModel notification) async {
    if (_currentUser == null || _onNotificationTap == null) {
      _pendingTapNotification = notification;
      return;
    }
    _notificationCubit.ingestExternalNotification(notification, surface: false);
    await _onNotificationTap!(notification);
  }
}
