import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminPasswordPolicyScreen extends StatefulWidget {
  const AdminPasswordPolicyScreen({super.key});

  @override
  State<AdminPasswordPolicyScreen> createState() =>
      _AdminPasswordPolicyScreenState();
}

class _AdminPasswordPolicyScreenState extends State<AdminPasswordPolicyScreen> {
  int _minLength = 8;
  bool _requireUppercase = true;
  bool _requireLowercase = true;
  bool _requireNumbers = true;
  bool _requireSpecialChars = true;
  int _expirationDays = 90;
  int _historyCount = 5;
  int _maxAttempts = 5;
  int _lockoutDuration = 30;
  bool _allowCommonPasswords = false;

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
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildStrengthMeter(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildComplexitySection(isDark, l10n, responsive),
                  SizedBox(height: responsive.p16),
                  _buildExpirationSection(isDark, l10n, responsive),
                  SizedBox(height: responsive.p16),
                  _buildLockoutSection(isDark, l10n, responsive),
                  SizedBox(height: responsive.p16),
                  _buildAdvancedSection(isDark, l10n, responsive),
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
        l10n.passwordPolicy,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildStrengthMeter(bool isDark, AppLocalizations l10n) {
    int score = 0;
    if (_minLength >= 8) score++;
    if (_minLength >= 12) score++;
    if (_requireUppercase) score++;
    if (_requireLowercase) score++;
    if (_requireNumbers) score++;
    if (_requireSpecialChars) score++;
    if (!_allowCommonPasswords) score++;

    String strength;
    Color color;
    if (score <= 2) {
      strength = l10n.weak;
      color = AdminColors.error;
    } else if (score <= 4) {
      strength = l10n.medium;
      color = AdminColors.warning;
    } else if (score <= 5) {
      strength = l10n.strong;
      color = AdminColors.success;
    } else {
      strength = l10n.veryStrong;
      color = const Color(0xFF10B981);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield_rounded, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.policyStrength,
                      style: TextStyle(
                        fontSize: 14,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strength,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$score/7',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 7,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexitySection(
      bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return _buildSection(
      isDark: isDark,
      title: l10n.passwordComplexity,
      icon: Icons.lock_outline_rounded,
      children: [
        _buildSliderItem(
          isDark: isDark,
          title: l10n.minimumLength,
          value: _minLength.toDouble(),
          min: 6,
          max: 20,
          divisions: 14,
          onChanged: (v) => setState(() => _minLength = v.round()),
          displayValue: '$_minLength ${l10n.characters}',
        ),
        _buildDivider(isDark),
        _buildSwitchItem(
          isDark: isDark,
          title: l10n.requireUppercase,
          subtitle: l10n.requireUppercaseDesc,
          value: _requireUppercase,
          onChanged: (v) => setState(() => _requireUppercase = v),
        ),
        _buildDivider(isDark),
        _buildSwitchItem(
          isDark: isDark,
          title: l10n.requireLowercase,
          subtitle: l10n.requireLowercaseDesc,
          value: _requireLowercase,
          onChanged: (v) => setState(() => _requireLowercase = v),
        ),
        _buildDivider(isDark),
        _buildSwitchItem(
          isDark: isDark,
          title: l10n.requireNumbers,
          subtitle: l10n.requireNumbersDesc,
          value: _requireNumbers,
          onChanged: (v) => setState(() => _requireNumbers = v),
        ),
        _buildDivider(isDark),
        _buildSwitchItem(
          isDark: isDark,
          title: l10n.requireSpecialChars,
          subtitle: l10n.requireSpecialCharsDesc,
          value: _requireSpecialChars,
          onChanged: (v) => setState(() => _requireSpecialChars = v),
        ),
      ],
    );
  }

  Widget _buildExpirationSection(
      bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return _buildSection(
      isDark: isDark,
      title: l10n.passwordExpiration,
      icon: Icons.timer_outlined,
      children: [
        _buildSliderItem(
          isDark: isDark,
          title: l10n.expirationPeriod,
          value: _expirationDays.toDouble(),
          min: 0,
          max: 365,
          divisions: 73,
          onChanged: (v) => setState(() => _expirationDays = v.round()),
          displayValue: _expirationDays == 0
              ? l10n.never
              : '$_expirationDays ${l10n.days}',
        ),
        _buildDivider(isDark),
        _buildSliderItem(
          isDark: isDark,
          title: l10n.passwordHistory,
          value: _historyCount.toDouble(),
          min: 0,
          max: 24,
          divisions: 24,
          onChanged: (v) => setState(() => _historyCount = v.round()),
          displayValue: _historyCount == 0
              ? l10n.disabled
              : '$_historyCount ${l10n.passwords}',
        ),
      ],
    );
  }

  Widget _buildLockoutSection(
      bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return _buildSection(
      isDark: isDark,
      title: l10n.accountLockout,
      icon: Icons.lock_clock_rounded,
      children: [
        _buildSliderItem(
          isDark: isDark,
          title: l10n.maxLoginAttempts,
          value: _maxAttempts.toDouble(),
          min: 3,
          max: 10,
          divisions: 7,
          onChanged: (v) => setState(() => _maxAttempts = v.round()),
          displayValue: '$_maxAttempts ${l10n.attempts}',
        ),
        _buildDivider(isDark),
        _buildSliderItem(
          isDark: isDark,
          title: l10n.lockoutDuration,
          value: _lockoutDuration.toDouble(),
          min: 5,
          max: 60,
          divisions: 11,
          onChanged: (v) => setState(() => _lockoutDuration = v.round()),
          displayValue: '$_lockoutDuration ${l10n.minutes}',
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(
      bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return _buildSection(
      isDark: isDark,
      title: l10n.advanced,
      icon: Icons.tune_rounded,
      children: [
        _buildSwitchItem(
          isDark: isDark,
          title: l10n.blockCommonPasswords,
          subtitle: l10n.blockCommonPasswordsDesc,
          value: !_allowCommonPasswords,
          onChanged: (v) => setState(() => _allowCommonPasswords = !v),
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
          Divider(
            height: 1,
            color: AdminColors.getDividerColor(isDark),
          ),
          ...children,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildSwitchItem({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
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
            content: Text(l10n.passwordPolicySaved),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AdminColors.success,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
