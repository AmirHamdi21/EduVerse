import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminSystemLogsScreen extends StatefulWidget {
  const AdminSystemLogsScreen({super.key});

  @override
  State<AdminSystemLogsScreen> createState() => _AdminSystemLogsScreenState();
}

class _AdminSystemLogsScreenState extends State<AdminSystemLogsScreen> {
  String _selectedLevel = 'all';
  String _selectedSource = 'all';
  final _searchController = TextEditingController();

  final List<_LogEntry> _logs = [
    _LogEntry(
      id: '1',
      level: 'error',
      message: 'Failed to connect to database: Connection timeout',
      source: 'Database',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    _LogEntry(
      id: '2',
      level: 'warning',
      message: 'High memory usage detected: 85% utilized',
      source: 'System',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    _LogEntry(
      id: '3',
      level: 'info',
      message: 'User authentication successful: admin@eduverse.com',
      source: 'Auth',
      timestamp: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
    _LogEntry(
      id: '4',
      level: 'info',
      message: 'Course created: Introduction to Flutter',
      source: 'Courses',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    _LogEntry(
      id: '5',
      level: 'debug',
      message: 'API request completed in 245ms: GET /api/v1/users',
      source: 'API',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    ),
    _LogEntry(
      id: '6',
      level: 'error',
      message: 'Payment processing failed: Invalid card number',
      source: 'Payments',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _LogEntry(
      id: '7',
      level: 'warning',
      message: 'Rate limit exceeded for IP: 192.168.1.100',
      source: 'Security',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    _LogEntry(
      id: '8',
      level: 'info',
      message: 'Backup completed successfully: 2.4GB',
      source: 'Backup',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    _LogEntry(
      id: '9',
      level: 'info',
      message: 'Email sent: Welcome email to new user',
      source: 'Email',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    _LogEntry(
      id: '10',
      level: 'debug',
      message: 'Cache cleared: 156MB freed',
      source: 'System',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  List<_LogEntry> get _filteredLogs {
    return _logs.where((log) {
      final matchesLevel =
          _selectedLevel == 'all' || log.level == _selectedLevel;
      final matchesSource =
          _selectedSource == 'all' || log.source == _selectedSource;
      final matchesSearch =
          _searchController.text.isEmpty ||
          log.message.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesLevel && matchesSource && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              child: Column(
                children: [
                  _buildStatsRow(isDark, l10n, responsive),
                  _buildFilters(isDark, l10n, responsive),
                  Expanded(child: _buildLogsList(isDark, l10n, responsive)),
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
        l10n.systemLogs,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _exportLogs(l10n),
          icon: Icon(Icons.download_rounded, color: AdminColors.primary),
          tooltip: l10n.export,
        ),
        IconButton(
          onPressed: () => _clearLogs(l10n),
          icon: Icon(Icons.delete_sweep_rounded, color: AdminColors.error),
          tooltip: l10n.clearLogs,
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final errorCount = _logs.where((l) => l.level == 'error').length;
    final warningCount = _logs.where((l) => l.level == 'warning').length;
    final infoCount = _logs.where((l) => l.level == 'info').length;

    return Container(
      padding: responsive.contentPadding,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              isDark: isDark,
              title: l10n.errors,
              value: '$errorCount',
              icon: Icons.error_rounded,
              color: AdminColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              isDark: isDark,
              title: l10n.warnings,
              value: '$warningCount',
              icon: Icons.warning_rounded,
              color: AdminColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              isDark: isDark,
              title: l10n.info,
              value: '$infoCount',
              icon: Icons.info_rounded,
              color: AdminColors.primary,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 8,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      padding: responsive.contentPadding,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: AdminColors.getTextColor(isDark)),
            decoration: InputDecoration(
              hintText: l10n.searchLogs,
              hintStyle: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
              filled: true,
              fillColor: AdminColors.getCardColor(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AdminColors.getCardColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AdminColors.getCardBorderColor(isDark),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLevel,
                      isExpanded: true,
                      dropdownColor: AdminColors.getCardColor(isDark),
                      style: TextStyle(color: AdminColors.getTextColor(isDark)),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(l10n.allLevels),
                        ),
                        DropdownMenuItem(
                          value: 'error',
                          child: Text(l10n.error),
                        ),
                        DropdownMenuItem(
                          value: 'warning',
                          child: Text(l10n.warning),
                        ),
                        DropdownMenuItem(value: 'info', child: Text(l10n.info)),
                        DropdownMenuItem(
                          value: 'debug',
                          child: Text(l10n.debug),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedLevel = v!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AdminColors.getCardColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AdminColors.getCardBorderColor(isDark),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSource,
                      isExpanded: true,
                      dropdownColor: AdminColors.getCardColor(isDark),
                      style: TextStyle(color: AdminColors.getTextColor(isDark)),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(l10n.allSources),
                        ),
                        const DropdownMenuItem(
                          value: 'System',
                          child: Text('System'),
                        ),
                        const DropdownMenuItem(
                          value: 'Auth',
                          child: Text('Auth'),
                        ),
                        const DropdownMenuItem(
                          value: 'Database',
                          child: Text('Database'),
                        ),
                        const DropdownMenuItem(
                          value: 'API',
                          child: Text('API'),
                        ),
                        const DropdownMenuItem(
                          value: 'Security',
                          child: Text('Security'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedSource = v!),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final logs = _filteredLogs;

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noLogsFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.adjustFilters,
              style: TextStyle(
                fontSize: 14,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return _buildLogItem(logs[index], isDark, l10n);
      },
    );
  }

  Widget _buildLogItem(_LogEntry log, bool isDark, AppLocalizations l10n) {
    Color levelColor;
    IconData levelIcon;
    switch (log.level) {
      case 'error':
        levelColor = AdminColors.error;
        levelIcon = Icons.error_rounded;
        break;
      case 'warning':
        levelColor = AdminColors.warning;
        levelIcon = Icons.warning_rounded;
        break;
      case 'info':
        levelColor = AdminColors.primary;
        levelIcon = Icons.info_rounded;
        break;
      default:
        levelColor = AdminColors.getTextTertiaryColor(isDark);
        levelIcon = Icons.bug_report_rounded;
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
            color: levelColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(levelIcon, color: levelColor, size: 22),
        ),
        title: Text(
          log.message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                log.level.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: levelColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              log.source,
              style: TextStyle(
                fontSize: 11,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(log.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.fullMessage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  log.message,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDetailItem(isDark, l10n.source, log.source),
                    const SizedBox(width: 24),
                    _buildDetailItem(
                      isDark,
                      l10n.timestamp,
                      _formatDateTime(log.timestamp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(bool isDark, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

  void _clearLogs(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = context.read<ThemeBloc>().state.isDark;
        return AlertDialog(
          backgroundColor: AdminColors.getCardColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_sweep_rounded,
                  color: AdminColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.clearLogs,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.clearLogsConfirm,
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
                setState(() => _logs.clear());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.logsCleared),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AdminColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.clear),
            ),
          ],
        );
      },
    );
  }
}

class _LogEntry {
  final String id;
  final String level;
  final String message;
  final String source;
  final DateTime timestamp;

  _LogEntry({
    required this.id,
    required this.level,
    required this.message,
    required this.source,
    required this.timestamp,
  });
}
