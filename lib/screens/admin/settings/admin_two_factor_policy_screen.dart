import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminTwoFactorPolicyScreen extends StatefulWidget {
  const AdminTwoFactorPolicyScreen({super.key});

  @override
  State<AdminTwoFactorPolicyScreen> createState() =>
      _AdminTwoFactorPolicyScreenState();
}

class _AdminTwoFactorPolicyScreenState
    extends State<AdminTwoFactorPolicyScreen> {
  bool _enableTwoFactor = true;
  bool _enforceForAdmins = true;
  bool _enforceForInstructors = false;
  bool _enforceForStudents = false;
  bool _allowSms = true;
  bool _allowEmail = true;
  bool _allowAuthenticator = true;
  bool _allowBackupCodes = true;
  int _codeLength = 6;
  int _codeExpiry = 5;
  int _backupCodesCount = 10;
  int _gracePeriodDays = 7;

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
                  _buildStatusCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildEnforcementSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildMethodsSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildSettingsSection(isDark, l10n),
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
        l10n.twoFactorAuth,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _enableTwoFactor
            ? AdminColors.greenGradient
            : LinearGradient(
                colors: [
                  AdminColors.error.withValues(alpha: 0.8),
                  AdminColors.error,
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_enableTwoFactor ? AdminColors.success : AdminColors.error)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _enableTwoFactor
                  ? Icons.verified_user_rounded
                  : Icons.gpp_bad_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.twoFactorAuthentication,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _enableTwoFactor ? l10n.enabled : l10n.disabled,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _enableTwoFactor,
            onChanged: (v) => setState(() => _enableTwoFactor = v),
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildEnforcementSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.enforcementRules,
      icon: Icons.admin_panel_settings_rounded,
      children: [
        _buildEnforcementItem(
          isDark: isDark,
          title: l10n.administrators,
          subtitle: l10n.adminEnforcementDesc,
          icon: Icons.security_rounded,
          iconColor: AdminColors.error,
          value: _enforceForAdmins,
          onChanged: (v) => setState(() => _enforceForAdmins = v),
        ),
        _buildDivider(isDark),
        _buildEnforcementItem(
          isDark: isDark,
          title: l10n.instructors,
          subtitle: l10n.instructorEnforcementDesc,
          icon: Icons.school_rounded,
          iconColor: AdminColors.primary,
          value: _enforceForInstructors,
          onChanged: (v) => setState(() => _enforceForInstructors = v),
        ),
        _buildDivider(isDark),
        _buildEnforcementItem(
          isDark: isDark,
          title: l10n.students,
          subtitle: l10n.studentEnforcementDesc,
          icon: Icons.person_rounded,
          iconColor: AdminColors.success,
          value: _enforceForStudents,
          onChanged: (v) => setState(() => _enforceForStudents = v),
        ),
        _buildDivider(isDark),
        _buildSliderItem(
          isDark: isDark,
          title: l10n.gracePeriod,
          value: _gracePeriodDays.toDouble(),
          min: 0,
          max: 30,
          divisions: 30,
          onChanged: (v) => setState(() => _gracePeriodDays = v.round()),
          displayValue: _gracePeriodDays == 0
              ? l10n.noGracePeriod
              : '$_gracePeriodDays ${l10n.days}',
        ),
      ],
    );
  }

  Widget _buildMethodsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.authenticationMethods,
      icon: Icons.phonelink_lock_rounded,
      children: [
        _buildMethodItem(
          isDark: isDark,
          title: l10n.authenticatorApp,
          subtitle: l10n.authenticatorAppDesc,
          icon: Icons.phone_android_rounded,
          value: _allowAuthenticator,
          onChanged: (v) => setState(() => _allowAuthenticator = v),
        ),
        _buildDivider(isDark),
        _buildMethodItem(
          isDark: isDark,
          title: l10n.smsVerification,
          subtitle: l10n.smsVerificationDesc,
          icon: Icons.sms_rounded,
          value: _allowSms,
          onChanged: (v) => setState(() => _allowSms = v),
        ),
        _buildDivider(isDark),
        _buildMethodItem(
          isDark: isDark,
          title: l10n.emailVerification,
          subtitle: l10n.emailVerificationDesc,
          icon: Icons.email_rounded,
          value: _allowEmail,
          onChanged: (v) => setState(() => _allowEmail = v),
        ),
        _buildDivider(isDark),
        _buildMethodItem(
          isDark: isDark,
          title: l10n.backupCodes,
          subtitle: l10n.backupCodesDesc,
          icon: Icons.key_rounded,
          value: _allowBackupCodes,
          onChanged: (v) => setState(() => _allowBackupCodes = v),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.codeSettings,
      icon: Icons.pin_rounded,
      children: [
        _buildSliderItem(
          isDark: isDark,
          title: l10n.codeLength,
          value: _codeLength.toDouble(),
          min: 4,
          max: 8,
          divisions: 4,
          onChanged: (v) => setState(() => _codeLength = v.round()),
          displayValue: '$_codeLength ${l10n.digits}',
        ),
        _buildDivider(isDark),
        _buildSliderItem(
          isDark: isDark,
          title: l10n.codeExpiry,
          value: _codeExpiry.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          onChanged: (v) => setState(() => _codeExpiry = v.round()),
          displayValue: '$_codeExpiry ${l10n.minutes}',
        ),
        _buildDivider(isDark),
        _buildSliderItem(
          isDark: isDark,
          title: l10n.backupCodesCount,
          value: _backupCodesCount.toDouble(),
          min: 5,
          max: 20,
          divisions: 15,
          onChanged: (v) => setState(() => _backupCodesCount = v.round()),
          displayValue: '$_backupCodesCount ${l10n.codes}',
        ),
      ],
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
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
            padding: const EdgeInsets.all(16),
            child: Row(
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AdminColors.getDividerColor(isDark)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEnforcementItem({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AdminColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodItem({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? AdminColors.success.withValues(alpha: 0.1)
                  : AdminColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value
                  ? AdminColors.success
                  : AdminColors.getTextTertiaryColor(isDark),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AdminColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem({
    required bool isDark,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.getTextColor(isDark),
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
                  displayValue,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AdminColors.primary,
              inactiveTrackColor: AdminColors.primary.withValues(alpha: 0.2),
              thumbColor: AdminColors.primary,
              overlayColor: AdminColors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AdminColors.getDividerColor(isDark),
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.twoFactorPolicySaved),
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
        l10n.savePolicy,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
