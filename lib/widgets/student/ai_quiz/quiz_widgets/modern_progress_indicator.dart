import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';

class ModernProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int answeredCount;
  final int skippedCount;
  final bool isDark;

  const ModernProgressIndicator({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredCount,
    required this.skippedCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final progress = currentQuestion / totalQuestions;

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252D48) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: responsive.fontSize12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                            fontFamily: 'Arimo',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: responsive.fontSize12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.p10),
                    // Animated progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3A4456)
                                  : const Color(0xFFF3F4F6),
                            ),
                          ),
                          // Progress
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            height: 10,
                            width:
                                MediaQuery.of(context).size.width *
                                progress *
                                0.75,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Answered',
                  count: answeredCount,
                  color: const Color(0xFF10B981),
                  responsive: responsive,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark
                    ? const Color(0xFF3A4456)
                    : const Color(0xFFF3F4F6),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.skip_next_rounded,
                  label: 'Skipped',
                  count: skippedCount,
                  color: const Color(0xFFF59E0B),
                  responsive: responsive,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark
                    ? const Color(0xFF3A4456)
                    : const Color(0xFFF3F4F6),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.pending_rounded,
                  label: 'Remaining',
                  count: totalQuestions - answeredCount - skippedCount,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                  responsive: responsive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required ResponsiveUtil responsive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            fontFamily: 'Arimo',
          ),
        ),
      ],
    );
  }
}
