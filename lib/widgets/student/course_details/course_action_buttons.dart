import 'package:flutter/material.dart';

class CourseActionButtons extends StatelessWidget {
  final bool isDark;
  final String primaryButtonLabel;
  final VoidCallback? onContinueLearning;
  final VoidCallback? onJoinChat;

  const CourseActionButtons({
    super.key,
    required this.isDark,
    required this.primaryButtonLabel,
    this.onContinueLearning,
    this.onJoinChat,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF155DFC);

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF155DFC).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onContinueLearning,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: Text(
                  primaryButtonLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: const Color(0xFF155DFC), width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onJoinChat,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: textColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Join Course Chat',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
