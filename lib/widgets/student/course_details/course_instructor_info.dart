import 'package:flutter/material.dart';

class CourseInstructorInfo extends StatelessWidget {
  final String instructor;
  final String? instructorImage;
  final bool isDark;

  const CourseInstructorInfo({
    super.key,
    required this.instructor,
    this.instructorImage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4A5565);

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF155DFC).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF155DFC).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: instructorImage != null
              ? ClipOval(
                  child: Image.network(
                    instructorImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFF155DFC),
                ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instructor,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Instructor',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
