import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';
import '../../widgets/it_admin/system_health/system_health_barrel.dart';

class ITSystemHealthScreen extends StatefulWidget {
  const ITSystemHealthScreen({super.key});

  @override
  State<ITSystemHealthScreen> createState() => _ITSystemHealthScreenState();
}

class _ITSystemHealthScreenState extends State<ITSystemHealthScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  // Data
  late List<SystemHealthMetric> _metrics;
  late List<HealthService> _services;
  late List<HealthAlert> _alerts;
  String _overallStatus = 'operational';
  double _systemScore = 98.5;

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

      _metrics = _getMockMetrics();
      _services = _getMockServices();
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

  List<SystemHealthMetric> _getMockMetrics() {
    return [
      SystemHealthMetric(
        id: '1',
        name: 'CPU',
        value: 52.0,
        maxValue: 100,
        unit: '%',
        status: 'operational',
        trend: '↓ 5%',
        icon: Icons.memory_rounded,
        history: [45, 52, 48, 55, 50, 52],
      ),
      SystemHealthMetric(
        id: '2',
        name: 'Memory',
        value: 71.0,
        maxValue: 100,
        unit: '%',
        status: 'operational',
        trend: '↑ 3%',
        icon: Icons.storage_rounded,
        history: [65, 68, 70, 69, 71, 71],
      ),
      SystemHealthMetric(
        id: '3',
        name: 'Disk',
        value: 45.0,
        maxValue: 100,
        unit: '%',
        status: 'operational',
        trend: '→ 0%',
        icon: Icons.sd_storage_rounded,
        history: [44, 44, 45, 45, 45, 45],
      ),
      SystemHealthMetric(
        id: '4',
        name: 'Network',
        value: 125.0,
        maxValue: 1000,
        unit: 'Mbps',
        status: 'operational',
        trend: '↑ 12%',
        icon: Icons.wifi_rounded,
        history: [100, 110, 115, 120, 122, 125],
      ),
      SystemHealthMetric(
        id: '5',
        name: 'Latency',
        value: 45.0,
        maxValue: 200,
        unit: 'ms',
        status: 'operational',
        trend: '↓ 8%',
        icon: Icons.speed_rounded,
        history: [50, 48, 47, 46, 45, 45],
      ),
      SystemHealthMetric(
        id: '6',
        name: 'Uptime',
        value: 99.9,
        maxValue: 100,
        unit: '%',
        status: 'operational',
        trend: '→ Stable',
        icon: Icons.timer_rounded,
        history: [99.9, 99.9, 99.9, 99.9, 99.9, 99.9],
      ),
    ];
  }

  List<HealthService> _getMockServices() {
    return [
      HealthService(
        id: '1',
        name: 'API Gateway',
        status: 'operational',
        description: 'Main API entry point',
        lastCheck: '2 min ago',
        uptime: 99.99,
        icon: Icons.api_rounded,
      ),
      HealthService(
        id: '2',
        name: 'Authentication Service',
        status: 'operational',
        description: 'User authentication & authorization',
        lastCheck: '1 min ago',
        uptime: 99.95,
        icon: Icons.lock_rounded,
      ),
      HealthService(
        id: '3',
        name: 'Database Cluster',
        status: 'operational',
        description: 'Primary database cluster',
        lastCheck: '30 sec ago',
        uptime: 99.99,
        icon: Icons.storage_rounded,
      ),
      HealthService(
        id: '4',
        name: 'Storage Service',
        status: 'degraded',
        description: 'File storage and CDN',
        lastCheck: '1 min ago',
        uptime: 98.50,
        icon: Icons.cloud_rounded,
      ),
      HealthService(
        id: '5',
        name: 'Notification Service',
        status: 'operational',
        description: 'Push & email notifications',
        lastCheck: '3 min ago',
        uptime: 99.90,
        icon: Icons.notifications_rounded,
      ),
      HealthService(
        id: '6',
        name: 'AI Processing',
        status: 'operational',
        description: 'ML model inference service',
        lastCheck: '2 min ago',
        uptime: 99.85,
        icon: Icons.psychology_rounded,
      ),
    ];
  }

  List<HealthAlert> _getMockAlerts() {
    return [
      HealthAlert(
        id: '1',
        title: 'Storage latency increased',
        description: 'Storage response time above threshold',
        severity: 'warning',
        time: '15 min ago',
        source: 'Storage Service',
      ),
      HealthAlert(
        id: '2',
        title: 'High memory usage on DB-02',
        description: 'Memory usage exceeded 85%',
        severity: 'warning',
        time: '45 min ago',
        source: 'Database Cluster',
      ),
    ];
  }

  List<HealthService> get _filteredServices {
    if (_selectedFilter == 'all') return _services;
    return _services.where((s) => s.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: ITColors.scaffoldColor(isDark),
          // drawer: ITDrawer(currentRoute: '/it-admin/system-health', isDark: isDark),
          appBar: _buildAppBar(l10n, isDark),
          body: _isLoading
              ? _buildLoadingState(isDark)
              : _errorMessage != null
              ? _buildErrorState(isDark, l10n)
              : _buildContent(isDark, l10n),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, bool isDark) {
    return AppBar(
      backgroundColor: ITColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: ITColors.textPrimaryColor(isDark),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        l10n.itSystemHealth,
        style: TextStyle(
          color: ITColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: ITColors.textSecondaryColor(isDark),
          ),
          onPressed: _loadData,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(child: CircularProgressIndicator(color: ITColors.primary));
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: ITColors.error),
          const SizedBox(height: 16),
          Text(
            l10n.errorOccurred,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.tryAgain),
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    final healthyCount = _services
        .where((s) => s.status == 'operational')
        .length;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SystemHealthOverviewCard(
            isDark: isDark,
            overallStatus: _overallStatus,
            healthyServices: healthyCount,
            totalServices: _services.length,
            systemScore: _systemScore,
          ),
          const SizedBox(height: 24),
          _buildFilterChips(isDark, l10n),
          const SizedBox(height: 20),
          SystemHealthMetricsGrid(
            isDark: isDark,
            metrics: _metrics,
            onMetricTap: _handleMetricTap,
          ),
          const SizedBox(height: 24),
          SystemHealthServicesSection(
            isDark: isDark,
            services: _filteredServices,
            onServiceTap: _handleServiceTap,
          ),
          const SizedBox(height: 24),
          SystemHealthAlertsSection(
            isDark: isDark,
            alerts: _alerts,
            onAlertTap: _handleAlertTap,
            onViewAll: () => context.push('/it-admin/alerts'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.all, 'icon': Icons.dashboard_rounded},
      {
        'id': 'operational',
        'label': l10n.itOperational,
        'icon': Icons.check_circle_rounded,
      },
      {
        'id': 'degraded',
        'label': l10n.itDegraded,
        'icon': Icons.warning_rounded,
      },
      {'id': 'offline', 'label': l10n.itOffline, 'icon': Icons.cancel_rounded},
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
              selectedColor: ITColors.primary,
              backgroundColor: ITColors.cardColor(isDark),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : ITColors.textPrimaryColor(isDark),
              ),
              side: BorderSide(
                color: isSelected
                    ? ITColors.primary
                    : ITColors.borderColor(isDark),
              ),
              onSelected: (_) {
                setState(() => _selectedFilter = filter['id'] as String);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleMetricTap(SystemHealthMetric metric) {
    _showMetricDetails(metric);
  }

  void _handleServiceTap(HealthService service) {
    _showServiceDetails(service);
  }

  void _handleAlertTap(HealthAlert alert) {
    _showAlertDetails(alert);
  }

  void _showMetricDetails(SystemHealthMetric metric) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ITColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ITColors.getMetricColor(
                      metric.name.toLowerCase(),
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    metric.icon,
                    color: ITColors.getMetricColor(metric.name.toLowerCase()),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Current: ${metric.value}${metric.unit}',
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              'Status',
              metric.status.toUpperCase(),
              ITColors.getStatusColor(metric.status),
              isDark,
            ),
            _buildDetailRow(
              'Trend',
              metric.trend,
              ITColors.textPrimaryColor(isDark),
              isDark,
            ),
            _buildDetailRow(
              'Max Value',
              '${metric.maxValue}${metric.unit}',
              ITColors.textPrimaryColor(isDark),
              isDark,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(HealthService service) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final statusColor = ITColors.getStatusColor(service.status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ITColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(service.icon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service.description,
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              'Status',
              service.status.toUpperCase(),
              statusColor,
              isDark,
            ),
            _buildDetailRow(
              'Uptime',
              '${service.uptime}%',
              ITColors.success,
              isDark,
            ),
            _buildDetailRow(
              'Last Check',
              service.lastCheck,
              ITColors.textPrimaryColor(isDark),
              isDark,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Health Check',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ITColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showAlertDetails(HealthAlert alert) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final severityColor = ITColors.getPriorityColor(alert.severity);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ITColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: severityColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        alert.source,
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              alert.description,
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              'Severity',
              alert.severity.toUpperCase(),
              severityColor,
              isDark,
            ),
            _buildDetailRow(
              'Time',
              alert.time,
              ITColors.textPrimaryColor(isDark),
              isDark,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ITColors.borderColor(isDark)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ITColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Investigate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
