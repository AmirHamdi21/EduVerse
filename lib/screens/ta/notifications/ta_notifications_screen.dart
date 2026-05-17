import 'package:flutter/material.dart';

import '../../../screens/shared/notifications/shared_notifications_screen.dart';
import '../../../widgets/shared/notifications/shared_notification_role_theme.dart';

class TANotificationsScreen extends StatelessWidget {
  const TANotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedNotificationsScreen(role: SharedNotificationRole.ta);
  }
}
