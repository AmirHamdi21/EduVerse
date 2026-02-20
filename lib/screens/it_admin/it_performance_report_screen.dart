import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/performance_report/it_performance_report_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITPerformanceReportScreen extends StatefulWidget {
  const ITPerformanceReportScreen({super.key});

  @override
  State<ITPerformanceReportScreen> createState() => _ITPerformanceReportScreenState();
}

class _ITPerformanceReportScreenState extends State<ITPerformanceReportScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // State
  TimePeriod _selectedPeriod = TimePeriod.today;
  int _selectedTrendTab = 0;
  
  // Data
  List<PerformanceMetric> _metrics = [];
  List<ServerHealth> _servers = [];
  List<PerformanceAlert> _alerts = [];
  List<ResourceUtilization> _resources = [];
  List<TrendDataPoint> _cpuTrend = [];
  List<TrendDataPoint> _memoryTrend = [];
  List<TrendDataPoint> _responseTimeTrend = [];

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
      _servers = _getMockServers();
      _alerts = _getMockAlerts();
      _resources = _getMockResources();
      _cpuTrend = _getMockTrendData(45, 75);
      _memoryTrend = _getMockTrendData(55, 85);
      _responseTimeTrend = _getMockTrendData(80, 250);

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

  List<PerformanceMetric> _getMockMetrics() {
    return [
      PerformanceMetric(
        id: 'cpu',
        name: 'CPU Usage',
        value: 67.5,
        unit: '%',
        icon: Icons.memory_rounded,
        color: ITColors.primary,
        trend: 5.2,
        isUp: true,
      ),
      PerformanceMetric(
        id: 'memory',
        name: 'Memory Usage',
        value: 78.3,
        unit: '%',
        icon: Icons.storage_rounded,
        color: ITColors.purple,
        trend: 2.1,
        isUp: true,
      ),
      PerformanceMetric(
        id: 'disk',
        name: 'Disk Usage',
        value: 45.8,
        unit: '%',
        icon: Icons.disc_full_rounded,
        color: ITColors.teal,
        trend: 0.5,
        isUp: true,
      ),
      PerformanceMetric(
        id: 'network',
        name: 'Network I/O',
        value: 125,
        maxValue: 1000,
        unit: 'Mbps',
        icon: Icons.wifi_rounded,
        color: ITColors.success,
        trend: 15.3,
        isUp: true,
      ),
      PerformanceMetric(
        id: 'response',
        name: 'Avg Response Time',
        value: 142,
        maxValue: 500,
        unit: 'ms',
        icon: Icons.speed_rounded,
        color: ITColors.orange,
        trend: 3.2,
        isUp: false,
      ),
      PerformanceMetric(
        id: 'users',
        name: 'Active Users',
        value: 1248,
        maxValue: 5000,
        unit: '',
        icon: Icons.people_rounded,
        color: ITColors.info,
        trend: 12.5,
        isUp: true,
      ),
    ];
  }

  List<ServerHealth> _getMockServers() {
    final now = DateTime.now();
    return [
      ServerHealth(
        id: 's1',
        name: 'App Server 01',
        type: 'Application',
        status: ServerStatus.healthy,
        cpuUsage: 45.2,
        memoryUsage: 62.5,
        diskUsage: 38.7,
        uptime: '45d 12h 30m',
        lastChecked: now,
      ),
      ServerHealth(
        id: 's2',
        name: 'Database Server',
        type: 'Database',
        status: ServerStatus.warning,
        cpuUsage: 78.5,
        memoryUsage: 85.2,
        diskUsage: 72.3,
        uptime: '30d 8h 15m',
        lastChecked: now,
      ),
      ServerHealth(
        id: 's3',
        name: 'Web Server',
        type: 'Web',
        status: ServerStatus.healthy,
        cpuUsage: 32.1,
        memoryUsage: 48.9,
        diskUsage: 25.4,
        uptime: '60d 4h 45m',
        lastChecked: now,
      ),
      ServerHealth(
        id: 's4',
        name: 'Cache Server',
        type: 'Cache',
        status: ServerStatus.critical,
        cpuUsage: 92.5,
        memoryUsage: 95.8,
        diskUsage: 88.2,
        uptime: '15d 2h 10m',
        lastChecked: now,
      ),
    ];
  }

  List<PerformanceAlert> _getMockAlerts() {
    final now = DateTime.now();
    return [
      PerformanceAlert(
        id: 'a1',
        type: AlertType.memory,
        severity: AlertSeverity.critical,
        title: 'High Memory Usage',
        description: 'Cache Server memory usage exceeded 95% threshold',
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      PerformanceAlert(
        id: 'a2',
        type: AlertType.cpu,
        severity: AlertSeverity.warning,
        title: 'Elevated CPU Usage',
        description: 'Database Server CPU usage at 78% for 15 minutes',
        timestamp: now.subtract(const Duration(minutes: 20)),
      ),
      PerformanceAlert(
        id: 'a3',
        type: AlertType.disk,
        severity: AlertSeverity.warning,
        title: 'Disk Space Low',
        description: 'Database Server disk usage approaching 75%',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      PerformanceAlert(
        id: 'a4',
        type: AlertType.latency,
        severity: AlertSeverity.info,
        title: 'Response Time Spike',
        description: 'API response time increased by 15% during peak hours',
        timestamp: now.subtract(const Duration(hours: 3)),
        isResolved: true,
      ),
      PerformanceAlert(
        id: 'a5',
        type: AlertType.network,
        severity: AlertSeverity.info,
        title: 'Network Traffic Increase',
        description: 'Unusual network traffic pattern detected',
        timestamp: now.subtract(const Duration(hours: 6)),
        isResolved: true,
      ),
    ];
  }

  List<ResourceUtilization> _getMockResources() {
    return [
      ResourceUtilization(
        name: 'Database Storage',
        used: 245.5,
        total: 500,
        unit: 'GB',
        color: ITColors.primary,
      ),
      ResourceUtilization(
        name: 'File Storage',
        used: 1.2,
        total: 2,
        unit: 'TB',
        color: ITColors.teal,
      ),
      ResourceUtilization(
        name: 'Backup Storage',
        used: 180,
        total: 300,
        unit: 'GB',
        color: ITColors.purple,
      ),
      ResourceUtilization(
        name: 'Log Archives',
        used: 45,
        total: 100,
        unit: 'GB',
        color: ITColors.orange,
      ),
    ];
  }

  List<TrendDataPoint> _getMockTrendData(double minValue, double maxValue) {
    final now = DateTime.now();
    final data = <TrendDataPoint>[];
    
    for (var i = 23; i >= 0; i--) {
      final time = now.subtract(Duration(hours: i));
      final range = maxValue - minValue;
      final value = minValue + (range * 0.5) + 
          (range * 0.3 * (i % 6 - 3) / 3) + 
          (range * 0.2 * ((i * 17) % 7 - 3) / 3);
      data.add(TrendDataPoint(time: time, value: value.clamp(minValue, maxValue)));
    }
    
    return data;
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

  void _handlePeriodChanged(TimePeriod period) {
    setState(() => _selectedPeriod = period);
    _loadData();
  }

  void _handleExport() {
    _showSnackBar('Exporting performance report...');
  }

  void _handleServerTap(ServerHealth server) {
    _showServerDetails(server);
  }

  void _showServerDetails(ServerHealth server) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Server info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: server.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    server.typeIcon,
                    size: 28,
                    color: server.statusColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: server.statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: server.statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  server.statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: server.statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Metrics
            _buildDetailMetricRow('CPU Usage', server.cpuUsage, ITColors.primary, isDark),
            const SizedBox(height: 12),
            _buildDetailMetricRow('Memory Usage', server.memoryUsage, ITColors.purple, isDark),
            const SizedBox(height: 12),
            _buildDetailMetricRow('Disk Usage', server.diskUsage, ITColors.teal, isDark),
            const SizedBox(height: 20),
            
            // Uptime
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : ITColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: 20,
                    color: ITColors.success,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Uptime: ${server.uptime}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ITColors.textPrimaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackBar('Restarting ${server.name}...');
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Restart'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ITColors.warning,
                      side: BorderSide(color: ITColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ITColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMetricRow(String label, double value, Color color, bool isDark) {
    final isHigh = value > 80;
    final isMedium = value > 60 && value <= 80;
    final displayColor = isHigh ? ITColors.error : isMedium ? ITColors.warning : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: ITColors.textSecondaryColor(isDark),
              ),
            ),
            Text(
              '${value.round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: displayColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [displayColor, displayColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleAlertTap(PerformanceAlert alert) {
    _showSnackBar('Viewing alert: ${alert.title}');
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
          drawer: ITDrawer(currentRoute: '/it-admin/performance', isDark: isDark),
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
                          Color(0xFFECFDF5),
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
          ITPerformanceReportAppBar(
            isDark: isDark,
            title: l10n.itPerformanceReports,
            subtitle: l10n.itPerformanceReportsSubtitle,
            onExportTap: _handleExport,
            onRefreshTap: _loadData,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Time Period Selector
                ITTimePeriodSelector(
                  isDark: isDark,
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: _handlePeriodChanged,
                  onCustomTap: () => _showSnackBar('Custom date range picker'),
                ),
                const SizedBox(height: 20),
                
                // Performance Overview Cards
                ITPerformanceOverviewCards(
                  isDark: isDark,
                  metrics: _metrics,
                  onViewDetails: () => _showSnackBar('Viewing detailed metrics'),
                ),
                const SizedBox(height: 20),
                
                // Server Health Section
                ITServerHealthSection(
                  isDark: isDark,
                  servers: _servers,
                  onServerTap: _handleServerTap,
                  onViewAll: () => _showSnackBar('Viewing all servers'),
                ),
                const SizedBox(height: 20),
                
                // Performance Trends Section
                ITPerformanceTrendsSection(
                  isDark: isDark,
                  cpuData: _cpuTrend,
                  memoryData: _memoryTrend,
                  responseTimeData: _responseTimeTrend,
                  selectedTrendTab: _selectedTrendTab,
                  onTrendTabChanged: (index) {
                    setState(() => _selectedTrendTab = index);
                  },
                ),
                const SizedBox(height: 20),
                
                // Recent Alerts Section
                ITRecentAlertsSection(
                  isDark: isDark,
                  alerts: _alerts,
                  onAlertTap: _handleAlertTap,
                  onViewAll: () => _showSnackBar('Viewing all alerts'),
                ),
                const SizedBox(height: 20),
                
                // Resource Utilization Section
                ITResourceUtilizationSection(
                  isDark: isDark,
                  resources: _resources,
                  onManageStorage: () => _showSnackBar('Managing storage'),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
