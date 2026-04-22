import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';

class SearchEmptyState extends StatelessWidget {
  final String query;
  final bool isDark;
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  const SearchEmptyState({
    super.key,
    required this.query,
    required this.isDark,
    this.hasFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.searchNoResults,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.searchNoResultsFor} "$query"',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.searchTryDifferent,
              style: TextStyle(
                color: isDark ? Colors.white38 : const Color(0xFFCBD5E1),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters && onClearFilters != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: Text(l10n.clearFilters),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF155DFC),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
