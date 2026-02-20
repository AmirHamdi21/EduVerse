import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/dashboard/it_dashboard_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITAdminDashboardScreen extends StatefulWidget {
  const ITAdminDashboardScreen({super.key});

  @override
  State<ITAdminDashboardScreen> createState() => _ITAdminDashboardScreenState();
}

class _ITAdminDashboardScreenState extends State<ITAdminDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  // Mock data
  late List<ServiceStatus> _services;
  late List<ITIncident> _incidents;
  late List<ServerInfo> _servers;
  late List<ITActivityItem> _activities;
  late List<ITAlert> _alerts;

  // Metrics
  final double _cpuUsage = 52.0;
  final double _memoryUsage = 71.0;
  final double _diskUsage = 67.0;
  final double _networkUsage = 45.0;
  final String _apiLatency = '127';
  final String _uptime = '99.94%';
  final int _activeIncidents = 2;
  final int _databaseConnections = 156;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      _services = _getMockServices();
      _incidents = _getMockIncidents();
      _servers = _getMockServers();
      _activities = _getMockActivities();
      _alerts = _getMockAlerts();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<ServiceStatus> _getMockServices() {
    return [
      ServiceStatus(
        name: 'API Gateway',
        status: 'operational',
        statusText: 'Operational',
        icon: Icons.api_rounded,
      ),
      ServiceStatus(
        name: 'Auth',
        status: 'operational',
        statusText: 'Operational',
        icon: Icons.lock_rounded,
      ),
      ServiceStatus(
        name: 'Database',
        status: 'operational',
        statusText: 'Operational',
        icon: Icons.storage_rounded,
      ),
      ServiceStatus(
        name: 'Storage',
        status: 'degraded',
        statusText: 'Degraded',
        icon: Icons.sd_storage_rounded,
      ),
    ];
  }

  List<ITIncident> _getMockIncidents() {
    return [
      ITIncident(
        id: '1',
        title: 'High memory usage on API server',
        description: 'API server memory usage exceeded 85% threshold. Auto-scaling triggered.',
        priority: 'high',
        service: 'API Gateway',
        time: '15 min ago',
        status: 'investigating',
      ),
      ITIncident(
        id: '2',
        title: 'Storage service degraded performance',
        description: 'File upload latency increased by 200%. Investigation ongoing.',
        priority: 'medium',
        service: 'Storage',
        time: '45 min ago',
        status: 'investigating',
      ),
    ];
  }

  List<ServerInfo> _getMockServers() {
    return [
      ServerInfo(
        id: '1',
        name: 'API Server 01',
        type: 'Application Server',
        status: 'Operational',
        cpuUsage: 52,
        memoryUsage: 71,
        diskUsage: 45,
        uptime: '45 days',
      ),
      ServerInfo(
        id: '2',
        name: 'Database Primary',
        type: 'Database Server',
        status: 'Operational',
        cpuUsage: 38,
        memoryUsage: 82,
        diskUsage: 67,
        uptime: '120 days',
      ),
      ServerInfo(
        id: '3',
        name: 'Storage Server',
        type: 'File Server',
        status: 'Degraded',
        cpuUsage: 65,
        memoryUsage: 78,
        diskUsage: 89,
        uptime: '30 days',
      ),
    ];
  }

  List<ITActivityItem> _getMockActivities() {
    return [
      ITActivityItem(
        id: '1',
        title: 'Auto-scaling triggered',
        description: 'Added 2 new instances to API cluster',
        type: 'success',
        time: '5 min ago',
      ),
      ITActivityItem(
        id: '2',
        title: 'Security patch applied',
        description: 'Critical security update deployed to all servers',
        type: 'security',
        time: '1 hour ago',
      ),
      ITActivityItem(
        id: '3',
        title: 'Backup completed',
        description: 'Daily backup completed successfully (2.4 TB)',
        type: 'backup',
        time: '3 hours ago',
      ),
      ITActivityItem(
        id: '4',
        title: 'Database maintenance',
        description: 'Index optimization completed',
        type: 'database',
        time: '6 hours ago',
      ),
    ];
  }

  List<ITAlert> _getMockAlerts() {
    return [
      ITAlert(
        id: '1',
        message: 'Storage server disk usage above 85%',
        severity: 'warning',
        source: 'Storage Server',
        time: '10 min ago',
      ),
      ITAlert(
        id: '2',
        message: 'SSL certificate expires in 7 days',
        severity: 'medium',
        source: 'Security',
        time: '2 hours ago',
      ),
      ITAlert(
        id: '3',
        message: 'Unusual login attempt detected',
        severity: 'high',
        source: 'Auth Service',
        time: '4 hours ago',
      ),
    ];
  }

  void _handleQuickAction(String action) {
    final l10n = AppLocalizations.of(context);
    final titles = {
      'system_health': l10n.itSystemHealth,
      'servers': l10n.itServers,
      'security': l10n.itSecurity,
      'backup': l10n.itBackup,
      'api': l10n.itApiManagement,
      'logs': l10n.itLogs,
      'database': l10n.itDatabase,
      'cloud': l10n.itCloudServices,
    };
    
    final title = titles[action] ?? action;
    _showFeatureDialog(title);
  }

  void _showFeatureDialog(String featureTitle) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.read<ThemeBloc>().state.isDark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ITColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.construction_rounded, color: ITColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                featureTitle,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.itFeatureComingSoon,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ITColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ITColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: ITColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.itStayTuned,
                      style: TextStyle(
                        color: ITColors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              l10n.close,
              style: TextStyle(
                color: ITColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFilterChange(String filter) {
    setState(() => _selectedFilter = filter);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          drawer: ITDrawer(currentRoute: '/it-admin/dashboard', isDark: isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEFF6FF),
                          Colors.white,
                          Color(0xFFECFEFF),
                        ],
                      ),
                    ),
              child: _buildContent(isDark, l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ITColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: CustomScrollView(
        slivers: [
          const ITAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // System Status Section
                ITSystemStatusSection(
                  isDark: isDark,
                  overallStatus: 'normal',
                  services: _services,
                  onRefresh: _loadData,
                ),
                const SizedBox(height: 24),

                // Filter chips
                _buildFilterSection(isDark, l10n),
                const SizedBox(height: 24),

                // System Metrics Grid
                ITSystemMetricsGrid(
                  isDark: isDark,
                  cpuUsage: _cpuUsage,
                  memoryUsage: _memoryUsage,
                  diskUsage: _diskUsage,
                  networkUsage: _networkUsage,
                  apiLatency: _apiLatency,
                  uptime: _uptime,
                  activeIncidents: _activeIncidents,
                  databaseConnections: _databaseConnections,
                ),
                const SizedBox(height: 24),

                // Quick Actions Grid
                ITQuickActionsGrid(
                  isDark: isDark,
                  onActionTap: _handleQuickAction,
                ),
                const SizedBox(height: 24),

                // Active Incidents
                if (_selectedFilter == 'all' || _selectedFilter == 'incidents')
                  ITIncidentsSection(
                    isDark: isDark,
                    incidents: _incidents,
                    onViewAll: () => _showFeatureDialog(AppLocalizations.of(context).itIncidents),
                    onIncidentTap: (incident) =>
                        _showSnackBar('Opening incident: ${incident.title}'),
                    onResolve: (incident) =>
                        _showSnackBar('Resolving: ${incident.title}'),
                  ),
                if (_selectedFilter == 'all' || _selectedFilter == 'incidents')
                  const SizedBox(height: 24),

                // Server Status
                if (_selectedFilter == 'all' || _selectedFilter == 'servers')
                  ITServerStatusSection(
                    isDark: isDark,
                    servers: _servers,
                    onViewAll: () => _showFeatureDialog(AppLocalizations.of(context).itServers),
                    onServerTap: (server) =>
                        _showSnackBar('Opening server: ${server.name}'),
                    onRestart: (server) =>
                        _showSnackBar('Restarting: ${server.name}'),
                  ),
                if (_selectedFilter == 'all' || _selectedFilter == 'servers')
                  const SizedBox(height: 24),

                // Alerts Section
                if (_selectedFilter == 'all' || _selectedFilter == 'alerts')
                  ITAlertsSection(
                    isDark: isDark,
                    alerts: _alerts,
                    onViewAll: () => _showFeatureDialog(AppLocalizations.of(context).itAlerts),
                    onAlertTap: (alert) =>
                        _showSnackBar('Alert: ${alert.message}'),
                    onDismiss: (alert) {
                      setState(() => _alerts.removeWhere((a) => a.id == alert.id));
                      _showSnackBar('Alert dismissed');
                    },
                  ),
                if (_selectedFilter == 'all' || _selectedFilter == 'alerts')
                  const SizedBox(height: 24),

                // Recent Activity
                if (_selectedFilter == 'all' || _selectedFilter == 'activity')
                  ITRecentActivitySection(
                    isDark: isDark,
                    activities: _activities,
                    onViewAll: () => _showFeatureDialog(AppLocalizations.of(context).itLogs),
                    onClearAll: () {
                      setState(() => _activities.clear());
                      _showSnackBar('Activity cleared');
                    },
                  ),
                if (_selectedFilter == 'all' || _selectedFilter == 'activity')
                  const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.itAll, 'icon': Icons.dashboard_rounded},
      {'id': 'incidents', 'label': l10n.itIncidents, 'icon': Icons.warning_rounded},
      {'id': 'servers', 'label': l10n.itServers, 'icon': Icons.dns_rounded},
      {'id': 'alerts', 'label': l10n.itAlerts, 'icon': Icons.notifications_rounded},
      {'id': 'activity', 'label': l10n.itActivity, 'icon': Icons.history_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : ITColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(filter['label'] as String),
                ],
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : ITColors.textPrimaryColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              selectedColor: ITColors.primary,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? ITColors.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : ITColors.border),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (_) => _handleFilterChange(filter['id'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: ITColors.error),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: ITColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
