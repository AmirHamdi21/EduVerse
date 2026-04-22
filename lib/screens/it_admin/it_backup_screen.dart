import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/backup/it_backup_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITBackupScreen extends StatefulWidget {
  const ITBackupScreen({super.key});

  @override
  State<ITBackupScreen> createState() => _ITBackupScreenState();
}

class _ITBackupScreenState extends State<ITBackupScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;
  BackupType? _selectedJobFilter;

  // Data
  List<BackupJob> _backupJobs = [];
  List<RestorePoint> _restorePoints = [];
  List<DRRunbook> _drRunbooks = [];
  List<IntegrityCheck> _integrityChecks = [];
  List<AIRecommendation> _recommendations = [];
  List<StorageItem> _storageItems = [];
  late BackupStats _stats;
  AlertSettings _alertSettings = AlertSettings();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      _backupJobs = _getMockBackupJobs();
      _restorePoints = _getMockRestorePoints();
      _drRunbooks = _getMockDRRunbooks();
      _integrityChecks = _getMockIntegrityChecks();
      _recommendations = _getMockRecommendations();
      _storageItems = _getMockStorageItems();
      _stats = _getMockStats();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<BackupJob> _getMockBackupJobs() {
    final now = DateTime.now();
    return [
      BackupJob(
        id: '1',
        name: 'Production Database',
        type: BackupType.full,
        status: BackupStatus.completed,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 45)),
        sizeGB: 256.8,
        target: 'AWS S3 - Primary',
        duration: const Duration(minutes: 15),
      ),
      BackupJob(
        id: '2',
        name: 'User Files Storage',
        type: BackupType.incremental,
        status: BackupStatus.running,
        startTime: now.subtract(const Duration(minutes: 15)),
        sizeGB: 42.3,
        target: 'Azure Blob Storage',
        progress: 67,
      ),
      BackupJob(
        id: '3',
        name: 'Application Logs',
        type: BackupType.incremental,
        status: BackupStatus.completed,
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 3, minutes: 50)),
        sizeGB: 8.2,
        target: 'AWS S3 - Logs',
        duration: const Duration(minutes: 10),
      ),
      BackupJob(
        id: '4',
        name: 'VM Snapshot - Web Server',
        type: BackupType.snapshot,
        status: BackupStatus.failed,
        startTime: now.subtract(const Duration(hours: 6)),
        endTime: now.subtract(const Duration(hours: 5, minutes: 30)),
        sizeGB: 128.0,
        target: 'Local Storage',
        errorMessage: 'Disk space insufficient on target',
      ),
      BackupJob(
        id: '5',
        name: 'Config Archive',
        type: BackupType.archive,
        status: BackupStatus.scheduled,
        startTime: now.add(const Duration(hours: 2)),
        sizeGB: 2.5,
        target: 'AWS S3 - Archive',
      ),
      BackupJob(
        id: '6',
        name: 'Media Assets',
        type: BackupType.differential,
        status: BackupStatus.completed,
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 7)),
        sizeGB: 186.4,
        target: 'Google Cloud Storage',
        duration: const Duration(hours: 1),
      ),
      BackupJob(
        id: '7',
        name: 'Student Records DB',
        type: BackupType.full,
        status: BackupStatus.completed,
        startTime: now.subtract(const Duration(hours: 12)),
        endTime: now.subtract(const Duration(hours: 11, minutes: 30)),
        sizeGB: 45.6,
        target: 'AWS S3 - Primary',
        duration: const Duration(minutes: 30),
      ),
      BackupJob(
        id: '8',
        name: 'Cache Server',
        type: BackupType.snapshot,
        status: BackupStatus.cancelled,
        startTime: now.subtract(const Duration(hours: 10)),
        sizeGB: 12.0,
        target: 'Local Storage',
      ),
    ];
  }

  List<RestorePoint> _getMockRestorePoints() {
    final now = DateTime.now();
    return [
      RestorePoint(
        id: 'rp1',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: BackupType.full,
        sizeGB: 256.8,
        status: RestorePointStatus.verified,
        source: 'Production Database',
        isVerified: true,
      ),
      RestorePoint(
        id: 'rp2',
        timestamp: now.subtract(const Duration(hours: 6)),
        type: BackupType.incremental,
        sizeGB: 42.3,
        status: RestorePointStatus.verified,
        source: 'User Files Storage',
        isVerified: true,
      ),
      RestorePoint(
        id: 'rp3',
        timestamp: now.subtract(const Duration(days: 1)),
        type: BackupType.full,
        sizeGB: 302.1,
        status: RestorePointStatus.pending,
        source: 'Full System Backup',
      ),
      RestorePoint(
        id: 'rp4',
        timestamp: now.subtract(const Duration(days: 2)),
        type: BackupType.snapshot,
        sizeGB: 128.0,
        status: RestorePointStatus.failed,
        source: 'VM Snapshot - Web Server',
      ),
      RestorePoint(
        id: 'rp5',
        timestamp: now.subtract(const Duration(days: 7)),
        type: BackupType.archive,
        sizeGB: 520.5,
        status: RestorePointStatus.verified,
        source: 'Weekly Archive',
        isVerified: true,
      ),
    ];
  }

  List<DRRunbook> _getMockDRRunbooks() {
    final now = DateTime.now();
    return [
      DRRunbook(
        id: 'dr1',
        name: 'Full System Recovery',
        description: 'Complete system restoration from latest verified backup',
        lastTested: now.subtract(const Duration(days: 7)),
        rtoMinutes: 60,
        rpoMinutes: 15,
        status: 'Ready',
        successRate: 100,
        steps: [
          'Verify backup integrity',
          'Stop all services',
          'Restore database',
          'Restore file systems',
          'Restart services',
          'Verify functionality',
        ],
      ),
      DRRunbook(
        id: 'dr2',
        name: 'Database Failover',
        description: 'Switch to secondary database cluster',
        lastTested: now.subtract(const Duration(days: 3)),
        rtoMinutes: 15,
        rpoMinutes: 5,
        status: 'Ready',
        successRate: 99.5,
        steps: [
          'Promote replica to primary',
          'Update connection strings',
          'Redirect traffic',
          'Verify data consistency',
        ],
      ),
      DRRunbook(
        id: 'dr3',
        name: 'Regional Failover',
        description: 'Switch operations to backup region',
        lastTested: now.subtract(const Duration(days: 14)),
        rtoMinutes: 120,
        rpoMinutes: 30,
        status: 'Needs Review',
        successRate: 95,
        steps: [
          'Activate backup region',
          'Sync DNS records',
          'Restore from regional backup',
          'Test all services',
          'Update monitoring',
        ],
      ),
      DRRunbook(
        id: 'dr4',
        name: 'Ransomware Recovery',
        description: 'Recovery procedure for ransomware incidents',
        lastTested: now.subtract(const Duration(days: 30)),
        rtoMinutes: 240,
        rpoMinutes: 60,
        status: 'Critical Review',
        successRate: 90,
        steps: [
          'Isolate affected systems',
          'Identify clean restore point',
          'Restore from air-gapped backup',
          'Scan for threats',
          'Gradual service restoration',
        ],
      ),
    ];
  }

  List<IntegrityCheck> _getMockIntegrityChecks() {
    final now = DateTime.now();
    return [
      IntegrityCheck(
        id: 'ic1',
        backupName: 'Production Database',
        checkedAt: now.subtract(const Duration(hours: 1)),
        passed: true,
        type: BackupType.full,
      ),
      IntegrityCheck(
        id: 'ic2',
        backupName: 'User Files Storage',
        checkedAt: now.subtract(const Duration(hours: 2)),
        passed: true,
        type: BackupType.incremental,
      ),
      IntegrityCheck(
        id: 'ic3',
        backupName: 'VM Snapshot - Web Server',
        checkedAt: now.subtract(const Duration(hours: 3)),
        passed: false,
        type: BackupType.snapshot,
        errorDetails: 'Checksum mismatch in block 4582',
      ),
      IntegrityCheck(
        id: 'ic4',
        backupName: 'Application Logs',
        checkedAt: now.subtract(const Duration(hours: 4)),
        passed: true,
        type: BackupType.incremental,
      ),
      IntegrityCheck(
        id: 'ic5',
        backupName: 'Media Assets',
        checkedAt: now.subtract(const Duration(hours: 5)),
        passed: true,
        type: BackupType.differential,
      ),
    ];
  }

  List<AIRecommendation> _getMockRecommendations() {
    return [
      AIRecommendation(
        id: 'ai1',
        title: 'Optimize Backup Schedule',
        description:
            'Based on your usage patterns, scheduling incremental backups at 3 AM instead of 2 AM could reduce network congestion by 40%.',
        type: 'optimize',
        actionLabel: 'Apply Optimization',
        color: ITColors.primary,
        icon: Icons.schedule_rounded,
        priority: 'medium',
      ),
      AIRecommendation(
        id: 'ai2',
        title: 'High Failure Risk Detected',
        description:
            'VM Snapshot backup target has 85% disk usage. Consider expanding storage or archiving old backups to prevent failures.',
        type: 'warning',
        actionLabel: 'Review Storage',
        color: ITColors.warning,
        icon: Icons.warning_amber_rounded,
        priority: 'high',
      ),
      AIRecommendation(
        id: 'ai3',
        title: 'Cost Optimization',
        description:
            'Moving infrequently accessed backups older than 30 days to cold storage could save \$245/month.',
        type: 'cost',
        actionLabel: 'View Savings Plan',
        color: ITColors.success,
        icon: Icons.savings_rounded,
        priority: 'low',
      ),
      AIRecommendation(
        id: 'ai4',
        title: 'Test Restore Due',
        description:
            'The Ransomware Recovery runbook hasn\'t been tested in 30 days. Regular testing ensures recovery readiness.',
        type: 'test',
        actionLabel: 'Schedule Test',
        color: ITColors.info,
        icon: Icons.verified_user_rounded,
        priority: 'medium',
      ),
    ];
  }

  List<StorageItem> _getMockStorageItems() {
    return [
      StorageItem(
        name: 'Database Backups',
        sizeGB: 256,
        color: const Color(0xFF3B82F6),
        icon: Icons.storage_rounded,
      ),
      StorageItem(
        name: 'File Backups',
        sizeGB: 186,
        color: const Color(0xFF10B981),
        icon: Icons.folder_rounded,
      ),
      StorageItem(
        name: 'VM Snapshots',
        sizeGB: 128,
        color: const Color(0xFF8B5CF6),
        icon: Icons.memory_rounded,
      ),
      StorageItem(
        name: 'Log Archives',
        sizeGB: 51,
        color: const Color(0xFFF59E0B),
        icon: Icons.article_rounded,
      ),
    ];
  }

  BackupStats _getMockStats() {
    return BackupStats(
      lastFullBackup: '2 hours ago',
      successful24h: 3,
      failed24h: 1,
      nextScheduled: 'in 2 hours',
      storageUsedGB: 620.8,
      storageTotalGB: 1000,
      recoveryScore: 98,
      verifiedBackups: 18,
      pendingVerification: 3,
    );
  }

  List<BackupJob> get _filteredBackupJobs {
    if (_selectedJobFilter == null) return _backupJobs;
    return _backupJobs.where((job) => job.type == _selectedJobFilter).toList();
  }

  void _handleJobFilterChange(BackupType? type) {
    setState(() => _selectedJobFilter = type);
  }

  String _getFilterName(BackupType type) {
    switch (type) {
      case BackupType.full:
        return 'Full';
      case BackupType.incremental:
        return 'Incremental';
      case BackupType.differential:
        return 'Differential';
      case BackupType.snapshot:
        return 'Snapshot';
      case BackupType.archive:
        return 'Archive';
    }
  }

  BackupType? _getFilterType(String filter) {
    switch (filter) {
      case 'Full':
        return BackupType.full;
      case 'Incremental':
        return BackupType.incremental;
      case 'Differential':
        return BackupType.differential;
      case 'Snapshot':
        return BackupType.snapshot;
      case 'Archive':
        return BackupType.archive;
      default:
        return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleViewJob(BackupJob job) {
    _showSnackBar('Viewing details for ${job.name}');
  }

  void _handleCancelJob(BackupJob job) {
    setState(() {
      final index = _backupJobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _backupJobs[index] = job.copyWith(status: BackupStatus.cancelled);
      }
    });
    _showSnackBar('Cancelled backup: ${job.name}');
  }

  void _handleRetryJob(BackupJob job) {
    setState(() {
      final index = _backupJobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _backupJobs[index] = job.copyWith(
          status: BackupStatus.running,
          startTime: DateTime.now(),
          progress: 0,
          errorMessage: null,
        );
      }
    });
    _showSnackBar('Retrying backup: ${job.name}');
  }

  void _handleRestore(RestorePoint point) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ITColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ITColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restore_rounded,
                color: ITColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Restore from ${point.source}?',
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will restore data from the selected restore point. Current data may be overwritten.',
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Restore initiated from ${point.source}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ITColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _handleVerify(RestorePoint point) {
    setState(() {
      final index = _restorePoints.indexWhere((p) => p.id == point.id);
      if (index != -1) {
        _restorePoints[index] = RestorePoint(
          id: point.id,
          timestamp: point.timestamp,
          type: point.type,
          sizeGB: point.sizeGB,
          status: RestorePointStatus.verified,
          source: point.source,
          isVerified: true,
        );
      }
    });
    _showSnackBar('Verification started for ${point.source}');
  }

  void _handleRunTest(DRRunbook runbook) {
    _showSnackBar('Running test for ${runbook.name}...');
  }

  void _handleViewRunbook(DRRunbook runbook) {
    _showSnackBar('Viewing runbook: ${runbook.name}');
  }

  void _handleIntegrityAction() {
    _showSnackBar('Running integrity verification...');
  }

  void _handleRecommendationAction(AIRecommendation rec) {
    _showSnackBar('${rec.actionLabel} for: ${rec.title}');
  }

  void _handleRecommendationDismiss(AIRecommendation rec) {
    setState(() {
      _recommendations.removeWhere((r) => r.id == rec.id);
    });
    _showSnackBar('Dismissed recommendation: ${rec.title}');
  }

  void _handleAlertSettingsChange(AlertSettings settings) {
    setState(() => _alertSettings = settings);
    _showSnackBar('Alert settings updated');
  }

  void _handleViewSuccessful() {
    _tabController.animateTo(0);
    _handleJobFilterChange(null);
    _showSnackBar('Showing all backup jobs');
  }

  void _handleInvestigateFailed() {
    _tabController.animateTo(0);
    _showSnackBar('Investigating failed backups');
  }

  void _handleCreateBackup() {
    _showSnackBar('Creating new backup...');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          drawer: ITDrawer(currentRoute: '/it-admin/backup', isDark: isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEFF6FF),
                          Colors.white,
                          Color(0xFFECFEFF),
                        ],
                      ),
                    ),
              child: _buildContent(isDark, l10n),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _handleCreateBackup,
            backgroundColor: ITColors.primary,
            icon: const Icon(Icons.backup_rounded, color: Colors.white),
            label: Text(
              l10n.itCreateBackup,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: ITColors.primary));
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: CustomScrollView(
        slivers: [
          ITBackupAppBar(
            isDark: isDark,
            title: l10n.itBackupRestoreDR,
            subtitle: l10n.itBackupSubtitle,
            onRefreshTap: _loadData,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status cards
                ITBackupStatusCards(
                  isDark: isDark,
                  stats: _stats,
                  onViewJobs: _handleViewSuccessful,
                  onInvestigate: _handleInvestigateFailed,
                ),
                const SizedBox(height: 20),
                // Tab section
                ITBackupTabSection(
                  isDark: isDark,
                  selectedIndex: _tabController.index,
                  onTabChanged: (index) {
                    _tabController.animateTo(index);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                // Tab content
                _buildTabContent(isDark, l10n),
                const SizedBox(height: 24),
                // AI Recommendations
                ITAIRecommendationsSection(
                  isDark: isDark,
                  recommendations: _recommendations,
                  onAction: _handleRecommendationAction,
                  onDismiss: _handleRecommendationDismiss,
                ),
                const SizedBox(height: 24),
                // Storage Distribution
                ITStorageDistributionSection(
                  isDark: isDark,
                  items: _storageItems,
                  totalUsedGB: _stats.storageUsedGB,
                  totalCapacityGB: _stats.storageTotalGB,
                ),
                const SizedBox(height: 24),
                // Alert Settings
                ITAlertSettingsSection(
                  isDark: isDark,
                  settings: _alertSettings,
                  onSettingsChanged: _handleAlertSettingsChange,
                ),
                const SizedBox(height: 100), // FAB space
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDark, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        switch (_tabController.index) {
          case 0:
            return ITBackupJobsSection(
              isDark: isDark,
              jobs: _filteredBackupJobs,
              selectedFilter: _selectedJobFilter == null
                  ? 'All'
                  : _getFilterName(_selectedJobFilter!),
              onFilterChanged: (filter) {
                if (filter == 'All') {
                  _handleJobFilterChange(null);
                } else {
                  _handleJobFilterChange(_getFilterType(filter));
                }
              },
              onJobTap: _handleViewJob,
              onRetry: _handleRetryJob,
              onCancel: _handleCancelJob,
              onStartBackup: _handleCreateBackup,
            );
          case 1:
            return ITRestoreSection(
              isDark: isDark,
              restorePoints: _restorePoints,
              onRestore: _handleRestore,
              onVerify: _handleVerify,
            );
          case 2:
            return ITDRRunbooksSection(
              isDark: isDark,
              runbooks: _drRunbooks,
              onRunTest: _handleRunTest,
              onViewDetails: _handleViewRunbook,
            );
          case 3:
            return ITIntegritySection(
              isDark: isDark,
              verifiedCount: _stats.verifiedBackups,
              pendingCount: _stats.pendingVerification,
              autoVerifySchedule: 'Daily',
              recentChecks: _integrityChecks,
              onVerifyNow: _handleIntegrityAction,
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: ITColors.error),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: ITColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
