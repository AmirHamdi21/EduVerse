import 'package:flutter/material.dart';
import 'announcement_colors.dart';

enum AnnouncementFilterType {
  all,
  published,
  scheduled,
  draft,
}

class AnnouncementFilterChips extends StatelessWidget {
  final AnnouncementFilterType selectedFilter;
  final Function(AnnouncementFilterType) onFilterChanged;
  final bool isDark;
  final Map<AnnouncementFilterType, int> counts;

  const AnnouncementFilterChips({
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            AnnouncementFilterType.all,
            Icons.dashboard_rounded,
            'All',
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            context,
            AnnouncementFilterType.published,
            Icons.check_circle_outline_rounded,
            'Published',
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            context,
            AnnouncementFilterType.scheduled,
            Icons.schedule_rounded,
            'Scheduled',
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            context,
            AnnouncementFilterType.draft,
            Icons.edit_note_rounded,
            'Draft',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AnnouncementFilterType filter,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AnnouncementColors.primary
                : (isDark 
                    ? AnnouncementColors.darkCard
                    : Colors.white),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? AnnouncementColors.primary
                  : (isDark 
                      ? AnnouncementColors.darkBorder.withOpacity(0.5)
                      : AnnouncementColors.border),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AnnouncementColors.primary.withOpacity(0.3),
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
                size: 18,
                color: isSelected
                    ? Colors.white
                    : AnnouncementColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AnnouncementColors.textSecondaryColor(isDark),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : _getCountBgColor(filter),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : _getCountTextColor(filter),
                      fontSize: 12,
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

  Color _getCountBgColor(AnnouncementFilterType filter) {
    switch (filter) {
      case AnnouncementFilterType.all:
        return isDark 
            ? AnnouncementColors.primary.withOpacity(0.2)
            : AnnouncementColors.primarySurface;
      case AnnouncementFilterType.published:
        return isDark 
            ? AnnouncementColors.published.withOpacity(0.2)
            : AnnouncementColors.publishedLight;
      case AnnouncementFilterType.scheduled:
        return isDark 
            ? AnnouncementColors.scheduled.withOpacity(0.2)
            : AnnouncementColors.scheduledLight;
      case AnnouncementFilterType.draft:
        return isDark 
            ? AnnouncementColors.draft.withOpacity(0.2)
            : AnnouncementColors.draftLight;
    }
  }

  Color _getCountTextColor(AnnouncementFilterType filter) {
    switch (filter) {
      case AnnouncementFilterType.all:
        return AnnouncementColors.primary;
      case AnnouncementFilterType.published:
        return AnnouncementColors.published;
      case AnnouncementFilterType.scheduled:
        return AnnouncementColors.scheduled;
      case AnnouncementFilterType.draft:
        return AnnouncementColors.draft;
    }
  }
}
