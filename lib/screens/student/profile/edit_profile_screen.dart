import 'package:flutter/material.dart';

import '../../shared/profile/role_profile_theme.dart';
import '../../shared/profile/shared_edit_profile_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedEditProfileScreen(
      title: 'Edit Profile',
      roleLabel: 'Student',
      theme: RoleProfileTheme.student(),
      fallbackRoute: '/dashboard',
    );
  }
}
