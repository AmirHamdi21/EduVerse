import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminEmailSettingsScreen extends StatefulWidget {
  const AdminEmailSettingsScreen({super.key});

  @override
  State<AdminEmailSettingsScreen> createState() =>
      _AdminEmailSettingsScreenState();
}

class _AdminEmailSettingsScreenState extends State<AdminEmailSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController(text: 'smtp.gmail.com');
  final _portController = TextEditingController(text: '587');
  final _usernameController = TextEditingController(text: 'noreply@eduverse.com');
  final _passwordController = TextEditingController();
  final _senderNameController = TextEditingController(text: 'EduVerse');
  final _senderEmailController = TextEditingController(text: 'noreply@eduverse.com');
  
  bool _enableSsl = true;
  bool _enableTls = true;
  bool _testLoading = false;
  bool _saveLoading = false;
  String _encryptionType = 'TLS';

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _senderNameController.dispose();
    _senderEmailController.dispose();
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: responsive.contentPadding,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildStatusCard(isDark, l10n),
                    SizedBox(height: responsive.p24),
                    _buildSmtpSection(isDark, l10n),
                    SizedBox(height: responsive.p16),
                    _buildAuthSection(isDark, l10n),
                    SizedBox(height: responsive.p16),
                    _buildSenderSection(isDark, l10n),
                    SizedBox(height: responsive.p24),
                    _buildActionButtons(isDark, l10n),
                    SizedBox(height: responsive.p32),
                  ],
                ),
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
        l10n.emailConfiguration,
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
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.3),
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
              Icons.email_rounded,
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
                  l10n.smtpServer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _hostController.text.isNotEmpty
                      ? _hostController.text
                      : l10n.notConfigured,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AdminColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  l10n.connected,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSmtpSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.smtpSettings,
      icon: Icons.dns_rounded,
      children: [
        _buildTextField(
          isDark: isDark,
          label: l10n.smtpHost,
          hint: 'smtp.example.com',
          controller: _hostController,
          prefixIcon: Icons.computer_rounded,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                isDark: isDark,
                label: l10n.port,
                hint: '587',
                controller: _portController,
                prefixIcon: Icons.tag_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                isDark: isDark,
                label: l10n.encryption,
                value: _encryptionType,
                items: ['None', 'SSL', 'TLS', 'STARTTLS'],
                onChanged: (v) => setState(() => _encryptionType = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.authentication,
      icon: Icons.lock_outline_rounded,
      children: [
        _buildTextField(
          isDark: isDark,
          label: l10n.username,
          hint: 'email@example.com',
          controller: _usernameController,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          isDark: isDark,
          label: l10n.password,
          hint: '••••••••',
          controller: _passwordController,
          prefixIcon: Icons.key_rounded,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildSenderSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.senderInfo,
      icon: Icons.contact_mail_rounded,
      children: [
        _buildTextField(
          isDark: isDark,
          label: l10n.senderName,
          hint: 'EduVerse',
          controller: _senderNameController,
          prefixIcon: Icons.badge_rounded,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          isDark: isDark,
          label: l10n.senderEmail,
          hint: 'noreply@example.com',
          controller: _senderEmailController,
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
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
          ...children,
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
            hintStyle: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
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
              borderSide: BorderSide(
                color: AdminColors.getDividerColor(isDark),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AdminColors.primary,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required bool isDark,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AdminColors.getBackgroundColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.getDividerColor(isDark)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AdminColors.getCardColor(isDark),
              style: TextStyle(color: AdminColors.getTextColor(isDark)),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: _testLoading ? null : _testConnection,
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
            _testLoading ? l10n.testing : l10n.sendTestEmail,
            style: TextStyle(
              color: AdminColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: AdminColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _saveLoading ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

  Future<void> _testConnection() async {
    setState(() => _testLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _testLoading = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.testEmailSent),
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
          content: Text(l10n.emailConfigSaved),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
