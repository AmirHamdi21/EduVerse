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
    final progress = (currentIndex + 1) / totalCards;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar with percentage
          Row(
            children: [
              // Circular progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: const Color(0xFF2B7FFF).withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2B7FFF),
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF101828),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Progress text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFB0B0B0)
                            : const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Arimo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Card ${currentIndex + 1} of $totalCards',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Navigation buttons
          Row(
            children: [
              // Previous button
              Expanded(
                child: GestureDetector(
                  onTap: canGoPrevious ? onPrevious : null,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: canGoPrevious
                          ? const Color(0xFF2B7FFF).withOpacity(0.1)
                          : (isDark
                                ? const Color(0xFF1A1A2E)
                                : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: canGoPrevious
                            ? const Color(0xFF2B7FFF).withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          color: canGoPrevious
                              ? const Color(0xFF2B7FFF)
                              : (isDark
                                    ? const Color(0xFF4D4D64)
                                    : const Color(0xFFD1D5DB)),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Previous',
                          style: TextStyle(
                            color: canGoPrevious
                                ? const Color(0xFF2B7FFF)
                                : (isDark
                                      ? const Color(0xFF4D4D64)
                                      : const Color(0xFFD1D5DB)),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Next button
              Expanded(
                child: GestureDetector(
                  onTap: canGoNext ? onNext : null,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: canGoNext
                          ? const LinearGradient(
                              colors: [Color(0xFF2B7FFF), Color(0xFF1E5FCC)],
                            )
                          : null,
                      color: canGoNext
                          ? null
                          : (isDark
                                ? const Color(0xFF1A1A2E)
                                : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: canGoNext
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2B7FFF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: canGoNext
                                ? Colors.white
                                : (isDark
                                      ? const Color(0xFF4D4D64)
                                      : const Color(0xFFD1D5DB)),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Arimo',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: canGoNext
                              ? Colors.white
                              : (isDark
                                    ? const Color(0xFF4D4D64)
                                    : const Color(0xFFD1D5DB)),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
