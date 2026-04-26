import 'package:flutter/material.dart';

import '../../shared/profile/shared_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedProfileScreen(
      editRoute: '/edit-profile',
      roleFallbackLabel: 'Student',
      title: 'Profile',
    );
  }
}
