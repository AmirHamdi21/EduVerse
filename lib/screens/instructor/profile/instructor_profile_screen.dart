import 'package:flutter/material.dart';

import '../../shared/profile/shared_profile_screen.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedProfileScreen(
      editRoute: '/instructor/edit-profile',
      roleFallbackLabel: 'Instructor',
      title: 'Instructor Profile',
    );
  }
}
