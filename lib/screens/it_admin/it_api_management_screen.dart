import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';
import '../../widgets/it_admin/api_management/api_management_barrel.dart';

class ITApiManagementScreen extends StatefulWidget {
  const ITApiManagementScreen({super.key});

  @override
  State<ITApiManagementScreen> createState() => _ITApiManagementScreenState();
}

class _ITApiManagementScreenState extends State<ITApiManagementScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  late List<ApiEndpoint> _endpoints;
  late List<ApiKey> _apiKeys;
  late ApiStats _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      _endpoints = _getMockEndpoints();
      _apiKeys = _getMockApiKeys();
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

  List<ApiEndpoint> _getMockEndpoints() {
    return [
      ApiEndpoint(
        id: '1',
        name: 'Get User Profile',
        method: 'GET',
        path: '/api/v1/users/{id}',
        version: 'v1',
        status: 'operational',
        requestsToday: 15420,
        avgResponseTime: 45,
        successRate: 99.8,
        rateLimit: '1000/min',
      ),
      ApiEndpoint(
        id: '2',
        name: 'Create Course',
        method: 'POST',
        path: '/api/v1/courses',
        version: 'v1',
        status: 'operational',
        requestsToday: 3250,
        avgResponseTime: 120,
        successRate: 99.5,
        rateLimit: '500/min',
      ),
      ApiEndpoint(
        id: '3',
        name: 'Update Assignment',
        method: 'PUT',
        path: '/api/v1/assignments/{id}',
        version: 'v1',
        status: 'operational',
        requestsToday: 8900,
        avgResponseTime: 85,
        successRate: 99.2,
        rateLimit: '750/min',
      ),
      ApiEndpoint(
        id: '4',
        name: 'Delete Submission',
        method: 'DELETE',
        path: '/api/v1/submissions/{id}',
        version: 'v1',
        status: 'operational',
        requestsToday: 450,
        avgResponseTime: 35,
        successRate: 100,
        rateLimit: '200/min',
      ),
      ApiEndpoint(
        id: '5',
        name: 'Get Grades (Legacy)',
        method: 'GET',
        path: '/api/v0/grades',
        version: 'v0',
        status: 'deprecated',
        requestsToday: 120,
        avgResponseTime: 200,
        successRate: 95.0,
        rateLimit: '100/min',
      ),
      ApiEndpoint(
        id: '6',
        name: 'Batch Upload',
        method: 'POST',
        path: '/api/v1/batch/upload',
        version: 'v1',
        status: 'degraded',
        requestsToday: 890,
        avgResponseTime: 2500,
        successRate: 92.5,
        rateLimit: '50/min',
      ),
    ];
  }

  List<ApiKey> _getMockApiKeys() {
    return [
      ApiKey(
        id: '1',
        name: 'Production App',
        key: 'sk_prod_abc123xyz789def456',
        status: 'active',
        createdAt: '2024-01-15',
        expiresAt: '2025-01-15',
        requestsToday: 45000,
        scopes: ['read', 'write'],
      ),
      ApiKey(
        id: '2',
        name: 'Mobile Client',
        key: 'sk_mob_def456ghi789jkl012',
        status: 'active',
        createdAt: '2024-03-01',
        expiresAt: '2025-03-01',
        requestsToday: 28000,
        scopes: ['read'],
      ),
      ApiKey(
        id: '3',
        name: 'Analytics Service',
        key: 'sk_ana_mno345pqr678stu901',
        status: 'active',
        createdAt: '2024-02-20',
        expiresAt: '2025-02-20',
        requestsToday: 12000,
        scopes: ['read', 'analytics'],
      ),
      ApiKey(
        id: '4',
        name: 'Legacy Integration',
        key: 'sk_leg_vwx234yza567bcd890',
        status: 'revoked',
        createdAt: '2023-06-01',
        expiresAt: '2024-06-01',
        requestsToday: 0,
        scopes: ['read'],
      ),
    ];
  }

  ApiStats _calculateStats() {
    final active = _endpoints.where((e) => e.status == 'operational').length;
    final deprecated = _endpoints.where((e) => e.status == 'deprecated').length;
    final totalReqs = _endpoints
        .map((e) => e.requestsToday)
        .reduce((a, b) => a + b);
    final avgTime =
        _endpoints.map((e) => e.avgResponseTime).reduce((a, b) => a + b) /
        _endpoints.length;

    return ApiStats(
      totalEndpoints: _endpoints.length,
      activeEndpoints: active,
      deprecatedEndpoints: deprecated,
      totalRequests: totalReqs,
      avgResponseTime: avgTime,
      uptime: 99.95,
    );
  }

  List<ApiEndpoint> get _filteredEndpoints {
    if (_selectedFilter == 'all') return _endpoints;
    return _endpoints.where((e) => e.status == _selectedFilter).toList();
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
          // drawer: ITDrawer(currentRoute: '/it-admin/api', isDark: isDark),
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
        l10n.itApiManagement,
        style: TextStyle(
          color: ITColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: ITColors.primary,
        labelColor: ITColors.primary,
        unselectedLabelColor: ITColors.textSecondaryColor(isDark),
        tabs: [
          Tab(text: l10n.itEndpoints),
          Tab(text: l10n.itApiKeys),
        ],
      ),
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
    return TabBarView(
      controller: _tabController,
      children: [
        _buildEndpointsTab(isDark, l10n),
        _buildApiKeysTab(isDark, l10n),
      ],
    );
  }

  Widget _buildEndpointsTab(bool isDark, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ApiStatsOverview(isDark: isDark, stats: _stats),
          const SizedBox(height: 20),
          ApiQuickActions(
            isDark: isDark,
            onCreateEndpoint: _showCreateEndpointDialog,
            onViewDocs: () => _showSnackBar('Opening API documentation...'),
            onViewLogs: () => _showSnackBar('Opening API logs...'),
          ),
          const SizedBox(height: 20),
          _buildFilterChips(isDark, l10n),
          const SizedBox(height: 16),
          ApiEndpointsSection(
            isDark: isDark,
            endpoints: _filteredEndpoints,
            onEndpointTap: _showEndpointDetails,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildApiKeysTab(bool isDark, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ApiKeysSection(
            isDark: isDark,
            apiKeys: _apiKeys,
            onKeyTap: _showKeyDetails,
            onCreateKey: _showCreateKeyDialog,
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
      {'id': 'deprecated', 'label': l10n.itDeprecated},
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

  void _showEndpointDetails(ApiEndpoint endpoint) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final methodColors = {
      'GET': ITColors.success,
      'POST': ITColors.info,
      'PUT': ITColors.warning,
      'DELETE': ITColors.error,
    };
    final methodColor = methodColors[endpoint.method] ?? ITColors.primary;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    endpoint.method,
                    style: TextStyle(
                      color: methodColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    endpoint.name,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ITColors.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                endpoint.path,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Version', endpoint.version, isDark),
            _buildDetailRow(
              'Requests Today',
              '${endpoint.requestsToday}',
              isDark,
            ),
            _buildDetailRow(
              'Avg Response Time',
              '${endpoint.avgResponseTime}ms',
              isDark,
            ),
            _buildDetailRow('Success Rate', '${endpoint.successRate}%', isDark),
            _buildDetailRow('Rate Limit', endpoint.rateLimit, isDark),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Test',
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

  void _showKeyDetails(ApiKey apiKey) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final statusColor = apiKey.status == 'active'
        ? ITColors.success
        : ITColors.error;

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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.key_rounded, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apiKey.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        apiKey.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Created', apiKey.createdAt, isDark),
            _buildDetailRow('Expires', apiKey.expiresAt, isDark),
            _buildDetailRow(
              'Requests Today',
              '${apiKey.requestsToday}',
              isDark,
            ),
            _buildDetailRow('Scopes', apiKey.scopes.join(', '), isDark),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSnackBar('Key copied to clipboard');
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSnackBar('Key revoked');
                    },
                    icon: const Icon(Icons.block_rounded, color: Colors.white),
                    label: const Text(
                      'Revoke',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ITColors.error,
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

  void _showCreateEndpointDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create Endpoint',
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Endpoint Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Path',
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
              _showSnackBar('Endpoint created');
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateKeyDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create API Key',
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Key Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Scopes (comma separated)',
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
              _showSnackBar('API Key created');
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
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
