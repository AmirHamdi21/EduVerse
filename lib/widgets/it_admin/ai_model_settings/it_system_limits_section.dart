import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_ai_model_settings_barrel.dart';

class ITSystemLimitsSection extends StatelessWidget {
  final bool isDark;
  final SystemLimits limits;
  final ValueChanged<SystemLimits> onLimitsChanged;

  const ITSystemLimitsSection({
    super.key,
    required this.isDark,
    required this.limits,
    required this.onLimitsChanged,
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
                      ITColors.error.withValues(alpha: 0.2),
                      ITColors.orange.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.speed_rounded,
                  color: ITColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Limits',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configure rate limits and usage quotas',
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
          const SizedBox(height: 20),

          // Daily Requests Limit
          _buildLimitInput(
            'Daily Requests per Day/User',
            limits.dailyRequestsPerUser,
            'req/day',
            (value) =>
                onLimitsChanged(limits.copyWith(dailyRequestsPerUser: value)),
          ),
          const SizedBox(height: 20),

          // Usage Progress
          Text(
            'Usage Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildUsageProgress(
            'Instructor',
            limits.instructorUsage,
            limits.instructorLimit,
            ITColors.primary,
          ),
          const SizedBox(height: 12),
          _buildUsageProgress(
            'Student',
            limits.studentUsage,
            limits.studentLimit,
            ITColors.teal,
          ),
          const SizedBox(height: 12),
          _buildUsageProgress(
            'TA',
            limits.taUsage,
            limits.taLimit,
            ITColors.purple,
          ),

          const SizedBox(height: 20),

          // High Load Warning
          _buildHighLoadWarning(),
        ],
      ),
    );
  }

  Widget _buildLimitInput(
    String label,
    int value,
    String unit,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ITColors.textPrimaryColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatNumber(value),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ITColors.textPrimaryColor(isDark),
                          ),
                        ),
                      ),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _buildAdjustButton(Icons.add, () => onChanged(value + 1000)),
                  const SizedBox(height: 4),
                  _buildAdjustButton(
                    Icons.remove,
                    () => onChanged((value - 1000).clamp(100, 100000)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ITColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: ITColors.primary),
      ),
    );
  }

  Widget _buildUsageProgress(String label, int used, int limit, Color color) {
    final progress = (used / limit).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ITColors.textPrimaryColor(isDark),
                    ),
                  ),
                ],
              ),
              Text(
                '${_formatNumber(used)} / ${_formatNumber(limit)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textSecondaryColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$percentage% used',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: percentage > 80 ? ITColors.error : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighLoadWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : ITColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: ITColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'High Load Warning',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ITColors.textPrimaryColor(isDark),
                  ),
                ),
              ),
              Switch(
                value: limits.highLoadWarningEnabled,
                onChanged: (value) => onLimitsChanged(
                  limits.copyWith(highLoadWarningEnabled: value),
                ),
                activeColor: ITColors.warning,
              ),
            ],
          ),
          if (limits.highLoadWarningEnabled) ...[
            const SizedBox(height: 12),
            Text(
              'Alert when system load reaches:',
              style: TextStyle(
                fontSize: 12,
                color: ITColors.textSecondaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: ITColors.warning,
                      inactiveTrackColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.2),
                      thumbColor: ITColors.warning,
                      overlayColor: ITColors.warning.withValues(alpha: 0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: limits.highLoadThreshold.toDouble(),
                      min: 50,
                      max: 100,
                      divisions: 10,
                      onChanged: (value) => onLimitsChanged(
                        limits.copyWith(highLoadThreshold: value.round()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ITColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${limits.highLoadThreshold}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ITColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }
}
