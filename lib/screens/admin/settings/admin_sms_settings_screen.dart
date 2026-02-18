import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminSmsSettingsScreen extends StatefulWidget {
  const AdminSmsSettingsScreen({super.key});

  @override
  State<AdminSmsSettingsScreen> createState() => _AdminSmsSettingsScreenState();
}

class _AdminSmsSettingsScreenState extends State<AdminSmsSettingsScreen> {
  String _selectedProvider = 'Twilio';
  final _accountSidController = TextEditingController();
  final _authTokenController = TextEditingController();
  final _phoneNumberController = TextEditingController(text: '+1234567890');
  bool _enabled = true;
  bool _testLoading = false;
  bool _saveLoading = false;

  final List<_SmsProvider> _providers = [
    _SmsProvider(
      name: 'Twilio',
      icon: Icons.message_rounded,
      color: const Color(0xFFF22F46),
    ),
    _SmsProvider(
      name: 'Nexmo',
      icon: Icons.sms_rounded,
      color: const Color(0xFF000000),
    ),
    _SmsProvider(
      name: 'AWS SNS',
      icon: Icons.cloud_rounded,
      color: const Color(0xFFFF9900),
    ),
    _SmsProvider(
      name: 'MessageBird',
      icon: Icons.send_rounded,
      color: const Color(0xFF2481D7),
    ),
  ];

  @override
  void dispose() {
    _accountSidController.dispose();
    _authTokenController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

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
                  _buildStatusCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildProviderSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildCredentialsSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildUsageSection(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildActionButtons(isDark, l10n),
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
        l10n.smsConfiguration,
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
        gradient: _enabled
            ? AdminColors.greenGradient
            : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade700]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_enabled ? AdminColors.success : Colors.grey)
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
            child: const Icon(
              Icons.sms_rounded,
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
                  l10n.smsService,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _enabled ? l10n.enabled : l10n.disabled,
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
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.smsProvider,
      icon: Icons.business_rounded,
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _providers.map((provider) {
              final isSelected = _selectedProvider == provider.name;
              return GestureDetector(
                onTap: () => setState(() => _selectedProvider = provider.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? provider.color.withValues(alpha: 0.15)
                        : AdminColors.getBackgroundColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? provider.color
                          : AdminColors.getDividerColor(isDark),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.icon,
                        size: 20,
                        color: isSelected
                            ? provider.color
                            : AdminColors.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? provider.color
                              : AdminColors.getTextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.credentials,
      icon: Icons.vpn_key_rounded,
      child: Column(
        children: [
          _buildTextField(
            isDark: isDark,
            label: l10n.accountSid,
            hint: 'ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
            controller: _accountSidController,
            prefixIcon: Icons.fingerprint_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            isDark: isDark,
            label: l10n.authToken,
            hint: '••••••••••••••••',
            controller: _authTokenController,
            prefixIcon: Icons.key_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            isDark: isDark,
            label: l10n.phoneNumber,
            hint: '+1234567890',
            controller: _phoneNumberController,
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.usageStatistics,
      icon: Icons.analytics_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.sentThisMonth,
                  value: '1,247',
                  icon: Icons.send_rounded,
                  color: AdminColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.failedThisMonth,
                  value: '12',
                  icon: Icons.error_outline_rounded,
                  color: AdminColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.remainingCredits,
                  value: '8,753',
                  icon: Icons.credit_card_rounded,
                  color: AdminColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.deliveryRate,
                  value: '99.0%',
                  icon: Icons.check_circle_outline_rounded,
                  color: AdminColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
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
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: AdminColors.getTextTertiaryColor(isDark)),
            prefixIcon: Icon(
              prefixIcon,
              color: AdminColors.getTextTertiaryColor(isDark),
              size: 20,
            ),
            filled: true,
            fillColor: AdminColors.getBackgroundColor(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AdminColors.getDividerColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AdminColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: _testLoading ? null : _testSms,
          icon: _testLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AdminColors.primary,
                  ),
                )
              : Icon(Icons.send_rounded, color: AdminColors.primary),
          label: Text(
            _testLoading ? l10n.testing : l10n.sendTestSms,
            style: TextStyle(
              color: AdminColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: AdminColors.primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _saveLoading ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _saveLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  l10n.saveConfiguration,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Future<void> _testSms() async {
    setState(() => _testLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _testLoading = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.testSmsSent),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saveLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _saveLoading = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.smsConfigSaved),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class _SmsProvider {
  final String name;
  final IconData icon;
  final Color color;

  _SmsProvider({
    required this.name,
    required this.icon,
    required this.color,
  });
}
