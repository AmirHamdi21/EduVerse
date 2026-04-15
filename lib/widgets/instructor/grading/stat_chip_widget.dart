import 'package:flutter/material.dart';
import 'grading_theme_colors.dart';

/// Statistics chip widget for displaying counts with gradient backgrounds
class StatChipWidget extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final LinearGradient? gradient;
  final IconData? icon;
  final bool isDark;
  final VoidCallback? onTap;

  const StatChipWidget({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    this.gradient,
    this.icon,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            gradient:
                gradient ??
                LinearGradient(
                  colors: [
                    color.withValues(alpha: isDark ? 0.2 : 0.12),
                    color.withValues(alpha: isDark ? 0.1 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 10),
              ],
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: count),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    value.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? color.withValues(alpha: 0.8)
                      : color.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact stat chip for app bar
class CompactStatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  const CompactStatChip({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats dashboard container
class StatsDashboard extends StatelessWidget {
  final int pendingCount;
  final int gradedCount;
  final int lateCount;
  final int totalCount;
  final bool isDark;
  final Function(String)? onStatTap;

  const StatsDashboard({
    super.key,
    required this.pendingCount,
    required this.gradedCount,
    required this.lateCount,
    required this.totalCount,
    required this.isDark,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  GradingColors.darkCard,
                  GradingColors.darkSurface.withValues(alpha: 0.5),
                ]
              : [
                  Colors.white,
                  GradingColors.primarySurface.withValues(alpha: 0.3),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? GradingColors.primary.withValues(alpha: 0.2)
              : GradingColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GradingColors.primary.withValues(alpha: isDark ? 0.1 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: GradingColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: GradingColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assessment_rounded,
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
                      'Submissions Overview',
                      style: TextStyle(
                        color: GradingColors.textPrimaryColor(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalCount total submissions',
                      style: TextStyle(
                        color: GradingColors.textSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatChipWidget(
                label: 'Pending',
                count: pendingCount,
                color: GradingColors.pending,
                icon: Icons.pending_actions_rounded,
                isDark: isDark,
                onTap: () => onStatTap?.call('pending'),
              ),
              const SizedBox(width: 12),
              StatChipWidget(
                label: 'Graded',
                count: gradedCount,
                color: GradingColors.graded,
                icon: Icons.check_circle_rounded,
                isDark: isDark,
                onTap: () => onStatTap?.call('graded'),
              ),
              const SizedBox(width: 12),
              StatChipWidget(
                label: 'Late',
                count: lateCount,
                color: GradingColors.late,
                icon: Icons.warning_rounded,
                isDark: isDark,
                onTap: () => onStatTap?.call('late'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
