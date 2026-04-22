import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';
import '../../widgets/it_admin/cloud_services/cloud_services_barrel.dart';

class ITCloudServicesScreen extends StatefulWidget {
  const ITCloudServicesScreen({super.key});

  @override
  State<ITCloudServicesScreen> createState() => _ITCloudServicesScreenState();
}

class _ITCloudServicesScreenState extends State<ITCloudServicesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedProvider = 'all';

  late List<CloudService> _services;
  late List<CloudProvider> _providers;
  late CloudStats _stats;

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
      _providers = _getMockProviders();
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

  List<CloudService> _getMockServices() {
    return [
      CloudService(
        id: '1',
        name: 'edu-web-app',
        provider: 'AWS',
        type: 'Compute',
        status: 'operational',
        region: 'us-east-1',
        monthlyCost: 450.00,
        usagePercent: 65,
        lastSync: '2 min ago',
      ),
      CloudService(
        id: '2',
        name: 'edu-api-gateway',
        provider: 'AWS',
        type: 'Serverless',
        status: 'operational',
        region: 'us-east-1',
        monthlyCost: 120.50,
        usagePercent: 45,
        lastSync: '5 min ago',
      ),
      CloudService(
        id: '3',
        name: 'edu-storage',
        provider: 'Azure',
        type: 'Storage',
        status: 'operational',
        region: 'eastus',
        monthlyCost: 280.00,
        usagePercent: 78,
        lastSync: '1 min ago',
      ),
      CloudService(
        id: '4',
        name: 'edu-cdn',
        provider: 'GCP',
        type: 'CDN',
        status: 'operational',
        region: 'global',
        monthlyCost: 95.25,
        usagePercent: 52,
        lastSync: '3 min ago',
      ),
      CloudService(
        id: '5',
        name: 'edu-ml-training',
        provider: 'AWS',
        type: 'Compute',
        status: 'degraded',
        region: 'us-west-2',
        monthlyCost: 890.00,
        usagePercent: 92,
        lastSync: '10 min ago',
      ),
      CloudService(
        id: '6',
        name: 'edu-backup',
        provider: 'Azure',
        type: 'Storage',
        status: 'operational',
        region: 'westeurope',
        monthlyCost: 150.00,
        usagePercent: 35,
        lastSync: '15 min ago',
      ),
    ];
  }

  List<CloudProvider> _getMockProviders() {
    return [
      CloudProvider(name: 'AWS', services: 3, cost: 1460.50, logo: 'aws'),
      CloudProvider(name: 'Azure', services: 2, cost: 430.00, logo: 'azure'),
      CloudProvider(name: 'GCP', services: 1, cost: 95.25, logo: 'gcp'),
    ];
  }

  CloudStats _calculateStats() {
    final active = _services.where((s) => s.status == 'operational').length;
    final totalCost = _services
        .map((s) => s.monthlyCost)
        .reduce((a, b) => a + b);
    final regions = _services.map((s) => s.region).toSet().length;

    return CloudStats(
      totalServices: _services.length,
      activeServices: active,
      totalCost: totalCost,
      budgetUsed: 75.5,
      avgUptime: 99.95,
      regions: regions,
    );
  }

  List<CloudService> get _filteredServices {
    if (_selectedProvider == 'all') return _services;
    return _services
        .where(
          (s) => s.provider.toLowerCase() == _selectedProvider.toLowerCase(),
        )
        .toList();
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
          // drawer: ITDrawer(currentRoute: '/it-admin/cloud', isDark: isDark),
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
        l10n.itCloudServices,
        style: TextStyle(
          color: ITColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.analytics_outlined,
            color: ITColors.textSecondaryColor(isDark),
          ),
          onPressed: () => _showCostAnalyticsSheet(isDark),
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
          CloudStatsOverview(isDark: isDark, stats: _stats),
          const SizedBox(height: 20),
          CloudProvidersSection(isDark: isDark, providers: _providers),
          const SizedBox(height: 20),
          CloudQuickActions(
            isDark: isDark,
            onAddService: _showAddServiceDialog,
            onViewCosts: () => _showCostAnalyticsSheet(isDark),
            onSync: () {
              _loadData();
              _showSnackBar('Syncing all services...');
            },
          ),
          const SizedBox(height: 20),
          _buildFilterChips(isDark, l10n),
          const SizedBox(height: 16),
          CloudServicesSection(
            isDark: isDark,
            services: _filteredServices,
            onServiceTap: _showServiceDetails,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.all},
      {'id': 'aws', 'label': 'AWS'},
      {'id': 'azure', 'label': 'Azure'},
      {'id': 'gcp', 'label': 'GCP'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedProvider == filter['id'];
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
                  setState(() => _selectedProvider = filter['id'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showServiceDetails(CloudService service) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final statusColor = ITColors.getStatusColor(service.status);
    final providerColors = {
      'aws': const Color(0xFFFF9900),
      'azure': const Color(0xFF0078D4),
      'gcp': const Color(0xFF4285F4),
    };
    final providerColor =
        providerColors[service.provider.toLowerCase()] ?? ITColors.primary;

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
                    color: providerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.cloud_rounded,
                    color: providerColor,
                    size: 32,
                  ),
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
                      Row(
                        children: [
                          Text(
                            service.provider,
                            style: TextStyle(
                              color: providerColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • ${service.type}',
                            style: TextStyle(
                              color: ITColors.textSecondaryColor(isDark),
                            ),
                          ),
                        ],
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
                    service.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Region', service.region, isDark),
            _buildDetailRow(
              'Monthly Cost',
              '\$${service.monthlyCost.toStringAsFixed(2)}',
              isDark,
            ),
            _buildDetailRow(
              'Usage',
              '${service.usagePercent.toInt()}%',
              isDark,
            ),
            _buildDetailRow('Last Sync', service.lastSync, isDark),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text('Configure'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSnackBar('Scaling ${service.name}...');
                    },
                    icon: const Icon(Icons.tune_rounded, color: Colors.white),
                    label: const Text(
                      'Scale',
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

  void _showCostAnalyticsSheet(bool isDark) {
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
            Text(
              'Cost Analytics',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildCostRow(
              'AWS Services',
              '\$1,460.50',
              const Color(0xFFFF9900),
              isDark,
            ),
            _buildCostRow(
              'Azure Services',
              '\$430.00',
              const Color(0xFF0078D4),
              isDark,
            ),
            _buildCostRow(
              'GCP Services',
              '\$95.25',
              const Color(0xFF4285F4),
              isDark,
            ),
            const Divider(height: 32),
            _buildCostRow(
              'Total Monthly',
              '\$${_stats.totalCost.toStringAsFixed(2)}',
              ITColors.primary,
              isDark,
              isBold: true,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ITColors.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: ITColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Status',
                          style: TextStyle(
                            color: ITColors.textPrimaryColor(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_stats.budgetUsed}% of monthly budget used',
                          style: TextStyle(
                            color: ITColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ITColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    String value,
    Color color,
    bool isDark, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
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

  void _showAddServiceDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Cloud Service',
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Provider',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'aws', child: Text('AWS')),
                DropdownMenuItem(value: 'azure', child: Text('Azure')),
                DropdownMenuItem(value: 'gcp', child: Text('GCP')),
              ],
              onChanged: (_) {},
              dropdownColor: ITColors.cardColor(isDark),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Service Name',
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
              _showSnackBar('Service added');
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
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
