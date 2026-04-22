import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminRegistrationSettingsScreen extends StatefulWidget {
  const AdminRegistrationSettingsScreen({super.key});

  @override
  State<AdminRegistrationSettingsScreen> createState() =>
      _AdminRegistrationSettingsScreenState();
}

class _AdminRegistrationSettingsScreenState
    extends State<AdminRegistrationSettingsScreen> {
  bool _allowSelfRegistration = true;
  bool _requireEmailVerification = true;
  bool _requireAdminApproval = false;
  bool _allowSocialLogin = true;
  bool _allowGoogleLogin = true;
  bool _allowMicrosoftLogin = true;
  bool _allowAppleLogin = false;
  String _defaultRole = 'student';
  int _maxUsersPerDay = 100;
  List<String> _allowedDomains = ['@university.edu', '@school.edu'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

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
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildStatusCard(isDark, l10n, responsive),
                  SizedBox(height: responsive.p24),
                  _buildSection(
                    title: l10n.registrationOptions,
                    isDark: isDark,
                    children: [
                      _buildSwitchTile(
                        isDark: isDark,
                        icon: Icons.person_add_alt_rounded,
                        title: l10n.allowSelfRegistration,
                        subtitle: l10n.allowSelfRegistrationDesc,
                        value: _allowSelfRegistration,
                        onChanged: (v) =>
                            setState(() => _allowSelfRegistration = v),
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        isDark: isDark,
                        icon: Icons.email_outlined,
                        title: l10n.requireEmailVerification,
                        subtitle: l10n.requireEmailVerificationDesc,
                        value: _requireEmailVerification,
                        onChanged: (v) =>
                            setState(() => _requireEmailVerification = v),
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        isDark: isDark,
                        icon: Icons.admin_panel_settings_outlined,
                        title: l10n.requireAdminApproval,
                        subtitle: l10n.requireAdminApprovalDesc,
                        value: _requireAdminApproval,
                        onChanged: (v) =>
                            setState(() => _requireAdminApproval = v),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p16),
                  _buildSection(
                    title: l10n.socialLogin,
                    isDark: isDark,
                    children: [
                      _buildSwitchTile(
                        isDark: isDark,
                        icon: Icons.login_rounded,
                        title: l10n.enableSocialLogin,
                        subtitle: l10n.enableSocialLoginDesc,
                        value: _allowSocialLogin,
                        onChanged: (v) => setState(() => _allowSocialLogin = v),
                      ),
                      if (_allowSocialLogin) ...[
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          isDark: isDark,
                          icon: Icons.g_mobiledata_rounded,
                          title: 'Google',
                          subtitle: l10n.allowGoogleLoginDesc,
                          value: _allowGoogleLogin,
                          onChanged: (v) =>
                              setState(() => _allowGoogleLogin = v),
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          isDark: isDark,
                          icon: Icons.window_rounded,
                          title: 'Microsoft',
                          subtitle: l10n.allowMicrosoftLoginDesc,
                          value: _allowMicrosoftLogin,
                          onChanged: (v) =>
                              setState(() => _allowMicrosoftLogin = v),
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          isDark: isDark,
                          icon: Icons.apple_rounded,
                          title: 'Apple',
                          subtitle: l10n.allowAppleLoginDesc,
                          value: _allowAppleLogin,
                          onChanged: (v) =>
                              setState(() => _allowAppleLogin = v),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: responsive.p16),
                  _buildSection(
                    title: l10n.defaultSettings,
                    isDark: isDark,
                    children: [
                      _buildDropdownTile(
                        isDark: isDark,
                        icon: Icons.badge_outlined,
                        title: l10n.defaultRole,
                        subtitle: l10n.defaultRoleDesc,
                        value: _defaultRole,
                        items: ['student', 'instructor', 'ta'],
                        onChanged: (v) => setState(() => _defaultRole = v!),
                      ),
                      _buildDivider(isDark),
                      _buildSliderTile(
                        isDark: isDark,
                        icon: Icons.people_outline_rounded,
                        title: l10n.maxRegistrationsPerDay,
                        value: _maxUsersPerDay.toDouble(),
                        min: 10,
                        max: 500,
                        onChanged: (v) =>
                            setState(() => _maxUsersPerDay = v.toInt()),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p16),
                  _buildSection(
                    title: l10n.allowedEmailDomains,
                    isDark: isDark,
                    trailing: IconButton(
                      onPressed: () =>
                          _showAddDomainDialog(context, l10n, isDark),
                      icon: Icon(Icons.add_rounded, color: AdminColors.primary),
                    ),
                    children: [
                      if (_allowedDomains.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.allDomainsAllowed,
                            style: TextStyle(
                              color: AdminColors.getTextSecondaryColor(isDark),
                            ),
                          ),
                        )
                      else
                        ..._allowedDomains.asMap().entries.map((entry) {
                          final index = entry.key;
                          final domain = entry.value;
                          return Column(
                            children: [
                              if (index > 0) _buildDivider(isDark),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AdminColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.alternate_email_rounded,
                                    color: AdminColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  domain,
                                  style: TextStyle(
                                    color: AdminColors.getTextColor(isDark),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: AdminColors.error,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _allowedDomains.remove(domain);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                    ],
                  ),
                  SizedBox(height: responsive.p24),
                  _buildSaveButton(isDark, l10n),
                  SizedBox(height: responsive.p32),
                ],
              ),
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
        l10n.registrationSettings,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: _allowSelfRegistration
            ? AdminColors.greenGradient
            : LinearGradient(
                colors: [AdminColors.warning, AdminColors.warningLight],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (_allowSelfRegistration
                        ? AdminColors.success
                        : AdminColors.warning)
                    .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _allowSelfRegistration
                  ? Icons.how_to_reg_rounded
                  : Icons.person_off_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.registrationStatus,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _allowSelfRegistration
                      ? l10n.registrationOpen
                      : l10n.registrationClosed,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Divider(color: AdminColors.getDividerColor(isDark), height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AdminColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AdminColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AdminColors.getTextColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AdminColors.getTextSecondaryColor(isDark),
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AdminColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AdminColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AdminColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AdminColors.getTextColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AdminColors.getTextSecondaryColor(isDark),
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AdminColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          dropdownColor: AdminColors.getCardColor(isDark),
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
          items: items
              .map(
                (e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AdminColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: AdminColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AdminColors.primary,
              inactiveTrackColor: AdminColors.primary.withValues(alpha: 0.2),
              thumbColor: AdminColors.primary,
              overlayColor: AdminColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 10).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: AdminColors.getDividerColor(isDark),
      height: 1,
      indent: 56,
    );
  }

  void _showAddDomainDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.addEmailDomain,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
          decoration: InputDecoration(
            hintText: '@domain.edu',
            hintStyle: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
            filled: true,
            fillColor: AdminColors.getBackgroundColor(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
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
              if (controller.text.isNotEmpty) {
                setState(() {
                  _allowedDomains.add(controller.text);
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsSaved),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AdminColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        l10n.saveSettings,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
