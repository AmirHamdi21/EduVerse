import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class ActiveSession {
  final String id;
  final String userName;
  final String userEmail;
  final String device;
  final String browser;
  final String location;
  final String ipAddress;
  final DateTime lastActive;
  final bool isCurrentSession;

  const ActiveSession({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.device,
    required this.browser,
    required this.location,
    required this.ipAddress,
    required this.lastActive,
    this.isCurrentSession = false,
  });
}

class ActiveSessionsCard extends StatelessWidget {
  final bool isDark;
  final List<ActiveSession> sessions;
  final Function(ActiveSession) onTerminate;
  final VoidCallback onTerminateAll;
  final VoidCallback onViewAll;

  const ActiveSessionsCard({
    super.key,
    required this.isDark,
    required this.sessions,
    required this.onTerminate,
    required this.onTerminateAll,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.chartCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  color: AdminColors.chartCyan,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.activeSessions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    Text(
                      '${sessions.length} ${l10n.activeNow}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
                onSelected: (value) {
                  if (value == 'terminate_all') {
                    onTerminateAll();
                  } else if (value == 'view_all') {
                    onViewAll();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view_all',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.viewAll),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'terminate_all',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: AdminColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.terminateAll,
                          style: TextStyle(color: AdminColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sessions
              .take(5)
              .map((session) => _buildSessionItem(session, l10n)),
          if (sessions.length > 5) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onViewAll,
                child: Text(
                  '${l10n.viewAll} (${sessions.length - 5} ${l10n.more})',
                  style: TextStyle(color: AdminColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionItem(ActiveSession session, AppLocalizations l10n) {
    final timeAgo = _getTimeAgo(session.lastActive, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: session.isCurrentSession
              ? AdminColors.success.withValues(alpha: 0.08)
              : isDark
              ? Colors.white.withValues(alpha: 0.03)
              : AdminColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: session.isCurrentSession
                ? AdminColors.success.withValues(alpha: 0.3)
                : AdminColors.getCardBorderColor(isDark),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getDeviceColor(session.device).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getDeviceIcon(session.device),
                color: _getDeviceColor(session.device),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        session.userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      if (session.isCurrentSession) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AdminColors.success,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.current,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.device} • ${session.browser} • ${session.location}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.lastActive}: $timeAgo',
                    style: TextStyle(
                      fontSize: 10,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            if (!session.isCurrentSession)
              IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onTerminate(session);
                },
                icon: Icon(
                  Icons.logout_rounded,
                  color: AdminColors.error,
                  size: 20,
                ),
                tooltip: l10n.terminateSession,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String device) {
    final lower = device.toLowerCase();
    if (lower.contains('iphone') ||
        lower.contains('android') ||
        lower.contains('mobile')) {
      return Icons.smartphone_rounded;
    } else if (lower.contains('ipad') || lower.contains('tablet')) {
      return Icons.tablet_rounded;
    } else if (lower.contains('mac') ||
        lower.contains('windows') ||
        lower.contains('linux')) {
      return Icons.laptop_rounded;
    }
    return Icons.devices_other_rounded;
  }

  Color _getDeviceColor(String device) {
    final lower = device.toLowerCase();
    if (lower.contains('iphone') ||
        lower.contains('mac') ||
        lower.contains('ipad')) {
      return AdminColors.chartPurple;
    } else if (lower.contains('windows')) {
      return AdminColors.primary;
    } else if (lower.contains('android')) {
      return AdminColors.success;
    } else if (lower.contains('linux')) {
      return AdminColors.chartOrange;
    }
    return AdminColors.chartCyan;
  }

  String _getTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
