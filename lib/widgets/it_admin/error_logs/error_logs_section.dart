import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'error_models.dart';

class ErrorLogsSection extends StatelessWidget {
  final bool isDark;
  final List<ErrorLog> errors;
  final Function(ErrorLog) onErrorTap;
  final Function(ErrorLog) onResolve;

  const ErrorLogsSection({
    super.key,
    required this.isDark,
    required this.errors,
    required this.onErrorTap,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Errors',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${errors.length} entries',
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...errors.map((error) => _buildErrorCard(error)),
      ],
    );
  }

  Widget _buildErrorCard(ErrorLog error) {
    final severityColor = _getSeverityColor(error.severity);

    return GestureDetector(
      onTap: () => onErrorTap(error),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: error.isResolved
                ? ITColors.borderColor(isDark)
                : severityColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(error.type),
                    color: severityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        error.type,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        error.source,
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (error.isResolved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ITColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'RESOLVED',
                      style: TextStyle(
                        color: ITColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.check_circle_outline_rounded,
                      color: ITColors.textSecondaryColor(isDark),
                    ),
                    onPressed: () => onResolve(error),
                    tooltip: 'Mark as resolved',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error.message,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetric(Icons.access_time_rounded, error.timestamp),
                const Spacer(),
                _buildMetric(Icons.repeat_rounded, '${error.occurrences}x'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    error.severity.toUpperCase(),
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: ITColors.textTertiaryColor(isDark), size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return ITColors.error;
      case 'high':
        return Colors.orange;
      case 'medium':
        return ITColors.warning;
      case 'low':
        return ITColors.info;
      default:
        return ITColors.textSecondaryColor(isDark);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'exception':
        return Icons.error_rounded;
      case 'api error':
        return Icons.api_rounded;
      case 'database error':
        return Icons.storage_rounded;
      case 'authentication error':
        return Icons.lock_outline_rounded;
      case 'validation error':
        return Icons.warning_rounded;
      default:
        return Icons.bug_report_rounded;
    }
  }
}
