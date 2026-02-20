import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertsSuppressTab extends StatelessWidget {
  final bool isDark;
  final List<SuppressionWindow> windows;
  final ValueChanged<SuppressionWindow> onWindowTap;
  final VoidCallback onCreateWindow;

  const ITAlertsSuppressTab({
    super.key,
    required this.isDark,
    required this.windows,
    required this.onWindowTap,
    required this.onCreateWindow,
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
                  color: ITColors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.do_not_disturb_on_rounded,
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
                      'Suppression Windows',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Schedule maintenance windows to suppress alerts',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCreateWindow,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ITColors.purple, ITColors.purple.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Create Window',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Windows list
        if (windows.isEmpty)
          _buildEmptyState()
        else
          ...windows.map((window) => _buildWindowCard(window)),
      ],
    );
  }

  Widget _buildWindowCard(SuppressionWindow window) {
    final isCurrentlyActive = window.isActive &&
        DateTime.now().isAfter(window.startTime) &&
        DateTime.now().isBefore(window.endTime);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return GestureDetector(
      onTap: () => onWindowTap(window),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ITColors.cardShadow(isDark),
          border: isCurrentlyActive
              ? Border.all(color: ITColors.purple, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            window.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ITColors.textPrimaryColor(isDark),
                            ),
                          ),
                          if (isCurrentlyActive) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ITColors.purple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Active Now',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ITColors.purple,
                                ),
                              ),
                            ),
                          ],
                          if (window.isRecurring) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ITColors.info.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.repeat_rounded,
                                    size: 12,
                                    color: ITColors.info,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Recurring',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: ITColors.info,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        window.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Time details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: 16,
                        color: ITColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Start: ${dateFormat.format(window.startTime)} UTC',
                        style: TextStyle(
                          fontSize: 12,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.stop_circle_outlined,
                        size: 16,
                        color: ITColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'End: ${dateFormat.format(window.endTime)} UTC',
                        style: TextStyle(
                          fontSize: 12,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Affected services
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: window.affectedServices.map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : ITColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ITColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: ITColors.textSecondaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No suppression windows',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a window to mute alerts during maintenance',
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
}
