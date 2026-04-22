import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/error_logs/error_logs_barrel.dart';

class ITErrorLogsScreen extends StatefulWidget {
  const ITErrorLogsScreen({super.key});

  @override
  State<ITErrorLogsScreen> createState() => _ITErrorLogsScreenState();
}

class _ITErrorLogsScreenState extends State<ITErrorLogsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedSeverity = 'all';
  String _selectedType = 'all';
  bool _showResolved = false;

  late List<ErrorLog> _errors;
  late ErrorStats _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      _errors = _getMockErrors();
      _stats = _calculateStats();

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

  List<ErrorLog> _getMockErrors() {
    return [
      ErrorLog(
        id: '1',
        type: 'Exception',
        message:
            'NullPointerException: Cannot invoke method on null object reference',
        source: 'UserService.java:245',
        severity: 'critical',
        timestamp: '2 min ago',
        stackTrace:
            'at com.edu.service.UserService.getUser()\nat com.edu.controller.UserController.show()',
        userId: 'user-123',
        requestId: 'req-abc',
        occurrences: 15,
        isResolved: false,
      ),
      ErrorLog(
        id: '2',
        type: 'API Error',
        message: 'Rate limit exceeded for endpoint /api/v1/courses',
        source: 'RateLimiter.kt:89',
        severity: 'high',
        timestamp: '15 min ago',
        stackTrace: 'at com.edu.middleware.RateLimiter.check()',
        userId: 'client-456',
        requestId: 'req-def',
        occurrences: 234,
        isResolved: false,
      ),
      ErrorLog(
        id: '3',
        type: 'Database Error',
        message: 'Connection pool exhausted: max connections (100) reached',
        source: 'ConnectionPool.java:156',
        severity: 'critical',
        timestamp: '1 hour ago',
        stackTrace: 'at com.edu.db.ConnectionPool.acquire()',
        userId: 'system',
        requestId: 'req-ghi',
        occurrences: 5,
        isResolved: true,
      ),
      ErrorLog(
        id: '4',
        type: 'Validation Error',
        message: 'Invalid email format in registration form',
        source: 'Validator.kt:45',
        severity: 'low',
        timestamp: '2 hours ago',
        stackTrace: 'at com.edu.validation.Validator.email()',
        userId: 'user-789',
        requestId: 'req-jkl',
        occurrences: 42,
        isResolved: false,
      ),
      ErrorLog(
        id: '5',
        type: 'Authentication Error',
        message: 'JWT token expired for user session',
        source: 'AuthMiddleware.java:78',
        severity: 'medium',
        timestamp: '3 hours ago',
        stackTrace: 'at com.edu.auth.AuthMiddleware.verify()',
        userId: 'user-012',
        requestId: 'req-mno',
        occurrences: 89,
        isResolved: true,
      ),
      ErrorLog(
        id: '6',
        type: 'Exception',
        message: 'FileNotFoundException: /uploads/document.pdf not found',
        source: 'FileService.kt:134',
        severity: 'medium',
        timestamp: '5 hours ago',
        stackTrace: 'at com.edu.service.FileService.read()',
        userId: 'user-345',
        requestId: 'req-pqr',
        occurrences: 3,
        isResolved: false,
      ),
    ];
  }

  ErrorStats _calculateStats() {
    final critical = _errors.where((e) => e.severity == 'critical').length;
    final warning = _errors
        .where((e) => e.severity == 'medium' || e.severity == 'high')
        .length;
    final resolved = _errors.where((e) => e.isResolved).length;
    final unresolved = _errors.where((e) => !e.isResolved).length;

    return ErrorStats(
      totalErrors: _errors.length,
      criticalErrors: critical,
      warningErrors: warning,
      resolvedToday: resolved,
      unresolvedErrors: unresolved,
      resolutionRate: _errors.isNotEmpty
          ? (resolved / _errors.length * 100)
          : 0,
    );
  }

  List<ErrorLog> get _filteredErrors {
    var filtered = _errors;
    if (_selectedSeverity != 'all') {
      filtered = filtered
          .where((e) => e.severity == _selectedSeverity)
          .toList();
    }
    if (_selectedType != 'all') {
      filtered = filtered
          .where((e) => e.type.toLowerCase() == _selectedType.toLowerCase())
          .toList();
    }
    if (!_showResolved) {
      filtered = filtered.where((e) => !e.isResolved).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: ITColors.scaffoldColor(isDark),
          // drawer: ITDrawer(currentRoute: '/it-admin/logs', isDark: isDark),
          appBar: _buildAppBar(l10n, isDark),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: ITColors.primary),
                )
              : _errorMessage != null
              ? _buildErrorState(isDark, l10n)
              : _buildContent(isDark, l10n),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, bool isDark) {
    return AppBar(
      backgroundColor: ITColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: ITColors.textPrimaryColor(isDark),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        l10n.itErrorLogs,
        style: TextStyle(
          color: ITColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list_rounded,
            color: ITColors.textSecondaryColor(isDark),
          ),
          onPressed: () => _showFiltersSheet(isDark),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: ITColors.error),
          const SizedBox(height: 16),
          Text(
            l10n.errorOccurred,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.tryAgain),
            style: ElevatedButton.styleFrom(backgroundColor: ITColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ErrorStatsOverview(isDark: isDark, stats: _stats),
          const SizedBox(height: 20),
          ErrorQuickActions(
            isDark: isDark,
            onExport: () => _showSnackBar('Exporting error logs...'),
            onClearResolved: _clearResolvedErrors,
            onRefresh: _loadData,
          ),
          const SizedBox(height: 20),
          ErrorLogsSection(
            isDark: isDark,
            errors: _filteredErrors,
            onErrorTap: _showErrorDetails,
            onResolve: _resolveError,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showFiltersSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ITColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filters',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSeverity,
              decoration: InputDecoration(
                labelText: 'Severity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
              ],
              onChanged: (v) => setState(() => _selectedSeverity = v ?? 'all'),
              dropdownColor: ITColors.cardColor(isDark),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'exception', child: Text('Exception')),
                DropdownMenuItem(value: 'api error', child: Text('API Error')),
                DropdownMenuItem(
                  value: 'database error',
                  child: Text('Database Error'),
                ),
              ],
              onChanged: (v) => setState(() => _selectedType = v ?? 'all'),
              dropdownColor: ITColors.cardColor(isDark),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Show resolved',
                style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
              ),
              value: _showResolved,
              onChanged: (v) => setState(() => _showResolved = v),
              activeTrackColor: ITColors.primary.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return ITColors.primary;
                }
                return null;
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ITColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showErrorDetails(ErrorLog error) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final severityColors = {
      'critical': ITColors.error,
      'high': Colors.orange,
      'medium': ITColors.warning,
      'low': ITColors.info,
    };
    final severityColor =
        severityColors[error.severity] ?? ITColors.textSecondaryColor(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ITColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bug_report_rounded,
                      color: severityColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          error.type,
                          style: TextStyle(
                            color: ITColors.textPrimaryColor(isDark),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                error.severity.toUpperCase(),
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${error.occurrences}x',
                              style: TextStyle(
                                color: ITColors.textSecondaryColor(isDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ITColors.surfaceColor(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  error.message,
                  style: TextStyle(color: ITColors.textPrimaryColor(isDark)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Stack Trace',
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  error.stackTrace,
                  style: const TextStyle(
                    color: Color(0xFFCE9178),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Source', error.source, isDark),
              _buildDetailRow('Time', error.timestamp, isDark),
              _buildDetailRow('User ID', error.userId, isDark),
              _buildDetailRow('Request ID', error.requestId, isDark),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _resolveError(error);
                      },
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Resolve',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ITColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
          ),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _resolveError(ErrorLog error) {
    setState(() {
      final index = _errors.indexWhere((e) => e.id == error.id);
      if (index != -1) {
        _errors[index] = ErrorLog(
          id: error.id,
          type: error.type,
          message: error.message,
          source: error.source,
          severity: error.severity,
          timestamp: error.timestamp,
          stackTrace: error.stackTrace,
          userId: error.userId,
          requestId: error.requestId,
          occurrences: error.occurrences,
          isResolved: true,
        );
        _stats = _calculateStats();
      }
    });
    _showSnackBar('Error marked as resolved');
  }

  void _clearResolvedErrors() {
    setState(() {
      _errors.removeWhere((e) => e.isResolved);
      _stats = _calculateStats();
    });
    _showSnackBar('Resolved errors cleared');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ITColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
