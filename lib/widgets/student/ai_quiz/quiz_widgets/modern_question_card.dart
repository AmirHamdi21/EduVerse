import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/models/quiz_models.dart';
import 'modern_mcq_options.dart';
import 'modern_true_false_options.dart';
import 'modern_short_answer_input.dart';

class ModernQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int questionNumber;
  final bool isDark;
  final Function(String) onAnswerSelected;
  final Function(List<String>) onMultipleAnswersSelected;

  const ModernQuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.isDark,
    required this.onAnswerSelected,
    required this.onMultipleAnswersSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252D48) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getBorderColor(),
          width: question.isSkipped || question.isAnswered ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(responsive),

          // Question text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.p20),
            child: _buildQuestionText(responsive),
          ),
          SizedBox(height: responsive.p20),

          // Options section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.p20),
            child: _buildOptionsSection(responsive),
          ),
          SizedBox(height: responsive.p20),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (question.isSkipped) {
      return const Color(0xFFF59E0B);
    } else if (question.isAnswered) {
      return const Color(0xFF10B981);
    }
    return Colors.transparent;
  }

  Widget _buildHeader(ResponsiveUtil responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        // color: isDark
        //     ? const Color(0xFF1E1E2D).withOpacity(0.5)
        //     : const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Question number badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Q$questionNumber',
              style: TextStyle(
                fontSize: responsive.fontSize14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Arimo',
              ),
            ),
          ),
          SizedBox(width: responsive.p12),

          // Question type badge
          _buildQuestionTypeBadge(responsive),
          const Spacer(),

          // Status badge
          if (question.isSkipped || question.isAnswered)
            _buildStatusBadge(responsive),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeBadge(ResponsiveUtil responsive) {
    IconData icon;
    String label;
    Color color;

    switch (question.type) {
      case QuizType.shortAnswer:
        icon = Icons.edit_note_rounded;
        label = 'Short Answer';
        color = const Color(0xFF8B5CF6);
        break;
      case QuizType.trueFalse:
        icon = Icons.swap_horiz_rounded;
        label = 'True / False';
        color = const Color(0xFF06B6D4);
        break;
      default:
        icon = Icons.list_alt_rounded;
        label = 'Multiple Choice';
        color = const Color(0xFF3B82F6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ResponsiveUtil responsive) {
    final isSkipped = question.isSkipped;
    final color = isSkipped ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final icon = isSkipped
        ? Icons.skip_next_rounded
        : Icons.check_circle_rounded;
    final label = isSkipped ? 'Skipped' : 'Answered';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionText(ResponsiveUtil responsive) {
    return Text(
      question.question,
      style: TextStyle(
        fontSize: responsive.fontSize18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        fontFamily: 'Arimo',
        height: 1.5,
      ),
    );
  }

  Widget _buildOptionsSection(ResponsiveUtil responsive) {
    switch (question.type) {
      case QuizType.shortAnswer:
        return ModernShortAnswerInput(
          question: question,
          isDark: isDark,
          onAnswerChanged: onAnswerSelected,
        );
      case QuizType.trueFalse:
        return ModernTrueFalseOptions(
          question: question,
          isDark: isDark,
          onAnswerSelected: onAnswerSelected,
        );
      default:
        return ModernMcqOptions(
          question: question,
          isDark: isDark,
          onAnswerSelected: onAnswerSelected,
        );
    }
  }
}
