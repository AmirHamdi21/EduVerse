import 'package:flutter/material.dart';

import '../../shared/profile/role_profile_theme.dart';
import '../../shared/profile/shared_edit_profile_screen.dart';

class InstructorEditProfileScreen extends StatelessWidget {
  const InstructorEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedEditProfileScreen(
      title: 'Edit Instructor Profile',
      roleLabel: 'Instructor',
      theme: RoleProfileTheme.instructor(),
      fallbackRoute: '/instructor/dashboard',
    );
  }
}
