import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ai_notes/ai_notes_models.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class AiNotesSortDropdown extends StatelessWidget {
  final NotesSort currentSort;
  final Function(NotesSort) onSortSelected;

  const AiNotesSortDropdown({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: isDark ? const Color(0xFF1A1A1B) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showSortOptions(context, isDark, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort_rounded,
                size: 18,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                _getSortLabel(l10n),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSortLabel(AppLocalizations l10n) {
    switch (currentSort) {
      case NotesSort.dateNewest:
        return l10n.newestFirst;
      case NotesSort.dateOldest:
        return l10n.oldestFirst;
      case NotesSort.titleAZ:
        return l10n.titleAZ;
      case NotesSort.titleZA:
        return l10n.titleZA;
      case NotesSort.courseAZ:
        return l10n.courseAZ;
    }
  }

  void _showSortOptions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sort_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.sortBy,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...NotesSort.values.map(
              (sort) => _buildSortTile(
                context,
                sort: sort,
                isDark: isDark,
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTile(
    BuildContext context, {
    required NotesSort sort,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final isSelected = currentSort == sort;
    final label = _getSortLabelForOption(sort, l10n);
    final icon = _getSortIcon(sort);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          onSortSelected(sort);
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : (isDark ? Colors.white60 : Colors.black54),
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              )
            : null,
      ),
    );
  }

  String _getSortLabelForOption(NotesSort sort, AppLocalizations l10n) {
    switch (sort) {
      case NotesSort.dateNewest:
        return l10n.newestFirst;
      case NotesSort.dateOldest:
        return l10n.oldestFirst;
      case NotesSort.titleAZ:
        return l10n.titleAZ;
      case NotesSort.titleZA:
        return l10n.titleZA;
      case NotesSort.courseAZ:
        return l10n.courseAZ;
    }
  }

  IconData _getSortIcon(NotesSort sort) {
    switch (sort) {
      case NotesSort.dateNewest:
        return Icons.arrow_downward_rounded;
      case NotesSort.dateOldest:
        return Icons.arrow_upward_rounded;
      case NotesSort.titleAZ:
        return Icons.sort_by_alpha_rounded;
      case NotesSort.titleZA:
        return Icons.sort_by_alpha_rounded;
      case NotesSort.courseAZ:
        return Icons.school_rounded;
    }
  }
}
