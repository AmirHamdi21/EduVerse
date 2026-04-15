import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

class TAChartCard extends StatelessWidget {
  final String title;
  final List<String> filters;
  final int selectedFilterIndex;
  final ValueChanged<int>? onFilterChanged;
  final List<ChartData> data;
  final bool isDark;
  final ChartType chartType;

  const TAChartCard({
    super.key,
    required this.title,
    this.filters = const [],
    this.selectedFilterIndex = 0,
    this.onFilterChanged,
    required this.data,
    required this.isDark,
    this.chartType = ChartType.bar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: chartType == ChartType.horizontalBar ? 160 : 140,
            child: chartType == ChartType.horizontalBar
                ? _buildHorizontalBarChart()
                : _buildVerticalBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (filters.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(filters.length, (index) {
                final isSelected = index == selectedFilterIndex;
                return GestureDetector(
                  onTap: () => onFilterChanged?.call(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TAColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: isSelected
                            ? TAColors.primary
                            : TAColors.textSecondaryColor(isDark),
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalBarChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth =
            (constraints.maxWidth - (data.length - 1) * 8) / data.length;
        final maxValue = data
            .map((d) => d.value)
            .reduce((a, b) => a > b ? a : b);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(data.length, (index) {
            final item = data[index];
            final barHeight =
                (item.value / maxValue) * (constraints.maxHeight - 24);

            return Container(
              width: barWidth,
              margin: EdgeInsets.only(right: index < data.length - 1 ? 8 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth * 0.7,
                    height: barHeight.clamp(4, constraints.maxHeight - 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          item.color ?? TAColors.primary,
                          (item.color ?? TAColors.primary).withValues(
                            alpha: 0.6,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHorizontalBarChart() {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(data.length, (index) {
        final item = data[index];
        final percentage = item.value / maxValue;

        return Padding(
          padding: EdgeInsets.only(bottom: index < data.length - 1 ? 10 : 0),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage.clamp(0.05, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.color ?? TAColors.primary,
                            (item.color ?? TAColors.primary).withValues(
                              alpha: 0.7,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '${item.value.toInt()}',
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color? color;

  ChartData({required this.label, required this.value, this.color});
}

enum ChartType { bar, horizontalBar }
