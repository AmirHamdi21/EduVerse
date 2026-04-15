import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/search/search_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import 'search_result_card.dart';

class SearchResultsSection extends StatelessWidget {
  final Map<SearchResultType, List<SearchResultItem>> groupedResults;
  final int totalCount;
  final bool isDark;

  const SearchResultsSection({
    super.key,
    required this.groupedResults,
    required this.totalCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                '$totalCount ${l10n.searchResultsFound}',
                style: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ...groupedResults.entries.map((entry) {
          return _ResultGroup(
            type: entry.key,
            items: entry.value,
            isDark: isDark,
          );
        }),
      ],
    );
  }
}

class _ResultGroup extends StatelessWidget {
  final SearchResultType type;
  final List<SearchResultItem> items;
  final bool isDark;

  const _ResultGroup({
    required this.type,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _getTypeColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getTypeLabel(l10n),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(
                    alpha: isDark ? 0.15 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    color: _getTypeColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: SearchResultCard(
              item: item,
              isDark: isDark,
              onTap: () {
                if (item.route != null) {
                  context.push(item.route!, extra: item.extra);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(AppLocalizations l10n) {
    switch (type) {
      case SearchResultType.course:
        return l10n.courses;
      case SearchResultType.task:
        return l10n.tasks;
      case SearchResultType.assignment:
        return l10n.assignments;
      case SearchResultType.lab:
        return l10n.labs;
      case SearchResultType.grade:
        return l10n.grades;
      case SearchResultType.flashcard:
        return l10n.flashcards;
      case SearchResultType.note:
        return l10n.searchCategoryNotes;
      case SearchResultType.message:
        return l10n.messages;
      case SearchResultType.feature:
        return l10n.searchCategoryFeatures;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case SearchResultType.course:
        return const Color(0xFF155DFC);
      case SearchResultType.task:
        return const Color(0xFF10B981);
      case SearchResultType.assignment:
        return const Color(0xFFF59E0B);
      case SearchResultType.lab:
        return const Color(0xFF06B6D4);
      case SearchResultType.grade:
        return const Color(0xFF8B5CF6);
      case SearchResultType.flashcard:
        return const Color(0xFFEF4444);
      case SearchResultType.note:
        return const Color(0xFF14B8A6);
      case SearchResultType.message:
        return const Color(0xFFEC4899);
      case SearchResultType.feature:
        return const Color(0xFF155DFC);
    }
  }
}
