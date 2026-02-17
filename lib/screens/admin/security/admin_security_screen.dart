import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/security/security_barrel.dart';
import '../../../widgets/admin/dashboard/admin_drawer.dart';

class AdminSecurityScreen extends StatefulWidget {
  const AdminSecurityScreen({super.key});

  @override
  State<AdminSecurityScreen> createState() => _AdminSecurityScreenState();
}

class _AdminSecurityScreenState extends State<AdminSecurityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _searchQuery = '';
  ActivityType _activityType = ActivityType.all;
  UserRoleFilter _userRole = UserRoleFilter.all;
  DateRangeFilter _dateRange = DateRangeFilter.lastWeek;
  bool _isLoading = false;

  // Sample data
  late List<ActivityLog> _logs;
  late List<SecurityAlert> _alerts;
  late List<LoginActivityData> _loginData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() => _isLoading = true);

    // Sample activity logs
    _logs = [
      const ActivityLog(
        id: '1',
        timestamp: '2024-02-17 14:23:45',
        userName: 'Ahmed Hassan',
        userEmail: 'ahmed@eduverse.com',
        activityType: LogActivityType.login,
        ipAddress: '192.168.1.105',
        status: LogStatus.success,
        details: 'Successful login from Chrome on Windows',
      ),
      const ActivityLog(
        id: '2',
        timestamp: '2024-02-17 14:20:12',
        userName: 'Sara Ahmed',
        userEmail: 'sara@eduverse.com',
        activityType: LogActivityType.passwordChange,
        ipAddress: '192.168.1.142',
        status: LogStatus.success,
        details: 'Password changed successfully',
      ),
      const ActivityLog(
        id: '3',
        timestamp: '2024-02-17 14:15:33',
        userName: 'Unknown User',
        userEmail: 'unknown@test.com',
        activityType: LogActivityType.login,
        ipAddress: '45.33.32.156',
        status: LogStatus.failed,
        details: 'Failed login attempt - Invalid credentials',
      ),
      const ActivityLog(
        id: '4',
        timestamp: '2024-02-17 14:10:05',
        userName: 'Admin System',
        userEmail: 'system@eduverse.com',
        activityType: LogActivityType.roleChange,
        ipAddress: '192.168.1.1',
        status: LogStatus.success,
        details: 'Role changed for user: Mohamed Ali (Student → TA)',
      ),
      const ActivityLog(
        id: '5',
        timestamp: '2024-02-17 13:55:22',
        userName: 'Dr. Fatima',
        userEmail: 'fatima@eduverse.com',
        activityType: LogActivityType.dataAccess,
        ipAddress: '192.168.1.88',
        status: LogStatus.success,
        details: 'Accessed student grades report',
      ),
      const ActivityLog(
        id: '6',
        timestamp: '2024-02-17 13:45:18',
        userName: 'System',
        userEmail: 'system@eduverse.com',
        activityType: LogActivityType.systemChange,
        ipAddress: '127.0.0.1',
        status: LogStatus.info,
        details: 'Database backup completed successfully',
      ),
    ];

    // Sample security alerts
    _alerts = [
      const SecurityAlert(
        id: '1',
        title: 'Multiple Failed Login Attempts',
        description:
            '5 failed login attempts detected from IP 45.33.32.156 in the last 10 minutes',
        timestamp: '10 minutes ago',
        severity: AlertSeverity.critical,
      ),
      const SecurityAlert(
        id: '2',
        title: 'Unusual Access Pattern',
        description: 'User accessing system from new location (Russia)',
        timestamp: '1 hour ago',
        severity: AlertSeverity.high,
      ),
      const SecurityAlert(
        id: '3',
        title: 'Password Policy Violation',
        description: '3 users have passwords that will expire in 3 days',
        timestamp: '2 hours ago',
        severity: AlertSeverity.medium,
      ),
    ];

    // Sample login activity data
    _loginData = const [
      LoginActivityData(hour: '6AM', successCount: 45, failedCount: 2),
      LoginActivityData(hour: '8AM', successCount: 120, failedCount: 5),
      LoginActivityData(hour: '10AM', successCount: 200, failedCount: 8),
      LoginActivityData(hour: '12PM', successCount: 150, failedCount: 3),
      LoginActivityData(hour: '2PM', successCount: 180, failedCount: 6),
      LoginActivityData(hour: '4PM', successCount: 140, failedCount: 4),
      LoginActivityData(hour: '6PM', successCount: 80, failedCount: 2),
      LoginActivityData(hour: '8PM', successCount: 50, failedCount: 1),
    ];

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  List<ActivityLog> get _filteredLogs {
    var filtered = _logs;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (log) =>
                log.userName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                log.userEmail.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                log.ipAddress.contains(_searchQuery),
          )
          .toList();
    }

    // Activity type filter
    if (_activityType != ActivityType.all) {
      filtered = filtered.where((log) {
        switch (_activityType) {
          case ActivityType.login:
            return log.activityType == LogActivityType.login;
          case ActivityType.logout:
            return log.activityType == LogActivityType.logout;
          case ActivityType.passwordChange:
            return log.activityType == LogActivityType.passwordChange;
          case ActivityType.roleChange:
            return log.activityType == LogActivityType.roleChange;
          case ActivityType.dataAccess:
            return log.activityType == LogActivityType.dataAccess;
          case ActivityType.systemChange:
            return log.activityType == LogActivityType.systemChange;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _activityType = ActivityType.all;
      _userRole = UserRoleFilter.all;
      _dateRange = DateRangeFilter.lastWeek;
    });
  }

  void _exportLogs() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.exportingLogs),
        backgroundColor: AdminColors.primary,
      ),
    );
  }

  void _openSettings() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.openingSecuritySettings),
        backgroundColor: AdminColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          // drawer: const AdminDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: AdminColors.getBackgroundGradient(isDark),
            ),
            child: SafeArea(
              child: _isLoading
                  ? _buildLoadingState()
                  : _buildContent(isDark, l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AdminColors.secondary),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AdminColors.secondary,
          child: CustomScrollView(
            slivers: [
              // App Bar
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.all(20),
              //     child: Row(
              //       children: [
              //         IconButton(
              //           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              //           icon: Icon(
              //             Icons.menu_rounded,
              //             color: AdminColors.getTextColor(isDark),
              //           ),
              //         ),
              //         const Spacer(),
              //       ],
              //     ),
              //   ),
              // ),
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SecurityHeader(
                    isDark: isDark,
                    onExport: _exportLogs,
                    onSettings: _openSettings,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              // Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SecurityFilters(
                    isDark: isDark,
                    searchQuery: _searchQuery,
                    activityType: _activityType,
                    userRole: _userRole,
                    dateRange: _dateRange,
                    onSearchChanged: (value) =>
                        setState(() => _searchQuery = value),
                    onActivityTypeChanged: (value) =>
                        setState(() => _activityType = value),
                    onUserRoleChanged: (value) =>
                        setState(() => _userRole = value),
                    onDateRangeChanged: (value) =>
                        setState(() => _dateRange = value),
                    onClearFilters: _clearFilters,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              // Overview Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SecurityOverviewCard(
                    isDark: isDark,
                    totalEvents: 12456,
                    failedLogins: 23,
                    securityAlerts: _alerts.where((a) => !a.isResolved).length,
                    activeSessions: 1234,
                    onCardTap: _onStatCardTap,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: isWide
                      ? _buildWideLayout(isDark, l10n)
                      : _buildNarrowLayout(isDark, l10n),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Activity Logs
        Expanded(
          flex: 2,
          child: ActivityLogsTable(
            isDark: isDark,
            logs: _filteredLogs,
            onViewDetails: _onViewLogDetails,
            onViewAll: () => _showViewMore(l10n.activityLogs),
          ),
        ),
        const SizedBox(width: 20),
        // Right Column
        Expanded(
          child: Column(
            children: [
              // Security Alerts
              SecurityAlertsCard(
                isDark: isDark,
                alerts: _alerts,
                onAlertTap: _onAlertTap,
                onResolve: _onResolveAlert,
                onViewAll: () => _showViewMore(l10n.securityAlerts),
              ),
              const SizedBox(height: 20),
              // Login Activity
              LoginActivityChart(
                isDark: isDark,
                data: _loginData,
                onViewDetails: () => _showViewMore(l10n.loginActivity),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Security Alerts
        SecurityAlertsCard(
          isDark: isDark,
          alerts: _alerts,
          onAlertTap: _onAlertTap,
          onResolve: _onResolveAlert,
          onViewAll: () => _showViewMore(l10n.securityAlerts),
        ),
        const SizedBox(height: 20),
        // Login Activity
        LoginActivityChart(
          isDark: isDark,
          data: _loginData,
          onViewDetails: () => _showViewMore(l10n.loginActivity),
        ),
        const SizedBox(height: 20),
        // Activity Logs
        ActivityLogsTable(
          isDark: isDark,
          logs: _filteredLogs,
          onViewDetails: _onViewLogDetails,
          onViewAll: () => _showViewMore(l10n.activityLogs),
        ),
      ],
    );
  }

  void _onStatCardTap(String cardType) {
    final l10n = AppLocalizations.of(context);
    String message;
    switch (cardType) {
      case 'totalEvents':
        message = l10n.viewingTotalEvents;
        break;
      case 'failedLogins':
        message = l10n.viewingFailedLogins;
        break;
      case 'securityAlerts':
        message = l10n.viewingSecurityAlerts;
        break;
      case 'activeSessions':
        message = l10n.viewingActiveSessions;
        break;
      default:
        message = cardType;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AdminColors.primary),
    );
  }

  void _onViewLogDetails(ActivityLog log) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            backgroundColor: AdminColors.getCardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AdminColors.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.activityDetails,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(l10n.timestamp, log.timestamp, isDark),
                _buildDetailRow(l10n.user, log.userName, isDark),
                _buildDetailRow(l10n.email, log.userEmail, isDark),
                _buildDetailRow(l10n.ipAddress, log.ipAddress, isDark),
                _buildDetailRow(l10n.details, log.details, isDark),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onAlertTap(SecurityAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(alert.title),
        backgroundColor: _getSeverityColor(alert.severity),
      ),
    );
  }

  void _onResolveAlert(SecurityAlert alert) {
    setState(() {
      final index = _alerts.indexWhere((a) => a.id == alert.id);
      if (index != -1) {
        _alerts[index] = SecurityAlert(
          id: alert.id,
          title: alert.title,
          description: alert.description,
          timestamp: alert.timestamp,
          severity: alert.severity,
          isResolved: true,
        );
      }
    });
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.alertResolved),
        backgroundColor: AdminColors.success,
      ),
    );
  }

  void _showViewMore(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context).viewingMore}: $section'),
        backgroundColor: AdminColors.primary,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AdminColors.error;
      case AlertSeverity.high:
        return AdminColors.chartOrange;
      case AlertSeverity.medium:
        return AdminColors.warning;
      case AlertSeverity.low:
        return AdminColors.chartCyan;
    }
  }
}
