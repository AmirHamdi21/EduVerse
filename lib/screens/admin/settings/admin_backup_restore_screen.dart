import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminBackupRestoreScreen extends StatefulWidget {
  const AdminBackupRestoreScreen({super.key});

  @override
  State<AdminBackupRestoreScreen> createState() =>
      _AdminBackupRestoreScreenState();
}

class _AdminBackupRestoreScreenState extends State<AdminBackupRestoreScreen> {
  bool _autoBackupEnabled = true;
  String _backupFrequency = 'daily';
  int _retentionDays = 30;
  bool _includeMedia = true;
  bool _includeUserData = true;
  bool _includeCourseData = true;
  bool _includeSettings = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  final List<_Backup> _backups = [
    _Backup(
      id: '1',
      name: 'Auto Backup',
      size: '2.4 GB',
      date: DateTime.now().subtract(const Duration(hours: 6)),
      type: 'automatic',
      status: 'completed',
    ),
    _Backup(
      id: '2',
      name: 'Manual Backup',
      size: '2.3 GB',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'manual',
      status: 'completed',
    ),
    _Backup(
      id: '3',
      name: 'Auto Backup',
      size: '2.1 GB',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'automatic',
      status: 'completed',
    ),
    _Backup(
      id: '4',
      name: 'Pre-Update Backup',
      size: '2.0 GB',
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: 'manual',
      status: 'completed',
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
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildStatusCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildQuickActions(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildAutoBackupSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildBackupOptionsSection(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildBackupsListSection(isDark, l10n, responsive),
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
        l10n.backupRestore,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark, AppLocalizations l10n) {
    final lastBackup = _backups.isNotEmpty ? _backups.first : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AdminColors.greenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.success.withValues(alpha: 0.3),
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
                  Icons.backup_rounded,
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
                      l10n.lastBackup,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastBackup != null
                          ? _formatDateTime(lastBackup.date)
                          : l10n.noBackups,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AdminColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.healthy,
                      style: TextStyle(
                        color: AdminColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.folder_rounded,
                  label: l10n.totalBackups,
                  value: '${_backups.length}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.storage_rounded,
                  label: l10n.totalSize,
                  value: '8.8 GB',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.schedule_rounded,
                  label: l10n.nextBackup,
                  value: '6h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            isDark: isDark,
            icon: Icons.backup_rounded,
            title: l10n.backupNow,
            color: AdminColors.primary,
            isLoading: _isBackingUp,
            onTap: _createBackup,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            isDark: isDark,
            icon: Icons.restore_rounded,
            title: l10n.restoreBackup,
            color: AdminColors.warning,
            isLoading: _isRestoring,
            onTap: () => _showRestoreDialog(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: color,
                      ),
                    )
                  : Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoBackupSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.automaticBackup,
      icon: Icons.schedule_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.enableAutoBackup,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              Switch.adaptive(
                value: _autoBackupEnabled,
                onChanged: (v) => setState(() => _autoBackupEnabled = v),
                activeColor: AdminColors.success,
              ),
            ],
          ),
          if (_autoBackupEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.frequency,
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
                          border: Border.all(
                              color: AdminColors.getDividerColor(isDark)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _backupFrequency,
                            isExpanded: true,
                            dropdownColor: AdminColors.getCardColor(isDark),
                            style: TextStyle(
                                color: AdminColors.getTextColor(isDark)),
                            items: [
                              DropdownMenuItem(
                                  value: 'hourly', child: Text(l10n.hourly)),
                              DropdownMenuItem(
                                  value: 'daily', child: Text(l10n.daily)),
                              DropdownMenuItem(
                                  value: 'weekly', child: Text(l10n.weekly)),
                              DropdownMenuItem(
                                  value: 'monthly', child: Text(l10n.monthly)),
                            ],
                            onChanged: (v) =>
                                setState(() => _backupFrequency = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.retention,
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
                          border: Border.all(
                              color: AdminColors.getDividerColor(isDark)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _retentionDays,
                            isExpanded: true,
                            dropdownColor: AdminColors.getCardColor(isDark),
                            style: TextStyle(
                                color: AdminColors.getTextColor(isDark)),
                            items: [7, 14, 30, 60, 90]
                                .map((d) => DropdownMenuItem(
                                    value: d, child: Text('$d ${l10n.days}')))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _retentionDays = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupOptionsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.backupOptions,
      icon: Icons.checklist_rounded,
      child: Column(
        children: [
          _buildCheckboxTile(
            isDark: isDark,
            title: l10n.userData,
            subtitle: l10n.userDataDesc,
            value: _includeUserData,
            onChanged: (v) => setState(() => _includeUserData = v!),
          ),
          _buildCheckboxTile(
            isDark: isDark,
            title: l10n.courseData,
            subtitle: l10n.courseDataDesc,
            value: _includeCourseData,
            onChanged: (v) => setState(() => _includeCourseData = v!),
          ),
          _buildCheckboxTile(
            isDark: isDark,
            title: l10n.mediaFiles,
            subtitle: l10n.mediaFilesDesc,
            value: _includeMedia,
            onChanged: (v) => setState(() => _includeMedia = v!),
          ),
          _buildCheckboxTile(
            isDark: isDark,
            title: l10n.systemSettings,
            subtitle: l10n.systemSettingsDesc,
            value: _includeSettings,
            onChanged: (v) => setState(() => _includeSettings = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupsListSection(
      bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentBackups,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.viewAll,
                style: TextStyle(color: AdminColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p12),
        ..._backups.map((backup) => _buildBackupItem(backup, isDark, l10n)),
      ],
    );
  }

  Widget _buildBackupItem(_Backup backup, bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (backup.type == 'automatic'
                      ? AdminColors.primary
                      : AdminColors.success)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              backup.type == 'automatic'
                  ? Icons.schedule_rounded
                  : Icons.touch_app_rounded,
              color: backup.type == 'automatic'
                  ? AdminColors.primary
                  : AdminColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(backup.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                backup.size,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.completed,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
            color: AdminColors.getCardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (v) {
              if (v == 'restore') {
                _restoreBackup(backup, l10n);
              } else if (v == 'download') {
                _downloadBackup(backup, l10n);
              } else if (v == 'delete') {
                _deleteBackup(backup, l10n);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore_rounded,
                        size: 18, color: AdminColors.primary),
                    const SizedBox(width: 8),
                    Text(l10n.restore),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded,
                        size: 18, color: AdminColors.success),
                    const SizedBox(width: 8),
                    Text(l10n.download),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded,
                        size: 18, color: AdminColors.error),
                    const SizedBox(width: 8),
                    Text(l10n.delete,
                        style: TextStyle(color: AdminColors.error)),
                  ],
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

  Widget _buildCheckboxTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AdminColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
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
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isBackingUp = false;
      _backups.insert(
        0,
        _Backup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Manual Backup',
          size: '2.4 GB',
          date: DateTime.now(),
          type: 'manual',
          status: 'completed',
        ),
      );
    });

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupCreated),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showRestoreDialog(bool isDark) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_rounded,
                  color: AdminColors.warning, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.restoreBackup,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.restoreWarning,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style:
                    TextStyle(color: AdminColors.getTextSecondaryColor(isDark))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreBackup(_backups.first, l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.warning,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
  }

  void _restoreBackup(_Backup backup, AppLocalizations l10n) async {
    setState(() => _isRestoring = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isRestoring = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupRestored),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AdminColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _downloadBackup(_Backup backup, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.backupDownloadStarted),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteBackup(_Backup backup, AppLocalizations l10n) {
    setState(() => _backups.remove(backup));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.backupDeleted),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _Backup {
  final String id;
  final String name;
  final String size;
  final DateTime date;
  final String type;
  final String status;

  _Backup({
    required this.id,
    required this.name,
    required this.size,
    required this.date,
    required this.type,
    required this.status,
  });
}
