import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/it_admin/shared/it_colors.dart';
import '../../../widgets/it_admin/it_settings/it_settings_barrel.dart';

class ITSettingsScreen extends StatefulWidget {
  const ITSettingsScreen({super.key});

  @override
  State<ITSettingsScreen> createState() => _ITSettingsScreenState();
}

class _ITSettingsScreenState extends State<ITSettingsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Settings state
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _twoFactorAuth = true;
  bool _systemAlerts = true;
  bool _maintenanceAlerts = true;

  // IT specific settings
  bool _autoBackup = true;
  bool _performanceMonitoring = true;
  bool _securityScanning = true;
  bool _apiLogging = true;

  // Font size state
  FontSizeOption _selectedFontSize = FontSizeOption.medium;

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
    _animationController.forward();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final themeState = context.read<ThemeBloc>().state;
    setState(() {
      _pushNotifications = prefs.getBool('it_push_notifications') ?? true;
      _emailNotifications = prefs.getBool('it_email_notifications') ?? true;
      _twoFactorAuth = prefs.getBool('it_two_factor_auth') ?? true;
      _systemAlerts = prefs.getBool('it_system_alerts') ?? true;
      _maintenanceAlerts = prefs.getBool('it_maintenance_alerts') ?? true;
      _autoBackup = prefs.getBool('it_auto_backup') ?? true;
      _performanceMonitoring =
          prefs.getBool('it_performance_monitoring') ?? true;
      _securityScanning = prefs.getBool('it_security_scanning') ?? true;
      _apiLogging = prefs.getBool('it_api_logging') ?? true;
      _selectedFontSize = themeState.fontSize;
    });
  }

  Future<void> _saveSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
        final isDark = themeState.themeMode == AppThemeMode.dark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: ITColors.scaffoldColor(isDark),
          // drawer: ITDrawer(
          //   currentRoute: '/it-admin/account-settings',
          //   isDark: isDark,
          // ),
          appBar: _buildAppBar(l10n, isDark),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // User Header
                ITSettingsHeader(
                  name: 'System Administrator',
                  email: 'it.admin@eduverse.dev',
                  role: l10n.itAdmin,
                  isDark: isDark,
                  onTap: () => context.push('/it-admin/profile'),
                ),

                const SizedBox(height: 24),

                // Account Section
                ITSettingsSection(
                  title: l10n.account,
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: Icons.person_outline_rounded,
                      title: l10n.editProfile,
                      subtitle: l10n.editProfileDesc,
                      onTap: () => context.push('/it-admin/edit-profile'),
                    ),
                    ITSettingsItem(
                      icon: Icons.lock_outline_rounded,
                      title: l10n.changePassword,
                      subtitle: l10n.changePasswordDesc,
                      onTap: () => _showChangePasswordSheet(isDark, l10n),
                    ),
                    ITSettingsItem(
                      icon: Icons.email_outlined,
                      title: l10n.emailPreferences,
                      subtitle: l10n.emailPreferencesDesc,
                      onTap: () => context.push('/settings/email'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notifications Section
                ITSettingsSection(
                  title: l10n.notifications,
                  icon: Icons.notifications_outlined,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: Icons.notifications_active_outlined,
                      title: l10n.pushNotifications,
                      subtitle: l10n.pushNotificationsSettingsDesc,
                      hasToggle: true,
                      toggleValue: _pushNotifications,
                      onToggleChanged: (value) {
                        setState(() => _pushNotifications = value);
                        _saveSettings('it_push_notifications', value);
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.email_outlined,
                      title: l10n.emailNotifications,
                      subtitle: l10n.emailNotificationsDesc,
                      hasToggle: true,
                      toggleValue: _emailNotifications,
                      onToggleChanged: (value) {
                        setState(() => _emailNotifications = value);
                        _saveSettings('it_email_notifications', value);
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.warning_amber_rounded,
                      title: l10n.itSettingsSystemAlerts,
                      subtitle: l10n.itSettingsSystemAlertsDesc,
                      iconColor: ITColors.warning,
                      hasToggle: true,
                      toggleValue: _systemAlerts,
                      onToggleChanged: (value) {
                        setState(() => _systemAlerts = value);
                        _saveSettings('it_system_alerts', value);
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.build_circle_outlined,
                      title: l10n.itSettingsMaintenanceAlerts,
                      subtitle: l10n.itSettingsMaintenanceAlertsDesc,
                      iconColor: ITColors.maintenance,
                      hasToggle: true,
                      toggleValue: _maintenanceAlerts,
                      onToggleChanged: (value) {
                        setState(() => _maintenanceAlerts = value);
                        _saveSettings('it_maintenance_alerts', value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Appearance Section
                ITSettingsSection(
                  title: l10n.appearance,
                  icon: Icons.palette_outlined,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: l10n.theme,
                      subtitle: isDark ? l10n.dark : l10n.light,
                      onTap: () => _showThemeSheet(isDark, l10n),
                    ),
                    ITSettingsItem(
                      icon: Icons.language_rounded,
                      title: l10n.language,
                      subtitle: l10n.currentLanguage,
                      onTap: () => context.push('/settings/language'),
                    ),
                    ITSettingsItem(
                      icon: Icons.text_fields_rounded,
                      title: l10n.fontSize,
                      subtitle: _getFontSizeLabel(l10n),
                      onTap: () => _showFontSizeSheet(isDark, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Privacy & Security Section
                ITSettingsSection(
                  title: l10n.privacySecurity,
                  icon: Icons.security_outlined,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: Icons.verified_user_outlined,
                      title: l10n.twoFactorAuth,
                      subtitle: _twoFactorAuth ? l10n.enabled : l10n.disabled,
                      hasToggle: true,
                      toggleValue: _twoFactorAuth,
                      onToggleChanged: (value) {
                        setState(() => _twoFactorAuth = value);
                        _saveSettings('it_two_factor_auth', value);
                        _showSnackBar(
                          value
                              ? l10n.itSettingsTwoFactorEnabled
                              : l10n.itSettingsTwoFactorDisabled,
                          isDark,
                        );
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.devices_rounded,
                      title: l10n.connectedDevices,
                      subtitle: l10n.devicesConnected(3),
                      onTap: () => context.push('/settings/connected-devices'),
                    ),
                    ITSettingsItem(
                      icon: Icons.history_rounded,
                      title: l10n.loginHistory,
                      subtitle: l10n.loginHistoryDesc,
                      onTap: () => context.push('/settings/login-history'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // IT Tools Section
                ITSettingsSection(
                  title: l10n.itSettingsTools,
                  icon: Icons.build_outlined,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: Icons.backup_rounded,
                      title: l10n.itSettingsAutoBackup,
                      subtitle: l10n.itSettingsAutoBackupDesc,
                      iconColor: ITColors.success,
                      hasToggle: true,
                      toggleValue: _autoBackup,
                      onToggleChanged: (value) {
                        setState(() => _autoBackup = value);
                        _saveSettings('it_auto_backup', value);
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.analytics_outlined,
                      title: l10n.itSettingsPerformanceMonitoring,
                      subtitle: l10n.itSettingsPerformanceMonitoringDesc,
                      hasToggle: true,
                      toggleValue: _performanceMonitoring,
                      onToggleChanged: (value) {
                        setState(() => _performanceMonitoring = value);
                        _saveSettings('it_performance_monitoring', value);
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.security_rounded,
                      title: l10n.itSettingsSecurityScanning,
                      subtitle: l10n.itSettingsSecurityScanningDesc,
                      iconColor: ITColors.error,
                      hasToggle: true,
                      toggleValue: _securityScanning,
                      onToggleChanged: (value) {
                        setState(() => _securityScanning = value);
                        _saveSettings('it_security_scanning', value);
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.api_rounded,
                      title: l10n.itSettingsApiLogging,
                      subtitle: l10n.itSettingsApiLoggingDesc,
                      iconColor: ITColors.secondary,
                      hasToggle: true,
                      toggleValue: _apiLogging,
                      onToggleChanged: (value) {
                        setState(() => _apiLogging = value);
                        _saveSettings('it_api_logging', value);
                      },
                    ),
                    ITSettingsItem(
                      icon: Icons.settings_applications_rounded,
                      title: l10n.itSettingsSystemConfig,
                      subtitle: l10n.itSettingsSystemConfigDesc,
                      onTap: () => context.push('/it-admin/settings'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Storage & Data Section
                ITSettingsSection(
                  title: l10n.storageData,
                  icon: Icons.storage_outlined,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: Icons.cleaning_services_outlined,
                      title: l10n.clearCache,
                      subtitle: l10n.clearCacheDesc,
                      onTap: () => _showClearCacheDialog(isDark, l10n),
                    ),
                    ITSettingsItem(
                      icon: Icons.download_rounded,
                      title: l10n.downloadMyData,
                      subtitle: l10n.downloadMyDataSettingsDesc,
                      onTap: () => _showExportDataDialog(isDark, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Support Section
                ITSettingsSection(
                  title: l10n.support,
                  icon: Icons.help_outline_rounded,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: Icons.help_outline_rounded,
                      title: l10n.helpCenter,
                      subtitle: l10n.helpCenterDesc,
                      onTap: () => context.push('/settings/help'),
                    ),
                    ITSettingsItem(
                      icon: Icons.feedback_outlined,
                      title: l10n.sendFeedback,
                      subtitle: l10n.sendFeedbackSettingsDesc,
                      onTap: () => _showFeedbackSheet(isDark, l10n),
                    ),
                    ITSettingsItem(
                      icon: Icons.bug_report_outlined,
                      title: l10n.reportBug,
                      subtitle: l10n.reportBugSettingsDesc,
                      onTap: () => _showBugReportSheet(isDark, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // About Section
                ITSettingsSection(
                  title: l10n.about,
                  icon: Icons.info_outline_rounded,
                  isDark: isDark,
                  items: [
                    ITSettingsItem(
                      icon: Icons.article_outlined,
                      title: l10n.termsOfService,
                      subtitle: '',
                      onTap: () => context.push('/settings/terms'),
                    ),
                    ITSettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      subtitle: '',
                      onTap: () => context.push('/settings/privacy-policy'),
                    ),
                    ITSettingsItem(
                      icon: Icons.info_outline_rounded,
                      title: l10n.aboutApp,
                      subtitle: 'Version 1.0.0',
                      onTap: () => context.push('/settings/about'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(isDark, l10n),

                const SizedBox(height: 32),
              ],
            ),
          ),
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
        l10n.itSettingsTitle,
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

  String _getFontSizeLabel(AppLocalizations l10n) {
    switch (_selectedFontSize) {
      case FontSizeOption.small:
        return l10n.small;
      case FontSizeOption.medium:
        return l10n.medium;
      case FontSizeOption.large:
        return l10n.large;
    }
  }

  Widget _buildLogoutButton(bool isDark, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(isDark, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: ITColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ITColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: ITColors.error, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n.logout,
                style: TextStyle(
                  color: ITColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
          decoration: InputDecoration(
            hintText: l10n.itSettingsSearchHint,
            hintStyle: TextStyle(color: ITColors.textTertiaryColor(isDark)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: ITColors.textSecondaryColor(isDark),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.borderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.borderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ITColors.primary),
            ),
          ),
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(bool isDark, AppLocalizations l10n) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ITColors.scaffoldColor(isDark),
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
                l10n.changePassword,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: currentPasswordController,
                label: l10n.currentPassword,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: newPasswordController,
                label: l10n.newPassword,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: confirmPasswordController,
                label: l10n.confirmPassword,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar(l10n.passwordChangedSuccess, isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ITColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.changePassword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ITColors.textSecondaryColor(isDark)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ITColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ITColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ITColors.primary),
        ),
      ),
      style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
    );
  }

  void _showThemeSheet(bool isDark, AppLocalizations l10n) {
    final themeMode = context.read<ThemeBloc>().state.themeMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ITColors.scaffoldColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ITColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.theme,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildThemeOption(
              icon: Icons.light_mode_rounded,
              title: l10n.light,
              isSelected: themeMode == AppThemeMode.light,
              isDark: isDark,
              onTap: () {
                context.read<ThemeBloc>().add(
                  const SetThemeModeEvent(AppThemeMode.light),
                );
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _buildThemeOption(
              icon: Icons.dark_mode_rounded,
              title: l10n.dark,
              isSelected: themeMode == AppThemeMode.dark,
              isDark: isDark,
              onTap: () {
                context.read<ThemeBloc>().add(
                  const SetThemeModeEvent(AppThemeMode.dark),
                );
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _buildThemeOption(
              icon: Icons.settings_suggest_rounded,
              title: l10n.system,
              isSelected: themeMode == AppThemeMode.system,
              isDark: isDark,
              onTap: () {
                context.read<ThemeBloc>().add(
                  const SetThemeModeEvent(AppThemeMode.system),
                );
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? ITColors.primary.withValues(alpha: 0.1)
                : ITColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ITColors.primary
                  : ITColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ITColors.primary
                    : ITColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? ITColors.primary
                        : ITColors.textPrimaryColor(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: ITColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ITColors.scaffoldColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ITColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.fontSize,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildFontSizeOption(
              title: l10n.small,
              size: FontSizeOption.small,
              isDark: isDark,
              ctx: ctx,
            ),
            const SizedBox(height: 10),
            _buildFontSizeOption(
              title: l10n.medium,
              size: FontSizeOption.medium,
              isDark: isDark,
              ctx: ctx,
            ),
            const SizedBox(height: 10),
            _buildFontSizeOption(
              title: l10n.large,
              size: FontSizeOption.large,
              isDark: isDark,
              ctx: ctx,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption({
    required String title,
    required FontSizeOption size,
    required bool isDark,
    required BuildContext ctx,
  }) {
    final isSelected = _selectedFontSize == size;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedFontSize = size);
          context.read<ThemeBloc>().add(SetFontSizeEvent(size));
          Navigator.pop(ctx);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? ITColors.primary.withValues(alpha: 0.1)
                : ITColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ITColors.primary
                  : ITColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  color: isSelected
                      ? ITColors.primary
                      : ITColors.textSecondaryColor(isDark),
                  fontSize: _getFontSizeValue(size),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? ITColors.primary
                        : ITColors.textPrimaryColor(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: ITColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _getFontSizeValue(FontSizeOption size) {
    switch (size) {
      case FontSizeOption.small:
        return 12;
      case FontSizeOption.medium:
        return 14;
      case FontSizeOption.large:
        return 16;
    }
  }

  void _showClearCacheDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.clearCache,
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          l10n.clearCacheConfirmation,
          style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(l10n.cacheCleared, isDark);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: Text(
              l10n.clearCache,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.downloadMyData,
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          l10n.downloadMyDataDesc,
          style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(l10n.dataExportStarted, isDark);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
            child: Text(
              l10n.download,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(bool isDark, AppLocalizations l10n) {
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ITColors.scaffoldColor(isDark),
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
                l10n.sendFeedback,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.feedbackHint,
                  hintStyle: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ITColors.borderColor(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ITColors.borderColor(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ITColors.primary),
                  ),
                ),
                style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar(l10n.feedbackSent, isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ITColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.submit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showBugReportSheet(bool isDark, AppLocalizations l10n) {
    final bugController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ITColors.scaffoldColor(isDark),
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
                l10n.reportBug,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: bugController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.reportBugDesc,
                  hintStyle: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ITColors.borderColor(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ITColors.borderColor(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ITColors.primary),
                  ),
                ),
                style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar(l10n.bugReportSent, isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ITColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.submit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ITColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.logout,
          style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.error),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ITColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
