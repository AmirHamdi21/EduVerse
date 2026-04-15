import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminAttendanceAnalytics extends StatelessWidget {
  final bool isDark;
  final List<DepartmentAttendance> departmentData;
  final List<WeeklyTrend> weeklyTrends;

  const AdminAttendanceAnalytics({
    super.key,
    required this.isDark,
    required this.departmentData,
    required this.weeklyTrends,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AdminColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Department Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...departmentData.map((dept) => _buildDepartmentBar(dept)),
          const SizedBox(height: 24),
          Text(
            'Weekly Trend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyTrends
                  .map((trend) => _buildTrendBar(trend))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weeklyTrends
                .map(
                  (trend) => Text(
                    trend.day,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AdminColors.darkTextTertiary
                          : AdminColors.lightTextTertiary,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentBar(DepartmentAttendance dept) {
    final color = dept.rate >= 0.9
        ? AdminColors.success
        : dept.rate >= 0.75
        ? AdminColors.warning
        : AdminColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dept.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AdminColors.darkText
                        : AdminColors.lightText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(dept.rate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: dept.rate,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBar(WeeklyTrend trend) {
    final maxHeight = 100.0;
    final barHeight = maxHeight * trend.rate;
    final color = trend.isToday
        ? AdminColors.primary
        : AdminColors.primary.withValues(alpha: 0.5);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${(trend.rate * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AdminColors.darkTextSecondary
                    : AdminColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                gradient: trend.isToday
                    ? AdminColors.primaryGradient
                    : LinearGradient(colors: [color, color]),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DepartmentAttendance {
  final String name;
  final double rate;

  const DepartmentAttendance({required this.name, required this.rate});
}

class WeeklyTrend {
  final String day;
  final double rate;
  final bool isToday;

  const WeeklyTrend({
    required this.day,
    required this.rate,
    this.isToday = false,
  });
}
