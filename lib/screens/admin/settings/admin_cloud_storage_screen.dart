import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminCloudStorageScreen extends StatefulWidget {
  const AdminCloudStorageScreen({super.key});

  @override
  State<AdminCloudStorageScreen> createState() =>
      _AdminCloudStorageScreenState();
}

class _AdminCloudStorageScreenState extends State<AdminCloudStorageScreen> {
  String _selectedProvider = 'AWS S3';
  bool _enabled = true;
  final _bucketController = TextEditingController(text: 'eduverse-storage');
  final _regionController = TextEditingController(text: 'us-east-1');
  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();

  final List<_StorageProvider> _providers = [
    _StorageProvider(
      name: 'AWS S3',
      icon: Icons.cloud_rounded,
      color: const Color(0xFFFF9900),
    ),
    _StorageProvider(
      name: 'Google Cloud',
      icon: Icons.cloud_circle_rounded,
      color: const Color(0xFF4285F4),
    ),
    _StorageProvider(
      name: 'Azure Blob',
      icon: Icons.cloud_queue_rounded,
      color: const Color(0xFF0089D6),
    ),
    _StorageProvider(
      name: 'DigitalOcean',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF0080FF),
    ),
  ];

  // Storage usage data
  final double _usedStorage = 45.7;
  final double _totalStorage = 100.0;

  @override
  void dispose() {
    _bucketController.dispose();
    _regionController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
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
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildStorageCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildProviderSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildCredentialsSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildStorageBreakdown(isDark, l10n),
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
        l10n.cloudStorage,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildStorageCard(bool isDark, AppLocalizations l10n) {
    final percentage = _usedStorage / _totalStorage;
    Color progressColor;
    if (percentage < 0.5) {
      progressColor = AdminColors.success;
    } else if (percentage < 0.8) {
      progressColor = AdminColors.warning;
    } else {
      progressColor = AdminColors.error;
    }

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.cloud_rounded,
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
                      l10n.storageUsage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_usedStorage.toStringAsFixed(1)} GB / ${_totalStorage.toInt()} GB',
                      style: const TextStyle(
                        fontSize: 22,
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
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(1)}% ${l10n.used}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '${(_totalStorage - _usedStorage).toStringAsFixed(1)} GB ${l10n.remaining}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.storageProvider,
      icon: Icons.business_rounded,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _providers.map((provider) {
          final isSelected = _selectedProvider == provider.name;
          return GestureDetector(
            onTap: () => setState(() => _selectedProvider = provider.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
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
    );
  }

  Widget _buildCredentialsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.credentials,
      icon: Icons.vpn_key_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  isDark: isDark,
                  label: l10n.bucketName,
                  hint: 'my-bucket',
                  controller: _bucketController,
                  prefixIcon: Icons.folder_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  isDark: isDark,
                  label: l10n.region,
                  hint: 'us-east-1',
                  controller: _regionController,
                  prefixIcon: Icons.public_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            isDark: isDark,
            label: l10n.accessKeyId,
            hint: 'AKIAXXXXXXXXXXXXXXXX',
            controller: _accessKeyController,
            prefixIcon: Icons.fingerprint_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            isDark: isDark,
            label: l10n.secretAccessKey,
            hint: '••••••••••••••••',
            controller: _secretKeyController,
            prefixIcon: Icons.key_rounded,
            isPassword: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBreakdown(bool isDark, AppLocalizations l10n) {
    final items = [
      _StorageItem(
        name: l10n.courseVideos,
        size: 28.5,
        color: AdminColors.primary,
      ),
      _StorageItem(name: l10n.documents, size: 8.2, color: AdminColors.success),
      _StorageItem(name: l10n.images, size: 5.1, color: AdminColors.warning),
      _StorageItem(name: l10n.userUploads, size: 3.9, color: AdminColors.error),
    ];

    return _buildSection(
      isDark: isDark,
      title: l10n.storageBreakdown,
      icon: Icons.pie_chart_rounded,
      child: Column(
        children: items.map((item) {
          final percentage = (item.size / _usedStorage) * 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${item.size.toStringAsFixed(1)} GB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AdminColors.getDividerColor(isDark),
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
              borderSide: BorderSide(color: AdminColors.primary, width: 2),
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.connectionTested),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AdminColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          icon: Icon(Icons.wifi_tethering_rounded, color: AdminColors.primary),
          label: Text(
            l10n.testConnection,
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.cloudStorageSaved),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            l10n.saveConfiguration,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StorageProvider {
  final String name;
  final IconData icon;
  final Color color;

  _StorageProvider({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _StorageItem {
  final String name;
  final double size;
  final Color color;

  _StorageItem({required this.name, required this.size, required this.color});
}
