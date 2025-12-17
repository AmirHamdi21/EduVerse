import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';

class QuizProgressBar extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final bool isDark;

  const QuizProgressBar({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final progress = currentQuestion / totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $currentQuestion',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF155DFC),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p8),
        ClipRRect(
          borderRadius: BorderRadius.circular(responsive.radius24),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: responsive.p8,
            backgroundColor: isDark
                ? const Color(0xFF3A4456)
                : const Color(0xFFECECF0),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF155DFC),
            ),
          ),
        ),
      ],
    );
  }
}
