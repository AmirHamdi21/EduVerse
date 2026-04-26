import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/settings/grading_settings_sheet.dart';
import '../../../widgets/instructor/settings/assignment_settings_sheet.dart';
import '../../../widgets/instructor/settings/attendance_settings_sheet.dart';

/// Instructor Settings Screen
class InstructorSettingsScreen extends StatefulWidget {
  const InstructorSettingsScreen({super.key});

  @override
  State<InstructorSettingsScreen> createState() =>
      _InstructorSettingsScreenState();
}

class _InstructorSettingsScreenState extends State<InstructorSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(isDark, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileSection(isDark, l10n),
                        _buildSection(isDark, l10n.preferences, [
                          _SettingItem(
                            icon: Icons.palette_outlined,
                            title: l10n.appearance,
                            subtitle: l10n.appearanceDesc,
                            route: '/settings/appearance',
                          ),
                          _SettingItem(
                            icon: Icons.language_outlined,
                            title: l10n.language,
                            subtitle: l10n.languageDesc,
                            route: '/settings/language',
                          ),
                          _SettingItem(
                            icon: Icons.notifications_outlined,
                            title: l10n.notifications,
                            subtitle: l10n.notificationsDesc,
                            route: '/settings/notifications',
                          ),
                        ]),
                        _buildSection(isDark, l10n.teachingSettings, [
                          _SettingItem(
                            icon: Icons.grading_outlined,
                            title: l10n.gradingPreferences,
                            subtitle: l10n.gradingPreferencesDesc,
                            onTap: () => _showGradingSettings(isDark, l10n),
                          ),
                          _SettingItem(
                            icon: Icons.assignment_outlined,
                            title: l10n.assignmentDefaults,
                            subtitle: l10n.assignmentDefaultsDesc,
                            onTap: () => _showAssignmentDefaults(isDark, l10n),
                          ),
                          _SettingItem(
                            icon: Icons.how_to_reg_outlined,
                            title: l10n.attendanceSettings,
                            subtitle: l10n.attendanceSettingsDesc,
                            onTap: () => _showAttendanceSettings(isDark, l10n),
                          ),
                        ]),
                        _buildSection(isDark, l10n.privacySecurity, [
                          _SettingItem(
                            icon: Icons.lock_outline,
                            title: l10n.privacy,
                            subtitle: l10n.privacyDesc,
                            route: '/settings/privacy',
                          ),
                          _SettingItem(
                            icon: Icons.security_outlined,
                            title: l10n.twoFactorAuth,
                            subtitle: l10n.twoFactorAuthDesc,
                            route: '/settings/two-factor-auth',
                          ),
                          _SettingItem(
                            icon: Icons.devices_outlined,
                            title: l10n.connectedDevices,
                            subtitle: l10n.connectedDevicesDesc,
                            route: '/settings/connected-devices',
                          ),
                          _SettingItem(
                            icon: Icons.history_outlined,
                            title: l10n.loginHistory,
                            subtitle: l10n.loginHistoryDesc,
                            route: '/settings/login-history',
                          ),
                        ]),
                        _buildSection(isDark, l10n.dataStorage, [
                          _SettingItem(
                            icon: Icons.storage_outlined,
                            title: l10n.storageUsage,
                            subtitle: l10n.storageUsageDesc,
                            route: '/settings/storage',
                          ),
                          _SettingItem(
                            icon: Icons.cloud_download_outlined,
                            title: l10n.exportData,
                            subtitle: l10n.exportDataDesc,
                            onTap: () => _showExportOptions(isDark, l10n),
                          ),
                        ]),
                        _buildSection(isDark, l10n.support, [
                          _SettingItem(
                            icon: Icons.help_outline,
                            title: l10n.helpCenter,
                            subtitle: l10n.helpCenterDesc,
                            route: '/settings/help',
                          ),
                          _SettingItem(
                            icon: Icons.feedback_outlined,
                            title: l10n.sendFeedback,
                            subtitle: l10n.sendFeedbackDesc,
                            onTap: () => _showFeedbackSheet(isDark, l10n),
                          ),
                          _SettingItem(
                            icon: Icons.share_outlined,
                            title: l10n.shareApp,
                            subtitle: l10n.shareAppDesc,
                            route: '/settings/share-app',
                          ),
                        ]),
                        _buildSection(isDark, l10n.legal, [
                          _SettingItem(
                            icon: Icons.description_outlined,
                            title: l10n.termsOfService,
                            subtitle: l10n.termsOfServiceDesc,
                            route: '/settings/terms',
                          ),
                          _SettingItem(
                            icon: Icons.privacy_tip_outlined,
                            title: l10n.privacyPolicy,
                            subtitle: l10n.privacyPolicyDesc,
                            route: '/settings/privacy-policy',
                          ),
                          _SettingItem(
                            icon: Icons.info_outline,
                            title: l10n.about,
                            subtitle: l10n.aboutDesc,
                            route: '/settings/about',
                          ),
                        ]),
                        _buildLogoutButton(isDark, l10n),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              l10n.settings,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(bool isDark, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push('/instructor/profile'),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [InstructorColors.primary, InstructorColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: InstructorColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'SM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dr. Sarah Mitchell',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'sarah.mitchell@university.edu',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Associate Professor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(bool isDark, String title, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: InstructorColors.textTertiaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildSettingTile(
                isDark,
                item,
                isFirst: index == 0,
                isLast: index == items.length - 1,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    bool isDark,
    _SettingItem item, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (item.route != null) {
          context.push(item.route!);
        } else if (item.onTap != null) {
          item.onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: InstructorColors.borderColor(
                      isDark,
                    ).withValues(alpha: 0.5),
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: InstructorColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: InstructorColors.textTertiaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (item.trailing != null)
              item.trailing!
            else
              Icon(
                Icons.chevron_right_rounded,
                color: InstructorColors.textTertiaryColor(isDark),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutConfirmation(isDark, l10n),
          icon: const Icon(Icons.logout_rounded),
          label: Text(l10n.logout),
          style: OutlinedButton.styleFrom(
            foregroundColor: InstructorColors.error,
            side: const BorderSide(color: InstructorColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _showGradingSettings(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GradingSettingsSheet(isDark: isDark),
    );
  }

  void _showAssignmentDefaults(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AssignmentSettingsSheet(isDark: isDark),
    );
  }

  void _showAttendanceSettings(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AttendanceSettingsSheet(isDark: isDark),
    );
  }

  void _showExportOptions(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.exportData,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              isDark,
              Icons.grade_outlined,
              l10n.exportGrades,
              () {},
            ),
            _buildExportOption(
              isDark,
              Icons.people_outlined,
              l10n.exportStudentList,
              () {},
            ),
            _buildExportOption(
              isDark,
              Icons.how_to_reg_outlined,
              l10n.exportAttendance,
              () {},
            ),
            _buildExportOption(
              isDark,
              Icons.assessment_outlined,
              l10n.exportReports,
              () {},
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    bool isDark,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting $title...'),
            backgroundColor: InstructorColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: InstructorColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.download_outlined,
              color: InstructorColors.textTertiaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackSheet(bool isDark, AppLocalizations l10n) {
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.sendFeedback,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: InstructorColors.textTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: l10n.feedbackHint,
                  hintStyle: TextStyle(
                    color: InstructorColors.textTertiaryColor(isDark),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: InstructorColors.borderColor(isDark),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: InstructorColors.borderColor(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: InstructorColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.feedbackSent),
                        backgroundColor: InstructorColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: Text(l10n.submit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: InstructorColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    bool isDark,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: InstructorColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: InstructorColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildScaleChip(
    bool isDark,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? InstructorColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? InstructorColors.primary
                : InstructorColors.borderColor(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : InstructorColors.textSecondaryColor(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showSavedMessage(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSaved),
        backgroundColor: InstructorColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutConfirmation(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: InstructorColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.logoutConfirmTitle,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(color: InstructorColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.onTap,
    this.trailing,
  });
}
