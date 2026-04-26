import 'package:flutter/material.dart';

import '../../shared/profile/shared_profile_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedProfileScreen(
      editRoute: '/admin/edit-profile',
      roleFallbackLabel: 'Administrator',
      title: 'Admin Profile',
    );
  }
}
