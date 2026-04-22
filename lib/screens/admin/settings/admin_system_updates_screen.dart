import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminSystemUpdatesScreen extends StatefulWidget {
  const AdminSystemUpdatesScreen({super.key});

  @override
  State<AdminSystemUpdatesScreen> createState() =>
      _AdminSystemUpdatesScreenState();
}

class _AdminSystemUpdatesScreenState extends State<AdminSystemUpdatesScreen> {
  bool _autoUpdates = true;
  bool _checkingUpdates = false;
  bool _updating = false;

  final _currentVersion = '2.5.3';
  final _latestVersion = '2.6.0';
  final bool _updateAvailable = true;

  final List<_UpdateItem> _changelog = [
    _UpdateItem(
      version: '2.6.0',
      date: DateTime.now().subtract(const Duration(days: 2)),
      changes: [
        'New admin dashboard design',
        'Improved performance',
        'Bug fixes and stability improvements',
        'Added dark mode support',
      ],
      type: 'major',
    ),
    _UpdateItem(
      version: '2.5.3',
      date: DateTime.now().subtract(const Duration(days: 30)),
      changes: [
        'Fixed login issues',
        'Security patches',
        'Minor UI improvements',
      ],
      type: 'patch',
    ),
    _UpdateItem(
      version: '2.5.2',
      date: DateTime.now().subtract(const Duration(days: 45)),
      changes: [
        'Performance optimizations',
        'Fixed notification delivery',
        'Updated dependencies',
      ],
      type: 'patch',
    ),
    _UpdateItem(
      version: '2.5.0',
      date: DateTime.now().subtract(const Duration(days: 60)),
      changes: [
        'New course management features',
        'Analytics dashboard',
        'Multi-language support',
        'API improvements',
      ],
      type: 'minor',
    ),
  ];

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
                  _buildVersionCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  if (_updateAvailable) ...[
                    _buildUpdateCard(isDark, l10n),
                    SizedBox(height: responsive.p24),
                  ],
                  _buildAutoUpdateSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildSystemInfo(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildChangelogSection(isDark, l10n, responsive),
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
        l10n.systemUpdates,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _checkingUpdates ? null : _checkForUpdates,
          icon: _checkingUpdates
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AdminColors.primary,
                  ),
                )
              : Icon(Icons.refresh_rounded, color: AdminColors.primary),
          tooltip: l10n.checkForUpdates,
        ),
      ],
    );
  }

  Widget _buildVersionCard(bool isDark, AppLocalizations l10n) {
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
              Icons.system_update_rounded,
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
                  l10n.currentVersion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v$_currentVersion',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _updateAvailable
                  ? AdminColors.warning
                  : AdminColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _updateAvailable
                      ? Icons.upgrade_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _updateAvailable ? l10n.updateAvailable : l10n.upToDate,
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

  Widget _buildUpdateCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.new_releases_rounded,
                  color: AdminColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'v$_latestVersion ${l10n.availableNow}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.newVersionDesc,
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _updating ? null : _installUpdate,
              icon: _updating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(_updating ? l10n.installing : l10n.installNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoUpdateSection(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.autorenew_rounded,
              color: AdminColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.automaticUpdates,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.automaticUpdatesDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _autoUpdates,
            onChanged: (v) => setState(() => _autoUpdates = v),
            activeColor: AdminColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfo(bool isDark, AppLocalizations l10n) {
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
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AdminColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.systemInformation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(isDark, l10n.platform, 'Flutter Web'),
          _buildInfoRow(isDark, l10n.flutterVersion, '3.24.0'),
          _buildInfoRow(isDark, l10n.dartVersion, '3.5.0'),
          _buildInfoRow(isDark, l10n.buildNumber, '2024.11.25.1'),
          _buildInfoRow(isDark, l10n.environment, 'Production'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogSection(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.changelog,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        SizedBox(height: responsive.p12),
        ..._changelog.map((item) => _buildChangelogItem(item, isDark, l10n)),
      ],
    );
  }

  Widget _buildChangelogItem(
    _UpdateItem item,
    bool isDark,
    AppLocalizations l10n,
  ) {
    Color typeColor;
    String typeLabel;
    switch (item.type) {
      case 'major':
        typeColor = AdminColors.error;
        typeLabel = l10n.major;
        break;
      case 'minor':
        typeColor = AdminColors.warning;
        typeLabel = l10n.minor;
        break;
      default:
        typeColor = AdminColors.success;
        typeLabel = l10n.patch;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.update_rounded, color: typeColor, size: 22),
        ),
        title: Row(
          children: [
            Text(
              'v${item.version}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          _formatDate(item.date),
          style: TextStyle(
            fontSize: 12,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
        ),
        children: item.changes.map((change) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AdminColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 14,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _checkForUpdates() async {
    setState(() => _checkingUpdates = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _checkingUpdates = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.updateCheckComplete),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _installUpdate() async {
    setState(() => _updating = true);
    await Future.delayed(const Duration(seconds: 4));
    setState(() => _updating = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.updateInstalled),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

class _UpdateItem {
  final String version;
  final DateTime date;
  final List<String> changes;
  final String type;

  _UpdateItem({
    required this.version,
    required this.date,
    required this.changes,
    required this.type,
  });
}
