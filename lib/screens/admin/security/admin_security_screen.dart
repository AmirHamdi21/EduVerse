import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/security/security_barrel.dart';
import '../../../common/utils/responsive.dart';

class AdminSecurityScreen extends StatefulWidget {
  const AdminSecurityScreen({super.key});

  @override
  State<AdminSecurityScreen> createState() => _AdminSecurityScreenState();
}

class _AdminSecurityScreenState extends State<AdminSecurityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _searchQuery = '';
  ActivityType _activityType = ActivityType.all;
  UserRoleFilter _userRole = UserRoleFilter.all;
  DateRangeFilter _dateRange = DateRangeFilter.lastWeek;
  bool _isLoading = false;

  // Sample data
  late List<ActivityLog> _logs;
  late List<SecurityAlert> _alerts;
  late List<LoginActivityData> _loginData;
  late List<AccessControl> _accessControls;
  late List<ActiveSession> _activeSessions;
  late List<IpRule> _ipRules;
  late List<SecurityPolicyItem> _securityPolicies;
  late List<ThreatData> _threatData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _isLoading = true);

    // Sample activity logs
    _logs = [
      const ActivityLog(
        id: '1',
        timestamp: '2026-02-18 14:23:45',
        userName: 'Ahmed Hassan',
        userEmail: 'ahmed@eduverse.com',
        activityType: LogActivityType.login,
        ipAddress: '192.168.1.105',
        status: LogStatus.success,
        details: 'Successful login from Chrome on Windows',
      ),
      const ActivityLog(
        id: '2',
        timestamp: '2026-02-18 14:20:12',
        userName: 'Sara Ahmed',
        userEmail: 'sara@eduverse.com',
        activityType: LogActivityType.passwordChange,
        ipAddress: '192.168.1.142',
        status: LogStatus.success,
        details: 'Password changed successfully',
      ),
      const ActivityLog(
        id: '3',
        timestamp: '2026-02-18 14:15:33',
        userName: 'Unknown User',
        userEmail: 'unknown@test.com',
        activityType: LogActivityType.login,
        ipAddress: '45.33.32.156',
        status: LogStatus.failed,
        details: 'Failed login attempt - Invalid credentials',
      ),
      const ActivityLog(
        id: '4',
        timestamp: '2026-02-18 14:10:05',
        userName: 'Admin System',
        userEmail: 'system@eduverse.com',
        activityType: LogActivityType.roleChange,
        ipAddress: '192.168.1.1',
        status: LogStatus.success,
        details: 'Role changed for user: Mohamed Ali (Student → TA)',
      ),
      const ActivityLog(
        id: '5',
        timestamp: '2026-02-18 13:55:22',
        userName: 'Dr. Fatima',
        userEmail: 'fatima@eduverse.com',
        activityType: LogActivityType.dataAccess,
        ipAddress: '192.168.1.88',
        status: LogStatus.success,
        details: 'Accessed student grades report',
      ),
      const ActivityLog(
        id: '6',
        timestamp: '2026-02-18 13:45:18',
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

    // Access controls
    _accessControls = [
      AccessControl(
        id: '1',
        name: 'Two-Factor Authentication',
        description: 'Require 2FA for all admin accounts',
        isEnabled: true,
        icon: Icons.verified_user_rounded,
        color: AdminColors.success,
      ),
      AccessControl(
        id: '2',
        name: 'IP Restriction',
        description: 'Limit access from approved IPs only',
        isEnabled: false,
        icon: Icons.public_rounded,
        color: AdminColors.chartOrange,
      ),
      AccessControl(
        id: '3',
        name: 'Session Timeout',
        description: 'Auto logout after 30 minutes of inactivity',
        isEnabled: true,
        icon: Icons.timer_rounded,
        color: AdminColors.primary,
      ),
      AccessControl(
        id: '4',
        name: 'Login Notifications',
        description: 'Send email on every new login',
        isEnabled: true,
        icon: Icons.notifications_active_rounded,
        color: AdminColors.chartPurple,
      ),
    ];

    // Active sessions
    _activeSessions = [
      ActiveSession(
        id: '1',
        userName: 'John Admin',
        userEmail: 'john.admin@eduverse.com',
        device: 'Windows PC',
        browser: 'Chrome 121',
        location: 'Cairo, Egypt',
        ipAddress: '192.168.1.100',
        lastActive: DateTime.now(),
        isCurrentSession: true,
      ),
      ActiveSession(
        id: '2',
        userName: 'Ahmed Hassan',
        userEmail: 'ahmed@eduverse.com',
        device: 'MacBook Pro',
        browser: 'Safari 17',
        location: 'Alexandria, Egypt',
        ipAddress: '192.168.1.105',
        lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ActiveSession(
        id: '3',
        userName: 'Sara Ahmed',
        userEmail: 'sara@eduverse.com',
        device: 'iPhone 15',
        browser: 'Mobile Safari',
        location: 'Giza, Egypt',
        ipAddress: '192.168.1.142',
        lastActive: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ActiveSession(
        id: '4',
        userName: 'Dr. Fatima',
        userEmail: 'fatima@eduverse.com',
        device: 'Android Phone',
        browser: 'Chrome Mobile',
        location: 'Cairo, Egypt',
        ipAddress: '192.168.1.88',
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    // IP rules
    _ipRules = [
      IpRule(
        id: '1',
        ipAddress: '192.168.1.0/24',
        description: 'Internal Network',
        isWhitelisted: true,
        addedDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      IpRule(
        id: '2',
        ipAddress: '10.0.0.0/8',
        description: 'VPN Network',
        isWhitelisted: true,
        addedDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      IpRule(
        id: '3',
        ipAddress: '45.33.32.156',
        description: 'Suspicious Activity',
        isWhitelisted: false,
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      IpRule(
        id: '4',
        ipAddress: '185.220.100.0/24',
        description: 'Known Tor Exit Node',
        isWhitelisted: false,
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    // Threat data
    _threatData = [
      ThreatData(
        category: 'Brute Force Attacks',
        count: 156,
        color: AdminColors.error,
      ),
      ThreatData(
        category: 'SQL Injection Attempts',
        count: 45,
        color: AdminColors.chartOrange,
      ),
      ThreatData(
        category: 'XSS Attempts',
        count: 28,
        color: AdminColors.warning,
      ),
      ThreatData(
        category: 'Bot Traffic',
        count: 892,
        color: AdminColors.chartPurple,
      ),
    ];

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _initSecurityPolicies(AppLocalizations l10n) {
    _securityPolicies = [
      SecurityPolicyItem(
        id: '1',
        name: l10n.passwordPolicy,
        description: l10n.passwordPolicyDesc,
        status: 'Strong',
        icon: Icons.lock_rounded,
        color: AdminColors.success,
        onConfigure: () => context.push('/admin/settings/password-policy'),
      ),
      SecurityPolicyItem(
        id: '2',
        name: l10n.twoFactorAuth,
        description: l10n.twoFactorAuthPlatformDesc,
        status: 'Enabled',
        icon: Icons.verified_user_rounded,
        color: AdminColors.primary,
        onConfigure: () => context.push('/admin/settings/two-factor'),
      ),
      SecurityPolicyItem(
        id: '3',
        name: l10n.sessionTimeout,
        description: '30 ${l10n.minutes}',
        status: 'Active',
        icon: Icons.timer_rounded,
        color: AdminColors.chartCyan,
        onConfigure: () => _showSessionTimeoutDialog(),
      ),
      SecurityPolicyItem(
        id: '4',
        name: l10n.dataEncryption,
        description: l10n.dataEncryptionDesc,
        status: 'Enabled',
        icon: Icons.enhanced_encryption_rounded,
        color: AdminColors.chartPurple,
        onConfigure: () => _showEncryptionSettings(),
      ),
    ];
  }

  List<ActivityLog> get _filteredLogs {
    var filtered = _logs;

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
    context.push('/admin/settings');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final responsive = context.responsive;
        _initSecurityPolicies(l10n);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: Container(
            decoration: isDark
                ? null
                : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
            child: SafeArea(
              child: _isLoading
                  ? _buildLoadingState()
                  : _buildContent(isDark, l10n, responsive),
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

  Widget _buildContent(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: responsive.contentPadding,
            child: SecurityHeader(
              isDark: isDark,
              onExport: _exportLogs,
              onSettings: _openSettings,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.p16),
            child: _buildTabBar(isDark, l10n),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDark, l10n, responsive),
          _buildAccessControlsTab(isDark, l10n, responsive),
          _buildActivityLogsTab(isDark, l10n, responsive),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AdminColors.getTextSecondaryColor(isDark),
        indicator: BoxDecoration(
          gradient: AdminColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: [
          Tab(text: l10n.overview),
          Tab(text: l10n.accessControls),
          Tab(text: l10n.activityLogs),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: AdminColors.secondary,
      child: ListView(
        padding: responsive.contentPadding,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          const SizedBox(height: 16),
          SecurityOverviewCard(
            isDark: isDark,
            totalEvents: 12456,
            failedLogins: 23,
            securityAlerts: _alerts.where((a) => !a.isResolved).length,
            activeSessions: _activeSessions.length,
            onCardTap: _onStatCardTap,
          ),
          const SizedBox(height: 20),
          ThreatAnalysisCard(
            isDark: isDark,
            threats: _threatData,
            blockedToday: 47,
            blockedThisWeek: 312,
            onViewDetails: () => _showThreatDetails(l10n),
          ),
          const SizedBox(height: 20),
          SecurityAlertsCard(
            isDark: isDark,
            alerts: _alerts,
            onAlertTap: _onAlertTap,
            onResolve: _onResolveAlert,
            onViewAll: () => _showViewMore(l10n.securityAlerts),
          ),
          const SizedBox(height: 20),
          LoginActivityChart(
            isDark: isDark,
            data: _loginData,
            onViewDetails: () => _showViewMore(l10n.loginActivity),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAccessControlsTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        const SizedBox(height: 16),
        AccessControlsCard(
          isDark: isDark,
          controls: _accessControls,
          onToggle: _onToggleAccessControl,
          onManage: () => context.push('/admin/settings'),
        ),
        const SizedBox(height: 20),
        SecurityPoliciesCard(isDark: isDark, policies: _securityPolicies),
        const SizedBox(height: 20),
        ActiveSessionsCard(
          isDark: isDark,
          sessions: _activeSessions,
          onTerminate: _onTerminateSession,
          onTerminateAll: _onTerminateAllSessions,
          onViewAll: () => _showAllSessions(l10n),
        ),
        const SizedBox(height: 20),
        IpManagementCard(
          isDark: isDark,
          rules: _ipRules,
          onRemove: _onRemoveIpRule,
          onAddWhitelist: () => _showAddIpDialog(true),
          onAddBlacklist: () => _showAddIpDialog(false),
          onViewAll: () => _showAllIpRules(l10n),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildActivityLogsTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        const SizedBox(height: 16),
        SecurityFilters(
          isDark: isDark,
          searchQuery: _searchQuery,
          activityType: _activityType,
          userRole: _userRole,
          dateRange: _dateRange,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onActivityTypeChanged: (value) =>
              setState(() => _activityType = value),
          onUserRoleChanged: (value) => setState(() => _userRole = value),
          onDateRangeChanged: (value) => setState(() => _dateRange = value),
          onClearFilters: _clearFilters,
        ),
        const SizedBox(height: 20),
        ActivityLogsTable(
          isDark: isDark,
          logs: _filteredLogs,
          onViewDetails: _onViewLogDetails,
          onViewAll: () => _showViewMore(l10n.activityLogs),
        ),
        const SizedBox(height: 100),
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
        _tabController.animateTo(0);
        break;
      case 'activeSessions':
        message = l10n.viewingActiveSessions;
        _tabController.animateTo(1);
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

  void _onToggleAccessControl(AccessControl control, bool value) {
    setState(() {
      final index = _accessControls.indexWhere((c) => c.id == control.id);
      if (index != -1) {
        _accessControls[index] = AccessControl(
          id: control.id,
          name: control.name,
          description: control.description,
          isEnabled: value,
          icon: control.icon,
          color: control.color,
        );
      }
    });
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? l10n.enabled : l10n.disabled),
        backgroundColor: value ? AdminColors.success : AdminColors.warning,
      ),
    );
  }

  void _onTerminateSession(ActiveSession session) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.terminateSession),
        content: Text('${l10n.terminateSessionConfirm} ${session.userName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(
                () => _activeSessions.removeWhere((s) => s.id == session.id),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.sessionTerminated),
                  backgroundColor: AdminColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            child: Text(
              l10n.terminate,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _onTerminateAllSessions() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.terminateAll),
        content: Text(l10n.terminateAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(
                () => _activeSessions.removeWhere((s) => !s.isCurrentSession),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.allSessionsTerminated),
                  backgroundColor: AdminColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            child: Text(
              l10n.terminateAll,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _onRemoveIpRule(IpRule rule) {
    final l10n = AppLocalizations.of(context);
    setState(() => _ipRules.removeWhere((r) => r.id == rule.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.ipRuleRemoved),
        backgroundColor: AdminColors.success,
      ),
    );
  }

  void _showAddIpDialog(bool isWhitelist) {
    final l10n = AppLocalizations.of(context);
    final ipController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          return AlertDialog(
            backgroundColor: AdminColors.getCardColor(isDark),
            title: Text(
              isWhitelist ? l10n.addToWhitelist : l10n.addToBlacklist,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                    labelText: l10n.ipAddress,
                    hintText: '192.168.1.1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (ipController.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    setState(() {
                      _ipRules.add(
                        IpRule(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          ipAddress: ipController.text,
                          description: descController.text.isEmpty
                              ? (isWhitelist
                                    ? 'Whitelisted IP'
                                    : 'Blacklisted IP')
                              : descController.text,
                          isWhitelisted: isWhitelist,
                          addedDate: DateTime.now(),
                        ),
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.ipRuleAdded),
                        backgroundColor: AdminColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWhitelist
                      ? AdminColors.success
                      : AdminColors.error,
                ),
                child: Text(
                  l10n.add,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
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

  void _showThreatDetails(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.viewingThreatDetails),
        backgroundColor: AdminColors.error,
      ),
    );
  }

  void _showAllSessions(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.viewingMore}: ${l10n.activeSessions}'),
        backgroundColor: AdminColors.chartCyan,
      ),
    );
  }

  void _showAllIpRules(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.viewingMore}: ${l10n.ipManagement}'),
        backgroundColor: AdminColors.chartOrange,
      ),
    );
  }

  void _showSessionTimeoutDialog() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.sessionTimeoutSettings),
        backgroundColor: AdminColors.chartCyan,
      ),
    );
  }

  void _showEncryptionSettings() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.encryptionSettings),
        backgroundColor: AdminColors.chartPurple,
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
