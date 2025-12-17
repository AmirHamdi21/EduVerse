import 'package:flutter/material.dart';

class CardProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCards;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isDark;
  final bool canGoPrevious;
  final bool canGoNext;

  const CardProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCards,
    required this.onPrevious,
    required this.onNext,
    required this.isDark,
    required this.canGoPrevious,
    required this.canGoNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Card counter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Card ${currentIndex + 1} of $totalCards',
            style: TextStyle(
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4A5565),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Arimo',
            ),
          ),
        ),
        // Navigation buttons and progress dots
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              GestureDetector(
                onTap: canGoPrevious ? onPrevious : null,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2B7FFF,
                    ).withValues(alpha: canGoPrevious ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF2B7FFF),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Progress dots
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalCards,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 8,
                        width: index == currentIndex ? 32 : 8,
                        decoration: BoxDecoration(
                          color: index == currentIndex
                              ? const Color(0xFF2B7FFF)
                              : const Color(0xFF2B7FFF).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Next button
              GestureDetector(
                onTap: canGoNext ? onNext : null,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2B7FFF,
                    ).withValues(alpha: canGoNext ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF2B7FFF),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
