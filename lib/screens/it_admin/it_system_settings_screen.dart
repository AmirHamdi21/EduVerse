import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/settings/it_settings_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITSystemSettingsScreen extends StatefulWidget {
  const ITSystemSettingsScreen({super.key});

  @override
  State<ITSystemSettingsScreen> createState() => _ITSystemSettingsScreenState();
}

class _ITSystemSettingsScreenState extends State<ITSystemSettingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedEnvironment = 'production';
  String _selectedFilter = 'all';

  // Data
  late List<EnvironmentConfig> _environments;
  late List<ServiceConfig> _services;
  late List<SecuritySetting> _securitySettings;
  late List<NotificationSetting> _notificationSettings;
  late List<MaintenanceWindow> _maintenanceWindows;
  late List<IntegrationConfig> _integrations;

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

      _environments = _getMockEnvironments();
      _services = _getMockServices();
      _securitySettings = _getMockSecuritySettings();
      _notificationSettings = _getMockNotificationSettings();
      _maintenanceWindows = _getMockMaintenanceWindows();
      _integrations = _getMockIntegrations();

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

  List<EnvironmentConfig> _getMockEnvironments() {
    return [
      EnvironmentConfig(
        id: 'production',
        name: 'Production',
        status: 'stable',
        isSelected: true,
        icon: Icons.check_circle_rounded,
      ),
      EnvironmentConfig(
        id: 'staging',
        name: 'Staging',
        status: 'testing',
        icon: Icons.science_rounded,
      ),
      EnvironmentConfig(
        id: 'development',
        name: 'Development',
        status: 'active',
        icon: Icons.code_rounded,
      ),
      EnvironmentConfig(
        id: 'sandbox',
        name: 'Sandbox',
        status: 'isolated',
        icon: Icons.all_inclusive_rounded,
      ),
    ];
  }

  List<ServiceConfig> _getMockServices() {
    return [
      ServiceConfig(
        id: '1',
        name: 'API Gateway',
        version: 'v2.4.1',
        status: 'online',
        region: 'us-east-1',
        lastUpdated: 'Updated 2 hours ago',
        icon: Icons.api_rounded,
      ),
      ServiceConfig(
        id: '2',
        name: 'Authentication Service',
        version: 'v1.8.3',
        status: 'online',
        region: 'us-east-1',
        lastUpdated: 'Updated 5 hours ago',
        icon: Icons.lock_rounded,
      ),
      ServiceConfig(
        id: '3',
        name: 'Database Cluster',
        version: 'v5.7.2',
        status: 'online',
        region: 'us-east-1',
        lastUpdated: 'Updated 1 day ago',
        icon: Icons.storage_rounded,
      ),
      ServiceConfig(
        id: '4',
        name: 'Storage Service',
        version: 'v3.2.0',
        status: 'degraded',
        region: 'eu-west-1',
        lastUpdated: 'Updated 3 hours ago',
        icon: Icons.cloud_rounded,
      ),
      ServiceConfig(
        id: '5',
        name: 'Notification Service',
        version: 'v2.1.4',
        status: 'online',
        region: 'us-east-1',
        lastUpdated: 'Updated 6 hours ago',
        icon: Icons.notifications_rounded,
      ),
    ];
  }

  List<SecuritySetting> _getMockSecuritySettings() {
    return [
      SecuritySetting(
        id: '1',
        title: 'Two-Factor Authentication',
        description: 'Require 2FA for all admin accounts',
        isEnabled: true,
        icon: Icons.security_rounded,
        lastUpdated: '2 days ago',
      ),
      SecuritySetting(
        id: '2',
        title: 'SSL/TLS Encryption',
        description: 'Force HTTPS for all connections',
        isEnabled: true,
        icon: Icons.https_rounded,
        lastUpdated: '1 week ago',
      ),
      SecuritySetting(
        id: '3',
        title: 'IP Whitelisting',
        description: 'Restrict access to approved IPs',
        isEnabled: false,
        icon: Icons.vpn_lock_rounded,
        lastUpdated: '3 days ago',
      ),
      SecuritySetting(
        id: '4',
        title: 'Rate Limiting',
        description: 'Protect against DDoS attacks',
        isEnabled: true,
        icon: Icons.speed_rounded,
        lastUpdated: '5 days ago',
      ),
    ];
  }

  List<NotificationSetting> _getMockNotificationSettings() {
    return [
      NotificationSetting(
        id: '1',
        title: 'Critical Alerts',
        description: 'System downtime and security breaches',
        isEnabled: true,
        channel: 'Email',
        icon: Icons.warning_rounded,
      ),
      NotificationSetting(
        id: '2',
        title: 'Performance Warnings',
        description: 'High CPU, memory, or latency',
        isEnabled: true,
        channel: 'Slack',
        icon: Icons.trending_up_rounded,
      ),
      NotificationSetting(
        id: '3',
        title: 'Backup Status',
        description: 'Daily backup completion reports',
        isEnabled: true,
        channel: 'Email',
        icon: Icons.backup_rounded,
      ),
      NotificationSetting(
        id: '4',
        title: 'Security Events',
        description: 'Login attempts and access logs',
        isEnabled: false,
        channel: 'Webhook',
        icon: Icons.shield_rounded,
      ),
    ];
  }

  List<MaintenanceWindow> _getMockMaintenanceWindows() {
    return [
      MaintenanceWindow(
        id: '1',
        title: 'Database Backup',
        schedule: 'Daily at 2:00 AM UTC',
        nextRun: 'Tomorrow, 2:00 AM',
        isActive: true,
        type: 'backup',
      ),
      MaintenanceWindow(
        id: '2',
        title: 'System Updates',
        schedule: 'Weekly on Sunday, 3:00 AM UTC',
        nextRun: 'Sunday, 3:00 AM',
        isActive: true,
        type: 'update',
      ),
      MaintenanceWindow(
        id: '3',
        title: 'Log Cleanup',
        schedule: 'Monthly on 1st, 4:00 AM UTC',
        nextRun: 'Mar 1, 4:00 AM',
        isActive: false,
        type: 'cleanup',
      ),
    ];
  }

  List<IntegrationConfig> _getMockIntegrations() {
    return [
      IntegrationConfig(
        id: '1',
        name: 'Google OAuth',
        type: 'OAuth',
        status: 'Connected',
        lastSync: '5 min ago',
        icon: Icons.g_mobiledata_rounded,
      ),
      IntegrationConfig(
        id: '2',
        name: 'Slack Webhook',
        type: 'Webhook',
        status: 'Connected',
        lastSync: '10 min ago',
        icon: Icons.tag_rounded,
      ),
      IntegrationConfig(
        id: '3',
        name: 'AWS S3',
        type: 'Storage',
        status: 'Connected',
        lastSync: '1 hour ago',
        icon: Icons.cloud_queue_rounded,
      ),
      IntegrationConfig(
        id: '4',
        name: 'Stripe API',
        type: 'API',
        status: 'Disconnected',
        lastSync: '3 days ago',
        icon: Icons.credit_card_rounded,
      ),
    ];
  }

  void _handleEnvironmentChange(String envId) {
    setState(() => _selectedEnvironment = envId);
    _showSnackBar(
      'Switched to ${envId.replaceFirst(envId[0], envId[0].toUpperCase())} environment',
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

  void _showFeatureDialog(String title, String description) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

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
              child: Icon(
                Icons.info_outline_rounded,
                color: ITColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
          // drawer: ITDrawer(currentRoute: '/it-admin/settings', isDark: isDark),
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
      return Center(child: CircularProgressIndicator(color: ITColors.primary));
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: CustomScrollView(
        slivers: [
          ITSettingsAppBar(
            isDark: isDark,
            title: l10n.itSystemSettings,
            subtitle: l10n.itConfigureSystemSettings,
            onRefreshTap: _loadData,
            onSearchTap: () => _showSnackBar('Search feature'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Filter chips
                _buildFilterSection(isDark, l10n),
                const SizedBox(height: 20),

                // Environment Section
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'environment')
                  ITEnvironmentSection(
                    isDark: isDark,
                    environments: _environments,
                    selectedEnvironment: _selectedEnvironment,
                    onEnvironmentSelected: _handleEnvironmentChange,
                    statusMessage: _getEnvironmentStatusMessage(),
                  ),
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'environment')
                  const SizedBox(height: 20),

                // Service Configuration Section
                if (_selectedFilter == 'all' || _selectedFilter == 'services')
                  ITServiceConfigSection(
                    isDark: isDark,
                    services: _services,
                    onViewService: (service) => _showFeatureDialog(
                      service.name,
                      'View configuration for ${service.name}\nVersion: ${service.version}\nRegion: ${service.region}',
                    ),
                    onEditService: (service) => _showFeatureDialog(
                      'Edit ${service.name}',
                      'Edit configuration settings for ${service.name}',
                    ),
                    onMoreOptions: (service) =>
                        _showServiceOptionsSheet(service, isDark),
                    onAddService: () => _showSnackBar('Add new service'),
                  ),
                if (_selectedFilter == 'all' || _selectedFilter == 'services')
                  const SizedBox(height: 20),

                // Security Section
                if (_selectedFilter == 'all' || _selectedFilter == 'security')
                  ITSecuritySection(
                    isDark: isDark,
                    settings: _securitySettings,
                    onToggle: (setting, value) {
                      setState(() {
                        final index = _securitySettings.indexWhere(
                          (s) => s.id == setting.id,
                        );
                        if (index != -1) {
                          _securitySettings[index] = SecuritySetting(
                            id: setting.id,
                            title: setting.title,
                            description: setting.description,
                            isEnabled: value,
                            icon: setting.icon,
                            lastUpdated: 'Just now',
                          );
                        }
                      });
                      _showSnackBar(
                        '${setting.title} ${value ? 'enabled' : 'disabled'}',
                      );
                    },
                    onConfigure: (setting) => _showFeatureDialog(
                      'Configure ${setting.title}',
                      'Advanced configuration options for ${setting.title}',
                    ),
                  ),
                if (_selectedFilter == 'all' || _selectedFilter == 'security')
                  const SizedBox(height: 20),

                // Notification Section
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'notifications')
                  ITNotificationSection(
                    isDark: isDark,
                    settings: _notificationSettings,
                    onToggle: (setting, value) {
                      setState(() {
                        final index = _notificationSettings.indexWhere(
                          (s) => s.id == setting.id,
                        );
                        if (index != -1) {
                          _notificationSettings[index] = NotificationSetting(
                            id: setting.id,
                            title: setting.title,
                            description: setting.description,
                            isEnabled: value,
                            channel: setting.channel,
                            icon: setting.icon,
                          );
                        }
                      });
                      _showSnackBar(
                        '${setting.title} ${value ? 'enabled' : 'disabled'}',
                      );
                    },
                    onConfigure: (setting) => _showFeatureDialog(
                      'Configure ${setting.title}',
                      'Configure notification channel and frequency for ${setting.title}',
                    ),
                  ),
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'notifications')
                  const SizedBox(height: 20),

                // Maintenance Section
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'maintenance')
                  ITMaintenanceSection(
                    isDark: isDark,
                    maintenanceWindows: _maintenanceWindows,
                    onEdit: (window) => _showFeatureDialog(
                      'Edit ${window.title}',
                      'Edit maintenance schedule for ${window.title}\nCurrent schedule: ${window.schedule}',
                    ),
                    onToggle: (window, value) {
                      setState(() {
                        final index = _maintenanceWindows.indexWhere(
                          (w) => w.id == window.id,
                        );
                        if (index != -1) {
                          _maintenanceWindows[index] = MaintenanceWindow(
                            id: window.id,
                            title: window.title,
                            schedule: window.schedule,
                            nextRun: window.nextRun,
                            isActive: value,
                            type: window.type,
                          );
                        }
                      });
                      _showSnackBar(
                        '${window.title} ${value ? 'activated' : 'deactivated'}',
                      );
                    },
                    onAddWindow: () => _showSnackBar('Add maintenance window'),
                  ),
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'maintenance')
                  const SizedBox(height: 20),

                // Integration Section
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'integrations')
                  ITIntegrationSection(
                    isDark: isDark,
                    integrations: _integrations,
                    onConfigure: (integration) => _showFeatureDialog(
                      'Configure ${integration.name}',
                      'Configure API keys and settings for ${integration.name}',
                    ),
                    onSync: (integration) {
                      _showSnackBar('Syncing ${integration.name}...');
                    },
                    onAddIntegration: () => _showSnackBar('Add integration'),
                  ),
                if (_selectedFilter == 'all' ||
                    _selectedFilter == 'integrations')
                  const SizedBox(height: 20),
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
      {
        'id': 'environment',
        'label': l10n.itEnvironment,
        'icon': Icons.public_rounded,
      },
      {'id': 'services', 'label': l10n.itServices, 'icon': Icons.dns_rounded},
      {
        'id': 'security',
        'label': l10n.itSecurity,
        'icon': Icons.security_rounded,
      },
      {
        'id': 'notifications',
        'label': l10n.itNotifications,
        'icon': Icons.notifications_rounded,
      },
      {
        'id': 'maintenance',
        'label': l10n.itMaintenance,
        'icon': Icons.build_rounded,
      },
      {
        'id': 'integrations',
        'label': l10n.itIntegrations,
        'icon': Icons.hub_rounded,
      },
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

  void _showServiceOptionsSheet(ServiceConfig service, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? ITColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ITColors.textTertiaryColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              service.name,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionItem(
              isDark: isDark,
              icon: Icons.restart_alt_rounded,
              label: 'Restart Service',
              color: ITColors.warning,
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Restarting ${service.name}...');
              },
            ),
            _buildOptionItem(
              isDark: isDark,
              icon: Icons.pause_rounded,
              label: 'Stop Service',
              color: ITColors.error,
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Stopping ${service.name}...');
              },
            ),
            _buildOptionItem(
              isDark: isDark,
              icon: Icons.history_rounded,
              label: 'View Logs',
              color: ITColors.info,
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Opening logs for ${service.name}...');
              },
            ),
            _buildOptionItem(
              isDark: isDark,
              icon: Icons.analytics_rounded,
              label: 'View Metrics',
              color: ITColors.purple,
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Opening metrics for ${service.name}...');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: ITColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ITColors.textTertiaryColor(isDark),
      ),
    );
  }

  String _getEnvironmentStatusMessage() {
    switch (_selectedEnvironment) {
      case 'production':
        return 'Production environment is stable';
      case 'staging':
        return 'Staging environment is ready for testing';
      case 'development':
        return 'Development environment is active';
      case 'sandbox':
        return 'Sandbox environment is isolated';
      default:
        return 'Environment status unknown';
    }
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
