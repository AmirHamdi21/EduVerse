import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ai_notes/ai_notes_models.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class AiNotesFilterChips extends StatelessWidget {
  final NotesFilter currentFilter;
  final List<NoteCategory> categories;
  final String? selectedCategoryId;
  final Function(NotesFilter, String?) onFilterSelected;

  const AiNotesFilterChips({
    super.key,
    required this.currentFilter,
    required this.categories,
    required this.selectedCategoryId,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context,
            isDark: isDark,
            label: l10n.allNotes,
            icon: Icons.notes_rounded,
            isSelected: currentFilter == NotesFilter.all,
            onTap: () => onFilterSelected(NotesFilter.all, null),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            isDark: isDark,
            label: l10n.byCourse,
            icon: Icons.school_rounded,
            isSelected: currentFilter == NotesFilter.byCourse,
            onTap: () => _showCategoryPicker(context, isDark, l10n),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            isDark: isDark,
            label: l10n.favorites,
            icon: Icons.favorite_rounded,
            isSelected: currentFilter == NotesFilter.favorites,
            onTap: () => onFilterSelected(NotesFilter.favorites, null),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            isDark: isDark,
            label: l10n.byDate,
            icon: Icons.calendar_today_rounded,
            isSelected: currentFilter == NotesFilter.byDate,
            onTap: () => onFilterSelected(NotesFilter.byDate, null),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required bool isDark,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? const Color(0xFF1A1A1B) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
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
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(
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
            const SizedBox(height: 5),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.selectCourse,
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
            ...categories.map(
              (category) => _buildCategoryTile(
                context,
                category: category,
                isDark: isDark,
                isSelected: selectedCategoryId == category.id,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required NoteCategory category,
    required bool isDark,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          onFilterSelected(NotesFilter.byCourse, category.id);
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
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
}
