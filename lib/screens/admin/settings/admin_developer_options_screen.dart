import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminDeveloperOptionsScreen extends StatefulWidget {
  const AdminDeveloperOptionsScreen({super.key});

  @override
  State<AdminDeveloperOptionsScreen> createState() =>
      _AdminDeveloperOptionsScreenState();
}

class _AdminDeveloperOptionsScreenState
    extends State<AdminDeveloperOptionsScreen> {
  bool _debugMode = false;
  bool _verboseLogging = false;
  bool _showPerformanceOverlay = false;
  bool _showDebugBanner = false;
  bool _enableDevTools = true;
  bool _mockApiEnabled = false;
  int _apiDelay = 0;
  String _environment = 'production';

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
                  _buildWarningCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildEnvironmentSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildDebugSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildApiSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildToolsSection(isDark, l10n),
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
        l10n.developerOptions,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildWarningCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: AdminColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.developerWarningTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.developerWarningDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.environment,
      icon: Icons.cloud_rounded,
      child: Column(
        children: [
          _buildEnvironmentOption(
            isDark: isDark,
            title: 'Production',
            subtitle: l10n.productionDesc,
            value: 'production',
            color: AdminColors.success,
            icon: Icons.verified_rounded,
          ),
          const SizedBox(height: 12),
          _buildEnvironmentOption(
            isDark: isDark,
            title: 'Staging',
            subtitle: l10n.stagingDesc,
            value: 'staging',
            color: AdminColors.warning,
            icon: Icons.science_rounded,
          ),
          const SizedBox(height: 12),
          _buildEnvironmentOption(
            isDark: isDark,
            title: 'Development',
            subtitle: l10n.developmentDesc,
            value: 'development',
            color: AdminColors.primary,
            icon: Icons.code_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentOption({
    required bool isDark,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _environment == value;

    return GestureDetector(
      onTap: () => setState(() => _environment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AdminColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AdminColors.getDividerColor(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
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
            Radio<String>(
              value: value,
              groupValue: _environment,
              onChanged: (v) => setState(() => _environment = v!),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.debugSettings,
      icon: Icons.bug_report_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.debugMode,
            subtitle: l10n.debugModeDesc,
            icon: Icons.bug_report_rounded,
            value: _debugMode,
            onChanged: (v) => setState(() => _debugMode = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.verboseLogging,
            subtitle: l10n.verboseLoggingDesc,
            icon: Icons.text_snippet_rounded,
            value: _verboseLogging,
            onChanged: (v) => setState(() => _verboseLogging = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.performanceOverlay,
            subtitle: l10n.performanceOverlayDesc,
            icon: Icons.speed_rounded,
            value: _showPerformanceOverlay,
            onChanged: (v) => setState(() => _showPerformanceOverlay = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.debugBanner,
            subtitle: l10n.debugBannerDesc,
            icon: Icons.flag_rounded,
            value: _showDebugBanner,
            onChanged: (v) => setState(() => _showDebugBanner = v),
          ),
        ],
      ),
    );
  }

  Widget _buildApiSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.apiSettings,
      icon: Icons.api_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.mockApi,
            subtitle: l10n.mockApiDesc,
            icon: Icons.cloud_off_rounded,
            value: _mockApiEnabled,
            onChanged: (v) => setState(() => _mockApiEnabled = v),
          ),
          _buildDivider(isDark),
          _buildSliderItem(
            isDark: isDark,
            title: l10n.simulatedDelay,
            value: _apiDelay.toDouble(),
            min: 0,
            max: 5000,
            divisions: 10,
            onChanged: (v) => setState(() => _apiDelay = v.round()),
            displayValue: _apiDelay == 0 ? l10n.disabled : '${_apiDelay}ms',
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.developerTools,
      icon: Icons.build_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.enableDevTools,
            subtitle: l10n.enableDevToolsDesc,
            icon: Icons.developer_mode_rounded,
            value: _enableDevTools,
            onChanged: (v) => setState(() => _enableDevTools = v),
          ),
          _buildDivider(isDark),
          _buildActionTile(
            isDark: isDark,
            title: l10n.clearCache,
            subtitle: l10n.clearCacheDesc,
            icon: Icons.delete_sweep_rounded,
            onTap: () => _showConfirmDialog(
              isDark,
              l10n.clearCache,
              l10n.clearCacheConfirm,
              l10n,
            ),
          ),
          _buildDivider(isDark),
          _buildActionTile(
            isDark: isDark,
            title: l10n.resetPreferences,
            subtitle: l10n.resetPreferencesDesc,
            icon: Icons.settings_backup_restore_rounded,
            onTap: () => _showConfirmDialog(
              isDark,
              l10n.resetPreferences,
              l10n.resetPreferencesConfirm,
              l10n,
            ),
          ),
          _buildDivider(isDark),
          _buildActionTile(
            isDark: isDark,
            title: l10n.exportLogs,
            subtitle: l10n.exportLogsDesc,
            icon: Icons.download_rounded,
            onTap: () => _exportLogs(l10n),
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

  Widget _buildSwitchTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? AdminColors.primary.withValues(alpha: 0.1)
                  : AdminColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value
                  ? AdminColors.primary
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
            activeColor: AdminColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminColors.getBackgroundColor(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AdminColors.primary, size: 22),
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
            Icon(
              Icons.chevron_right_rounded,
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
    return Divider(height: 1, color: AdminColors.getDividerColor(isDark));
  }

  void _showConfirmDialog(
    bool isDark,
    String title,
    String message,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.operationCompleted),
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
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _exportLogs(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.logsExported),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
