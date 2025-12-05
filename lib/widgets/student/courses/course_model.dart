import 'package:flutter/material.dart';

class CourseModel {
  final String title;
  final String instructor;
  final double progress;
  final String nextEvent;
  final String eventDate;
  final Color iconBackgroundColor;
  final IconData courseIcon;
  final String primaryButtonLabel;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;

  CourseModel({
    required this.title,
    required this.instructor,
    required this.progress,
    required this.nextEvent,
    required this.eventDate,
    required this.iconBackgroundColor,
    required this.courseIcon,
    this.primaryButtonLabel = 'Continue',
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
  });

  int get eventDateAsNumber {
    final monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final parts = eventDate.split(' ');
    if (parts.length == 2) {
      final month = monthMap[parts[0]] ?? 0;
      final day = int.tryParse(parts[1]) ?? 0;
      return month * 100 + day;
    }
    return 0;
  }
}
