import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';

class QuestionBulkValidationPanel extends StatelessWidget {
  const QuestionBulkValidationPanel({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: InstructorColors.error.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: InstructorColors.error.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: InstructorColors.error.withValues(
                alpha: isDark ? 0.22 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: InstructorColors.error,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
