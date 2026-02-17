import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum LogStatus { success, warning, failed, info }

enum LogActivityType {
  login,
  logout,
  passwordChange,
  roleChange,
  dataAccess,
  systemChange,
}

class ActivityLog {
  final String id;
  final String timestamp;
  final String userName;
  final String userEmail;
  final LogActivityType activityType;
  final String ipAddress;
  final LogStatus status;
  final String details;

  const ActivityLog({
    required this.id,
    required this.timestamp,
    required this.userName,
    required this.userEmail,
    required this.activityType,
    required this.ipAddress,
    required this.status,
    required this.details,
  });
}

/// Column widths — single source of truth so header & rows always align
const double _colTimestamp = 160.0;
const double _colUser = 180.0;
const double _colActivity = 160.0;
const double _colIp = 140.0;
const double _colStatus = 100.0;
const double _colAction = 60.0;

class ActivityLogsTable extends StatelessWidget {
  final bool isDark;
  final List<ActivityLog> logs;
  final Function(ActivityLog) onViewDetails;
  final VoidCallback? onViewAll;
  final bool isLoading;

  const ActivityLogsTable({
    super.key,
    required this.isDark,
    required this.logs,
    required this.onViewDetails,
    this.onViewAll,
    this.isLoading = false,
  });

  double get _tableMinWidth =>
      _colTimestamp +
      _colUser +
      _colActivity +
      _colIp +
      _colStatus +
      _colAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card header — full width, no scroll ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      color: AdminColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.activityLogs,
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
          ),

          // ── Table header + rows share one horizontal scroll view ─────────
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AdminColors.primary),
            )
          else if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noLogsFound,
                    style: TextStyle(
                      fontSize: 14,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: _tableMinWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTableHeader(l10n),
                    ...logs.map((log) => _buildLogRow(context, log)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle get _headerStyle => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AdminColors.getTextSecondaryColor(isDark),
  );

  Widget _buildTableHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _colTimestamp,
            child: Text(l10n.timestamp, style: _headerStyle),
          ),
          SizedBox(
            width: _colUser,
            child: Text(l10n.user, style: _headerStyle),
          ),
          SizedBox(
            width: _colActivity,
            child: Text(l10n.activityType, style: _headerStyle),
          ),
          SizedBox(
            width: _colIp,
            child: Text(l10n.ipAddress, style: _headerStyle),
          ),
          SizedBox(
            width: _colStatus,
            child: Text(
              l10n.status,
              style: _headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          // Empty action column header placeholder
          const SizedBox(width: _colAction),
        ],
      ),
    );
  }

  Widget _buildLogRow(BuildContext context, ActivityLog log) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => onViewDetails(log),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AdminColors.getDividerColor(isDark),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timestamp
            SizedBox(
              width: _colTimestamp,
              child: Text(
                log.timestamp,
                style: TextStyle(
                  fontSize: 13,
                  color: AdminColors.getTextColor(isDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // User
            SizedBox(
              width: _colUser,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    log.userName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.getTextColor(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    log.userEmail,
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Activity Type
            SizedBox(
              width: _colActivity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getActivityColor(
                      log.activityType,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getActivityIcon(log.activityType),
                        size: 14,
                        color: _getActivityColor(log.activityType),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getActivityLabel(log.activityType, l10n),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getActivityColor(log.activityType),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // IP Address
            SizedBox(
              width: _colIp,
              child: Text(
                log.ipAddress,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: AdminColors.getTextColor(isDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Status
            SizedBox(
              width: _colStatus,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(log.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(log.status, l10n),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(log.status),
                    ),
                  ),
                ),
              ),
            ),

            // Action
            SizedBox(
              width: _colAction,
              child: IconButton(
                onPressed: () => onViewDetails(log),
                icon: Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: AdminColors.primary,
                ),
                tooltip: l10n.viewDetails,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(LogActivityType type) {
    switch (type) {
      case LogActivityType.login:
        return AdminColors.success;
      case LogActivityType.logout:
        return AdminColors.chartCyan;
      case LogActivityType.passwordChange:
        return AdminColors.warning;
      case LogActivityType.roleChange:
        return AdminColors.secondary;
      case LogActivityType.dataAccess:
        return AdminColors.primary;
      case LogActivityType.systemChange:
        return AdminColors.chartOrange;
    }
  }

  IconData _getActivityIcon(LogActivityType type) {
    switch (type) {
      case LogActivityType.login:
        return Icons.login_rounded;
      case LogActivityType.logout:
        return Icons.logout_rounded;
      case LogActivityType.passwordChange:
        return Icons.lock_reset_rounded;
      case LogActivityType.roleChange:
        return Icons.admin_panel_settings_rounded;
      case LogActivityType.dataAccess:
        return Icons.folder_open_rounded;
      case LogActivityType.systemChange:
        return Icons.settings_rounded;
    }
  }

  String _getActivityLabel(LogActivityType type, AppLocalizations l10n) {
    switch (type) {
      case LogActivityType.login:
        return l10n.login;
      case LogActivityType.logout:
        return l10n.logout;
      case LogActivityType.passwordChange:
        return l10n.passwordChangeActivity;
      case LogActivityType.roleChange:
        return l10n.roleChangeActivity;
      case LogActivityType.dataAccess:
        return l10n.dataAccessActivity;
      case LogActivityType.systemChange:
        return l10n.systemChangeActivity;
    }
  }

  Color _getStatusColor(LogStatus status) {
    switch (status) {
      case LogStatus.success:
        return AdminColors.success;
      case LogStatus.warning:
        return AdminColors.warning;
      case LogStatus.failed:
        return AdminColors.error;
      case LogStatus.info:
        return AdminColors.primary;
    }
  }

  String _getStatusLabel(LogStatus status, AppLocalizations l10n) {
    switch (status) {
      case LogStatus.success:
        return l10n.success;
      case LogStatus.warning:
        return l10n.warning;
      case LogStatus.failed:
        return l10n.failed;
      case LogStatus.info:
        return l10n.info;
    }
  }
}
