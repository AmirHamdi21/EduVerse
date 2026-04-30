import 'package:flutter/material.dart';

import '../../shared/profile/role_profile_theme.dart';
import '../../shared/profile/shared_profile_screen.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedProfileScreen(
      editRoute: '/instructor/edit-profile',
      roleFallbackLabel: 'Instructor',
      title: 'Instructor Profile',
      theme: RoleProfileTheme.instructor(),
    );
  }
}
