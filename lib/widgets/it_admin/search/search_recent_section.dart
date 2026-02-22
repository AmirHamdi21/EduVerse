import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITSearchRecentSection extends StatelessWidget {
  final bool isDark;
  final List<String> recentSearches;
  final String recentSearchesLabel;
  final String clearAllLabel;
  final VoidCallback onClearAll;
  final ValueChanged<String> onSearchTap;

  const ITSearchRecentSection({
    super.key,
    required this.isDark,
    required this.recentSearches,
    required this.recentSearchesLabel,
    required this.clearAllLabel,
    required this.onClearAll,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              recentSearchesLabel,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onClearAll,
              child: Text(clearAllLabel),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.map((search) {
            return ActionChip(
              avatar: Icon(
                Icons.history_rounded,
                size: 16,
                color: ITColors.textSecondaryColor(isDark),
              ),
              label: Text(search),
              onPressed: () => onSearchTap(search),
              backgroundColor: ITColors.cardColor(isDark),
              labelStyle: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
              ),
              side: BorderSide(color: ITColors.borderColor(isDark)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
