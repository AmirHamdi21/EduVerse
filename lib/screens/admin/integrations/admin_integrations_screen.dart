import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/integrations/integrations_barrel.dart';
import '../../../common/utils/responsive.dart';

class AdminIntegrationsScreen extends StatefulWidget {
  const AdminIntegrationsScreen({super.key});

  @override
  State<AdminIntegrationsScreen> createState() =>
      _AdminIntegrationsScreenState();
}

class _AdminIntegrationsScreenState extends State<AdminIntegrationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter state
  String? _selectedCategory;
  bool _isLoading = false;

  // Sample integrations data
  final List<Integration> _integrations = [
    Integration(
      id: '1',
      name: 'Google Classroom',
      description: 'Sync courses and assignments with Google Classroom',
      category: 'lms',
      status: 'active',
      icon: Icons.school_rounded,
      iconColor: const Color(0xFF4285F4),
      lastSync: DateTime.now().subtract(const Duration(minutes: 15)),
      isConnected: true,
    ),
    Integration(
      id: '2',
      name: 'Microsoft Teams',
      description: 'Video conferencing and collaboration',
      category: 'communication',
      status: 'active',
      icon: Icons.groups_rounded,
      iconColor: const Color(0xFF6264A7),
      lastSync: DateTime.now().subtract(const Duration(hours: 1)),
      isConnected: true,
    ),
    Integration(
      id: '3',
      name: 'Stripe',
      description: 'Payment processing for subscriptions',
      category: 'payment',
      status: 'active',
      icon: Icons.payment_rounded,
      iconColor: const Color(0xFF635BFF),
      lastSync: DateTime.now().subtract(const Duration(hours: 2)),
      isConnected: true,
    ),
    Integration(
      id: '4',
      name: 'AWS S3',
      description: 'Cloud storage for media files',
      category: 'storage',
      status: 'active',
      icon: Icons.cloud_rounded,
      iconColor: const Color(0xFFFF9900),
      lastSync: DateTime.now().subtract(const Duration(minutes: 30)),
      isConnected: true,
    ),
    Integration(
      id: '5',
      name: 'Zoom',
      description: 'Video conferencing for live classes',
      category: 'communication',
      status: 'inactive',
      icon: Icons.videocam_rounded,
      iconColor: const Color(0xFF2D8CFF),
      isConnected: false,
    ),
    Integration(
      id: '6',
      name: 'Google Analytics',
      description: 'Website and app analytics tracking',
      category: 'analytics',
      status: 'active',
      icon: Icons.analytics_rounded,
      iconColor: const Color(0xFFE37400),
      lastSync: DateTime.now().subtract(const Duration(hours: 3)),
      isConnected: true,
    ),
    Integration(
      id: '7',
      name: 'PayPal',
      description: 'Alternative payment method',
      category: 'payment',
      status: 'error',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFF003087),
      isConnected: false,
    ),
    Integration(
      id: '8',
      name: 'Moodle',
      description: 'Learning management system integration',
      category: 'lms',
      status: 'inactive',
      icon: Icons.menu_book_rounded,
      iconColor: const Color(0xFFFF7D00),
      isConnected: false,
    ),
  ];

  // Sample API keys data
  final List<ApiKey> _apiKeys = [
    ApiKey(
      id: '1',
      name: 'Production API Key',
      key: 'sk_live_4eC39HqLyjWDarjtT1zdp7dc',
      description: 'Main production key for live environment',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
      permissions: ['read', 'write', 'delete'],
    ),
    ApiKey(
      id: '2',
      name: 'Development API Key',
      key: 'sk_test_51H1234567890abcdefg',
      description: 'Testing and development use only',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      isActive: true,
      permissions: ['read', 'write'],
    ),
    ApiKey(
      id: '3',
      name: 'Mobile App Key',
      key: 'sk_mobile_app_key_12345',
      description: 'Dedicated key for mobile applications',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastUsed: DateTime.now().subtract(const Duration(minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
      permissions: ['read'],
    ),
  ];

  // Sample webhooks data
  final List<Webhook> _webhooks = [
    Webhook(
      id: '1',
      name: 'User Registration',
      url: 'https://api.example.com/webhooks/user-registered',
      events: ['user.created', 'user.verified'],
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastTriggered: DateTime.now().subtract(const Duration(hours: 1)),
      successCount: 1234,
      failureCount: 12,
    ),
    Webhook(
      id: '2',
      name: 'Payment Events',
      url: 'https://api.example.com/webhooks/payments',
      events: ['payment.completed', 'payment.failed', 'refund.created'],
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastTriggered: DateTime.now().subtract(const Duration(minutes: 30)),
      successCount: 5678,
      failureCount: 45,
    ),
    Webhook(
      id: '3',
      name: 'Course Updates',
      url: 'https://api.example.com/webhooks/courses',
      events: ['course.created', 'course.updated', 'enrollment.created'],
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      successCount: 890,
      failureCount: 5,
    ),
  ];

  // Sample API usage data
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'method': 'GET',
      'endpoint': '/api/v1/users',
      'status': 200,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
      'latency': 45,
    },
    {
      'method': 'POST',
      'endpoint': '/api/v1/courses',
      'status': 201,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'latency': 120,
    },
    {
      'method': 'PUT',
      'endpoint': '/api/v1/users/123',
      'status': 200,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 8)),
      'latency': 85,
    },
    {
      'method': 'DELETE',
      'endpoint': '/api/v1/enrollments/456',
      'status': 404,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
      'latency': 30,
    },
    {
      'method': 'GET',
      'endpoint': '/api/v1/analytics/dashboard',
      'status': 200,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'latency': 250,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _showIntegrationDialog(Integration integration) {
    final l10n = AppLocalizations.of(context)!;
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: integration.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    integration.icon,
                    color: integration.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    integration.name,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                  integration.description,
                  style: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDialogInfoRow(
                  l10n.category,
                  _getCategoryLabel(integration.category, l10n),
                  isDark,
                ),
                _buildDialogInfoRow(l10n.status, integration.status, isDark),
                if (integration.lastSync != null)
                  _buildDialogInfoRow(
                    l10n.lastSync,
                    _formatTime(integration.lastSync!),
                    isDark,
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
              if (integration.isConnected)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('${l10n.syncing} ${integration.name}...');
                  },
                  icon: const Icon(Icons.sync, size: 18),
                  label: Text(l10n.syncNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (!integration.isConnected)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('${l10n.connecting} ${integration.name}...');
                  },
                  icon: const Icon(Icons.link, size: 18),
                  label: Text(l10n.connect),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'lms':
        return l10n.lms;
      case 'payment':
        return l10n.payment;
      case 'communication':
        return l10n.communication;
      case 'storage':
        return l10n.storage;
      case 'analytics':
        return l10n.analytics;
      default:
        return category;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showCreateApiKeyDialog() {
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar(l10n.createApiKeyDescription);
  }

  void _showCreateWebhookDialog() {
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar(l10n.webhooksDescription);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      expandedHeight: 100,
                      floating: true,
                      pinned: true,
                      backgroundColor: isDark
                          ? AdminColors.darkBackground
                          : Colors.white.withValues(alpha: 0.9),
                      elevation: innerBoxIsScrolled ? 2 : 0,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AdminColors.getTextColor(isDark),
                        ),
                        onPressed: () => context.pop(),
                      ),
                      title: Text(
                        l10n.integrationsApi,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: AdminColors.getTextColor(isDark),
                          ),
                          onPressed: () {
                            setState(() => _isLoading = true);
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                _showSnackBar(l10n.dataRefreshed);
                              }
                            });
                          },
                        ),
                      ],
                      bottom: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AdminColors.primary,
                        unselectedLabelColor: AdminColors.getTextSecondaryColor(
                          isDark,
                        ),
                        indicatorColor: AdminColors.primary,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        tabs: [
                          Tab(text: l10n.overview),
                          Tab(text: l10n.integrations),
                          Tab(text: l10n.apiKeys),
                          Tab(text: l10n.webhooks),
                        ],
                      ),
                    ),
                  ];
                },
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(isDark, l10n, responsive),
                          _buildIntegrationsTab(isDark, l10n, responsive),
                          _buildApiKeysTab(isDark, l10n, responsive),
                          _buildWebhooksTab(isDark, l10n, responsive),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          IntegrationStatsCard(isDark: isDark),
          const SizedBox(height: 16),
          ApiUsageCard(
            isDark: isDark,
            totalRequests: 125430,
            successfulRequests: 123456,
            failedRequests: 1974,
            averageLatency: 85,
            recentActivity: _recentActivity,
            onViewDetails: () => _tabController.animateTo(2),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIntegrationsTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        children: [
          const SizedBox(height: 16),
          IntegrationsListCard(
            isDark: isDark,
            integrations: _integrations,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
            },
            onIntegrationTap: _showIntegrationDialog,
            onToggleConnection: (integration, value) {
              setState(() {
                final index = _integrations.indexWhere(
                  (i) => i.id == integration.id,
                );
                if (index != -1) {
                  _integrations[index] = Integration(
                    id: integration.id,
                    name: integration.name,
                    description: integration.description,
                    category: integration.category,
                    status: value ? 'active' : 'inactive',
                    icon: integration.icon,
                    iconColor: integration.iconColor,
                    lastSync: integration.lastSync,
                    isConnected: value,
                  );
                }
              });
              _showSnackBar(
                value
                    ? '${integration.name} ${l10n.connected}'
                    : '${integration.name} ${l10n.disconnected}',
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildApiKeysTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        children: [
          const SizedBox(height: 16),
          ApiKeysCard(
            isDark: isDark,
            apiKeys: _apiKeys,
            onCreateKey: _showCreateApiKeyDialog,
            onEditKey: (key) => _showSnackBar('${l10n.edit} ${key.name}'),
            onDeleteKey: (key) => _showSnackBar('${l10n.delete} ${key.name}'),
            onRevokeKey: (key) => _showSnackBar('${l10n.revoke} ${key.name}'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWebhooksTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        children: [
          const SizedBox(height: 16),
          WebhooksCard(
            isDark: isDark,
            webhooks: _webhooks,
            onCreateWebhook: _showCreateWebhookDialog,
            onEditWebhook: (webhook) =>
                _showSnackBar('${l10n.edit} ${webhook.name}'),
            onDeleteWebhook: (webhook) =>
                _showSnackBar('${l10n.delete} ${webhook.name}'),
            onTestWebhook: (webhook) =>
                _showSnackBar('${l10n.test} ${webhook.name}'),
            onToggleWebhook: (webhook, value) {
              setState(() {
                final index = _webhooks.indexWhere((w) => w.id == webhook.id);
                if (index != -1) {
                  _webhooks[index] = Webhook(
                    id: webhook.id,
                    name: webhook.name,
                    url: webhook.url,
                    secret: webhook.secret,
                    events: webhook.events,
                    isActive: value,
                    createdAt: webhook.createdAt,
                    lastTriggered: webhook.lastTriggered,
                    successCount: webhook.successCount,
                    failureCount: webhook.failureCount,
                  );
                }
              });
              _showSnackBar(
                value
                    ? '${webhook.name} ${l10n.activated}'
                    : '${webhook.name} ${l10n.deactivated}',
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
