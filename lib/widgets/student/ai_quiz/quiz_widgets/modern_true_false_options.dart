import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/models/quiz_models.dart';

class ModernTrueFalseOptions extends StatefulWidget {
  final QuizQuestion question;
  final bool isDark;
  final Function(String) onAnswerSelected;

  const ModernTrueFalseOptions({
    super.key,
    required this.question,
    required this.isDark,
    required this.onAnswerSelected,
  });

  @override
  State<ModernTrueFalseOptions> createState() => _ModernTrueFalseOptionsState();
}

class _ModernTrueFalseOptionsState extends State<ModernTrueFalseOptions>
    with TickerProviderStateMixin {
  late AnimationController _trueController;
  late AnimationController _falseController;
  late Animation<double> _trueScale;
  late Animation<double> _falseScale;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _selectedAnswer = widget.question.userAnswer;
    _initAnimations();
  }

  void _initAnimations() {
    _trueController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _falseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _trueScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _trueController, curve: Curves.easeInOut),
    );
    _falseScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _falseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ModernTrueFalseOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selectedAnswer = widget.question.userAnswer;
    }
  }

  @override
  void dispose() {
    _trueController.dispose();
    _falseController.dispose();
    super.dispose();
  }

  void _handleTap(bool isTrue, String optionId) {
    final controller = isTrue ? _trueController : _falseController;
    controller.forward().then((_) => controller.reverse());

    setState(() {
      _selectedAnswer = optionId;
    });
    widget.onAnswerSelected(optionId);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final trueOption = widget.question.options[0];
    final falseOption = widget.question.options[1];

    return Row(
      children: [
        // True option
        Expanded(
          child: ScaleTransition(
            scale: _trueScale,
            child: _buildOption(
              option: trueOption,
              isTrue: true,
              isSelected: _selectedAnswer == trueOption.id,
              responsive: responsive,
            ),
          ),
        ),
        SizedBox(width: responsive.p12),
        // False option
        Expanded(
          child: ScaleTransition(
            scale: _falseScale,
            child: _buildOption(
              option: falseOption,
              isTrue: false,
              isSelected: _selectedAnswer == falseOption.id,
              responsive: responsive,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required QuizOption option,
    required bool isTrue,
    required bool isSelected,
    required ResponsiveUtil responsive,
  }) {
    final color = isTrue ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isTrue ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return GestureDetector(
      onTap: () => _handleTap(isTrue, option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.p16,
          vertical: responsive.p24,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (widget.isDark ? const Color(0xFF252D48) : Colors.white),
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
                    color: color.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 36,
              ),
            ),
            SizedBox(height: responsive.p12),

            // Text
            Text(
              option.text,
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (widget.isDark ? Colors.white : const Color(0xFF1A1A2E)),
                fontFamily: 'Arimo',
              ),
            ),
            SizedBox(height: responsive.p8),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: widget.isDark
                            ? const Color(0xFF3A4456)
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? Colors.white
                        : (widget.isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF)),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSelected ? 'Selected' : 'Tap to select',
                    style: TextStyle(
                      fontSize: responsive.fontSize12,
                      color: isSelected
                          ? Colors.white
                          : (widget.isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF)),
                      fontFamily: 'Arimo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
