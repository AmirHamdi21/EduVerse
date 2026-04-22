import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';
import '../../widgets/it_admin/database/database_barrel.dart';

class ITDatabaseScreen extends StatefulWidget {
  const ITDatabaseScreen({super.key});

  @override
  State<ITDatabaseScreen> createState() => _ITDatabaseScreenState();
}

class _ITDatabaseScreenState extends State<ITDatabaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  late List<DatabaseInstance> _databases;
  late DatabaseStats _stats;
  late List<TableInfo> _tables;

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

      _databases = _getMockDatabases();
      _stats = _calculateStats();
      _tables = _getMockTables();

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

  List<DatabaseInstance> _getMockDatabases() {
    return [
      DatabaseInstance(
        id: '1',
        name: 'edu-primary',
        type: 'PostgreSQL',
        status: 'operational',
        version: '15.2',
        host: 'db-primary.edu.local',
        port: 5432,
        storageUsed: 245.5,
        storageTotal: 500,
        activeConnections: 85,
        maxConnections: 200,
        queryLatency: 2.5,
      ),
      DatabaseInstance(
        id: '2',
        name: 'edu-replica',
        type: 'PostgreSQL',
        status: 'operational',
        version: '15.2',
        host: 'db-replica.edu.local',
        port: 5432,
        storageUsed: 245.2,
        storageTotal: 500,
        activeConnections: 45,
        maxConnections: 200,
        queryLatency: 3.2,
      ),
      DatabaseInstance(
        id: '3',
        name: 'edu-analytics',
        type: 'MongoDB',
        status: 'operational',
        version: '6.0',
        host: 'mongo.edu.local',
        port: 27017,
        storageUsed: 128.7,
        storageTotal: 250,
        activeConnections: 25,
        maxConnections: 100,
        queryLatency: 5.8,
      ),
      DatabaseInstance(
        id: '4',
        name: 'edu-cache',
        type: 'Redis',
        status: 'degraded',
        version: '7.2',
        host: 'redis.edu.local',
        port: 6379,
        storageUsed: 4.2,
        storageTotal: 16,
        activeConnections: 150,
        maxConnections: 500,
        queryLatency: 0.3,
      ),
      DatabaseInstance(
        id: '5',
        name: 'edu-search',
        type: 'Elasticsearch',
        status: 'operational',
        version: '8.11',
        host: 'search.edu.local',
        port: 9200,
        storageUsed: 85.3,
        storageTotal: 200,
        activeConnections: 12,
        maxConnections: 50,
        queryLatency: 15.2,
      ),
    ];
  }

  List<TableInfo> _getMockTables() {
    return [
      TableInfo(
        name: 'users',
        rows: 125000,
        size: 45.2,
        lastUpdated: '2 min ago',
      ),
      TableInfo(
        name: 'courses',
        rows: 3500,
        size: 12.8,
        lastUpdated: '5 min ago',
      ),
      TableInfo(
        name: 'enrollments',
        rows: 450000,
        size: 78.5,
        lastUpdated: '1 min ago',
      ),
      TableInfo(
        name: 'assignments',
        rows: 28000,
        size: 156.3,
        lastUpdated: '3 min ago',
      ),
      TableInfo(
        name: 'submissions',
        rows: 890000,
        size: 234.7,
        lastUpdated: '30 sec ago',
      ),
      TableInfo(
        name: 'grades',
        rows: 750000,
        size: 45.9,
        lastUpdated: '2 min ago',
      ),
    ];
  }

  DatabaseStats _calculateStats() {
    final active = _databases.where((d) => d.status == 'operational').length;
    final totalStorage = _databases
        .map((d) => d.storageTotal)
        .reduce((a, b) => a + b);
    final usedStorage = _databases
        .map((d) => d.storageUsed)
        .reduce((a, b) => a + b);
    final totalConns = _databases
        .map((d) => d.activeConnections)
        .reduce((a, b) => a + b);
    final avgLatency =
        _databases.map((d) => d.queryLatency).reduce((a, b) => a + b) /
        _databases.length;

    return DatabaseStats(
      totalDatabases: _databases.length,
      activeDatabases: active,
      totalStorage: totalStorage,
      usedStorage: usedStorage,
      totalConnections: totalConns,
      avgLatency: avgLatency,
    );
  }

  List<DatabaseInstance> get _filteredDatabases {
    if (_selectedFilter == 'all') return _databases;
    if (_selectedFilter == 'type') return _databases;
    return _databases.where((d) => d.status == _selectedFilter).toList();
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
          // drawer: ITDrawer(currentRoute: '/it-admin/database', isDark: isDark),
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
        l10n.itDatabase,
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
          onPressed: () => _showSearchDialog(isDark),
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
          DatabaseStatsOverview(isDark: isDark, stats: _stats),
          const SizedBox(height: 20),
          DatabaseQuickActions(
            isDark: isDark,
            onBackup: () => _showBackupDialog(isDark),
            onOptimize: () => _showSnackBar('Optimizing databases...'),
            onQuery: () => _showQueryDialog(isDark),
          ),
          const SizedBox(height: 20),
          _buildFilterChips(isDark, l10n),
          const SizedBox(height: 16),
          DatabaseListSection(
            isDark: isDark,
            databases: _filteredDatabases,
            onDatabaseTap: _showDatabaseDetails,
          ),
          const SizedBox(height: 20),
          TableListSection(
            isDark: isDark,
            tables: _tables,
            onTableTap: _showTableDetails,
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

  void _showSearchDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Search Tables',
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Table name...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: ITColors.textSecondaryColor(isDark),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDatabaseDetails(DatabaseInstance db) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final statusColor = ITColors.getStatusColor(db.status);

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
                  child: Icon(
                    Icons.storage_rounded,
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        db.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${db.type} ${db.version}',
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
                    db.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Host', '${db.host}:${db.port}', isDark),
            _buildDetailRow(
              'Storage',
              '${db.storageUsed.toStringAsFixed(1)} / ${db.storageTotal.toStringAsFixed(0)} GB',
              isDark,
            ),
            _buildDetailRow(
              'Connections',
              '${db.activeConnections} / ${db.maxConnections}',
              isDark,
            ),
            _buildDetailRow('Query Latency', '${db.queryLatency}ms', isDark),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.terminal_rounded),
                    label: const Text('Console'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSnackBar('Backup started for ${db.name}');
                    },
                    icon: const Icon(Icons.backup_rounded, color: Colors.white),
                    label: const Text(
                      'Backup',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ITColors.primary,
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

  void _showTableDetails(TableInfo table) {
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
                    color: ITColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.table_chart_rounded,
                    color: ITColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  table.name,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Rows', _formatNumber(table.rows), isDark),
            _buildDetailRow(
              'Size',
              '${table.size.toStringAsFixed(1)} MB',
              isDark,
            ),
            _buildDetailRow('Last Updated', table.lastUpdated, isDark),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.schema_rounded),
                    label: const Text('Schema'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.code_rounded, color: Colors.white),
                    label: const Text(
                      'Query',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ITColors.primary,
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

  void _showBackupDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Backup Database',
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _databases
              .map(
                (db) => ListTile(
                  leading: Icon(Icons.storage_rounded, color: ITColors.primary),
                  title: Text(
                    db.name,
                    style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
                  ),
                  subtitle: Text(
                    db.type,
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSnackBar('Backup started for ${db.name}');
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showQueryDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Run Query',
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'SELECT * FROM users LIMIT 10;',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('Query executed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: const Text('Run', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
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
