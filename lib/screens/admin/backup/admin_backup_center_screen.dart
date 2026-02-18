import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/backup/backup_barrel.dart';
import '../../../common/utils/responsive.dart';

class AdminBackupCenterScreen extends StatefulWidget {
  const AdminBackupCenterScreen({super.key});

  @override
  State<AdminBackupCenterScreen> createState() =>
      _AdminBackupCenterScreenState();
}

class _AdminBackupCenterScreenState extends State<AdminBackupCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Backup state
  bool _isBackingUp = false;
  bool _isExporting = false;
  bool _autoBackupEnabled = true;
  String _backupFrequency = 'daily';
  int _retentionDays = 30;
  String _selectedFormat = 'csv';

  // Sample data
  final List<BackupItem> _backups = [
    BackupItem(
      id: '1',
      name: 'Auto Backup',
      size: '2.4 GB',
      date: DateTime.now().subtract(const Duration(hours: 6)),
      type: 'automatic',
      status: 'completed',
    ),
    BackupItem(
      id: '2',
      name: 'Manual Backup',
      size: '2.3 GB',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'manual',
      status: 'completed',
    ),
    BackupItem(
      id: '3',
      name: 'Weekly Backup',
      size: '2.1 GB',
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: 'automatic',
      status: 'completed',
    ),
    BackupItem(
      id: '4',
      name: 'Pre-Update Backup',
      size: '2.0 GB',
      date: DateTime.now().subtract(const Duration(days: 14)),
      type: 'manual',
      status: 'completed',
    ),
    BackupItem(
      id: '5',
      name: 'Monthly Backup',
      size: '1.9 GB',
      date: DateTime.now().subtract(const Duration(days: 30)),
      type: 'automatic',
      status: 'completed',
    ),
  ];

  late List<ExportOption> _exportOptions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _exportOptions = [
      ExportOption(
        id: 'users',
        title: l10n.userData,
        description: l10n.exportUserDataDesc,
        icon: Icons.people_rounded,
        isSelected: true,
      ),
      ExportOption(
        id: 'courses',
        title: l10n.courseData,
        description: l10n.exportCourseDataDesc,
        icon: Icons.school_rounded,
        isSelected: true,
      ),
      ExportOption(
        id: 'grades',
        title: l10n.gradesData,
        description: l10n.exportGradesDataDesc,
        icon: Icons.grade_rounded,
      ),
      ExportOption(
        id: 'attendance',
        title: l10n.attendanceData,
        description: l10n.exportAttendanceDataDesc,
        icon: Icons.fact_check_rounded,
      ),
      ExportOption(
        id: 'analytics',
        title: l10n.analyticsData,
        description: l10n.exportAnalyticsDataDesc,
        icon: Icons.analytics_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          body: Container(
            decoration: isDark
                ? null
                : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
            child: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      floating: true,
                      snap: true,
                      leading: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      title: Text(
                        l10n.backupDataCenter,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: _showBackupSettings,
                          icon: Icon(
                            Icons.settings_outlined,
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      bottom: TabBar(
                        controller: _tabController,
                        labelColor: AdminColors.primary,
                        unselectedLabelColor: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                        indicatorColor: AdminColors.primary,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        tabs: [
                          Tab(text: l10n.overview),
                          Tab(text: l10n.backups),
                          Tab(text: l10n.export),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isDark, l10n, responsive),
                    _buildBackupsTab(isDark, l10n, responsive),
                    _buildExportTab(isDark, l10n, responsive),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        BackupStatusCard(
          isDark: isDark,
          lastBackupTime: '6 ${l10n.hours} ${l10n.ago}',
          lastBackupSize: '2.4 GB',
          backupStatus: 'healthy',
          totalBackups: _backups.length,
          storageUsed: '12.8 GB',
        ),
        SizedBox(height: responsive.p24),
        BackupQuickActions(
          isDark: isDark,
          isBackingUp: _isBackingUp,
          isExporting: _isExporting,
          onBackupNow: _performBackup,
          onExportData: () => _tabController.animateTo(2),
          onRestoreBackup: _showRestoreDialog,
          onScheduleBackup: () => _tabController.animateTo(1),
        ),
        SizedBox(height: responsive.p24),
        StorageInfoCard(
          isDark: isDark,
          usedStorage: 12.8,
          totalStorage: 50.0,
          localBackups: 3,
          cloudBackups: _backups.length - 3,
          onManageStorage: _showStorageManagement,
        ),
        SizedBox(height: responsive.p24),
        BackupHistoryCard(
          isDark: isDark,
          backups: _backups.take(3).toList(),
          onRestore: _restoreBackup,
          onDownload: _downloadBackup,
          onDelete: _deleteBackup,
          onViewAll: () => _tabController.animateTo(1),
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  Widget _buildBackupsTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        BackupScheduleCard(
          isDark: isDark,
          autoBackupEnabled: _autoBackupEnabled,
          backupFrequency: _backupFrequency,
          retentionDays: _retentionDays,
          nextBackupTime: _getNextBackupTime(),
          onAutoBackupChanged: (value) {
            setState(() => _autoBackupEnabled = value);
            _showSnackBar(
              value ? l10n.autoBackupEnabled : l10n.autoBackupDisabled,
            );
          },
          onFrequencyChanged: (value) {
            setState(() => _backupFrequency = value);
            _showSnackBar(
              '${l10n.backupFrequencyChanged}: ${_getFrequencyLabel(value)}',
            );
          },
          onRetentionChanged: (value) {
            setState(() => _retentionDays = value);
            _showSnackBar(
              '${l10n.retentionPeriodChanged}: $value ${l10n.days}',
            );
          },
        ),
        SizedBox(height: responsive.p24),
        BackupHistoryCard(
          isDark: isDark,
          backups: _backups,
          onRestore: _restoreBackup,
          onDownload: _downloadBackup,
          onDelete: _deleteBackup,
          onViewAll: () {},
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  Widget _buildExportTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        ExportOptionsCard(
          isDark: isDark,
          options: _exportOptions,
          selectedFormat: _selectedFormat,
          isExporting: _isExporting,
          onOptionToggled: (id) {
            setState(() {
              final index = _exportOptions.indexWhere((o) => o.id == id);
              if (index != -1) {
                _exportOptions[index] = _exportOptions[index].copyWith(
                  isSelected: !_exportOptions[index].isSelected,
                );
              }
            });
          },
          onFormatChanged: (format) => setState(() => _selectedFormat = format),
          onExport: _performExport,
        ),
        SizedBox(height: responsive.p24),
        _buildExportHistorySection(isDark, l10n),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  Widget _buildExportHistorySection(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.greenGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                l10n.recentExports,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExportHistoryItem(
            isDark,
            'user_data_export.csv',
            '2.1 MB',
            '2 ${l10n.hours} ${l10n.ago}',
          ),
          _buildExportHistoryItem(
            isDark,
            'course_analytics.xlsx',
            '5.4 MB',
            '1 ${l10n.days} ${l10n.ago}',
          ),
          _buildExportHistoryItem(
            isDark,
            'attendance_report.pdf',
            '1.8 MB',
            '3 ${l10n.days} ${l10n.ago}',
          ),
        ],
      ),
    );
  }

  Widget _buildExportHistoryItem(
    bool isDark,
    String filename,
    String size,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.file_download_done_rounded,
              size: 18,
              color: AdminColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$size • $time',
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminColors.getTextColor(
                      isDark,
                    ).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSnackBar('Downloading $filename'),
            icon: Icon(
              Icons.download_rounded,
              size: 20,
              color: AdminColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getNextBackupTime() {
    switch (_backupFrequency) {
      case 'hourly':
        return 'In 45 minutes';
      case 'daily':
        return 'Tomorrow at 2:00 AM';
      case 'weekly':
        return 'Next Sunday at 2:00 AM';
      case 'monthly':
        return 'First day of next month';
      default:
        return 'Not scheduled';
    }
  }

  String _getFrequencyLabel(String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'hourly':
        return l10n.hourly;
      case 'daily':
        return l10n.daily;
      case 'weekly':
        return l10n.weekly;
      case 'monthly':
        return l10n.monthly;
      default:
        return value;
    }
  }

  void _performBackup() async {
    setState(() => _isBackingUp = true);
    final l10n = AppLocalizations.of(context);

    // Simulate backup
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isBackingUp = false;
        _backups.insert(
          0,
          BackupItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Manual Backup',
            size: '2.5 GB',
            date: DateTime.now(),
            type: 'manual',
            status: 'completed',
          ),
        );
      });
      _showSnackBar(l10n.backupCompleted);
    }
  }

  void _performExport() async {
    setState(() => _isExporting = true);
    final l10n = AppLocalizations.of(context);

    // Simulate export
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isExporting = false);
      _showSnackBar(l10n.exportCompleted);
    }
  }

  void _restoreBackup(BackupItem backup) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreBackup),
        content: Text(
          '${l10n.restoreBackupConfirm}\n\n${backup.name} (${backup.size})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(l10n.restoreStarted);
            },
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
  }

  void _downloadBackup(BackupItem backup) {
    _showSnackBar('Downloading ${backup.name}...');
  }

  void _deleteBackup(BackupItem backup) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBackup),
        content: Text('${l10n.deleteBackupConfirm}\n\n${backup.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _backups.removeWhere((b) => b.id == backup.id));
              _showSnackBar(l10n.backupDeleted);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminColors.getCardColor(
        context.read<ThemeBloc>().state.isDark,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectBackupToRestore,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._backups
                  .take(5)
                  .map(
                    (backup) => ListTile(
                      leading: const Icon(Icons.backup_rounded),
                      title: Text(backup.name),
                      subtitle: Text(
                        '${backup.size} • ${_formatDate(backup.date)}',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _restoreBackup(backup);
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupSettings() {
    _showSnackBar('Opening backup settings...');
    context.push('/admin/settings/backup-restore');
  }

  void _showStorageManagement() {
    _showSnackBar('Opening storage management...');
    context.push('/admin/settings/cloud-storage');
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
