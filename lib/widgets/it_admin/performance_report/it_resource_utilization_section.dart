import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_performance_report_barrel.dart';

class ITResourceUtilizationSection extends StatelessWidget {
  final bool isDark;
  final List<ResourceUtilization> resources;
  final VoidCallback? onManageStorage;

  const ITResourceUtilizationSection({
    super.key,
    required this.isDark,
    required this.resources,
    this.onManageStorage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.teal.withValues(alpha: 0.2),
                      ITColors.primary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: ITColors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resource Utilization',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Storage and resource breakdown',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (onManageStorage != null)
                TextButton.icon(
                  onPressed: onManageStorage,
                  icon: Icon(
                    Icons.settings_rounded,
                    size: 16,
                    color: ITColors.primary,
                  ),
                  label: Text(
                    'Manage',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ITColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Resource bars
          ...resources.map((resource) => _buildResourceBar(resource)),

          const SizedBox(height: 16),

          // Summary
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildResourceBar(ResourceUtilization resource) {
    final isHigh = resource.percentage > 80;
    final isMedium = resource.percentage > 60 && resource.percentage <= 80;
    final displayColor = isHigh
        ? ITColors.error
        : isMedium
        ? ITColors.warning
        : resource.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: resource.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    resource.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ITColors.textPrimaryColor(isDark),
                    ),
                  ),
                ],
              ),
              Text(
                '${resource.usedFormatted} / ${resource.totalFormatted}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: displayColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: resource.percentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        displayColor,
                        displayColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${resource.percentage.toStringAsFixed(1)}% used',
              style: TextStyle(
                fontSize: 10,
                color: isHigh
                    ? ITColors.error
                    : ITColors.textSecondaryColor(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final totalUsed = resources.fold<double>(0, (sum, r) => sum + r.used);
    final totalCapacity = resources.fold<double>(0, (sum, r) => sum + r.total);
    final overallPercentage = totalCapacity > 0
        ? (totalUsed / totalCapacity * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ITColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
            ITColors.teal.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ITColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Storage Usage',
                  style: TextStyle(
                    fontSize: 12,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${overallPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ITColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _CircleProgressPainter(
                progress: overallPercentage / 100,
                color: ITColors.primary,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Icon(
                  Icons.storage_rounded,
                  size: 28,
                  color: ITColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 8.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -90 * 3.14159 / 180;
    final sweepAngle = progress * 2 * 3.14159;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
