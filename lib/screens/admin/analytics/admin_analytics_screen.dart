import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/analytics/analytics_barrel.dart';
import '../../../widgets/admin/dashboard/admin_drawer.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TimePeriod _selectedPeriod = TimePeriod.thisWeek;
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Sample data
  late double _systemHealth;
  late double _cpuUsage;
  late double _memoryUsage;
  late double _diskUsage;
  late double _networkLatency;
  late List<KeyMetric> _keyMetrics;
  late List<UserActivityData> _activityData;
  late List<ServerInfo> _servers;
  late List<SystemEvent> _events;
  late List<String> _aiInsights;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() => _isLoading = true);

    // Sample system health data
    _systemHealth = 63.4;
    _cpuUsage = 42.5;
    _memoryUsage = 68.2;
    _diskUsage = 55.8;
    _networkLatency = 120;

    // Key metrics
    _keyMetrics = [
      KeyMetric(
        id: '1',
        title: 'Active Users',
        value: '1,234',
        change: '+12.5%',
        isPositive: true,
        icon: Icons.people_outline_rounded,
        color: AdminColors.primary,
      ),
      KeyMetric(
        id: '2',
        title: 'Page Views',
        value: '45.2K',
        change: '+8.3%',
        isPositive: true,
        icon: Icons.visibility_outlined,
        color: AdminColors.secondary,
      ),
      KeyMetric(
        id: '3',
        title: 'Avg Response',
        value: '120ms',
        change: '-5.2%',
        isPositive: true,
        icon: Icons.speed_rounded,
        color: AdminColors.chartCyan,
      ),
      KeyMetric(
        id: '4',
        title: 'Error Rate',
        value: '0.5%',
        change: '-0.3%',
        isPositive: true,
        icon: Icons.error_outline_rounded,
        color: AdminColors.chartGreen,
      ),
    ];

    // Activity data
    _activityData = [
      const UserActivityData(label: 'Mon', value: 2400),
      const UserActivityData(label: 'Tue', value: 1398),
      const UserActivityData(label: 'Wed', value: 9800),
      const UserActivityData(label: 'Thu', value: 3908),
      const UserActivityData(label: 'Fri', value: 4800),
      const UserActivityData(label: 'Sat', value: 3800),
      const UserActivityData(label: 'Sun', value: 4300),
    ];

    // Server data
    _servers = [
      const ServerInfo(
        id: '1',
        name: 'Primary Server',
        status: ServerStatus.online,
        cpuUsage: 45,
        memoryUsage: 62,
        uptime: '99.99%',
        region: 'US-East',
      ),
      const ServerInfo(
        id: '2',
        name: 'Database Server',
        status: ServerStatus.online,
        cpuUsage: 38,
        memoryUsage: 71,
        uptime: '99.95%',
        region: 'US-East',
      ),
      const ServerInfo(
        id: '3',
        name: 'CDN Server',
        status: ServerStatus.warning,
        cpuUsage: 78,
        memoryUsage: 85,
        uptime: '99.80%',
        region: 'EU-West',
      ),
      const ServerInfo(
        id: '4',
        name: 'Backup Server',
        status: ServerStatus.online,
        cpuUsage: 12,
        memoryUsage: 25,
        uptime: '100%',
        region: 'US-West',
      ),
    ];

    // Events
    _events = [
      const SystemEvent(
        id: '1',
        message: 'System backup completed successfully',
        timestamp: '2 minutes ago',
        type: EventType.success,
      ),
      const SystemEvent(
        id: '2',
        message: 'High CPU usage detected on CDN Server',
        timestamp: '15 minutes ago',
        type: EventType.warning,
      ),
      const SystemEvent(
        id: '3',
        message: 'New user registration spike detected',
        timestamp: '1 hour ago',
        type: EventType.info,
      ),
      const SystemEvent(
        id: '4',
        message: 'Database optimization completed',
        timestamp: '3 hours ago',
        type: EventType.success,
      ),
    ];

    // AI Insights
    _aiInsights = [
      'Peak usage times are between 9 AM - 11 AM and 2 PM - 4 PM',
      'Consider scaling up CDN resources for better performance',
      'Memory usage has increased 15% over the past week',
      'Recommend enabling auto-scaling for traffic spikes',
    ];

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _refreshData() {
    setState(() => _isRefreshing = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _loadData();
        setState(() => _isRefreshing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).dataRefreshed),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    });
  }

  void _exportData() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.exportingData),
        backgroundColor: AdminColors.primary,
      ),
    );
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AdminColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedPeriod = TimePeriod.custom);
      // Apply custom date range
    }
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
    return Center(child: CircularProgressIndicator(color: AdminColors.primary));
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        return RefreshIndicator(
          onRefresh: () async => _refreshData(),
          color: AdminColors.primary,
          child: CustomScrollView(
            slivers: [
              // App Bar
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.all(20),
              //     child: Row(
              //       children: [
              //         IconButton(
              //           onPressed: () =>
              //               _scaffoldKey.currentState?.openDrawer(),
              //           icon: Icon(
              //             Icons.menu_rounded,
              //             color: AdminColors.getTextColor(isDark),
              //           ),
              //         ),
              //         const Spacer(),
              //         if (_isRefreshing)
              //           SizedBox(
              //             width: 20,
              //             height: 20,
              //             child: CircularProgressIndicator(
              //               strokeWidth: 2,
              //               color: AdminColors.primary,
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnalyticsHeader(
                    isDark: isDark,
                    onExport: _exportData,
                    onRefresh: _refreshData,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              // Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnalyticsFilters(
                    isDark: isDark,
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() => _selectedPeriod = period);
                      _loadData();
                    },
                    onCustomDateRange: _showCustomDatePicker,
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
        // Left Column
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Key Metrics
              KeyMetricsGrid(
                isDark: isDark,
                metrics: _keyMetrics,
                onMetricTap: _onMetricTap,
              ),
              const SizedBox(height: 20),
              // User Activity Chart
              UserActivityChart(
                isDark: isDark,
                data: _activityData,
                title: l10n.userActivity,
                onViewMore: () => _showViewMore(l10n.userActivity),
              ),
              const SizedBox(height: 20),
              // Recent Events
              RecentEventsCard(
                isDark: isDark,
                events: _events,
                onEventTap: _onEventTap,
                onViewAll: () => _showViewMore(l10n.recentSystemEvents),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right Column
        Expanded(
          child: Column(
            children: [
              // System Health
              SystemHealthCard(
                isDark: isDark,
                healthPercent: _systemHealth,
                cpuUsage: _cpuUsage,
                memoryUsage: _memoryUsage,
                diskUsage: _diskUsage,
                networkLatency: _networkLatency,
              ),
              const SizedBox(height: 20),
              // AI Insights
              AnalyticsAiInsights(
                isDark: isDark,
                insights: _aiInsights,
                onViewDetails: () => _showViewMore(l10n.aiInsights),
              ),
              const SizedBox(height: 20),
              // Server Status
              ServerStatusCard(
                isDark: isDark,
                servers: _servers,
                onServerTap: _onServerTap,
                onViewAll: () => _showViewMore(l10n.serverStatus),
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
        // Key Metrics Row
        KeyMetricsRow(
          isDark: isDark,
          metrics: _keyMetrics,
          onMetricTap: _onMetricTap,
        ),
        const SizedBox(height: 20),
        // System Health
        SystemHealthCard(
          isDark: isDark,
          healthPercent: _systemHealth,
          cpuUsage: _cpuUsage,
          memoryUsage: _memoryUsage,
          diskUsage: _diskUsage,
          networkLatency: _networkLatency,
        ),
        const SizedBox(height: 20),
        // User Activity Chart
        UserActivityChart(
          isDark: isDark,
          data: _activityData,
          title: l10n.userActivity,
          onViewMore: () => _showViewMore(l10n.userActivity),
        ),
        const SizedBox(height: 20),
        // Server Status
        ServerStatusCard(
          isDark: isDark,
          servers: _servers,
          onServerTap: _onServerTap,
          onViewAll: () => _showViewMore(l10n.serverStatus),
        ),
        const SizedBox(height: 20),
        // AI Insights
        AnalyticsAiInsights(
          isDark: isDark,
          insights: _aiInsights,
          onViewDetails: () => _showViewMore(l10n.aiInsights),
        ),
        const SizedBox(height: 20),
        // Recent Events
        RecentEventsCard(
          isDark: isDark,
          events: _events,
          onEventTap: _onEventTap,
          onViewAll: () => _showViewMore(l10n.recentSystemEvents),
        ),
      ],
    );
  }

  void _onMetricTap(KeyMetric metric) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${metric.title}: ${metric.value}'),
        backgroundColor: metric.color,
      ),
    );
  }

  void _onServerTap(ServerInfo server) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          return AlertDialog(
            backgroundColor: AdminColors.getCardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(server.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  server.name,
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
                _buildDetailRow(l10n.region, server.region, isDark),
                _buildDetailRow(l10n.cpuUsage, '${server.cpuUsage}%', isDark),
                _buildDetailRow(
                  l10n.memoryUsage,
                  '${server.memoryUsage}%',
                  isDark,
                ),
                _buildDetailRow(l10n.uptime, server.uptime, isDark),
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

  void _onEventTap(SystemEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(event.message),
        backgroundColor: AdminColors.primary,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.online:
        return AdminColors.success;
      case ServerStatus.warning:
        return AdminColors.warning;
      case ServerStatus.offline:
        return AdminColors.error;
      case ServerStatus.maintenance:
        return AdminColors.chartPurple;
    }
  }
}
