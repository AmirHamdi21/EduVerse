import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeAnswers();
  }

  void _initializeAnswers() {
    selectedAnswers = List.filled(widget.question.options.length, false);
    singleSelectedAnswer = widget.question.userAnswer;
  }

  @override
  void didUpdateWidget(QuizQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _initializeAnswers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final cardColor = widget.isDark ? const Color(0xFF252D48) : Colors.white;
    final borderColor = widget.isDark
        ? const Color(0xFF3A4456)
        : const Color(0xFFD1D5DC);

    return Container(
      padding: EdgeInsets.all(responsive.p24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(responsive.radius24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.question,
            style: TextStyle(
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.6,
            ),
          ),
          SizedBox(height: responsive.p24),
          if (widget.question.type == QuizType.shortAnswer)
            _buildShortAnswerInput(context, responsive, borderColor)
          else if (widget.question.type == QuizType.trueFalse)
            _buildTrueFalseOptions(context, responsive, borderColor)
          else
            _buildMCQOptions(context, responsive, borderColor),
        ],
      ),
    );
  }

  Widget _buildShortAnswerInput(
    BuildContext context,
    ResponsiveUtil responsive,
    Color borderColor,
  ) {
    return TextField(
      onChanged: (value) {
        widget.onAnswerSelected(value);
      },
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).selectAnswer,
        hintStyle: TextStyle(
          color: widget.isDark
              ? const Color(0xFF8A8E96)
              : const Color(0xFFB0B3C1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.p16,
          vertical: responsive.p12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: const BorderSide(color: Color(0xFF2B7FFF), width: 2),
        ),
      ),
      maxLines: 4,
      style: TextStyle(
        fontSize: responsive.fontSize14,
        color: widget.isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildTrueFalseOptions(
    BuildContext context,
    ResponsiveUtil responsive,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        widget.question.options.length,
        (index) => _buildOptionButton(
          context,
          widget.question.options[index],
          index,
          responsive,
          borderColor,
          isMultipleSelect: false,
        ),
      ),
    );
  }

  Widget _buildMCQOptions(
    BuildContext context,
    ResponsiveUtil responsive,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        widget.question.options.length,
        (index) => _buildOptionButton(
          context,
          widget.question.options[index],
          index,
          responsive,
          borderColor,
          isMultipleSelect: false,
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    QuizOption option,
    int index,
    ResponsiveUtil responsive,
    Color borderColor, {
    required bool isMultipleSelect,
  }) {
    final isSelected = isMultipleSelect
        ? selectedAnswers[index]
        : singleSelectedAnswer == option.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isMultipleSelect) {
            selectedAnswers[index] = !selectedAnswers[index];
            final selectedIds = [];
            for (int i = 0; i < selectedAnswers.length; i++) {
              if (selectedAnswers[i]) {
                selectedIds.add(widget.question.options[i].id);
              }
            }
            widget.onMultipleAnswersSelected(List<String>.from(selectedIds));
          } else {
            singleSelectedAnswer = option.id;
            widget.onAnswerSelected(option.id);
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: responsive.p12),
        padding: EdgeInsets.all(responsive.p16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.radius14),
          color: Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF2B7FFF) : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: responsive.p20,
              height: responsive.p20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF2B7FFF)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2B7FFF) : borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: responsive.p12)
                  : null,
            ),
            SizedBox(width: responsive.p12),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
