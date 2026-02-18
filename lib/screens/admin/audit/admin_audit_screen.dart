import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/audit/audit_barrel.dart';
import '../../../common/utils/responsive.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter state
  String? _selectedSeverity;
  String? _selectedAction;
  DateTimeRange? _dateRange;
  String _searchQuery = '';
  String _exportFormat = 'pdf';
  bool _includeDetails = true;
  bool _isExporting = false;
  bool _isChecking = false;
  bool _isLoadingMore = false;

  // Sample audit logs
  final List<AuditLog> _auditLogs = [
    AuditLog(
      id: '1',
      action: 'User Login',
      user: 'John Doe',
      userRole: 'Admin',
      ipAddress: '192.168.1.100',
      resource: '/auth/login',
      severity: 'info',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AuditLog(
      id: '2',
      action: 'Failed Login Attempt',
      user: 'Unknown',
      userRole: 'N/A',
      ipAddress: '10.0.0.55',
      resource: '/auth/login',
      severity: 'warning',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    AuditLog(
      id: '3',
      action: 'Unauthorized Access Attempt',
      user: 'Jane Smith',
      userRole: 'Student',
      ipAddress: '172.16.0.23',
      resource: '/admin/users',
      severity: 'critical',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AuditLog(
      id: '4',
      action: 'User Created',
      user: 'Admin System',
      userRole: 'System',
      ipAddress: '127.0.0.1',
      resource: '/api/users',
      severity: 'info',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AuditLog(
      id: '5',
      action: 'Password Changed',
      user: 'Mike Johnson',
      userRole: 'Instructor',
      ipAddress: '192.168.1.45',
      resource: '/api/users/profile',
      severity: 'info',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AuditLog(
      id: '6',
      action: 'Course Deleted',
      user: 'Admin User',
      userRole: 'Admin',
      ipAddress: '192.168.1.1',
      resource: '/api/courses/123',
      severity: 'warning',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AuditLog(
      id: '7',
      action: 'Bulk Data Export',
      user: 'System Admin',
      userRole: 'Admin',
      ipAddress: '192.168.1.100',
      resource: '/api/export/users',
      severity: 'info',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Sample compliance items
  final List<ComplianceItem> _complianceItems = [
    ComplianceItem(
      id: '1',
      name: 'Data Encryption',
      description: 'All sensitive data is encrypted at rest and in transit',
      category: 'Security',
      status: 'compliant',
      lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
      score: 100,
    ),
    ComplianceItem(
      id: '2',
      name: 'Password Policy',
      description: 'Strong password requirements enforced',
      category: 'Authentication',
      status: 'compliant',
      lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
      score: 95,
    ),
    ComplianceItem(
      id: '3',
      name: 'Access Control',
      description: 'Role-based access control implemented',
      category: 'Authorization',
      status: 'partial',
      lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
      score: 78,
    ),
    ComplianceItem(
      id: '4',
      name: 'Audit Logging',
      description: 'All user actions are logged',
      category: 'Monitoring',
      status: 'compliant',
      lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
      score: 100,
    ),
    ComplianceItem(
      id: '5',
      name: 'Data Retention',
      description: 'Data retention policies configured',
      category: 'Data Management',
      status: 'non_compliant',
      lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
      score: 45,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AuditLog> get _filteredLogs {
    return _auditLogs.where((log) {
      if (_selectedSeverity != null && log.severity != _selectedSeverity) {
        return false;
      }
      if (_selectedAction != null &&
          !log.action.toLowerCase().contains(_selectedAction!.toLowerCase())) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !log.action.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !log.user.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_dateRange != null) {
        if (log.timestamp.isBefore(_dateRange!.start) ||
            log.timestamp.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: Container(
            decoration: isDark
                ? null
                : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
            child: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      floating: true,
                      snap: true,
                      leading: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      title: Text(
                        l10n.auditCompliance,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: _refreshData,
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      bottom: TabBar(
                        controller: _tabController,
                        labelColor: AdminColors.primary,
                        unselectedLabelColor:
                            AdminColors.getTextColor(isDark).withValues(alpha: 0.6),
                        indicatorColor: AdminColors.primary,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        tabs: [
                          Tab(text: l10n.overview),
                          Tab(text: l10n.auditLogs),
                          Tab(text: l10n.compliance),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isDark, l10n, responsive),
                    _buildAuditLogsTab(isDark, l10n, responsive),
                    _buildComplianceTab(isDark, l10n, responsive),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    final criticalCount = _auditLogs.where((l) => l.severity == 'critical').length;
    final warningCount = _auditLogs.where((l) => l.severity == 'warning').length;
    final todayCount = _auditLogs.where((l) {
      final today = DateTime.now();
      return l.timestamp.year == today.year &&
          l.timestamp.month == today.month &&
          l.timestamp.day == today.day;
    }).length;

    final compliantCount = _complianceItems.where((i) => i.status == 'compliant').length;
    final complianceScore = _complianceItems.isEmpty
        ? 0.0
        : _complianceItems.map((i) => i.score).reduce((a, b) => a + b) /
            _complianceItems.length;

    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        AuditStatsCard(
          isDark: isDark,
          totalLogs: _auditLogs.length,
          todayLogs: todayCount,
          criticalEvents: criticalCount,
          warningEvents: warningCount,
          complianceScore: complianceScore,
        ),
        SizedBox(height: responsive.p24),
        AuditLogsList(
          isDark: isDark,
          logs: _auditLogs.take(5).toList(),
          onViewDetails: _viewLogDetails,
          onLoadMore: () => _tabController.animateTo(1),
        ),
        SizedBox(height: responsive.p24),
        ComplianceStatusCard(
          isDark: isDark,
          items: _complianceItems.take(3).toList(),
          onRunCheck: _runComplianceCheck,
          onViewDetails: _viewComplianceDetails,
          isChecking: _isChecking,
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  Widget _buildAuditLogsTab(bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        AuditFiltersCard(
          isDark: isDark,
          selectedSeverity: _selectedSeverity,
          selectedAction: _selectedAction,
          dateRange: _dateRange,
          searchQuery: _searchQuery,
          onSeverityChanged: (v) => setState(() => _selectedSeverity = v),
          onActionChanged: (v) => setState(() => _selectedAction = v),
          onDateRangeChanged: (v) => setState(() => _dateRange = v),
          onSearchChanged: (v) => setState(() => _searchQuery = v),
          onClearFilters: _clearFilters,
        ),
        SizedBox(height: responsive.p24),
        AuditLogsList(
          isDark: isDark,
          logs: _filteredLogs,
          filterSeverity: _selectedSeverity,
          searchQuery: _searchQuery,
          onViewDetails: _viewLogDetails,
          onLoadMore: _loadMoreLogs,
          isLoading: _isLoadingMore,
        ),
        SizedBox(height: responsive.p24),
        AuditExportCard(
          isDark: isDark,
          selectedFormat: _exportFormat,
          includeDetails: _includeDetails,
          isExporting: _isExporting,
          onFormatChanged: (v) => setState(() => _exportFormat = v),
          onIncludeDetailsChanged: (v) => setState(() => _includeDetails = v),
          onExport: _exportLogs,
          onScheduleReport: _scheduleReport,
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  Widget _buildComplianceTab(bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        ComplianceStatusCard(
          isDark: isDark,
          items: _complianceItems,
          onRunCheck: _runComplianceCheck,
          onViewDetails: _viewComplianceDetails,
          isChecking: _isChecking,
        ),
        SizedBox(height: responsive.p24),
        AuditExportCard(
          isDark: isDark,
          selectedFormat: _exportFormat,
          includeDetails: _includeDetails,
          isExporting: _isExporting,
          onFormatChanged: (v) => setState(() => _exportFormat = v),
          onIncludeDetailsChanged: (v) => setState(() => _includeDetails = v),
          onExport: _exportComplianceReport,
          onScheduleReport: _scheduleReport,
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  void _viewLogDetails(AuditLog log) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminColors.getCardColor(
        context.read<ThemeBloc>().state.isDark,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.logDetails,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(l10n.action, log.action),
            _buildDetailRow(l10n.user, '${log.user} (${log.userRole})'),
            _buildDetailRow(l10n.ipAddress, log.ipAddress),
            _buildDetailRow(l10n.resource, log.resource),
            _buildDetailRow(l10n.severity, log.severity.toUpperCase()),
            _buildDetailRow(l10n.timestamp, _formatDateTime(log.timestamp)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AdminColors.getTextColor(
                  context.read<ThemeBloc>().state.isDark,
                ).withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _viewComplianceDetails(ComplianceItem item) {
    _showSnackBar('Viewing details for ${item.name}');
  }

  void _runComplianceCheck() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isChecking = false);
      final l10n = AppLocalizations.of(context);
      _showSnackBar(l10n.complianceCheckComplete);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedSeverity = null;
      _selectedAction = null;
      _dateRange = null;
      _searchQuery = '';
    });
  }

  void _loadMoreLogs() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoadingMore = false);
      _showSnackBar('Loaded more logs');
    }
  }

  void _exportLogs() async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isExporting = false);
      final l10n = AppLocalizations.of(context);
      _showSnackBar(l10n.exportCompleted);
    }
  }

  void _exportComplianceReport() async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isExporting = false);
      final l10n = AppLocalizations.of(context);
      _showSnackBar(l10n.complianceReportExported);
    }
  }

  void _scheduleReport() {
    final l10n = AppLocalizations.of(context);
    _showSnackBar(l10n.reportScheduled);
  }

  void _refreshData() {
    final l10n = AppLocalizations.of(context);
    _showSnackBar(l10n.dataRefreshed);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
