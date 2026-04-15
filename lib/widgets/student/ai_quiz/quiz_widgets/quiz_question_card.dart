import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/models/quiz_models.dart';

class QuizQuestionCard extends StatefulWidget {
  final QuizQuestion question;
  final bool isDark;
  final Function(String) onAnswerSelected;
  final Function(List<String>) onMultipleAnswersSelected;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.isDark,
    required this.onAnswerSelected,
    required this.onMultipleAnswersSelected,
  });

  @override
  State<QuizQuestionCard> createState() => _QuizQuestionCardState();
}

class _QuizQuestionCardState extends State<QuizQuestionCard> {
  late List<bool> selectedAnswers;
  String? singleSelectedAnswer;
  late TextEditingController _shortAnswerController;

  @override
  void initState() {
    super.initState();
    _shortAnswerController = TextEditingController();
    _initializeAnswers();
  }

  void _initializeAnswers() {
    selectedAnswers = List.filled(widget.question.options.length, false);
    singleSelectedAnswer = widget.question.userAnswer;

    // Initialize short answer controller with saved answer
    if (widget.question.type == QuizType.shortAnswer) {
      _shortAnswerController.text = widget.question.userAnswer ?? '';
    }
  }

  @override
  void didUpdateWidget(QuizQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _initializeAnswers();
    }
  }

  @override
  void dispose() {
    _shortAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final cardColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;

    return Container(
      padding: EdgeInsets.all(responsive.p24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.question.isSkipped
              ? const Color(0xFFF59E0B)
              : (widget.question.isAnswered
                    ? const Color(0xFF10B981)
                    : Colors.transparent),
          width: widget.question.isSkipped || widget.question.isAnswered
              ? 2
              : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question type badge and status
          Row(
            children: [
              _buildQuestionTypeBadge(),
              const Spacer(),
              if (widget.question.isSkipped || widget.question.isAnswered)
                _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 20),

          // Question text
          Text(
            widget.question.question,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.5,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 24),

          // Options based on type
          if (widget.question.type == QuizType.shortAnswer)
            _buildShortAnswerInput(context, responsive)
          else if (widget.question.type == QuizType.trueFalse)
            _buildTrueFalseOptions(context, responsive)
          else
            _buildMCQOptions(context, responsive),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeBadge() {
    IconData icon;
    String label;
    Color color;

    switch (widget.question.type) {
      case QuizType.shortAnswer:
        icon = Icons.edit_note;
        label = 'Short Answer';
        color = const Color(0xFF8B5CF6);
        break;
      case QuizType.trueFalse:
        icon = Icons.check_box_outlined;
        label = 'True/False';
        color = const Color(0xFF06B6D4);
        break;
      default:
        icon = Icons.quiz_outlined;
        label = 'Multiple Choice';
        color = const Color(0xFF3B82F6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.question.isSkipped
            ? const Color(0xFFF59E0B).withOpacity(0.15)
            : const Color(0xFF10B981).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.question.isSkipped
                ? Icons.skip_next_rounded
                : Icons.check_circle_rounded,
            size: 16,
            color: widget.question.isSkipped
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10B981),
          ),
          const SizedBox(width: 6),
          Text(
            widget.question.isSkipped ? 'Skipped' : 'Answered',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.question.isSkipped
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF10B981),
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortAnswerInput(
    BuildContext context,
    ResponsiveUtil responsive,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1A1A2E).withOpacity(0.5)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark
              ? const Color(0xFF3A4456)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: TextField(
        controller: _shortAnswerController,
        onChanged: (value) {
          widget.onAnswerSelected(value);
        },
        decoration: InputDecoration(
          hintText: 'Type your answer here...',
          hintStyle: TextStyle(
            color: widget.isDark
                ? const Color(0xFF6B7280)
                : const Color(0xFF9CA3AF),
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.edit_outlined,
            color: const Color(0xFF8B5CF6),
            size: 20,
          ),
        ),
        maxLines: 5,
        minLines: 3,
        style: TextStyle(
          fontSize: 15,
          color: widget.isDark ? Colors.white : const Color(0xFF101828),
          fontFamily: 'Arimo',
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTrueFalseOptions(
    BuildContext context,
    ResponsiveUtil responsive,
  ) {
    return Column(
      children: [
        _buildModernOption(
          context,
          widget.question.options[0],
          0,
          icon: Icons.check_circle,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildModernOption(
          context,
          widget.question.options[1],
          1,
          icon: Icons.cancel,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildMCQOptions(BuildContext context, ResponsiveUtil responsive) {
    return Column(
      children: List.generate(
        widget.question.options.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < widget.question.options.length - 1 ? 12 : 0,
          ),
          child: _buildModernOption(
            context,
            widget.question.options[index],
            index,
          ),
        ),
      ),
    );
  }

  Widget _buildModernOption(
    BuildContext context,
    QuizOption option,
    int index, {
    IconData? icon,
    Color? color,
  }) {
    final isSelected = singleSelectedAnswer == option.id;
    final optionColor = color ?? const Color(0xFF3B82F6);
    final optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

    return GestureDetector(
      onTap: () {
        setState(() {
          singleSelectedAnswer = option.id;
          widget.onAnswerSelected(option.id);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? LinearGradient(
                  colors: [optionColor, optionColor.withOpacity(0.8)],
                )
              : null,
          color: isSelected
              ? null
              : (widget.isDark
                    ? const Color(0xFF1A1A2E).withOpacity(0.5)
                    : const Color(0xFFF8F9FA)),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (widget.isDark
                      ? const Color(0xFF3A4456)
                      : const Color(0xFFE5E7EB)),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: optionColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Option label or icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : (widget.isDark ? const Color(0xFF3A4456) : Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: icon != null
                    ? Icon(
                        icon,
                        color: isSelected ? Colors.white : optionColor,
                        size: 20,
                      )
                    : Text(
                        optionLabels[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF6B7280)),
                          fontFamily: 'Arimo',
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (widget.isDark
                            ? Colors.white
                            : const Color(0xFF101828)),
                  fontFamily: 'Arimo',
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
