import 'package:flutter/material.dart';
import '../../../bloc/search/search_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SearchCategoryChips extends StatelessWidget {
  final SearchCategory selected;
  final ValueChanged<SearchCategory> onSelected;
  final bool isDark;

  const SearchCategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = <SearchCategory, String>{
      SearchCategory.all: l10n.searchCategoryAll,
      SearchCategory.courses: l10n.searchCategoryCourses,
      SearchCategory.tasks: l10n.searchCategoryTasks,
      SearchCategory.assignments: l10n.searchCategoryAssignments,
      SearchCategory.labs: l10n.searchCategoryLabs,
      SearchCategory.grades: l10n.searchCategoryGrades,
      SearchCategory.flashcards: l10n.searchCategoryFlashcards,
      SearchCategory.notes: l10n.searchCategoryNotes,
      SearchCategory.messages: l10n.searchCategoryMessages,
    };

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = categories.entries.elementAt(index);
          final isSelected = entry.key == selected;

          return GestureDetector(
            onTap: () => onSelected(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF155DFC), Color(0xFF2B7FFF)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
              ),
              child: Center(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? Colors.white70
                        : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
