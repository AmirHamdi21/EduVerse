import 'package:flutter/material.dart';

class CourseDetailsHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final bool isDark;

  const CourseDetailsHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final bgColor = isDark ? const Color(0xFF2D2D44) : Colors.white;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: textColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }
}
