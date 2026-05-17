import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/settings/settings_header.dart';
import '../../../widgets/student/settings/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => safeBack(context, '/dashboard'),
          icon: Icon(
            iosBackIcon(context),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context, l10n, isDark),
            icon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            tooltip: l10n.search,
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // User Quick Info
                if (state is ProfileLoaded)
                  SettingsHeader(
                    profile: state.profile,
                    isDark: isDark,
                    onTap: () => context.push('/profile'),
                  ),

                const SizedBox(height: 24),

                // Account Section
                SettingsSection(
                  title: l10n.account,
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: Icons.person_outline_rounded,
                      title: l10n.editProfile,
                      subtitle: l10n.editProfileDesc,
                      onTap: () => context.push('/edit-profile'),
                    ),
                    SettingsItem(
                      icon: Icons.lock_outline_rounded,
                      title: l10n.changePassword,
                      subtitle: l10n.changePasswordDesc,
                      onTap: () =>
                          _showChangePasswordSheet(context, l10n, isDark),
                    ),
                    SettingsItem(
                      icon: Icons.email_outlined,
                      title: l10n.emailPreferences,
                      subtitle: l10n.emailPreferencesDesc,
                      onTap: () => context.push('/settings/email'),
                    ),
                    SettingsItem(
                      icon: Icons.phone_outlined,
                      title: l10n.phoneNumber,
                      subtitle: state is ProfileLoaded
                          ? (state.profile.phoneNumber ?? l10n.notSet)
                          : '',
                      onTap: () => _showPhoneSheet(context, l10n, isDark),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notifications Section
                SettingsSection(
                  title: l10n.notifications,
                  icon: Icons.notifications_outlined,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: Icons.notifications_active_outlined,
                      title: l10n.pushNotifications,
                      subtitle: l10n.pushNotificationsSettingsDesc,
                      onTap: () => context.push('/settings/notifications'),
                    ),
                    SettingsItem(
                      icon: Icons.email_outlined,
                      title: l10n.emailNotifications,
                      subtitle: l10n.emailNotificationsDesc,
                      onTap: () =>
                          context.push('/settings/email-notifications'),
                    ),
                    SettingsItem(
                      icon: Icons.do_not_disturb_on_outlined,
                      title: l10n.doNotDisturb,
                      subtitle: l10n.doNotDisturbDesc,
                      onTap: () => context.push('/settings/dnd'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Appearance Section
                SettingsSection(
                  title: l10n.appearance,
                  icon: Icons.palette_outlined,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: l10n.theme,
                      subtitle: isDark ? l10n.dark : l10n.light,
                      onTap: () => context.push('/settings/appearance'),
                    ),
                    SettingsItem(
                      icon: Icons.language_rounded,
                      title: l10n.language,
                      subtitle: l10n.currentLanguage,
                      onTap: () => context.push('/settings/language'),
                    ),
                    SettingsItem(
                      icon: Icons.text_fields_rounded,
                      title: l10n.fontSize,
                      subtitle: l10n.medium,
                      onTap: () => _showFontSizeSheet(context, l10n, isDark),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Privacy & Security Section
                SettingsSection(
                  title: l10n.privacySecurity,
                  icon: Icons.security_outlined,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: Icons.verified_user_outlined,
                      title: l10n.twoFactorAuth,
                      subtitle:
                          state is ProfileLoaded && state.settings.twoFactorAuth
                          ? l10n.enabled
                          : l10n.disabled,
                      onTap: () => context.push('/settings/two-factor-auth'),
                    ),
                    SettingsItem(
                      icon: Icons.devices_rounded,
                      title: l10n.connectedDevices,
                      subtitle: state is ProfileLoaded
                          ? l10n.devicesConnected(state.connectedDevices.length)
                          : '',
                      onTap: () => context.push('/settings/connected-devices'),
                    ),
                    SettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacySettings,
                      subtitle: l10n.privacySettingsDesc,
                      onTap: () => context.push('/settings/privacy'),
                    ),
                    SettingsItem(
                      icon: Icons.history_rounded,
                      title: l10n.loginHistory,
                      subtitle: l10n.loginHistoryDesc,
                      onTap: () => context.push('/settings/login-history'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Learning Section
                SettingsSection(
                  title: l10n.learning,
                  icon: Icons.school_outlined,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: Icons.auto_awesome_outlined,
                      title: l10n.aiSettings,
                      subtitle: l10n.aiSettingsDesc,
                      onTap: () => context.push('/settings/ai'),
                    ),
                    SettingsItem(
                      icon: Icons.download_outlined,
                      title: l10n.downloadSettings,
                      subtitle: l10n.downloadSettingsDesc,
                      onTap: () => context.push('/settings/storage'),
                    ),
                    SettingsItem(
                      icon: Icons.swipe_rounded,
                      title: l10n.swipeActions,
                      subtitle: l10n.swipeActionsDesc,
                      onTap: () => context.push('/settings/swipe-actions'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Storage & Data Section
                SettingsSection(
                  title: l10n.storageData,
                  icon: Icons.storage_outlined,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: Icons.cleaning_services_outlined,
                      title: l10n.clearCache,
                      subtitle: l10n.clearCacheDesc,
                      onTap: () => _showClearCacheDialog(context, l10n, isDark),
                    ),
                    SettingsItem(
                      icon: Icons.download_rounded,
                      title: l10n.downloadMyData,
                      subtitle: l10n.downloadMyDataSettingsDesc,
                      onTap: () => _showExportDataDialog(context, l10n, isDark),
                    ),
                    SettingsItem(
                      icon: Icons.backup_outlined,
                      title: l10n.backup,
                      subtitle: l10n.backupDesc,
                      onTap: () => context.push('/settings/storage'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Support Section
                SettingsSection(
                  title: l10n.support,
                  icon: Icons.help_outline_rounded,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: Icons.help_outline_rounded,
                      title: l10n.helpCenter,
                      subtitle: l10n.helpCenterDesc,
                      onTap: () => context.push('/settings/help'),
                    ),
                    SettingsItem(
                      icon: Icons.feedback_outlined,
                      title: l10n.sendFeedback,
                      subtitle: l10n.sendFeedbackSettingsDesc,
                      onTap: () => _showFeedbackSheet(context, l10n, isDark),
                    ),
                    SettingsItem(
                      icon: Icons.bug_report_outlined,
                      title: l10n.reportBug,
                      subtitle: l10n.reportBugSettingsDesc,
                      onTap: () => _showBugReportSheet(context, l10n, isDark),
                    ),
                    SettingsItem(
                      icon: Icons.star_outline_rounded,
                      title: l10n.rateApp,
                      subtitle: l10n.rateAppDesc,
                      onTap: () => _showRateAppDialog(context, l10n, isDark),
                    ),
                    SettingsItem(
                      icon: Icons.share_rounded,
                      title: l10n.shareApp,
                      subtitle: l10n.shareAppDesc,
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => context.push('/settings/share-app'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // About Section
                SettingsSection(
                  title: l10n.about,
                  icon: Icons.info_outline_rounded,
                  isDark: isDark,
                  items: [
                    SettingsItem(
                      icon: Icons.article_outlined,
                      title: l10n.termsOfService,
                      subtitle: '',
                      onTap: () => context.push('/settings/terms'),
                    ),
                    SettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      subtitle: '',
                      onTap: () => context.push('/settings/privacy-policy'),
                    ),
                    SettingsItem(
                      icon: Icons.description_outlined,
                      title: l10n.licenses,
                      subtitle: '',
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'EduVerse',
                        applicationVersion: '1.0.0',
                      ),
                    ),
                    SettingsItem(
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
          );
        },
      ),
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
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.dangerZone,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDangerItem(
            context,
            icon: Icons.logout_rounded,
            title: l10n.signOut,
            onTap: () => _showSignOutDialog(context, l10n, isDark),
          ),
          const SizedBox(height: 12),
          _buildDangerItem(
            context,
            icon: Icons.delete_forever_outlined,
            title: l10n.deleteAccount,
            onTap: () => _showDeleteAccountDialog(context, l10n, isDark),
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
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.red.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showSearch(
      context: context,
      delegate: SettingsSearchDelegate(isDark: isDark, l10n: l10n),
    );
  }

  void _showChangePasswordSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.changePassword,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                currentController,
                l10n.currentPassword,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildPasswordField(newController, l10n.newPassword, isDark),
              const SizedBox(height: 12),
              _buildPasswordField(
                confirmController,
                l10n.confirmPassword,
                isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.passwordChangedSuccess),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.updatePassword,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool isDark,
  ) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
    );
  }

  void _showPhoneSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final controller = TextEditingController();
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      controller.text = state.profile.phoneNumber ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.phoneNumber,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.phoneUpdated),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.fontSize,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildFontSizeOption(context, l10n.small, false, isDark),
            _buildFontSizeOption(context, l10n.medium, true, isDark),
            _buildFontSizeOption(context, l10n.large, false, isDark),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    String label,
    bool isSelected,
    bool isDark,
  ) {
    return ListTile(
      onTap: () => Navigator.pop(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected
          ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
          : Colors.transparent,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected
            ? const Color(0xFF3B82F6)
            : (isDark ? Colors.white54 : Colors.black45),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
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
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.cleaning_services_outlined,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.clearCache,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.clearCacheConfirmation,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.cacheCleared),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
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

  void _showExportDataDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.download_rounded, color: Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            Text(
              l10n.downloadMyData,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.downloadDataConfirmation,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileCubit>().exportData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.dataExportStarted),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF3B82F6),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.download),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.sendFeedback,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 5,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: l10n.feedbackPlaceholder,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.feedbackSent),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.submit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showBugReportSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.reportBug,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: l10n.bugTitle,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: l10n.bugDescription,
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.bugReportSent),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.submit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showRateAppDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.rateApp,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.rateAppMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedRating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 30,
                              color: index < selectedRating
                                  ? Colors.amber
                                  : (isDark ? Colors.white38 : Colors.black26),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.notNow,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedRating > 0
                            ? () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.thankYouForRating),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          disabledBackgroundColor: isDark
                              ? Colors.white12
                              : Colors.black12,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(l10n.submit),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              l10n.signOut,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.signOutConfirmation,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    context.push('/profile');
  }
}

