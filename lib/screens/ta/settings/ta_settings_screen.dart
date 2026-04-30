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
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/settings/ta_settings_barrel.dart';

class TASettingsScreen extends StatefulWidget {
  const TASettingsScreen({super.key});

  @override
  State<TASettingsScreen> createState() => _TASettingsScreenState();
}

class _TASettingsScreenState extends State<TASettingsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Settings state
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _twoFactorAuth = false;
  bool _autoGradeAssist = true;
  bool _studentAlerts = true;

  // Grading preferences state
  bool _showAISuggestions = true;
  bool _autoSaveGrades = true;
  bool _plagiarismCheck = false;

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
    final themeState = context.read<ThemeBloc>().state;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('ta_push_notifications') ?? true;
      _emailNotifications = prefs.getBool('ta_email_notifications') ?? true;
      _twoFactorAuth = prefs.getBool('ta_two_factor_auth') ?? false;
      _autoGradeAssist = prefs.getBool('ta_auto_grade_assist') ?? true;
      _studentAlerts = prefs.getBool('ta_student_alerts') ?? true;
      _showAISuggestions = prefs.getBool('ta_show_ai_suggestions') ?? true;
      _autoSaveGrades = prefs.getBool('ta_auto_save_grades') ?? true;
      _plagiarismCheck = prefs.getBool('ta_plagiarism_check') ?? false;
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
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(),
          appBar: _buildAppBar(l10n, isDark),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // User Header
                TASettingsHeader(
                  name: 'Ahmed Hassan',
                  email: 'ta@eduverse.dev',
                  role: l10n.taRole,
                  isDark: isDark,
                  onTap: () => context.push('/ta/profile'),
                ),

                const SizedBox(height: 24),

                // Account Section
                TASettingsSection(
                  title: l10n.account,
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: Icons.person_outline_rounded,
                      title: l10n.editProfile,
                      subtitle: l10n.editProfileDesc,
                      onTap: () => context.push('/ta/edit-profile'),
                    ),
                    TASettingsItem(
                      icon: Icons.lock_outline_rounded,
                      title: l10n.changePassword,
                      subtitle: l10n.changePasswordDesc,
                      onTap: () => _showChangePasswordSheet(isDark, l10n),
                    ),
                    TASettingsItem(
                      icon: Icons.email_outlined,
                      title: l10n.emailPreferences,
                      subtitle: l10n.emailPreferencesDesc,
                      onTap: () => context.push('/settings/email'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notifications Section
                TASettingsSection(
                  title: l10n.notifications,
                  icon: Icons.notifications_outlined,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: Icons.notifications_active_outlined,
                      title: l10n.pushNotifications,
                      subtitle: l10n.pushNotificationsSettingsDesc,
                      hasToggle: true,
                      toggleValue: _pushNotifications,
                      onToggleChanged: (value) {
                        setState(() => _pushNotifications = value);
                        _saveSettings('ta_push_notifications', value);
                      },
                    ),
                    TASettingsItem(
                      icon: Icons.email_outlined,
                      title: l10n.emailNotifications,
                      subtitle: l10n.emailNotificationsDesc,
                      hasToggle: true,
                      toggleValue: _emailNotifications,
                      onToggleChanged: (value) {
                        setState(() => _emailNotifications = value);
                        _saveSettings('ta_email_notifications', value);
                      },
                    ),
                    TASettingsItem(
                      icon: Icons.warning_amber_rounded,
                      title: l10n.taSettingsStudentAlerts,
                      subtitle: l10n.taSettingsStudentAlertsDesc,
                      iconColor: TAColors.warning,
                      hasToggle: true,
                      toggleValue: _studentAlerts,
                      onToggleChanged: (value) {
                        setState(() => _studentAlerts = value);
                        _saveSettings('ta_student_alerts', value);
                      },
                    ),
                    TASettingsItem(
                      icon: Icons.swipe_rounded,
                      title: l10n.taNotifSwipeSettings,
                      subtitle: l10n.swipeActionsDesc,
                      onTap: () =>
                          context.push('/settings/swipe-actions/notifications'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Appearance Section
                TASettingsSection(
                  title: l10n.appearance,
                  icon: Icons.palette_outlined,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: l10n.theme,
                      subtitle: isDark ? l10n.dark : l10n.light,
                      onTap: () => _showThemeSheet(isDark, l10n),
                    ),
                    TASettingsItem(
                      icon: Icons.language_rounded,
                      title: l10n.language,
                      subtitle: l10n.currentLanguage,
                      onTap: () => context.push('/settings/language'),
                    ),
                    TASettingsItem(
                      icon: Icons.text_fields_rounded,
                      title: l10n.fontSize,
                      subtitle: l10n.medium,
                      onTap: () => _showFontSizeSheet(isDark, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Privacy & Security Section
                TASettingsSection(
                  title: l10n.privacySecurity,
                  icon: Icons.security_outlined,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: Icons.verified_user_outlined,
                      title: l10n.twoFactorAuth,
                      subtitle: _twoFactorAuth ? l10n.enabled : l10n.disabled,
                      hasToggle: true,
                      toggleValue: _twoFactorAuth,
                      onToggleChanged: (value) {
                        setState(() => _twoFactorAuth = value);
                        _saveSettings('ta_two_factor_auth', value);
                        _showSnackBar(
                          value
                              ? 'Two-factor authentication enabled'
                              : 'Two-factor authentication disabled',
                          isDark,
                        );
                      },
                    ),
                    TASettingsItem(
                      icon: Icons.devices_rounded,
                      title: l10n.connectedDevices,
                      subtitle: l10n.devicesConnected(2),
                      onTap: () => context.push('/settings/connected-devices'),
                    ),
                    TASettingsItem(
                      icon: Icons.history_rounded,
                      title: l10n.loginHistory,
                      subtitle: l10n.loginHistoryDesc,
                      onTap: () => context.push('/settings/login-history'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // TA Tools Section
                TASettingsSection(
                  title: l10n.taSettingsTools,
                  icon: Icons.build_outlined,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: Icons.auto_fix_high_rounded,
                      title: l10n.taSettingsAIGrading,
                      subtitle: l10n.taSettingsAIGradingDesc,
                      iconColor: TAColors.primary,
                      hasToggle: true,
                      toggleValue: _autoGradeAssist,
                      onToggleChanged: (value) {
                        setState(() => _autoGradeAssist = value);
                        _saveSettings('ta_auto_grade_assist', value);
                      },
                    ),
                    TASettingsItem(
                      icon: Icons.analytics_outlined,
                      title: l10n.taSettingsAnalytics,
                      subtitle: l10n.taSettingsAnalyticsDesc,
                      onTap: () => context.push('/ta/analytics'),
                    ),
                    TASettingsItem(
                      icon: Icons.schedule_rounded,
                      title: l10n.taSettingsOfficeHours,
                      subtitle: l10n.taSettingsOfficeHoursDesc,
                      onTap: () => _showOfficeHoursSheet(isDark, l10n),
                    ),
                    TASettingsItem(
                      icon: Icons.grading_rounded,
                      title: l10n.taSettingsGradingPrefs,
                      subtitle: l10n.taSettingsGradingPrefsDesc,
                      onTap: () => _showGradingPrefsSheet(isDark, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Storage & Data Section
                TASettingsSection(
                  title: l10n.storageData,
                  icon: Icons.storage_outlined,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: Icons.cleaning_services_outlined,
                      title: l10n.clearCache,
                      subtitle: l10n.clearCacheDesc,
                      onTap: () => _showClearCacheDialog(isDark, l10n),
                    ),
                    TASettingsItem(
                      icon: Icons.download_rounded,
                      title: l10n.downloadMyData,
                      subtitle: l10n.downloadMyDataSettingsDesc,
                      onTap: () => _showExportDataDialog(isDark, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Support Section
                TASettingsSection(
                  title: l10n.support,
                  icon: Icons.help_outline_rounded,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: Icons.help_outline_rounded,
                      title: l10n.helpCenter,
                      subtitle: l10n.helpCenterDesc,
                      onTap: () => context.push('/settings/help'),
                    ),
                    TASettingsItem(
                      icon: Icons.feedback_outlined,
                      title: l10n.sendFeedback,
                      subtitle: l10n.sendFeedbackSettingsDesc,
                      onTap: () => _showFeedbackSheet(isDark, l10n),
                    ),
                    TASettingsItem(
                      icon: Icons.bug_report_outlined,
                      title: l10n.reportBug,
                      subtitle: l10n.reportBugSettingsDesc,
                      onTap: () => _showBugReportSheet(isDark, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // About Section
                TASettingsSection(
                  title: l10n.about,
                  icon: Icons.info_outline_rounded,
                  isDark: isDark,
                  items: [
                    TASettingsItem(
                      icon: Icons.article_outlined,
                      title: l10n.termsOfService,
                      subtitle: '',
                      onTap: () => context.push('/settings/terms'),
                    ),
                    TASettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      subtitle: '',
                      onTap: () => context.push('/settings/privacy-policy'),
                    ),
                    TASettingsItem(
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
      backgroundColor: TAColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        l10n.settings,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
          onPressed: () => _showSearchDialog(isDark, l10n),
        ),
        const SizedBox(width: 8),
      ],
    );
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
            color: TAColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TAColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: TAColors.error, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n.logout,
                style: TextStyle(
                  color: TAColors.error,
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
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.search,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search settings...',
            hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: TAColors.textSecondaryColor(isDark),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TAColors.borderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TAColors.borderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TAColors.primary),
            ),
          ),
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
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
            color: TAColors.scaffoldColor(isDark),
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
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.changePassword,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: currentPasswordController,
                label: 'Current Password',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: newPasswordController,
                label: 'New Password',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: confirmPasswordController,
                label: 'Confirm New Password',
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Password changed successfully', isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TAColors.primary,
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
        labelStyle: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TAColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TAColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TAColors.primary),
        ),
      ),
      style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
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
          color: TAColors.scaffoldColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.theme,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
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
                ? TAColors.primary.withValues(alpha: 0.1)
                : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? TAColors.primary
                  : TAColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? TAColors.primary
                    : TAColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? TAColors.primary
                        : TAColors.textPrimaryColor(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: TAColors.primary),
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TAColors.scaffoldColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.fontSize,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildFontSizeOptionNew(
                l10n.small,
                'Aa',
                14,
                isDark,
                FontSizeOption.small,
                _selectedFontSize,
                (option) {
                  setSheetState(() {});
                  setState(() => _selectedFontSize = option);
                  context.read<ThemeBloc>().add(SetFontSizeEvent(option));
                  Navigator.pop(ctx);
                  _showSnackBar(l10n.small, isDark);
                },
              ),
              const SizedBox(height: 10),
              _buildFontSizeOptionNew(
                l10n.medium,
                'Aa',
                16,
                isDark,
                FontSizeOption.medium,
                _selectedFontSize,
                (option) {
                  setSheetState(() {});
                  setState(() => _selectedFontSize = option);
                  context.read<ThemeBloc>().add(SetFontSizeEvent(option));
                  Navigator.pop(ctx);
                  _showSnackBar(l10n.medium, isDark);
                },
              ),
              const SizedBox(height: 10),
              _buildFontSizeOptionNew(
                l10n.large,
                'Aa',
                18,
                isDark,
                FontSizeOption.large,
                _selectedFontSize,
                (option) {
                  setSheetState(() {});
                  setState(() => _selectedFontSize = option);
                  context.read<ThemeBloc>().add(SetFontSizeEvent(option));
                  Navigator.pop(ctx);
                  _showSnackBar(l10n.large, isDark);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeOptionNew(
    String title,
    String preview,
    double size,
    bool isDark,
    FontSizeOption option,
    FontSizeOption selectedOption,
    ValueChanged<FontSizeOption> onTap,
  ) {
    final isSelected = option == selectedOption;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? TAColors.primary.withValues(alpha: 0.1)
                : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? TAColors.primary
                  : TAColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              Text(
                preview,
                style: TextStyle(
                  fontSize: size,
                  color: TAColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: TAColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showOfficeHoursSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.scaffoldColor(isDark),
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
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.taSettingsOfficeHours,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildOfficeHourSlot('Monday', '2:00 PM - 4:00 PM', isDark),
            _buildOfficeHourSlot('Wednesday', '10:00 AM - 12:00 PM', isDark),
            _buildOfficeHourSlot('Friday', '3:00 PM - 5:00 PM', isDark),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeHourSlot(String day, String time, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: TAColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGradingPrefsSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TAColors.scaffoldColor(isDark),
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
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.taSettingsGradingPrefs,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildGradingPrefItemWithState(
                'Show AI Suggestions',
                'Display AI-generated feedback suggestions',
                _showAISuggestions,
                isDark,
                (value) {
                  setSheetState(() {});
                  setState(() => _showAISuggestions = value);
                  _saveSettings('ta_show_ai_suggestions', value);
                },
              ),
              _buildGradingPrefItemWithState(
                'Auto-save Grades',
                'Automatically save grades while typing',
                _autoSaveGrades,
                isDark,
                (value) {
                  setSheetState(() {});
                  setState(() => _autoSaveGrades = value);
                  _saveSettings('ta_auto_save_grades', value);
                },
              ),
              _buildGradingPrefItemWithState(
                'Plagiarism Check',
                'Run plagiarism check on submissions',
                _plagiarismCheck,
                isDark,
                (value) {
                  setSheetState(() {});
                  setState(() => _plagiarismCheck = value);
                  _saveSettings('ta_plagiarism_check', value);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Grading preferences saved', isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TAColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(
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

  Widget _buildGradingPrefItemWithState(
    String title,
    String subtitle,
    bool value,
    bool isDark,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: TAColors.primary,
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.clearCache,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          'This will clear all cached data. Are you sure?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cache cleared successfully', isDark);
            },
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.primary),
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
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.downloadMyData,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          'Export all your data including grading history, feedback, and settings.',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Data export started...', isDark);
            },
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.primary),
            child: const Text('Export', style: TextStyle(color: Colors.white)),
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
            color: TAColors.scaffoldColor(isDark),
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
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.sendFeedback,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us what you think...',
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TAColors.primary),
                  ),
                ),
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Thank you for your feedback!', isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TAColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Feedback',
                    style: TextStyle(
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
            color: TAColors.scaffoldColor(isDark),
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
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.reportBug,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bugController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the bug in detail...',
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TAColors.primary),
                  ),
                ),
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Bug report submitted. Thank you!', isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TAColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Bug Report',
                    style: TextStyle(
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
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.logout,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
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
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.error),
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
        backgroundColor: TAColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
