import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

class TALabQualityScore extends StatelessWidget {
  final int score;
  final bool isDark;

  const TALabQualityScore({
    super.key,
    required this.score,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor().withValues(alpha: 0.2),
            _getScoreColor().withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Circular score display
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: TAColors.borderColor(isDark),
                    valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toString(),
                      style: TextStyle(
                        color: _getScoreColor(),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        color: TAColors.textTertiaryColor(isDark),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Score details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lab Quality Score',
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreMessage(),
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMiniStat('Clarity', '${(score * 0.95).toInt()}%', isDark),
                    const SizedBox(width: 16),
                    _buildMiniStat('Complete', '${(score * 0.92).toInt()}%', isDark),
                    const SizedBox(width: 16),
                    _buildMiniStat('Updated', '${(score * 0.88).toInt()}%', isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textTertiaryColor(isDark),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor() {
    if (score >= 80) return TAColors.success;
    if (score >= 60) return TAColors.warning;
    return TAColors.error;
  }

  String _getScoreMessage() {
    if (score >= 80) return 'Excellent! Your materials are well-organized';
    if (score >= 60) return 'Good, but some materials need attention';
    return 'Materials need significant improvement';
  }
}
