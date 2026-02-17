import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum EventType { info, warning, error, success }

class SystemEvent {
  final String id;
  final String message;
  final String timestamp;
  final EventType type;

  const SystemEvent({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.type,
  });
}

class RecentEventsCard extends StatelessWidget {
  final bool isDark;
  final List<SystemEvent> events;
  final VoidCallback? onViewAll;
  final Function(SystemEvent) onEventTap;

  const RecentEventsCard({
    super.key,
    required this.isDark,
    required this.events,
    this.onViewAll,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.getCardBorderColor(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: AdminColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.recentSystemEvents,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    l10n.viewAll,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...events.map((event) => _buildEventItem(event)),
        ],
      ),
    );
  }

  Widget _buildEventItem(SystemEvent event) {
    return InkWell(
      onTap: () => onEventTap(event),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AdminColors.darkSurface
              : AdminColors.lightBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _getEventColor(event.type).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEventColor(event.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(event.type),
                size: 16,
                color: _getEventColor(event.type),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.getTextColor(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.timestamp,
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.info:
        return AdminColors.primary;
      case EventType.warning:
        return AdminColors.warning;
      case EventType.error:
        return AdminColors.error;
      case EventType.success:
        return AdminColors.success;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.info:
        return Icons.info_outline_rounded;
      case EventType.warning:
        return Icons.warning_amber_rounded;
      case EventType.error:
        return Icons.error_outline_rounded;
      case EventType.success:
        return Icons.check_circle_outline_rounded;
    }
  }
}
