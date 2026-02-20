import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITDRRunbooksSection extends StatelessWidget {
  final bool isDark;
  final List<DRRunbook> runbooks;
  final Function(DRRunbook) onRunTest;
  final Function(DRRunbook) onViewDetails;
  final VoidCallback? onCreateRunbook;

  const ITDRRunbooksSection({
    super.key,
    required this.isDark,
    required this.runbooks,
    required this.onRunTest,
    required this.onViewDetails,
    this.onCreateRunbook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DR Runbooks',
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Disaster recovery procedures and testing',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (onCreateRunbook != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCreateRunbook,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ITColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'New Runbook',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Runbooks list
        if (runbooks.isEmpty)
          _buildEmptyState()
        else
          ...runbooks.map((runbook) => _buildRunbookCard(runbook)),
      ],
    );
  }

  Widget _buildRunbookCard(DRRunbook runbook) {
    return GestureDetector(
      onTap: () => onViewDetails(runbook),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : ITColors.border,
          ),
          boxShadow: ITColors.lightCardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ITColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: ITColors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        runbook.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        runbook.description,
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(runbook.status),
              ],
            ),
            const SizedBox(height: 16),
            // RTO/RPO metrics
            Row(
              children: [
                _buildMetricChip(
                  icon: Icons.timer_rounded,
                  label: 'RTO',
                  value: '${runbook.rtoMinutes}m',
                  color: ITColors.info,
                ),
                const SizedBox(width: 10),
                _buildMetricChip(
                  icon: Icons.restore_rounded,
                  label: 'RPO',
                  value: '${runbook.rpoMinutes}m',
                  color: ITColors.teal,
                ),
                const SizedBox(width: 10),
                _buildMetricChip(
                  icon: Icons.check_circle_rounded,
                  label: 'Success',
                  value: '${runbook.successRate.toStringAsFixed(0)}%',
                  color: _getSuccessRateColor(runbook.successRate),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 14,
                  color: ITColors.textTertiaryColor(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  'Last tested: ${_formatDate(runbook.lastTested)}',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onRunTest(runbook),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ITColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ITColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: ITColors.success,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Run Test',
                            style: TextStyle(
                              color: ITColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = ITColors.successLight;
        textColor = ITColors.success;
        break;
      case 'draft':
        bgColor = ITColors.warningLight;
        textColor = ITColors.warning;
        break;
      case 'outdated':
        bgColor = ITColors.errorLight;
        textColor = ITColors.error;
        break;
      default:
        bgColor = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9);
        textColor = ITColors.textTertiaryColor(isDark);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 10,
            ),
          ),
          Text(
            value,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: ITColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            'No DR runbooks',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create your first disaster recovery runbook',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 95) return ITColors.success;
    if (rate >= 80) return ITColors.warning;
    return ITColors.error;
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
