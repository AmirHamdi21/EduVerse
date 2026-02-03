import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/models/quiz_models.dart';

class QuizQuestionNavigator extends StatelessWidget {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final bool isDark;
  final Function(int) onQuestionSelected;

  const QuizQuestionNavigator({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.isDark,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF3A4456) 
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: Row(
              children: [
                Text(
                  'Question Navigator',
                  style: TextStyle(
                    fontSize: responsive.fontSize18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontFamily: 'Arimo',
                  ),
                ),
                const Spacer(),
                _buildLegend(responsive),
              ],
            ),
          ),
          
          // Divider
          Divider(
            color: isDark 
                ? const Color(0xFF2D2D44) 
                : const Color(0xFFF3F4F6),
            height: 1,
          ),
          
          // Question grid
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.p16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  questions.length,
                  (index) => _buildQuestionItem(
                    context,
                    index,
                    responsive,
                  ),
                ),
              ),
            ),
          ),
          
          // Summary
          _buildSummary(context, responsive),
        ],
      ),
    );
  }

  Widget _buildLegend(ResponsiveUtil responsive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(
          color: const Color(0xFF10B981),
          label: 'Answered',
          responsive: responsive,
        ),
        const SizedBox(width: 12),
        _buildLegendItem(
          color: const Color(0xFFF59E0B),
          label: 'Skipped',
          responsive: responsive,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required ResponsiveUtil responsive,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark 
                ? const Color(0xFF9CA3AF) 
                : const Color(0xFF6B7280),
            fontFamily: 'Arimo',
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(
    BuildContext context,
    int index,
    ResponsiveUtil responsive,
  ) {
    final question = questions[index];
    final isCurrent = index == currentIndex;
    final isAnswered = question.isAnswered;
    final isSkipped = question.isSkipped;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isCurrent) {
      bgColor = const Color(0xFF6366F1);
      borderColor = const Color(0xFF6366F1);
      textColor = Colors.white;
    } else if (isAnswered) {
      bgColor = const Color(0xFF10B981).withOpacity(0.15);
      borderColor = const Color(0xFF10B981);
      textColor = const Color(0xFF10B981);
    } else if (isSkipped) {
      bgColor = const Color(0xFFF59E0B).withOpacity(0.15);
      borderColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFF59E0B);
    } else {
      bgColor = isDark 
          ? const Color(0xFF2D2D44) 
          : const Color(0xFFF3F4F6);
      borderColor = isDark 
          ? const Color(0xFF3A4456) 
          : const Color(0xFFE5E7EB);
      textColor = isDark ? Colors.white : const Color(0xFF6B7280);
    }

    return GestureDetector(
      onTap: () {
        onQuestionSelected(index);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: responsive.fontSize14,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Arimo',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, ResponsiveUtil responsive) {
    final answered = questions.where((q) => q.isAnswered).length;
    final skipped = questions.where((q) => q.isSkipped).length;
    final remaining = questions.length - answered - skipped;

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF252D48) 
            : const Color(0xFFF9FAFB),
        border: Border(
          top: BorderSide(
            color: isDark 
                ? const Color(0xFF2D2D44) 
                : const Color(0xFFF3F4F6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              label: 'Answered',
              count: answered,
              color: const Color(0xFF10B981),
              responsive: responsive,
            ),
            _buildSummaryItem(
              label: 'Skipped',
              count: skipped,
              color: const Color(0xFFF59E0B),
              responsive: responsive,
            ),
            _buildSummaryItem(
              label: 'Remaining',
              count: remaining,
              color: isDark ? Colors.white : const Color(0xFF6B7280),
              responsive: responsive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required int count,
    required Color color,
    required ResponsiveUtil responsive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: responsive.fontSize20,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Arimo',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize12,
            color: isDark 
                ? const Color(0xFF9CA3AF) 
                : const Color(0xFF6B7280),
            fontFamily: 'Arimo',
          ),
        ),
      ],
    );
  }
}
