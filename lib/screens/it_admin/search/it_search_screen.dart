import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/it_admin/shared/it_colors.dart';
import '../../../widgets/it_admin/search/search_barrel.dart';

class ITSearchScreen extends StatefulWidget {
  const ITSearchScreen({super.key});

  @override
  State<ITSearchScreen> createState() => _ITSearchScreenState();
}

class _ITSearchScreenState extends State<ITSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedCategory = 'all';
  String _statusFilter = 'all';
  String _priorityFilter = 'all';
  DateTimeRange? _dateRangeFilter;

  List<ITSearchResult> _searchResults = [];
  List<String> _recentSearches = [
    'API Server',
    'Database Error',
    'SSL Certificate',
    'Memory Usage',
  ];
  bool _isSearching = false;

  // Mock data for IT admin search
  final List<ITSearchResult> _allData = [
    // Servers
    ITSearchResult(
      id: '1',
      title: 'API Server 01',
      subtitle: 'Production • us-east-1',
      type: 'server',
      status: 'operational',
      timestamp: '45 days uptime',
    ),
    ITSearchResult(
      id: '2',
      title: 'Database Primary',
      subtitle: 'Production • us-east-1',
      type: 'server',
      status: 'operational',
      timestamp: '120 days uptime',
    ),
    ITSearchResult(
      id: '3',
      title: 'Storage Server',
      subtitle: 'Production • us-west-2',
      type: 'server',
      status: 'degraded',
      timestamp: '30 days uptime',
    ),
    ITSearchResult(
      id: '4',
      title: 'Auth Server',
      subtitle: 'Production • eu-west-1',
      type: 'server',
      status: 'operational',
      timestamp: '90 days uptime',
    ),
    ITSearchResult(
      id: '5',
      title: 'Cache Server',
      subtitle: 'Production • us-east-1',
      type: 'server',
      status: 'maintenance',
      timestamp: 'Scheduled maintenance',
    ),

    // Users
    ITSearchResult(
      id: '6',
      title: 'John Admin',
      subtitle: 'IT Administrator • Active',
      type: 'user',
      status: 'active',
    ),
    ITSearchResult(
      id: '7',
      title: 'Sarah Tech',
      subtitle: 'System Admin • Active',
      type: 'user',
      status: 'active',
    ),
    ITSearchResult(
      id: '8',
      title: 'Mike Support',
      subtitle: 'Support Engineer • Away',
      type: 'user',
      status: 'away',
    ),

    // Services
    ITSearchResult(
      id: '9',
      title: 'API Gateway',
      subtitle: 'Load Balancer • 127ms latency',
      type: 'service',
      status: 'operational',
    ),
    ITSearchResult(
      id: '10',
      title: 'Authentication',
      subtitle: 'OAuth 2.0 • Active',
      type: 'service',
      status: 'operational',
    ),
    ITSearchResult(
      id: '11',
      title: 'Email Service',
      subtitle: 'SMTP • 99.9% uptime',
      type: 'service',
      status: 'operational',
    ),
    ITSearchResult(
      id: '12',
      title: 'CDN',
      subtitle: 'CloudFront • Global',
      type: 'service',
      status: 'operational',
    ),

    // Alerts
    ITSearchResult(
      id: '13',
      title: 'High Memory Usage',
      subtitle: 'API Server 01 • Memory > 85%',
      type: 'alert',
      status: 'warning',
      timestamp: '15 min ago',
    ),
    ITSearchResult(
      id: '14',
      title: 'SSL Certificate Expiring',
      subtitle: 'api.eduverse.com • 7 days left',
      type: 'alert',
      status: 'warning',
      timestamp: '2 hours ago',
    ),
    ITSearchResult(
      id: '15',
      title: 'Disk Space Low',
      subtitle: 'Storage Server • 89% used',
      type: 'alert',
      status: 'critical',
      timestamp: '10 min ago',
    ),

    // Incidents
    ITSearchResult(
      id: '16',
      title: 'Database Connection Pool',
      subtitle: 'Connection limit reached',
      type: 'incident',
      status: 'resolved',
      timestamp: 'Yesterday',
    ),
    ITSearchResult(
      id: '17',
      title: 'API Latency Spike',
      subtitle: 'Response time > 500ms',
      type: 'incident',
      status: 'investigating',
      timestamp: '30 min ago',
    ),

    // Logs
    ITSearchResult(
      id: '18',
      title: 'Error: NullPointerException',
      subtitle: 'API Server 01 • auth-service',
      type: 'log',
      status: 'error',
      timestamp: '5 min ago',
    ),
    ITSearchResult(
      id: '19',
      title: 'Warning: Slow Query',
      subtitle: 'Database • users_table',
      type: 'log',
      status: 'warning',
      timestamp: '12 min ago',
    ),
    ITSearchResult(
      id: '20',
      title: 'Info: Backup Completed',
      subtitle: 'Database • 2.4TB',
      type: 'log',
      status: 'info',
      timestamp: '3 hours ago',
    ),

    // Configs
    ITSearchResult(
      id: '21',
      title: 'Database Config',
      subtitle: 'PostgreSQL • Production',
      type: 'config',
      status: 'active',
    ),
    ITSearchResult(
      id: '22',
      title: 'Redis Config',
      subtitle: 'Cache • 6GB Memory',
      type: 'config',
      status: 'active',
    ),
    ITSearchResult(
      id: '23',
      title: 'Nginx Config',
      subtitle: 'Load Balancer • Updated',
      type: 'config',
      status: 'active',
      timestamp: '2 days ago',
    ),

    // Backups
    ITSearchResult(
      id: '24',
      title: 'Daily Backup',
      subtitle: 'Database • 2.4TB',
      type: 'backup',
      status: 'completed',
      timestamp: '3 hours ago',
    ),
    ITSearchResult(
      id: '25',
      title: 'Weekly Full Backup',
      subtitle: 'All Systems • 15TB',
      type: 'backup',
      status: 'completed',
      timestamp: '2 days ago',
    ),
    ITSearchResult(
      id: '26',
      title: 'Incremental Backup',
      subtitle: 'Storage • 500GB',
      type: 'backup',
      status: 'in_progress',
      timestamp: 'In progress',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allData.where((item) {
        final matchesQuery =
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.subtitle.toLowerCase().contains(query.toLowerCase());
        final matchesCategory =
            _selectedCategory == 'all' || item.type == _selectedCategory;
        final matchesStatus =
            _statusFilter == 'all' ||
            item.status.toLowerCase() == _statusFilter;
        return matchesQuery && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  void _showFilterSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ITSearchFilterSheet(
        isDark: isDark,
        selectedStatus: _statusFilter,
        selectedPriority: _priorityFilter,
        dateRange: _dateRangeFilter,
        onApply: (status, priority, dateRange) {
          setState(() {
            _statusFilter = status;
            _priorityFilter = priority;
            _dateRangeFilter = dateRange;
          });
          _performSearch(_searchController.text);
        },
      ),
    );
  }

  void _handleResultTap(ITSearchResult result) {
    final query = _searchController.text;

    // Add to recent searches
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    // Navigate based on type
    switch (result.type) {
      case 'server':
        context.push('/it-admin/servers');
        break;
      case 'alert':
      case 'incident':
        context.push('/it-admin/system-health');
        break;
      case 'log':
        context.push('/it-admin/logs');
        break;
      case 'backup':
        context.push('/it-admin/backup');
        break;
      case 'config':
        context.push('/it-admin/settings');
        break;
      case 'service':
        context.push('/it-admin/api');
        break;
      case 'user':
        context.push('/it-admin/users');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${result.title}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;

        return Scaffold(
          backgroundColor: ITColors.scaffoldColor(isDark),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  ITSearchHeader(
                    isDark: isDark,
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: l10n.itSearchPlaceholder,
                    onBack: () => context.pop(),
                    onClear: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                    onChanged: _performSearch,
                    onFilterTap: () => _showFilterSheet(isDark),
                  ),
                  const SizedBox(height: 8),
                  ITSearchCategoryChips(
                    isDark: isDark,
                    selectedCategory: _selectedCategory,
                    categories: _getCategories(l10n),
                    onCategoryChanged: (category) {
                      setState(() => _selectedCategory = category);
                      _performSearch(_searchController.text);
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildBody(isDark, l10n)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getCategories(AppLocalizations l10n) {
    return [
      {'id': 'all', 'label': l10n.all, 'icon': Icons.dashboard_rounded},
      {'id': 'server', 'label': l10n.itServers, 'icon': Icons.dns_rounded},
      {
        'id': 'service',
        'label': l10n.itServices,
        'icon': Icons.miscellaneous_services_rounded,
      },
      {
        'id': 'alert',
        'label': l10n.itAlerts,
        'icon': Icons.notifications_rounded,
      },
      {
        'id': 'incident',
        'label': l10n.itIncidents,
        'icon': Icons.warning_rounded,
      },
      {'id': 'log', 'label': l10n.itLogs, 'icon': Icons.article_rounded},
      {'id': 'backup', 'label': l10n.itBackup, 'icon': Icons.backup_rounded},
    ];
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    if (_searchController.text.isEmpty) {
      return _buildInitialState(isDark, l10n);
    }

    if (_searchResults.isEmpty && _isSearching) {
      return ITSearchEmptyState(
        isDark: isDark,
        title: l10n.noResultsFound,
        subtitle: l10n.itSearchNoResultsHint,
      );
    }

    return _buildSearchResults(isDark, l10n);
  }

  Widget _buildInitialState(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          ITSearchRecentSection(
            isDark: isDark,
            recentSearches: _recentSearches,
            recentSearchesLabel: l10n.recentSearches,
            clearAllLabel: l10n.clearAll,
            onClearAll: () => setState(() => _recentSearches.clear()),
            onSearchTap: (search) {
              _searchController.text = search;
              _performSearch(search);
            },
          ),

          // Quick Actions
          ITSearchQuickActions(
            isDark: isDark,
            title: l10n.quickActions,
            actions: _getQuickActions(l10n),
            onActionTap: (route) => context.push(route),
          ),

          // Browse by Category
          ITSearchBrowseCategories(
            isDark: isDark,
            title: l10n.itSearchBrowseCategories,
            categories: _getBrowseCategories(l10n),
            onCategoryTap: (type) {
              setState(() {
                _selectedCategory = type;
                _searchResults = _allData
                    .where((item) => item.type == type)
                    .toList();
                _isSearching = true;
              });
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getQuickActions(AppLocalizations l10n) {
    return [
      {
        'icon': Icons.warning_amber_rounded,
        'label': l10n.itActiveIncidents,
        'route': '/it-admin/system-health',
        'color': ITColors.error,
      },
      {
        'icon': Icons.speed_rounded,
        'label': l10n.itSystemMetrics,
        'route': '/it-admin/dashboard',
        'color': ITColors.info,
      },
      {
        'icon': Icons.bug_report_rounded,
        'label': l10n.itErrorLogs,
        'route': '/it-admin/logs',
        'color': ITColors.warning,
      },
      {
        'icon': Icons.backup_rounded,
        'label': l10n.itBackupStatus,
        'route': '/it-admin/backup',
        'color': ITColors.success,
      },
    ];
  }

  List<Map<String, dynamic>> _getBrowseCategories(AppLocalizations l10n) {
    return [
      {
        'icon': Icons.dns_rounded,
        'label': l10n.itAllServers,
        'count': '${_allData.where((d) => d.type == 'server').length}',
        'type': 'server',
      },
      {
        'icon': Icons.miscellaneous_services_rounded,
        'label': l10n.itAllServices,
        'count': '${_allData.where((d) => d.type == 'service').length}',
        'type': 'service',
      },
      {
        'icon': Icons.notifications_rounded,
        'label': l10n.itAllAlerts,
        'count': '${_allData.where((d) => d.type == 'alert').length}',
        'type': 'alert',
      },
      {
        'icon': Icons.article_rounded,
        'label': l10n.itAllLogs,
        'count': '${_allData.where((d) => d.type == 'log').length}',
        'type': 'log',
      },
      {
        'icon': Icons.settings_rounded,
        'label': l10n.itAllConfigs,
        'count': '${_allData.where((d) => d.type == 'config').length}',
        'type': 'config',
      },
      {
        'icon': Icons.backup_rounded,
        'label': l10n.itAllBackups,
        'count': '${_allData.where((d) => d.type == 'backup').length}',
        'type': 'backup',
      },
    ];
  }

  Widget _buildSearchResults(bool isDark, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_searchResults.length} ${l10n.resultsFound}',
                  style: TextStyle(
                    color: ITColors.textSecondaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
                if (_statusFilter != 'all' ||
                    _priorityFilter != 'all' ||
                    _dateRangeFilter != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _statusFilter = 'all';
                        _priorityFilter = 'all';
                        _dateRangeFilter = null;
                      });
                      _performSearch(_searchController.text);
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: Text(l10n.clearFilters),
                    style: TextButton.styleFrom(
                      foregroundColor: ITColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          );
        }

        final result = _searchResults[index - 1];
        return ITSearchResultCard(
          isDark: isDark,
          result: result,
          onTap: () => _handleResultTap(result),
        );
      },
    );
  }
}
