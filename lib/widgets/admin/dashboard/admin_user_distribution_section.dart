import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminUserDistributionSection extends StatelessWidget {
  const AdminUserDistributionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkCard.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightCardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pie_chart_rounded,
                    color: AdminColors.getTextColor(isDark),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.userDistribution,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: const Size(160, 160),
                        painter: _PieChartPainter(isDark: isDark),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '12.8K',
                              style: TextStyle(
                                color: AdminColors.getTextColor(isDark),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.total,
                              style: TextStyle(
                                color: AdminColors.getTextTertiaryColor(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLegendItem(isDark, AdminColors.chartBlue, l10n.students, '10,234'),
              const SizedBox(height: 8),
              _buildLegendItem(isDark, AdminColors.chartPurple, l10n.instructors, '1,876'),
              const SizedBox(height: 8),
              _buildLegendItem(isDark, AdminColors.chartPink, l10n.tas, '687'),
              const SizedBox(height: 8),
              _buildLegendItem(isDark, AdminColors.chartCyan, l10n.admins, '50'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(bool isDark, Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final bool isDark;

  _PieChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 24.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Students: 80%
    paint.color = AdminColors.chartBlue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.57, // Start from top
      5.02, // 80% of 2*pi
      false,
      paint,
    );

    // Instructors: 14.6%
    paint.color = AdminColors.chartPurple;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.45,
      0.92, // 14.6% of 2*pi
      false,
      paint,
    );

    // TAs: 5%
    paint.color = AdminColors.chartPink;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      4.37,
      0.31, // 5% of 2*pi
      false,
      paint,
    );

    // Admins: 0.4%
    paint.color = AdminColors.chartCyan;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      4.68,
      0.03, // 0.4% of 2*pi
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
