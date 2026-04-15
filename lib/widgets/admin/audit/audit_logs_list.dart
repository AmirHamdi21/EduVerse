import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AuditLog {
  final String id;
  final String action;
  final String user;
  final String userRole;
  final String ipAddress;
  final String resource;
  final String severity; // 'info', 'warning', 'critical'
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const AuditLog({
    required this.id,
    required this.action,
    required this.user,
    required this.userRole,
    required this.ipAddress,
    required this.resource,
    required this.severity,
    required this.timestamp,
    this.details,
  });
}

class AuditLogsList extends StatelessWidget {
  final bool isDark;
  final List<AuditLog> logs;
  final String? filterSeverity;
  final String? searchQuery;
  final Function(AuditLog) onViewDetails;
  final VoidCallback onLoadMore;
  final bool isLoading;

  const AuditLogsList({
    super.key,
    required this.isDark,
    required this.logs,
    this.filterSeverity,
    this.searchQuery,
    required this.onViewDetails,
    required this.onLoadMore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.auditLogs,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${logs.length} ${l10n.entriesFound}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AdminColors.getTextColor(
                        isDark,
                      ).withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noLogsFound,
                      style: TextStyle(
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...logs.map((log) => _buildLogItem(context, log, l10n)),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (logs.isNotEmpty)
            Center(
              child: TextButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.loadMore),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogItem(
    BuildContext context,
    AuditLog log,
    AppLocalizations l10n,
  ) {
    final severityColor = _getSeverityColor(log.severity);
    final severityIcon = _getSeverityIcon(log.severity);

    return GestureDetector(
      onTap: () => onViewDetails(log),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: log.severity == 'critical'
                ? AdminColors.error.withValues(alpha: 0.3)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(severityIcon, color: severityColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.action,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getSeverityLabel(l10n, log.severity),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: severityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${log.user} (${log.userRole})',
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.getTextColor(
                            isDark,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.language_rounded,
                              size: 14,
                              color: AdminColors.getTextColor(
                                isDark,
                              ).withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              log.ipAddress,
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminColors.getTextColor(
                                  isDark,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.folder_outlined,
                              size: 14,
                              color: AdminColors.getTextColor(
                                isDark,
                              ).withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                log.resource,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.getTextColor(
                                    isDark,
                                  ).withValues(alpha: 0.5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(log.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: AdminColors.getTextColor(
                            isDark,
                          ).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AdminColors.error;
      case 'warning':
        return AdminColors.warning;
      default:
        return AdminColors.primary;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getSeverityLabel(AppLocalizations l10n, String severity) {
    switch (severity) {
      case 'critical':
        return l10n.critical;
      case 'warning':
        return l10n.warning;
      default:
        return l10n.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
