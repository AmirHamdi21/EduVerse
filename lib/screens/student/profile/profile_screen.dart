import 'package:flutter/material.dart';

import '../../shared/profile/role_profile_theme.dart';
import '../../shared/profile/shared_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedProfileScreen(
      editRoute: '/edit-profile',
      roleFallbackLabel: 'Student',
      title: 'Student Profile',
      theme: RoleProfileTheme.student(),
    );
  }
}
