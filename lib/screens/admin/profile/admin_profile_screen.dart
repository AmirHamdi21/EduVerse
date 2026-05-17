import 'package:flutter/material.dart';

import '../../shared/profile/role_profile_theme.dart';
import '../../shared/profile/shared_profile_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedProfileScreen(
      editRoute: '/admin/edit-profile',
      roleFallbackLabel: 'Administrator',
      title: 'Admin Profile',
      theme: RoleProfileTheme.admin(),
      fallbackRoute: '/admin/dashboard',
    );
  }
}
