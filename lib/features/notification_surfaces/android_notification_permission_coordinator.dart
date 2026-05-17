import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'eduverse_local_notification_service.dart';

enum EduVerseNotificationPermissionStatus {
  unsupported,
  notDetermined,
  authorized,
  denied,
}

class EduVerseNotificationPermissionSnapshot {
  final EduVerseNotificationPermissionStatus status;

  const EduVerseNotificationPermissionSnapshot(this.status);

  bool get canShowSystemCards =>
      status == EduVerseNotificationPermissionStatus.authorized;

  bool get canRequest =>
      Platform.isAndroid &&
      status != EduVerseNotificationPermissionStatus.unsupported;
}

class AndroidNotificationPermissionCoordinator {
  const AndroidNotificationPermissionCoordinator();

  Future<EduVerseNotificationPermissionSnapshot> status() async {
    if (!Platform.isAndroid) {
      return const EduVerseNotificationPermissionSnapshot(
        EduVerseNotificationPermissionStatus.unsupported,
      );
    }

    final platformStatus = await Permission.notification.status;
    if (platformStatus.isGranted || platformStatus.isLimited) {
      return const EduVerseNotificationPermissionSnapshot(
        EduVerseNotificationPermissionStatus.authorized,
      );
    }
    if (platformStatus.isPermanentlyDenied || platformStatus.isRestricted) {
      return const EduVerseNotificationPermissionSnapshot(
        EduVerseNotificationPermissionStatus.denied,
      );
    }

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return EduVerseNotificationPermissionSnapshot(
      _mapFirebaseStatus(settings.authorizationStatus),
    );
  }

  Future<EduVerseNotificationPermissionSnapshot> request() async {
    if (!Platform.isAndroid) {
      return const EduVerseNotificationPermissionSnapshot(
        EduVerseNotificationPermissionStatus.unsupported,
      );
    }

    final platformStatus = await Permission.notification.request();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await EduVerseLocalNotificationService.requestAndroidPermission();
    if (platformStatus.isGranted || platformStatus.isLimited) {
      return const EduVerseNotificationPermissionSnapshot(
        EduVerseNotificationPermissionStatus.authorized,
      );
    }
    return status();
  }

  Future<bool> openSystemSettings() {
    return openAppSettings();
  }

  EduVerseNotificationPermissionStatus _mapFirebaseStatus(
    AuthorizationStatus status,
  ) {
    switch (status) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return EduVerseNotificationPermissionStatus.authorized;
      case AuthorizationStatus.denied:
        return EduVerseNotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return EduVerseNotificationPermissionStatus.notDetermined;
    }
  }
}
