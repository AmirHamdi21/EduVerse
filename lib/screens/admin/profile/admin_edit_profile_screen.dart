import 'package:flutter/material.dart';

import '../../shared/profile/role_profile_theme.dart';
import '../../shared/profile/shared_edit_profile_screen.dart';

class AdminEditProfileScreen extends StatelessWidget {
  const AdminEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedEditProfileScreen(
      title: 'Edit Admin Profile',
      roleLabel: 'Administrator',
      theme: RoleProfileTheme.admin(),
    );
  }
}
