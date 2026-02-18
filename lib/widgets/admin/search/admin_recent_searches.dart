import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminRecentSearches extends StatelessWidget {
  final bool isDark;
  final List<String> recentSearches;
  final Function(String) onSearchTap;
  final Function(String) onRemove;
  final VoidCallback onClearAll;

  const AdminRecentSearches({
    super.key,
    required this.isDark,
    required this.recentSearches,
    required this.onSearchTap,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 13,
                    color: AdminColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentSearches.map((search) => _buildRecentItem(search)),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String search) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSearchTap(search),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    search,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AdminColors.darkText : AdminColors.lightText,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary,
                  ),
                  onPressed: () => onRemove(search),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
