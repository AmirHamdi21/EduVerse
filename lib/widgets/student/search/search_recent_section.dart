import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';

class SearchRecentSection extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;
  final bool isDark;

  const SearchRecentSection({
    super.key,
    required this.recentSearches,
    required this.onTap,
    required this.onRemove,
    required this.onClearAll,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.searchRecentSearches,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onClearAll,
                child: Text(
                  l10n.clearAll,
                  style: const TextStyle(
                    color: Color(0xFF155DFC),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...recentSearches.take(5).map((query) => _RecentSearchItem(
              query: query,
              onTap: () => onTap(query),
              onRemove: () => onRemove(query),
              isDark: isDark,
            )),
      ],
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool isDark;

  const _RecentSearchItem({
    required this.query,
    required this.onTap,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.north_west_rounded,
                size: 16,
                color: isDark ? Colors.white38 : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  query,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
