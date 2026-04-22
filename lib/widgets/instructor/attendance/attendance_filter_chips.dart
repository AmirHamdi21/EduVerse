import 'package:flutter/material.dart';
import 'attendance_colors.dart';

enum AttendanceFilterType { all, unmarked, present, absent }

class AttendanceFilterChips extends StatelessWidget {
  final AttendanceFilterType selectedFilter;
  final Function(AttendanceFilterType) onFilterChanged;
  final bool isDark;
  final Map<AttendanceFilterType, int> counts;

  const AttendanceFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isDark,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            AttendanceFilterType.all,
            Icons.people_rounded,
            'All',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            AttendanceFilterType.unmarked,
            Icons.radio_button_unchecked,
            'Unmarked',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            AttendanceFilterType.present,
            Icons.check_circle_outline_rounded,
            'Present',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            AttendanceFilterType.absent,
            Icons.cancel_outlined,
            'Absent',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AttendanceFilterType filter,
    IconData icon,
    String label,
  ) {
    final isSelected = selectedFilter == filter;
    final count = counts[filter] ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onFilterChanged(filter),
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AttendanceColors.primary
                : (isDark ? AttendanceColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? AttendanceColors.primary
                  : (isDark
                        ? AttendanceColors.darkBorder.withValues(alpha: 0.5)
                        : AttendanceColors.border),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AttendanceColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : AttendanceColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AttendanceColors.textSecondaryColor(isDark),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : _getCountBgColor(filter),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : _getCountTextColor(filter),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCountBgColor(AttendanceFilterType filter) {
    switch (filter) {
      case AttendanceFilterType.all:
        return isDark
            ? AttendanceColors.primary.withValues(alpha: 0.2)
            : AttendanceColors.primarySurface;
      case AttendanceFilterType.present:
        return isDark
            ? AttendanceColors.present.withValues(alpha: 0.2)
            : AttendanceColors.presentLight;
      case AttendanceFilterType.absent:
        return isDark
            ? AttendanceColors.absent.withValues(alpha: 0.2)
            : AttendanceColors.absentLight;
      case AttendanceFilterType.unmarked:
        return isDark
            ? AttendanceColors.unmarked.withValues(alpha: 0.2)
            : AttendanceColors.unmarkedLight;
    }
  }

  Color _getCountTextColor(AttendanceFilterType filter) {
    switch (filter) {
      case AttendanceFilterType.all:
        return AttendanceColors.primary;
      case AttendanceFilterType.present:
        return AttendanceColors.present;
      case AttendanceFilterType.absent:
        return AttendanceColors.absent;
      case AttendanceFilterType.unmarked:
        return AttendanceColors.unmarked;
    }
  }
}

class AttendanceQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAllPresent;
  final VoidCallback onAllAbsent;
  final VoidCallback onClearAll;
  final VoidCallback onQRScan;

  const AttendanceQuickActions({
    super.key,
    required this.isDark,
    required this.onAllPresent,
    required this.onAllAbsent,
    required this.onClearAll,
    required this.onQRScan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: AttendanceColors.textSecondaryColor(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildQuickAction(
                icon: Icons.check_circle_rounded,
                label: 'All Present',
                color: AttendanceColors.present,
                onTap: onAllPresent,
              ),
              const SizedBox(width: 8),
              _buildQuickAction(
                icon: Icons.cancel_rounded,
                label: 'All Absent',
                color: AttendanceColors.absent,
                onTap: onAllAbsent,
              ),
              const SizedBox(width: 8),
              _buildQuickAction(
                icon: Icons.refresh_rounded,
                label: 'Clear All',
                color: AttendanceColors.unmarked,
                onTap: onClearAll,
              ),
              const SizedBox(width: 8),
              _buildQuickAction(
                icon: Icons.qr_code_scanner_rounded,
                label: 'QR Scan',
                color: AttendanceColors.primary,
                onTap: onQRScan,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary
                ? color
                : (isDark
                      ? color.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: isPrimary ? 1 : 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isPrimary ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
