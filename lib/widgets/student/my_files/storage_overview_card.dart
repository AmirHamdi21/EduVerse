import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class StorageOverviewCard extends StatelessWidget {
  final bool isDark;

  const StorageOverviewCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<MyFilesCubit, MyFilesState>(
      buildWhen: (p, c) => p.storageStats != c.storageStats,
      builder: (context, state) {
        final stats = state.storageStats;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                  : [Colors.white, const Color(0xFFF1F5F9)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.storage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            stats.formattedUsed,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '/ ${stats.formattedTotal}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildCircularProgress(stats, l10n),
                ],
              ),
              const SizedBox(height: 20),
              _buildProgressBar(stats),
              const SizedBox(height: 20),
              _buildTypeDistribution(stats, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(StorageStats stats, AppLocalizations l10n) {
    final percentage = (stats.usedPercentage * 100).toInt();
    final color = percentage > 90
        ? const Color(0xFFEF4444)
        : percentage > 70
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: stats.usedPercentage,
            strokeWidth: 8,
            backgroundColor: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            Text(
              l10n.used,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(StorageStats stats) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            FractionallySizedBox(
              widthFactor: stats.usedPercentage.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDistribution(StorageStats stats, AppLocalizations l10n) {
    final typeColors = {
      FileType.pdf: const Color(0xFFEF4444),
      FileType.document: const Color(0xFF3B82F6),
      FileType.image: const Color(0xFF10B981),
      FileType.video: const Color(0xFF8B5CF6),
      FileType.audio: const Color(0xFFF59E0B),
      FileType.other: const Color(0xFF64748B),
    };

    final typeLabels = {
      FileType.pdf: 'PDF',
      FileType.document: l10n.documents,
      FileType.image: l10n.images,
      FileType.video: l10n.videos,
      FileType.audio: l10n.audio,
      FileType.other: l10n.other,
    };

    final distribution =
        stats.typeDistribution.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (distribution.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: distribution.take(4).map((entry) {
        final color = typeColors[entry.key] ?? const Color(0xFF64748B);
        final label = typeLabels[entry.key] ?? l10n.other;
        final size = _formatSize(entry.value);

        return Row(
          mainAxisSize: MainAxisSize.min,
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
              '$label ($size)',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
