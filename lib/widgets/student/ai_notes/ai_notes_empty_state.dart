import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ai_notes/ai_notes_models.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class AiNotesEmptyState extends StatelessWidget {
  final bool hasSearchQuery;
  final NotesFilter filter;
  final VoidCallback onClearFilters;

  const AiNotesEmptyState({
    super.key,
    required this.hasSearchQuery,
    required this.filter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearchQuery
                    ? Icons.search_off_rounded
                    : (filter == NotesFilter.favorites
                        ? Icons.favorite_border_rounded
                        : Icons.notes_rounded),
                size: 56,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearchQuery
                  ? l10n.noNotesFoundSearch
                  : (filter == NotesFilter.favorites
                      ? l10n.noFavoriteNotes
                      : l10n.noNotesYet),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearchQuery
                  ? l10n.tryDifferentSearch
                  : (filter == NotesFilter.favorites
                      ? l10n.favoriteNotesWillAppear
                      : l10n.generateFirstNote),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasSearchQuery || filter != NotesFilter.all) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.clear_all_rounded),
                label: Text(l10n.clearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

