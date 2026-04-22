import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';
import '../../widgets/it_admin/servers/servers_barrel.dart';

class ITServerManagementScreen extends StatefulWidget {
  const ITServerManagementScreen({super.key});

  @override
  State<ITServerManagementScreen> createState() =>
      _ITServerManagementScreenState();
}

class _ITServerManagementScreenState extends State<ITServerManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  late List<Server> _servers;
  late ServerStats _stats;

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

      _servers = _getMockServers();
      _stats = _calculateStats();

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

  List<Server> _getMockServers() {
    return [
      Server(
        id: '1',
        name: 'APP-SERVER-01',
        type: 'Application',
        status: 'operational',
        ipAddress: '10.0.1.10',
        region: 'US-East',
        cpuUsage: 45.0,
        memoryUsage: 62.0,
        diskUsage: 38.0,
        uptime: '45 days',
        os: 'Ubuntu 22.04',
        activeConnections: 234,
      ),
      Server(
        id: '2',
        name: 'APP-SERVER-02',
        type: 'Application',
        status: 'operational',
        ipAddress: '10.0.1.11',
        region: 'US-East',
        cpuUsage: 52.0,
        memoryUsage: 71.0,
        diskUsage: 45.0,
        uptime: '45 days',
        os: 'Ubuntu 22.04',
        activeConnections: 189,
      ),
      Server(
        id: '3',
        name: 'DB-PRIMARY',
        type: 'Database',
        status: 'operational',
        ipAddress: '10.0.2.10',
        region: 'US-East',
        cpuUsage: 38.0,
        memoryUsage: 78.0,
        diskUsage: 55.0,
        uptime: '120 days',
        os: 'Ubuntu 22.04',
        activeConnections: 45,
      ),
      Server(
        id: '4',
        name: 'DB-REPLICA-01',
        type: 'Database',
        status: 'operational',
        ipAddress: '10.0.2.11',
        region: 'US-West',
        cpuUsage: 25.0,
        memoryUsage: 65.0,
        diskUsage: 52.0,
        uptime: '90 days',
        os: 'Ubuntu 22.04',
        activeConnections: 12,
      ),
      Server(
        id: '5',
        name: 'CACHE-01',
        type: 'Cache',
        status: 'degraded',
        ipAddress: '10.0.3.10',
        region: 'US-East',
        cpuUsage: 82.0,
        memoryUsage: 88.0,
        diskUsage: 20.0,
        uptime: '30 days',
        os: 'Alpine',
        activeConnections: 500,
      ),
      Server(
        id: '6',
        name: 'LB-01',
        type: 'Load Balancer',
        status: 'operational',
        ipAddress: '10.0.0.10',
        region: 'US-East',
        cpuUsage: 15.0,
        memoryUsage: 22.0,
        diskUsage: 10.0,
        uptime: '180 days',
        os: 'HAProxy',
        activeConnections: 1250,
      ),
      Server(
        id: '7',
        name: 'STORAGE-01',
        type: 'Storage',
        status: 'maintenance',
        ipAddress: '10.0.4.10',
        region: 'US-East',
        cpuUsage: 0.0,
        memoryUsage: 0.0,
        diskUsage: 72.0,
        uptime: '0 days',
        os: 'FreeNAS',
        activeConnections: 0,
      ),
    ];
  }

  ServerStats _calculateStats() {
    final online = _servers.where((s) => s.status == 'operational').length;
    final offline = _servers.where((s) => s.status == 'offline').length;
    final maintenance = _servers.where((s) => s.status == 'maintenance').length;
    final avgCpu =
        _servers.map((s) => s.cpuUsage).reduce((a, b) => a + b) /
        _servers.length;
    final avgMem =
        _servers.map((s) => s.memoryUsage).reduce((a, b) => a + b) /
        _servers.length;

    return ServerStats(
      totalServers: _servers.length,
      onlineServers: online,
      offlineServers: offline,
      maintenanceServers: maintenance,
      avgCpu: avgCpu,
      avgMemory: avgMem,
    );
  }

  List<Server> get _filteredServers {
    var filtered = _servers;
    if (_selectedFilter != 'all') {
      filtered = filtered.where((s) => s.status == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.ipAddress.contains(_searchQuery),
          )
          .toList();
    }
    return filtered;
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
          // drawer: ITDrawer(currentRoute: '/it-admin/servers', isDark: isDark),
          appBar: _buildAppBar(l10n, isDark),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: ITColors.primary),
                )
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
        l10n.itServerManagement,
        style: TextStyle(
          color: ITColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: ITColors.textSecondaryColor(isDark),
          ),
          onPressed: () => _showSearchDialog(isDark, l10n),
        ),
        const SizedBox(width: 8),
      ],
    );
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
    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ServerStatsOverview(isDark: isDark, stats: _stats),
          const SizedBox(height: 20),
          ServerQuickActions(
            isDark: isDark,
            onAddServer: _showAddServerDialog,
            onBulkAction: _showBulkActionsDialog,
            onRefresh: _loadData,
          ),
          const SizedBox(height: 20),
          _buildFilterChips(isDark, l10n),
          const SizedBox(height: 16),
          ServerListSection(
            isDark: isDark,
            servers: _filteredServers,
            onServerTap: _showServerDetails,
            onServerAction: _handleServerAction,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.all},
      {'id': 'operational', 'label': l10n.itOperational},
      {'id': 'degraded', 'label': l10n.itDegraded},
      {'id': 'maintenance', 'label': l10n.itMaintenance},
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
              label: Text(filter['label'] as String),
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
              onSelected: (_) =>
                  setState(() => _selectedFilter = filter['id'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSearchDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.search,
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search servers...',
            hintStyle: TextStyle(color: ITColors.textTertiaryColor(isDark)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: ITColors.textSecondaryColor(isDark),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: Text(
              l10n.search,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerDetails(Server server) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final statusColor = ITColors.getStatusColor(server.status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.dns_rounded, color: statusColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${server.type} Server',
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    server.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('IP Address', server.ipAddress, isDark),
            _buildDetailRow('Region', server.region, isDark),
            _buildDetailRow('OS', server.os, isDark),
            _buildDetailRow('Uptime', server.uptime, isDark),
            _buildDetailRow(
              'Connections',
              '${server.activeConnections}',
              isDark,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildUsageIndicator('CPU', server.cpuUsage, isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUsageIndicator(
                    'RAM',
                    server.memoryUsage,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUsageIndicator('Disk', server.diskUsage, isDark),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.terminal_rounded),
                    label: const Text('SSH'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Restart',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ITColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
          ),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageIndicator(String label, double value, bool isDark) {
    final color = value > 80
        ? ITColors.error
        : value > 60
        ? ITColors.warning
        : ITColors.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ITColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${value.toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: ITColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleServerAction(Server server) {
    _showSnackBar('Action performed on ${server.name}');
  }

  void _showAddServerDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Server',
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Server Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'IP Address',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('Server added successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBulkActionsDialog() {
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
          children: [
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: const Text('Restart All'),
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Restarting all servers...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.update_rounded),
              title: const Text('Update All'),
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Updating all servers...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup_rounded),
              title: const Text('Backup All'),
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Backing up all servers...');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ITColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
