import 'package:flutter/material.dart';

import '../../shared/profile/shared_profile_screen.dart';

class TAProfileScreen extends StatelessWidget {
  const TAProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedProfileScreen(
      editRoute: '/ta/edit-profile',
      roleFallbackLabel: 'Teaching Assistant',
      title: 'Teaching Assistant Profile',
    );
  }
}
