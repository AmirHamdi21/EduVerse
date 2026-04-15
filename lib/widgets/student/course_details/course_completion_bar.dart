import 'package:flutter/material.dart';

class CourseCompletionBar extends StatelessWidget {
  final double progress;
  final bool isDark;

  const CourseCompletionBar({
    super.key,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF364153);
    final backgroundColor = isDark
        ? const Color(0xFF3D3D54)
        : const Color(0xFFE5E7EB);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Completion',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Color(0xFF155DFC),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: backgroundColor,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2B7FFF)),
          ),
        ),
      ],
    );
  }
}
