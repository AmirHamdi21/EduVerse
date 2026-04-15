import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_performance_report_barrel.dart';

class ITPerformanceTrendsSection extends StatelessWidget {
  final bool isDark;
  final List<TrendDataPoint> cpuData;
  final List<TrendDataPoint> memoryData;
  final List<TrendDataPoint> responseTimeData;
  final int selectedTrendTab;
  final ValueChanged<int> onTrendTabChanged;

  const ITPerformanceTrendsSection({
    super.key,
    required this.isDark,
    required this.cpuData,
    required this.memoryData,
    required this.responseTimeData,
    required this.selectedTrendTab,
    required this.onTrendTabChanged,
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
                      ITColors.purple.withValues(alpha: 0.2),
                      ITColors.primary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: ITColors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Trends',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Historical performance data',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trend tabs
          _buildTrendTabs(),
          const SizedBox(height: 20),

          // Chart
          _buildChart(),
          const SizedBox(height: 16),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildTrendTabs() {
    final tabs = ['CPU Usage', 'Memory', 'Response Time'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedTrendTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTrendTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ITColors.primary : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDark ? Colors.white : ITColors.primary)
                          : ITColors.textSecondaryColor(isDark),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChart() {
    final data = selectedTrendTab == 0
        ? cpuData
        : selectedTrendTab == 1
        ? memoryData
        : responseTimeData;

    final color = selectedTrendTab == 0
        ? ITColors.primary
        : selectedTrendTab == 1
        ? ITColors.purple
        : ITColors.teal;

    if (data.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text(
          'No trend data available',
          style: TextStyle(
            fontSize: 14,
            color: ITColors.textSecondaryColor(isDark),
          ),
        ),
      );
    }

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Column(
      children: [
        // Y-axis labels + Chart
        SizedBox(
          height: 150,
          child: Row(
            children: [
              // Y-axis
              SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      selectedTrendTab == 2
                          ? '${maxValue.round()}ms'
                          : '${maxValue.round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                    Text(
                      selectedTrendTab == 2
                          ? '${((maxValue + minValue) / 2).round()}ms'
                          : '${((maxValue + minValue) / 2).round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                    Text(
                      selectedTrendTab == 2
                          ? '${minValue.round()}ms'
                          : '${minValue.round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chart area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, 150),
                    painter: _ChartPainter(
                      data: data,
                      color: color,
                      minValue: minValue,
                      range: range == 0 ? 1 : range,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // X-axis labels
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(data.length > 6 ? 6 : data.length, (index) {
              final dataIndex = (data.length * index / 5).floor().clamp(
                0,
                data.length - 1,
              );
              final point = data[dataIndex];
              return Text(
                '${point.time.hour}:${point.time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 9,
                  color: ITColors.textSecondaryColor(isDark),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Average', ITColors.primary),
        const SizedBox(width: 20),
        _buildLegendItem('Peak', ITColors.error),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: ITColors.textSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<TrendDataPoint> data;
  final Color color;
  final double minValue;
  final double range;
  final bool isDark;

  _ChartPainter({
    required this.data,
    required this.color,
    required this.minValue,
    required this.range,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw line chart
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final normalizedValue = (data[i].value - minValue) / range;
      final y =
          size.height -
          (normalizedValue * size.height * 0.9) -
          size.height * 0.05;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw data points
    final dotPaint = Paint()..color = color;
    final dotBorderPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < data.length; i++) {
      if (i % (data.length ~/ 6 + 1) != 0 && i != data.length - 1) continue;

      final x = size.width * i / (data.length - 1);
      final normalizedValue = (data[i].value - minValue) / range;
      final y =
          size.height -
          (normalizedValue * size.height * 0.9) -
          size.height * 0.05;

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
