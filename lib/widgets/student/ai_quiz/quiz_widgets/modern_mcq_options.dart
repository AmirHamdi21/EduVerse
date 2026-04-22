import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/models/quiz_models.dart';

class ModernMcqOptions extends StatefulWidget {
  final QuizQuestion question;
  final bool isDark;
  final Function(String) onAnswerSelected;

  const ModernMcqOptions({
    super.key,
    required this.question,
    required this.isDark,
    required this.onAnswerSelected,
  });

  @override
  State<ModernMcqOptions> createState() => _ModernMcqOptionsState();
}

class _ModernMcqOptionsState extends State<ModernMcqOptions>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  String? _selectedAnswer;

  static const List<Color> optionColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
  ];

  static const List<String> optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    _selectedAnswer = widget.question.userAnswer;
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.question.options.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void didUpdateWidget(ModernMcqOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selectedAnswer = widget.question.userAnswer;
      for (var controller in _controllers) {
        controller.dispose();
      }
      _initAnimations();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index, String optionId) {
    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });

    setState(() {
      _selectedAnswer = optionId;
    });
    widget.onAnswerSelected(optionId);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Column(
      children: List.generate(widget.question.options.length, (index) {
        final option = widget.question.options[index];
        final isSelected = _selectedAnswer == option.id;
        final color = optionColors[index % optionColors.length];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < widget.question.options.length - 1 ? 12 : 0,
          ),
          child: ScaleTransition(
            scale: _scaleAnimations[index],
            child: _buildOptionCard(
              option: option,
              index: index,
              isSelected: isSelected,
              color: color,
              responsive: responsive,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOptionCard({
    required QuizOption option,
    required int index,
    required bool isSelected,
    required Color color,
    required ResponsiveUtil responsive,
  }) {
    return GestureDetector(
      onTap: () => _handleTap(index, option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(responsive.p16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
        child: Row(
          children: [
            // Option label badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Center(
                child: Text(
                  optionLabels[index],
                  style: TextStyle(
                    fontSize: responsive.fontSize16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                    fontFamily: 'Arimo',
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive.p14),

            // Option text
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (widget.isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E)),
                  fontFamily: 'Arimo',
                  height: 1.4,
                ),
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected
                    ? null
                    : Border.all(
                        color: widget.isDark
                            ? const Color(0xFF3A4456)
                            : const Color(0xFFE5E7EB),
                        width: 2,
                      ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
