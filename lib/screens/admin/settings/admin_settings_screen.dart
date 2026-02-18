import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/settings/admin_settings_barrel.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String? _errorMessage;

  // Mock admin data
  final String _adminName = 'John Administrator';
  final String _adminEmail = 'admin@eduverse.edu';
  final String _adminRole = 'System Administrator';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate loading
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: _buildContent(isDark, l10n),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AdminColors.getBackgroundColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      title: Text(
        l10n.platformSettings,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showSearchDialog(context, l10n, isDark),
          icon: Icon(
            Icons.search_rounded,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
          tooltip: l10n.search,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadSettings,
        color: AdminColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            // Admin Profile Header
            AdminSettingsHeader(
              isDark: isDark,
              adminName: _adminName,
              adminEmail: _adminEmail,
              adminRole: _adminRole,
              onTap: () => context.push('/admin/profile'),
            ),

            const SizedBox(height: 24),

            // Platform Status Card
            _buildPlatformStatusCard(isDark, l10n),

            const SizedBox(height: 24),

            // General Settings Section
            AdminSettingsSection(
              title: l10n.generalSettings,
              icon: Icons.tune_rounded,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.business_rounded,
                  title: l10n.platformInfo,
                  subtitle: l10n.platformInfoDesc,
                  onTap: () => _showPlatformInfoDialog(context, l10n, isDark),
                ),
                AdminSettingsItem(
                  icon: Icons.access_time_rounded,
                  title: l10n.timezone,
                  subtitle: 'UTC+00:00 (Cairo)',
                  onTap: () => _showTimezoneSheet(context, l10n, isDark),
                ),
                AdminSettingsItem(
                  icon: Icons.date_range_rounded,
                  title: l10n.academicYear,
                  subtitle: '2025-2026',
                  onTap: () => _showAcademicYearSheet(context, l10n, isDark),
                ),
                AdminSettingsItem(
                  icon: Icons.school_outlined,
                  title: l10n.semesterSettings,
                  subtitle: l10n.semesterSettingsDesc,
                  onTap: () => context.push('/admin/settings/semester'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Management Section
            AdminSettingsSection(
              title: l10n.userManagement,
              icon: Icons.people_outline_rounded,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.person_add_outlined,
                  title: l10n.registrationSettings,
                  subtitle: l10n.registrationSettingsDesc,
                  onTap: () => context.push('/admin/settings/registration'),
                ),
                AdminSettingsItem(
                  icon: Icons.verified_user_outlined,
                  title: l10n.rolePermissions,
                  subtitle: l10n.rolePermissionsDesc,
                  onTap: () => context.push('/admin/roles'),
                ),
                AdminSettingsItem(
                  icon: Icons.group_work_outlined,
                  title: l10n.userGroups,
                  subtitle: l10n.userGroupsDesc,
                  onTap: () => context.push('/admin/users'),
                ),
                AdminSettingsItem(
                  icon: Icons.block_outlined,
                  title: l10n.blockedUsers,
                  subtitle: l10n.blockedUsersDesc,
                  showBadge: true,
                  badgeText: '3',
                  onTap: () => context.push('/admin/settings/blocked-users'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Appearance Section
            AdminSettingsSection(
              title: l10n.appearance,
              icon: Icons.palette_outlined,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: l10n.theme,
                  subtitle: isDark ? l10n.dark : l10n.light,
                  onTap: () => context.push('/admin/settings/appearance'),
                ),
                AdminSettingsItem(
                  icon: Icons.language_rounded,
                  title: l10n.defaultLanguage,
                  subtitle: l10n.defaultLanguageDesc,
                  onTap: () => context.push('/admin/settings/language'),
                ),
                AdminSettingsItem(
                  icon: Icons.color_lens_outlined,
                  title: l10n.brandingColors,
                  subtitle: l10n.brandingColorsDesc,
                  onTap: () => context.push('/admin/settings/branding'),
                ),
                AdminSettingsItem(
                  icon: Icons.image_outlined,
                  title: l10n.logoAssets,
                  subtitle: l10n.logoAssetsDesc,
                  onTap: () => context.push('/admin/settings/logo-assets'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Security Section
            AdminSettingsSection(
              title: l10n.securityPolicies,
              icon: Icons.security_outlined,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.password_rounded,
                  title: l10n.passwordPolicy,
                  subtitle: l10n.passwordPolicyDesc,
                  onTap: () => context.push('/admin/settings/password-policy'),
                ),
                AdminSettingsItem(
                  icon: Icons.verified_user_outlined,
                  title: l10n.twoFactorAuth,
                  subtitle: l10n.twoFactorAuthPlatformDesc,
                  onTap: () => context.push('/admin/settings/two-factor'),
                ),
                AdminSettingsItem(
                  icon: Icons.timer_outlined,
                  title: l10n.sessionTimeout,
                  subtitle: '30 ${l10n.minutes}',
                  onTap: () => _showSessionTimeoutSheet(context, l10n, isDark),
                ),
                AdminSettingsItem(
                  icon: Icons.history_rounded,
                  title: l10n.auditLogs,
                  subtitle: l10n.auditLogsDesc,
                  onTap: () => context.push('/admin/security'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notifications Section
            AdminSettingsSection(
              title: l10n.notificationSettings,
              icon: Icons.notifications_outlined,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.email_outlined,
                  title: l10n.emailConfiguration,
                  subtitle: l10n.emailConfigurationDesc,
                  onTap: () => context.push('/admin/settings/email'),
                ),
                AdminSettingsItem(
                  icon: Icons.sms_outlined,
                  title: l10n.smsConfiguration,
                  subtitle: l10n.smsConfigurationDesc,
                  onTap: () => context.push('/admin/settings/sms'),
                ),
                AdminSettingsItem(
                  icon: Icons.notifications_active_outlined,
                  title: l10n.pushNotifications,
                  subtitle: l10n.pushNotificationsConfigDesc,
                  onTap: () =>
                      context.push('/admin/settings/push-notifications'),
                ),
                AdminSettingsItem(
                  icon: Icons.webhook_outlined,
                  title: l10n.webhooks,
                  subtitle: l10n.webhooksDesc,
                  onTap: () => context.push('/admin/settings/webhooks'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Integrations Section
            AdminSettingsSection(
              title: l10n.integrations,
              icon: Icons.integration_instructions_outlined,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.api_rounded,
                  title: l10n.apiManagement,
                  subtitle: l10n.apiManagementDesc,
                  onTap: () => context.push('/admin/settings/api'),
                ),
                AdminSettingsItem(
                  icon: Icons.cloud_outlined,
                  title: l10n.cloudStorage,
                  subtitle: l10n.cloudStorageDesc,
                  onTap: () => context.push('/admin/settings/cloud-storage'),
                ),
                AdminSettingsItem(
                  icon: Icons.payment_outlined,
                  title: l10n.paymentGateways,
                  subtitle: l10n.paymentGatewaysDesc,
                  onTap: () => context.push('/admin/settings/payment-gateways'),
                ),
                AdminSettingsItem(
                  icon: Icons.video_library_outlined,
                  title: l10n.videoConferencing,
                  subtitle: l10n.videoConferencingDesc,
                  onTap: () =>
                      context.push('/admin/settings/video-conferencing'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // System Section
            AdminSettingsSection(
              title: l10n.systemSettings,
              icon: Icons.settings_applications_outlined,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.backup_outlined,
                  title: l10n.backupRestore,
                  subtitle: l10n.backupRestoreDesc,
                  onTap: () => context.push('/admin/settings/backup-restore'),
                ),
                AdminSettingsItem(
                  icon: Icons.build_circle_outlined,
                  title: l10n.maintenanceMode,
                  subtitle: l10n.maintenanceModeDesc,
                  onTap: () =>
                      _showMaintenanceModeDialog(context, l10n, isDark),
                ),
                AdminSettingsItem(
                  icon: Icons.cleaning_services_outlined,
                  title: l10n.clearSystemCache,
                  subtitle: l10n.clearSystemCacheDesc,
                  onTap: () => _showClearCacheDialog(context, l10n, isDark),
                ),
                AdminSettingsItem(
                  icon: Icons.update_rounded,
                  title: l10n.systemUpdates,
                  subtitle: l10n.systemUpdatesDesc,
                  showBadge: true,
                  badgeText: l10n.updateAvailable,
                  onTap: () => context.push('/admin/settings/system-updates'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Advanced Section
            AdminSettingsSection(
              title: l10n.advancedSettings,
              icon: Icons.code_rounded,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.developer_mode_rounded,
                  title: l10n.developerOptions,
                  subtitle: l10n.developerOptionsDesc,
                  onTap: () =>
                      context.push('/admin/settings/developer-options'),
                ),
                AdminSettingsItem(
                  icon: Icons.bug_report_outlined,
                  title: l10n.debugMode,
                  subtitle: l10n.debugModeDesc,
                  trailing: Switch.adaptive(
                    value: false,
                    onChanged: (value) =>
                        _toggleDebugMode(context, value, l10n),
                    activeColor: AdminColors.primary,
                  ),
                ),
                AdminSettingsItem(
                  icon: Icons.terminal_rounded,
                  title: l10n.systemLogs,
                  subtitle: l10n.systemLogsDesc,
                  onTap: () => context.push('/admin/settings/system-logs'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // About Section
            AdminSettingsSection(
              title: l10n.about,
              icon: Icons.info_outline_rounded,
              isDark: isDark,
              items: [
                AdminSettingsItem(
                  icon: Icons.article_outlined,
                  title: l10n.termsOfService,
                  subtitle: '',
                  onTap: () => context.push('/settings/terms'),
                ),
                AdminSettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacyPolicy,
                  subtitle: '',
                  onTap: () => context.push('/settings/privacy-policy'),
                ),
                AdminSettingsItem(
                  icon: Icons.description_outlined,
                  title: l10n.licenses,
                  subtitle: '',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'EduVerse',
                    applicationVersion: '1.0.0',
                  ),
                ),
                AdminSettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: l10n.appVersion,
                  subtitle: '1.0.0 (Build 100)',
                  onTap: null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Danger Zone
            _buildDangerZone(context, l10n, isDark),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformStatusCard(bool isDark, AppLocalizations l10n) {
    return AdminPlatformConfigCard(
      isDark: isDark,
      title: l10n.platformStatus,
      description: l10n.platformStatusDesc,
      icon: Icons.dns_rounded,
      status: l10n.operational,
      isActive: true,
      items: [
        PlatformConfigItem(
          label: l10n.activeUsers,
          value: '2,456',
          statusColor: AdminColors.success,
        ),
        PlatformConfigItem(
          label: l10n.activeCourses,
          value: '148',
          statusColor: AdminColors.primary,
        ),
        PlatformConfigItem(
          label: l10n.serverUptime,
          value: '99.9%',
          statusColor: AdminColors.success,
        ),
        PlatformConfigItem(
          label: l10n.lastBackup,
          value: '2 ${l10n.hoursAgo(2)}',
          statusColor: AdminColors.warning,
        ),
      ],
    );
  }

  Widget _buildDangerZone(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AdminColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dangerZone,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDangerItem(
            context,
            icon: Icons.restart_alt_rounded,
            title: l10n.resetPlatformSettings,
            onTap: () => _showResetSettingsDialog(context, l10n, isDark),
          ),
          const SizedBox(height: 12),
          _buildDangerItem(
            context,
            icon: Icons.delete_forever_outlined,
            title: l10n.purgeAllData,
            onTap: () => _showPurgeDataDialog(context, l10n, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AdminColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AdminColors.error, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AdminColors.error,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AdminColors.error.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AdminColors.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AdminColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSettings,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
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

  // Dialog methods
  void _showSearchDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showSearch(
      context: context,
      delegate: AdminSettingsSearchDelegate(isDark: isDark, l10n: l10n),
    ).then((route) {
      if (route != null && route.isNotEmpty && mounted) {
        if (context.mounted) {
          context.push(route);
        }
      }
    });
  }

  void _showPlatformInfoDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AdminColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.business_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.platformInfo,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(l10n.platformName, 'EduVerse', isDark),
            _buildInfoRow(l10n.version, '1.0.0', isDark),
            _buildInfoRow(l10n.environment, 'Production', isDark),
            _buildInfoRow(l10n.serverRegion, 'Europe (Frankfurt)', isDark),
            _buildInfoRow(l10n.databaseVersion, 'PostgreSQL 15.1', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.close,
              style: TextStyle(color: AdminColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showTimezoneSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final timezones = [
      'UTC+00:00 (London)',
      'UTC+01:00 (Paris)',
      'UTC+02:00 (Cairo)',
      'UTC+03:00 (Moscow)',
      'UTC+05:30 (Mumbai)',
      'UTC+08:00 (Singapore)',
      'UTC-05:00 (New York)',
      'UTC-08:00 (Los Angeles)',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHandle(isDark),
              const SizedBox(height: 20),
              Text(
                l10n.selectTimezone,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              const SizedBox(height: 16),
              ...timezones.map(
                (tz) => _buildOptionTile(
                  context,
                  tz,
                  tz == 'UTC+02:00 (Cairo)',
                  isDark,
                  () {
                    Navigator.pop(context);
                    _showSuccessSnackBar(
                      context,
                      '${l10n.timezone} updated to $tz',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAcademicYearSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final years = ['2024-2025', '2025-2026', '2026-2027'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetHandle(isDark),
            const SizedBox(height: 20),
            Text(
              l10n.selectAcademicYear,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 16),
            ...years.map(
              (year) => _buildOptionTile(
                context,
                year,
                year == '2025-2026',
                isDark,
                () {
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    context,
                    '${l10n.academicYear} set to $year',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionTimeoutSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final timeouts = [
      '15 ${l10n.minutes}',
      '30 ${l10n.minutes}',
      '60 ${l10n.minutes}',
      '120 ${l10n.minutes}',
      l10n.never,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetHandle(isDark),
            const SizedBox(height: 20),
            Text(
              l10n.sessionTimeout,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 16),
            ...timeouts.map(
              (timeout) => _buildOptionTile(
                context,
                timeout,
                timeout == '30 ${l10n.minutes}',
                isDark,
                () {
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    context,
                    '${l10n.sessionTimeout} set to $timeout',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaintenanceModeDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.build_circle_outlined, color: AdminColors.warning),
            const SizedBox(width: 12),
            Text(
              l10n.maintenanceMode,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.maintenanceModeConfirmation,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar(context, l10n.maintenanceModeEnabled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.enable),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cleaning_services_outlined, color: AdminColors.primary),
            const SizedBox(width: 12),
            Text(
              l10n.clearSystemCache,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.clearSystemCacheConfirmation,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar(context, l10n.cacheCleared);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AdminColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.resetPlatformSettings,
                style: TextStyle(
                  color: AdminColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.resetPlatformSettingsWarning,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar(context, l10n.settingsReset);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  void _showPurgeDataDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_forever_outlined, color: AdminColors.error),
            const SizedBox(width: 12),
            Text(
              l10n.purgeAllData,
              style: TextStyle(
                color: AdminColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.purgeAllDataWarning,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.typeConfirmToProceed,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              style: TextStyle(color: AdminColors.getTextColor(isDark)),
              decoration: InputDecoration(
                hintText: 'CONFIRM',
                hintStyle: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
                filled: true,
                fillColor: AdminColors.getBackgroundColor(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text == 'CONFIRM') {
                Navigator.pop(context);
                _showSuccessSnackBar(context, l10n.dataPurged);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.purge),
          ),
        ],
      ),
    );
  }

  void _toggleDebugMode(
    BuildContext context,
    bool value,
    AppLocalizations l10n,
  ) {
    setState(() {});
    _showSuccessSnackBar(
      context,
      value ? l10n.debugModeEnabled : l10n.debugModeDisabled,
    );
  }

  Widget _buildSheetHandle(bool isDark) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AdminColors.getDividerColor(isDark),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AdminColors.primary.withValues(alpha: 0.1) : null,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected
            ? AdminColors.primary
            : AdminColors.getTextTertiaryColor(isDark),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AdminColors.getTextColor(isDark),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
