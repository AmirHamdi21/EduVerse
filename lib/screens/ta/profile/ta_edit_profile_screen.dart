import 'package:flutter/material.dart';

import '../../shared/profile/role_profile_theme.dart';
import '../../shared/profile/shared_edit_profile_screen.dart';

class TAEditProfileScreen extends StatelessWidget {
  const TAEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedEditProfileScreen(
      title: 'Edit Teaching Assistant Profile',
      roleLabel: 'Teaching Assistant',
      theme: RoleProfileTheme.ta(),
    );
  }
}
