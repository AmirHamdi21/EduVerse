import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/models/quiz_models.dart';

class ModernShortAnswerInput extends StatefulWidget {
  final QuizQuestion question;
  final bool isDark;
  final Function(String) onAnswerChanged;

  const ModernShortAnswerInput({
    super.key,
    required this.question,
    required this.isDark,
    required this.onAnswerChanged,
  });

  @override
  State<ModernShortAnswerInput> createState() => _ModernShortAnswerInputState();
}

class _ModernShortAnswerInputState extends State<ModernShortAnswerInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.question.userAnswer ?? '');
    _characterCount = _controller.text.length;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(ModernShortAnswerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _controller.text = widget.question.userAnswer ?? '';
      _characterCount = _controller.text.length;
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final primaryColor = const Color(0xFF8B5CF6);

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _isFocused
                ? LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _isFocused
                ? null
                : (widget.isDark ? const Color(0xFF252D48) : Colors.white),
            border: Border.all(
              color: _isFocused
                  ? primaryColor
                  : (widget.isDark
                        ? const Color(0xFF3A4456)
                        : const Color(0xFFE5E7EB)),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        widget.isDark ? 0.2 : 0.04,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Container(
                padding: EdgeInsets.all(responsive.p16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _isFocused
                          ? primaryColor.withOpacity(0.3)
                          : (widget.isDark
                                ? const Color(0xFF3A4456)
                                : const Color(0xFFF3F4F6)),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isFocused
                            ? primaryColor.withOpacity(0.15)
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: responsive.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Answer',
                            style: TextStyle(
                              fontSize: responsive.fontSize14,
                              fontWeight: FontWeight.w600,
                              color: _isFocused
                                  ? primaryColor
                                  : (widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E)),
                              fontFamily: 'Arimo',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Type your response below',
                            style: TextStyle(
                              fontSize: responsive.fontSize12,
                              color: widget.isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Character count indicator
                    if (_characterCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _characterCount > 500
                              ? const Color(0xFFF59E0B).withOpacity(0.15)
                              : const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_characterCount',
                          style: TextStyle(
                            fontSize: responsive.fontSize12,
                            fontWeight: FontWeight.w600,
                            color: _characterCount > 500
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Text field
              Padding(
                padding: EdgeInsets.all(responsive.p16),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    setState(() {
                      _characterCount = value.length;
                    });
                    widget.onAnswerChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Start typing your answer here...',
                    hintStyle: TextStyle(
                      color: widget.isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                      fontSize: responsive.fontSize14,
                      fontFamily: 'Arimo',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 8,
                  minLines: 5,
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1A1A2E),
                    fontFamily: 'Arimo',
                    height: 1.6,
                  ),
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                ),
              ),

              // Footer with tips
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.p16,
                  vertical: responsive.p12,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF1E1E2D)
                      : const Color(0xFFF9FAFB),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Be clear and concise in your answer',
                        style: TextStyle(
                          fontSize: responsive.fontSize12,
                          color: widget.isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ),
                    if (_characterCount > 0)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          setState(() {
                            _characterCount = 0;
                          });
                          widget.onAnswerChanged('');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.clear_rounded,
                                color: const Color(0xFFEF4444),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: responsive.fontSize12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFEF4444),
                                  fontFamily: 'Arimo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
