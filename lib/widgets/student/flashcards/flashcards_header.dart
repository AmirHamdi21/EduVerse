import 'package:flutter/material.dart';

class FlashcardsHeader extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onRegeneratePressed;
  final bool isDark;

  const FlashcardsHeader({
    super.key,
    required this.onBackPressed,
    required this.onRegeneratePressed,
    required this.isDark,
  });

  @override
  State<FlashcardsHeader> createState() => _FlashcardsHeaderState();
}

class _FlashcardsHeaderState extends State<FlashcardsHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onBackPressed,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B7FFF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF2B7FFF),
                    size: 18,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onRegeneratePressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    // color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.refresh,
                        color: Color(0xFF2B7FFF),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Regenerate Cards',
                        style: TextStyle(
                          color: const Color(0xFF2B7FFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Title and description
          Center(
            child: Text(
              'Flashcards by AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Review key concepts generated from your course materials.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Arimo',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
