import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/attendance/attendance_cubit.dart';
import '../../../bloc/attendance/attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class AttendanceRecordsList extends StatelessWidget {
  const AttendanceRecordsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<AttendanceCubit, AttendanceState>(
          buildWhen: (previous, current) =>
              previous.filteredRecords != current.filteredRecords ||
              previous.filterOption != current.filterOption,
          builder: (context, state) {
            if (state.filteredRecords.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            final groupedRecords = _groupRecordsByDate(state.filteredRecords);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterChips(context, state, isDark),
                const SizedBox(height: 16),
                ...groupedRecords.entries.map(
                  (entry) => _buildDateSection(
                    context,
                    entry.key,
                    entry.value,
                    isDark,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRecordsFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noRecordsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    AttendanceState state,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.all,
            isSelected: state.filterOption == FilterOption.all,
            onTap: () =>
                context.read<AttendanceCubit>().setFilter(FilterOption.all),
            isDark: isDark,
          ),
          _FilterChip(
            label: l10n.present,
            isSelected: state.filterOption == FilterOption.present,
            onTap: () =>
                context.read<AttendanceCubit>().setFilter(FilterOption.present),
            isDark: isDark,
            color: const Color(0xFF10B981),
          ),
          _FilterChip(
            label: l10n.late,
            isSelected: state.filterOption == FilterOption.late,
            onTap: () =>
                context.read<AttendanceCubit>().setFilter(FilterOption.late),
            isDark: isDark,
            color: const Color(0xFFF59E0B),
          ),
          _FilterChip(
            label: l10n.absent,
            isSelected: state.filterOption == FilterOption.absent,
            onTap: () =>
                context.read<AttendanceCubit>().setFilter(FilterOption.absent),
            isDark: isDark,
            color: const Color(0xFFEF4444),
          ),
          _FilterChip(
            label: l10n.excused,
            isSelected: state.filterOption == FilterOption.excused,
            onTap: () =>
                context.read<AttendanceCubit>().setFilter(FilterOption.excused),
            isDark: isDark,
            color: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    String date,
    List<AttendanceRecord> records,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        ...records.map(
          (record) => _AttendanceRecordCard(record: record, isDark: isDark),
        ),
      ],
    );
  }

  Map<String, List<AttendanceRecord>> _groupRecordsByDate(
    List<AttendanceRecord> records,
  ) {
    final Map<String, List<AttendanceRecord>> grouped = {};

    for (var record in records) {
      final dateKey = _formatDate(record.date);
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }

    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return 'Today';
    } else if (recordDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFF3B82F6))
              : isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : color?.withValues(alpha: 0.5) ??
                      (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? const Color(0xFF3B82F6)).withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : color ?? (isDark ? Colors.white : const Color(0xFF1E293B)),
          ),
        ),
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  final AttendanceRecord record;
  final bool isDark;

  const _AttendanceRecordCard({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _getStatusColor(record.status);
    final statusText = _getStatusText(record.status, l10n);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: 0.2),
                statusColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(record.status),
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          record.courseName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              record.lectureTitle ?? record.courseCode,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${record.startTime.format()} - ${record.endTime.format()}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF10B981);
      case AttendanceStatus.absent:
        return const Color(0xFFEF4444);
      case AttendanceStatus.late:
        return const Color(0xFFF59E0B);
      case AttendanceStatus.excused:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.late:
        return Icons.access_time_rounded;
      case AttendanceStatus.excused:
        return Icons.event_available_rounded;
    }
  }

  String _getStatusText(AttendanceStatus status, AppLocalizations l10n) {
    switch (status) {
      case AttendanceStatus.present:
        return l10n.present;
      case AttendanceStatus.absent:
        return l10n.absent;
      case AttendanceStatus.late:
        return l10n.late;
      case AttendanceStatus.excused:
        return l10n.excused;
    }
  }
}
