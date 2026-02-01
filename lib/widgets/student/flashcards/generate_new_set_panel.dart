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
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF2D2D44) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate New Set',
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : const Color(0xFF101828),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arimo',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Create AI-powered flashcards',
                          style: TextStyle(
                            color: widget.isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 1,
              color: widget.isDark
                  ? const Color(0xFF4D4D64).withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
            ),
            
            // Options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Weak topics toggle
                  GestureDetector(
                    onTap: () {
                      widget.onIncludeWeakTopicsChanged(!widget.includeWeakTopics);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.includeWeakTopics
                            ? const Color(0xFF2B7FFF).withOpacity(0.1)
                            : (widget.isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.includeWeakTopics
                              ? const Color(0xFF2B7FFF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              gradient: widget.includeWeakTopics
                                  ? const LinearGradient(
                                      colors: [Color(0xFF2B7FFF), Color(0xFF1E5FCC)],
                                    )
                                  : null,
                              color: widget.includeWeakTopics
                                  ? null
                                  : (widget.isDark ? const Color(0xFF4D4D64) : const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: widget.includeWeakTopics
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Focus on weak topics',
                                  style: TextStyle(
                                    color: widget.isDark ? Colors.white : const Color(0xFF101828),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'AI will prioritize topics you need practice',
                                  style: TextStyle(
                                    color: widget.isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Generate button
                  GestureDetector(
                    onTap: widget.onGeneratePressed,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Generate New Flashcards',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
