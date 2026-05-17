import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../models/notifications/device_notification_preferences.dart';
import '../../models/notifications/notification_model.dart';
import 'notification_payload_mapper.dart';

@pragma('vm:entry-point')
Future<void> eduVerseFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    await EduVerseLocalNotificationService.ensureInitializedForBackground();
    await EduVerseLocalNotificationService.showRemoteMessage(message);
  } catch (_) {
    // Background isolates must never crash the process because of a display issue.
  }
}

@pragma('vm:entry-point')
void eduVerseLocalNotificationTapBackground(NotificationResponse response) {}

class EduVerseLocalNotificationService {
  EduVerseLocalNotificationService._();

  static const String channelId = 'eduverse_notifications_v2';
  static const String channelName = 'EduVerse updates';
  static const String channelDescription =
      'Course, message, assignment, and system updates from EduVerse.';
  static const String groupKey = 'com.eduverse.app.notifications';
  static const String notificationIcon = 'ic_stat_eduverse_notification';
  static const String largeNotificationIcon = 'ic_notification_large';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final StreamController<String> _tapController =
      StreamController<String>.broadcast();

  static bool _initialized = false;

  static Stream<String> get notificationTaps => _tapController.stream;

  static Future<String?> initialize() async {
    if (!Platform.isAndroid) {
      return null;
    }

    await _initialize(
      onTap: (response) {
        final payload = response.payload;
        if (payload != null && payload.trim().isNotEmpty) {
          _tapController.add(payload);
        }
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      return launchDetails?.notificationResponse?.payload;
    }
    return null;
  }

  static Future<void> ensureInitializedForBackground() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _initialize();
  }

  static Future<bool> requestAndroidPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  static Future<void> showRemoteMessage(RemoteMessage message) async {
    final notification = NotificationPayloadMapper.fromRemoteMessage(message);
    if (notification == null) {
      return;
    }
    await showNotification(notification);
  }

  static Future<void> showNotification(
    NotificationModel notification, {
    DeviceNotificationPreferences preferences =
        const DeviceNotificationPreferences(),
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    await ensureInitializedForBackground();

    final title = notification.title.trim().isEmpty
        ? 'EduVerse'
        : notification.title.trim();
    final body = preferences.showPreview ? notification.message.trim() : '';
    final payload = NotificationPayloadMapper.toPayload(notification);
    final priorityAccent = _accentFor(notification.type);

    await _plugin.show(
      id: _notificationId(notification.id),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          icon: notificationIcon,
          largeIcon: const DrawableResourceAndroidBitmap(largeNotificationIcon),
          color: priorityAccent,
          colorized: _shouldColorize(notification.priority),
          importance: _importanceFor(notification.priority),
          priority: _priorityFor(notification.priority),
          category: AndroidNotificationCategory.status,
          visibility: preferences.showPreview
              ? NotificationVisibility.public
              : NotificationVisibility.private,
          groupKey: groupKey,
          channelShowBadge: true,
          playSound: preferences.soundEnabled,
          enableVibration: preferences.vibrationEnabled,
          enableLights: true,
          ledColor: priorityAccent,
          ledOnMs: 900,
          ledOffMs: 1800,
          subText: 'EduVerse',
          ticker: title,
          styleInformation: body.isEmpty
              ? null
              : BigTextStyleInformation(
                  body,
                  contentTitle: title,
                  summaryText: 'EduVerse',
                ),
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> _initialize({
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    if (_initialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(notificationIcon),
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse:
          eduVerseLocalNotificationTapBackground,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        enableLights: true,
        ledColor: Color(0xFF0A84FF),
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    _initialized = true;
  }

  static int _notificationId(String id) {
    final parsed = int.tryParse(id);
    if (parsed != null && parsed > 0) {
      return parsed & 0x7fffffff;
    }
    return id.hashCode & 0x7fffffff;
  }

  static Importance _importanceFor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
      case NotificationPriority.high:
        return Importance.max;
      case NotificationPriority.low:
        return Importance.defaultImportance;
      case NotificationPriority.normal:
        return Importance.high;
    }
  }

  static Priority _priorityFor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.low:
        return Priority.defaultPriority;
      case NotificationPriority.normal:
        return Priority.high;
    }
  }

  static bool _shouldColorize(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
      case NotificationPriority.high:
        return true;
      case NotificationPriority.low:
      case NotificationPriority.normal:
        return false;
    }
  }

  static Color _accentFor(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
      case NotificationType.quiz:
      case NotificationType.lab:
        return const Color(0xFF0A84FF);
      case NotificationType.grade:
        return const Color(0xFF30D158);
      case NotificationType.message:
      case NotificationType.discussion:
      case NotificationType.community:
        return const Color(0xFFBF5AF2);
      case NotificationType.deadline:
      case NotificationType.schedule:
      case NotificationType.officeHours:
        return const Color(0xFFFF9F0A);
      case NotificationType.system:
      case NotificationType.announcement:
      case NotificationType.material:
      case NotificationType.enrollment:
      case NotificationType.unknown:
        return const Color(0xFF64D2FF);
    }
  }
}