class SettingsSearchDelegate extends SearchDelegate {
  final bool isDark;
  final AppLocalizations l10n;

  SettingsSearchDelegate({required this.isDark, required this.l10n});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(iosBackIcon(context)),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = _getSearchResults();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.searchSettings,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: const Color(0xFF3B82F6),
          ),
          title: Text(
            item['title'] as String,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          subtitle: Text(
            item['category'] as String,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            close(context, null);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getSearchResults() {
    final allItems = [
      {
        'title': 'Edit Profile',
        'category': 'Account',
        'icon': Icons.person_outline_rounded,
      },
      {
        'title': 'Change Password',
        'category': 'Account',
        'icon': Icons.lock_outline_rounded,
      },
      {
        'title': 'Push Notifications',
        'category': 'Notifications',
        'icon': Icons.notifications_active_outlined,
      },
      {
        'title': 'Email Notifications',
        'category': 'Notifications',
        'icon': Icons.email_outlined,
      },
      {
        'title': 'Theme',
        'category': 'Appearance',
        'icon': Icons.palette_outlined,
      },
      {
        'title': 'Language',
        'category': 'Appearance',
        'icon': Icons.language_rounded,
      },
      {
        'title': 'Two-Factor Authentication',
        'category': 'Security',
        'icon': Icons.verified_user_outlined,
      },
      {
        'title': 'Connected Devices',
        'category': 'Security',
        'icon': Icons.devices_rounded,
      },
      {
        'title': 'Privacy Settings',
        'category': 'Security',
        'icon': Icons.privacy_tip_outlined,
      },
      {
        'title': 'AI Settings',
        'category': 'Learning',
        'icon': Icons.auto_awesome_outlined,
      },
      {
        'title': 'Clear Cache',
        'category': 'Storage',
        'icon': Icons.cleaning_services_outlined,
      },
      {
        'title': 'Help Center',
        'category': 'Support',
        'icon': Icons.help_outline_rounded,
      },
    ];

    if (query.isEmpty) return [];

    return allItems
        .where(
          (item) =>
              (item['title'] as String).toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              (item['category'] as String).toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }
}
