import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/admin/admin_periods_models.dart';
import '../../../services/api/admin_periods_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

class AdminEnrollmentPeriodsScreen extends StatefulWidget {
  final AdminPeriodsService? periodsService;

  const AdminEnrollmentPeriodsScreen({super.key, this.periodsService});

  @override
  State<AdminEnrollmentPeriodsScreen> createState() =>
      _AdminEnrollmentPeriodsScreenState();
}

class _AdminEnrollmentPeriodsScreenState
    extends State<AdminEnrollmentPeriodsScreen> {
  CoreApiClient? _coreApiClient;
  late final AdminPeriodsService _periodsService;

  bool _isLoading = true;
  String? _errorMessage;
  String _statusFilter = 'all';
  List<EnrollmentPeriodModel> _periods = const <EnrollmentPeriodModel>[];

  @override
  void initState() {
    super.initState();
    if (widget.periodsService != null) {
      _periodsService = widget.periodsService!;
    } else {
      _coreApiClient = CoreApiClient();
      _periodsService = AdminPeriodsService(coreApiClient: _coreApiClient!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadPeriods();
    });
  }

  @override
  void dispose() {
    _coreApiClient?.dio.close(force: true);
    super.dispose();
  }

  Future<void> _loadPeriods() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _periodsService.getEnrollmentPeriods();

    if (!mounted) {
      return;
    }

    if (result.isFailure || result.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.error?.message ?? l10n.adminEnrollmentPeriodsLoadFailed;
      });
      return;
    }

    final periods = result.data!
      ..sort((a, b) {
        final aDate =
            a.registrationStart ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.registrationStart ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    setState(() {
      _isLoading = false;
      _periods = periods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final filtered = _filteredPeriods();

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
              child: RefreshIndicator(
                onRefresh: _loadPeriods,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildHeroCard(isDark, l10n),
                    const SizedBox(height: 16),
                    _buildStatusFilters(isDark, l10n),
                    const SizedBox(height: 16),
                    if (_isLoading) _buildLoadingState(isDark),
                    if (!_isLoading && _errorMessage != null)
                      _buildErrorState(isDark, _errorMessage!, l10n),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        filtered.isEmpty)
                      _buildEmptyState(isDark, l10n),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        filtered.isNotEmpty)
                      ...filtered.map(
                        (period) => _buildPeriodCard(period, isDark, l10n),
                      ),
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
        l10n.adminEnrollmentPeriods,
        style: TextStyle(
          color: AdminColors.getTextColor(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          tooltip: l10n.refresh,
          onPressed: _loadPeriods,
          icon: Icon(Icons.refresh_rounded, color: AdminColors.primary),
        ),
      ],
    );
  }

  Widget _buildHeroCard(bool isDark, AppLocalizations l10n) {
    final active = _periods.where((period) => period.status == 'active').length;
    final upcoming = _periods
        .where((period) => period.status == 'upcoming')
        .length;
    final closed = _periods.where((period) => period.status == 'closed').length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminEnrollmentPeriodsControlCenter,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adminEnrollmentPeriodsLiveDataHint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMetricChip(l10n.active, active.toString())),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricChip(l10n.upcoming, upcoming.toString()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricChip(
                  l10n.adminStatusClosed,
                  closed.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters(bool isDark, AppLocalizations l10n) {
    final filters = <String>['all', 'active', 'upcoming', 'closed'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((filter) {
        final selected = _statusFilter == filter;
        return ChoiceChip(
          label: Text(_statusLabel(filter, l10n)),
          selected: selected,
          onSelected: (_) => setState(() => _statusFilter = filter),
          selectedColor: AdminColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AdminColors.primary,
          side: BorderSide(
            color: selected
                ? AdminColors.primary
                : AdminColors.getCardBorderColor(isDark),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? AdminColors.primary
                : AdminColors.getTextSecondaryColor(isDark),
          ),
          backgroundColor: AdminColors.getCardColor(isDark),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(bool isDark, String message, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: AdminColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminEnrollmentPeriodsLoadErrorTitle,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(message),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loadPeriods,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 44,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.adminEnrollmentPeriodsEmptyState,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(
    EnrollmentPeriodModel period,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final statusColor = _statusColor(period.status);
    final percent = period.totalStudents <= 0
        ? 0.0
        : (period.registeredStudents / period.totalStudents).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  period.semester,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(period.status, l10n),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            period.department,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.adminDateRange(
              _formatDate(period.registrationStart, l10n),
              _formatDate(period.registrationEnd, l10n),
            ),
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AdminColors.getDividerColor(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.adminEnrollmentRegistered(
              period.registeredStudents,
              period.totalStudents,
            ),
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            period.description,
            style: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  List<EnrollmentPeriodModel> _filteredPeriods() {
    if (_statusFilter == 'all') {
      return _periods;
    }

    return _periods
        .where((period) => period.status.toLowerCase() == _statusFilter)
        .toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AdminColors.success;
      case 'closed':
        return AdminColors.error;
      default:
        return AdminColors.warning;
    }
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) {
      return l10n.adminTbd;
    }

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _statusLabel(String value, AppLocalizations l10n) {
    switch (value.toLowerCase()) {
      case 'all':
        return l10n.all;
      case 'active':
        return l10n.active;
      case 'upcoming':
        return l10n.upcoming;
      case 'closed':
        return l10n.adminStatusClosed;
      default:
        return _toTitleCase(value);
    }
  }

  String _toTitleCase(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
