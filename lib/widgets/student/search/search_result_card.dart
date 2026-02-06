import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../bloc/search/search_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResultItem item;
  final bool isDark;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(context)),
              _buildTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: item.iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        item.icon,
        color: item.iconColor,
        size: 22,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          item.subtitle,
          style: TextStyle(
            color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.date != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 12,
                color: isDark ? Colors.white38 : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(item.date!, context),
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFFCBD5E1),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (item.status != null) {
      return _buildStatusBadge(context);
    }
    if (item.progress != null) {
      return _buildProgressIndicator();
    }
    return Icon(
      Icons.chevron_right_rounded,
      color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
      size: 20,
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColors = {
      'pending': const Color(0xFFF59E0B),
      'inProgress': const Color(0xFF155DFC),
      'completed': const Color(0xFF10B981),
      'overdue': const Color(0xFFEF4444),
      'submitted': const Color(0xFF8B5CF6),
      'graded': const Color(0xFF10B981),
      'late': const Color(0xFFEF4444),
      'upcoming': const Color(0xFF06B6D4),
      'missed': const Color(0xFFEF4444),
    };

    final statusLabels = {
      'pending': l10n.pending,
      'inProgress': l10n.inProgress,
      'completed': l10n.completed,
      'overdue': l10n.overdue,
      'submitted': l10n.submitted,
      'graded': l10n.graded,
      'late': l10n.late,
      'upcoming': l10n.upcoming,
      'missed': l10n.missed,
    };

    final color = statusColors[item.status] ?? const Color(0xFF94A3B8);
    final label = statusLabels[item.status] ?? item.status!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: item.progress,
            strokeWidth: 3,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation(item.iconColor),
          ),
          Text(
            '${(item.progress! * 100).toInt()}%',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0 && date.day == now.day) {
      return AppLocalizations.of(context).today;
    }
    if (diff.inDays == 1 || (diff.inDays == 0 && date.day == now.day + 1)) {
      return AppLocalizations.of(context).tomorrow;
    }
    return DateFormat.MMMd().format(date);
  }
}
