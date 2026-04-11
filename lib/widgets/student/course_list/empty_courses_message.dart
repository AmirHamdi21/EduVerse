import 'package:flutter/material.dart';

class EmptyCoursesMessage extends StatelessWidget {
  const EmptyCoursesMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No enrolled courses yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Your courses will appear here once enrollment is completed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
