import 'package:flutter/material.dart';

class GenerateNewSetPanel extends StatefulWidget {
  final VoidCallback onGeneratePressed;
  final Function(bool) onIncludeWeakTopicsChanged;
  final bool includeWeakTopics;
  final bool isDark;

  const GenerateNewSetPanel({
    super.key,
    required this.onGeneratePressed,
    required this.onIncludeWeakTopicsChanged,
    required this.includeWeakTopics,
    required this.isDark,
  });

  @override
  State<GenerateNewSetPanel> createState() => _GenerateNewSetPanelState();
}

class _GenerateNewSetPanelState extends State<GenerateNewSetPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox for weak topics
          GestureDetector(
            onTap: () {
              widget.onIncludeWeakTopicsChanged(!widget.includeWeakTopics);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: widget.includeWeakTopics
                          ? const Color(0xFF2B7FFF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: widget.includeWeakTopics
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Include AI-recommended weak topics',
                      style: TextStyle(
                        color: const Color(0xFF2B7FFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Generate button
          GestureDetector(
            onTap: widget.onGeneratePressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2B7FFF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Generate New Set',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
