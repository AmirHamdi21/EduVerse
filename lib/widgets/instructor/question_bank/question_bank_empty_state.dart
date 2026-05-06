import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';

class QuestionBankEmptyState extends StatelessWidget {
  const QuestionBankEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(
                  alpha: isDark ? 0.22 : 0.12,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 30,
                color: InstructorColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                height: 1.35,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
