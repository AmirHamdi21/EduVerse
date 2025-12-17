import 'package:flutter/material.dart';
import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/common/utils/responsive.dart';

class QuizQuestionReviewCard extends StatefulWidget {
  final QuizQuestion question;
  final int questionNumber;
  final bool isDark;

  const QuizQuestionReviewCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.isDark,
  });

  @override
  State<QuizQuestionReviewCard> createState() => _QuizQuestionReviewCardState();
}

class _QuizQuestionReviewCardState extends State<QuizQuestionReviewCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _optionsAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _optionsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(QuizQuestionReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No need to handle expansion state changes here
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  bool get isExpanded => _isExpanded;
  bool get isAnsweredCorrectly => widget.question.isCorrect;
  bool get isAnswered => widget.question.isAnswered;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final bgColor = widget.isDark ? const Color(0xFF252D48) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFFB0B3C1)
        : const Color(0xFF6A7282);
    final borderColor = widget.isDark
        ? const Color(0xFF3A4456)
        : const Color(0xFFD1D5DC);

    Color statusColor;
    String statusText;
    Color statusBgColor;

    if (!isAnswered) {
      statusColor = const Color(0xFFFFA500);
      statusText = 'Skipped';
      statusBgColor = const Color(0xFFFFF3E0);
    } else if (isAnsweredCorrectly) {
      statusColor = const Color(0xFF51C77A);
      statusText = 'Correct';
      statusBgColor = const Color(0xFFE8F5E9);
    } else {
      statusColor = const Color(0xFFFF6B6B);
      statusText = 'Incorrect';
      statusBgColor = const Color(0xFFFFEBEE);
    }

    return Container(
      margin: EdgeInsets.only(bottom: responsive.p16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(responsive.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleExpand,
            child: Padding(
              padding: EdgeInsets.all(responsive.p16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${widget.questionNumber}',
                          style: TextStyle(
                            fontSize: responsive.fontSize14,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: responsive.p8),
                        Text(
                          widget.question.question,
                          style: TextStyle(
                            fontSize: responsive.fontSize16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: responsive.p12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.p8,
                          vertical: responsive.p4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(
                            responsive.radius8,
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: responsive.fontSize12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.p8),
                      GestureDetector(
                        onTap: _toggleExpand,
                        child: Container(
                          width: responsive.p36,
                          height: responsive.p36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isDark
                                ? const Color(0xFF3A4456)
                                : const Color(0xFFF3F4F6),
                          ),
                          child: AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.expand_more,
                              color: textColor,
                              size: responsive.p20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: borderColor,
              indent: responsive.p16,
              endIndent: responsive.p16,
            ),
            Padding(
              padding: EdgeInsets.all(responsive.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _optionsAnimation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, -0.2),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _expandController,
                              curve: const Interval(
                                0.0,
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          widget.question.options.length,
                          (index) => _buildOptionDisplay(
                            context,
                            widget.question.options[index],
                            responsive,
                            borderColor,
                            textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionDisplay(
    BuildContext context,
    QuizOption option,
    ResponsiveUtil responsive,
    Color borderColor,
    Color textColor,
  ) {
    final isUserSelectedAnswer = widget.question.userAnswer == option.id;
    final isCorrectAnswer = option.isCorrect;
    final isAnswered = widget.question.isAnswered;

    Color optionBorderColor = borderColor;
    Color optionBgColor = widget.isDark
        ? const Color(0xFF3A4456)
        : const Color(0xFFF9FAFB);
    Widget? statusIcon;

    if (isAnswered) {
      if (isCorrectAnswer) {
        optionBorderColor = const Color(0xFF51C77A);
        optionBgColor = const Color(0xFFE8F5E9);
        statusIcon = Icon(
          Icons.check_circle,
          color: const Color(0xFF51C77A),
          size: responsive.p20,
        );
      } else if (isUserSelectedAnswer) {
        optionBorderColor = const Color(0xFFFF6B6B);
        optionBgColor = const Color(0xFFFFEBEE);
        statusIcon = Icon(
          Icons.close,
          color: const Color(0xFFFF6B6B),
          size: responsive.p20,
        );
      }
    } else {
      // Skipped - show correct answer
      if (isCorrectAnswer) {
        optionBorderColor = const Color(0xFF51C77A);
        optionBgColor = const Color(0xFFE8F5E9);
        statusIcon = Icon(
          Icons.check_circle,
          color: const Color(0xFF51C77A),
          size: responsive.p20,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.radius12),
        color: Colors.transparent,
        border: Border.all(color: optionBorderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option.text,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                fontWeight: isCorrectAnswer ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (statusIcon != null) ...[
            SizedBox(width: responsive.p12),
            statusIcon,
          ],
        ],
      ),
    );
  }
}
