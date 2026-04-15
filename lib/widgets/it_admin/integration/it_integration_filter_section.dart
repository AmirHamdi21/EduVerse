import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_integration_barrel.dart';

class ITIntegrationFilterSection extends StatelessWidget {
  final bool isDark;
  final IntegrationCategory selectedCategory;
  final String searchQuery;
  final Function(IntegrationCategory) onCategoryChanged;
  final Function(String) onSearchChanged;
  final VoidCallback? onClearSearch;

  const ITIntegrationFilterSection({
    super.key,
    required this.isDark,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ITColors.lightCardShadow(isDark),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : ITColors.border,
            ),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search integrations, providers...',
              hintStyle: TextStyle(
                color: ITColors.textTertiaryColor(isDark),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: ITColors.textTertiaryColor(isDark),
                size: 22,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: ITColors.textTertiaryColor(isDark),
                        size: 20,
                      ),
                      onPressed: onClearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        // Category filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: IntegrationCategory.values.map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : ITColors.textSecondaryColor(isDark),
                      ),
                      const SizedBox(width: 6),
                      Text(_getCategoryLabel(category)),
                    ],
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : ITColors.textPrimaryColor(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  selectedColor: ITColors.primary,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected
                        ? ITColors.primary
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : ITColors.border),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (_) => onCategoryChanged(category),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(IntegrationCategory category) {
    switch (category) {
      case IntegrationCategory.all:
        return Icons.apps_rounded;
      case IntegrationCategory.lms:
        return Icons.school_rounded;
      case IntegrationCategory.ai:
        return Icons.psychology_rounded;
      case IntegrationCategory.storage:
        return Icons.cloud_rounded;
      case IntegrationCategory.productivity:
        return Icons.work_rounded;
      case IntegrationCategory.communication:
        return Icons.chat_rounded;
      case IntegrationCategory.analytics:
        return Icons.analytics_rounded;
      case IntegrationCategory.security:
        return Icons.security_rounded;
    }
  }

  String _getCategoryLabel(IntegrationCategory category) {
    switch (category) {
      case IntegrationCategory.all:
        return 'All Providers';
      case IntegrationCategory.lms:
        return 'LMS';
      case IntegrationCategory.ai:
        return 'AI';
      case IntegrationCategory.storage:
        return 'Storage';
      case IntegrationCategory.productivity:
        return 'Productivity';
      case IntegrationCategory.communication:
        return 'Communication';
      case IntegrationCategory.analytics:
        return 'Analytics';
      case IntegrationCategory.security:
        return 'Security';
    }
  }
}
