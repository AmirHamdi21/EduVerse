import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertsHistoryTab extends StatelessWidget {
  final bool isDark;
  final List<AlertHistoryEntry> history;
  final ValueChanged<AlertHistoryEntry> onEntryTap;

  const ITAlertsHistoryTab({
    super.key,
    required this.isDark,
    required this.history,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ITColors.cardShadow(isDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ITColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: ITColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert History & Logs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View past alerts and their resolution status',
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
        ),
        const SizedBox(height: 16),

        // History table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Timestamp',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rule',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Severity',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),

        // History list
        if (history.isEmpty)
          _buildEmptyState()
        else
          Container(
            decoration: BoxDecoration(
              color: isDark ? ITColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              boxShadow: ITColors.cardShadow(isDark),
            ),
            child: Column(
              children: history
                  .map((entry) => _buildHistoryRow(entry))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryRow(AlertHistoryEntry entry) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isLast = entry == history.last;

    return GestureDetector(
      onTap: () => onEntryTap(entry),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                dateFormat.format(entry.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.ruleName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildSeverityBadge(entry.severity)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(AlertSeverity severity) {
    final color = _getSeverityColor(severity);
    final label = _getSeverityLabel(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: ITColors.textSecondaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No alert history',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alert events will appear here',
              style: TextStyle(
                fontSize: 13,
                color: ITColors.textSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return ITColors.error;
      case AlertSeverity.warning:
        return ITColors.warning;
      case AlertSeverity.info:
        return ITColors.info;
    }
  }

  String _getSeverityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.info:
        return 'Info';
    }
  }
}
