import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/attendance/attendance_cubit.dart';
import '../../../bloc/attendance/attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class AttendanceStatsCard extends StatelessWidget {
  const AttendanceStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<AttendanceCubit, AttendanceState>(
          buildWhen: (previous, current) =>
              previous.statistics != current.statistics,
          builder: (context, state) {
            final stats = state.statistics;

            if (stats == null) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [Colors.white, const Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDark, stats),
                  const SizedBox(height: 24),
                  _buildCircularProgress(context, isDark, stats),
                  const SizedBox(height: 24),
                  _buildStatsBars(context, isDark, stats),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AttendanceStatistics stats,
  ) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.attendanceOverview,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${stats.totalClasses} ${l10n.totalClasses}',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: stats.overallPercentage >= 75
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : stats.overallPercentage >= 50
                  ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                  : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${stats.overallPercentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(
    BuildContext context,
    bool isDark,
    AttendanceStatistics stats,
  ) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMiniStat(
          icon: Icons.check_circle_rounded,
          label: l10n.present,
          value: stats.presentCount.toString(),
          color: const Color(0xFF10B981),
          isDark: isDark,
        ),
        _buildMiniStat(
          icon: Icons.access_time_rounded,
          label: l10n.late,
          value: stats.lateCount.toString(),
          color: const Color(0xFFF59E0B),
          isDark: isDark,
        ),
        _buildMiniStat(
          icon: Icons.cancel_rounded,
          label: l10n.absent,
          value: stats.absentCount.toString(),
          color: const Color(0xFFEF4444),
          isDark: isDark,
        ),
        _buildMiniStat(
          icon: Icons.event_available_rounded,
          label: l10n.excused,
          value: stats.excusedCount.toString(),
          color: const Color(0xFF6366F1),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBars(
    BuildContext context,
    bool isDark,
    AttendanceStatistics stats,
  ) {
    final l10n = AppLocalizations.of(context);
    final total = stats.totalClasses > 0 ? stats.totalClasses : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.distribution,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                Expanded(
                  flex: (stats.presentCount * 100 / total).round(),
                  child: Container(color: const Color(0xFF10B981)),
                ),
                Expanded(
                  flex: (stats.lateCount * 100 / total).round(),
                  child: Container(color: const Color(0xFFF59E0B)),
                ),
                Expanded(
                  flex: (stats.excusedCount * 100 / total).round(),
                  child: Container(color: const Color(0xFF6366F1)),
                ),
                Expanded(
                  flex: (stats.absentCount * 100 / total).round(),
                  child: Container(color: const Color(0xFFEF4444)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem(l10n.present, const Color(0xFF10B981), isDark),
            _buildLegendItem(l10n.late, const Color(0xFFF59E0B), isDark),
            _buildLegendItem(l10n.excused, const Color(0xFF6366F1), isDark),
            _buildLegendItem(l10n.absent, const Color(0xFFEF4444), isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
