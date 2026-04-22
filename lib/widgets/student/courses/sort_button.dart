import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/utils/student_courses_theme.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SortButton extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  const SortButton({
    required this.onSortChanged,
    this.selectedSort = 'title_asc',
    super.key,
  });

  bool get _hasCustomSort => selectedSort != 'title_asc';

  String _getSortLabel(String sort, AppLocalizations l10n) {
    switch (sort) {
      case 'title_asc':
        return l10n.titleAZ;
      case 'title_desc':
        return l10n.titleZA;
      case 'credits_desc':
        return '${l10n.credits} ↓';
      case 'credits_asc':
        return '${l10n.credits} ↑';
      case 'date':
        return l10n.recent;
      default:
        return l10n.sort;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Expanded(
          child: Semantics(
            button: true,
            label: l10n.sortBy,
            value: _getSortLabel(selectedSort, l10n),
            hint: l10n.sort,
            child: GestureDetector(
              onTap: () => _showSortMenu(context, isDark, l10n),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: StudentCoursesTheme.cardBackground(isDark),
                  borderRadius: StudentCoursesTheme.controlRadius,
                  border: Border.all(
                    color: _hasCustomSort
                        ? const Color(0xFF155DFC)
                        : StudentCoursesTheme.borderColor(isDark),
                    width: _hasCustomSort ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Icon(
                      Icons.swap_vert,
                      color: _hasCustomSort
                          ? const Color(0xFF155DFC)
                          : (isDark ? Colors.white54 : const Color(0xFF495565)),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _getSortLabel(selectedSort, l10n),
                        style: TextStyle(
                          color: _hasCustomSort
                              ? const Color(0xFF155DFC)
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF364153)),
                          fontSize: 14,
                          fontWeight: _hasCustomSort
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSortMenu(BuildContext context, bool isDark, AppLocalizations l10n) {
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.8;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sortBy,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSortOption(context, 'title_asc', l10n.titleAZ, isDark),
                  _buildSortOption(context, 'title_desc', l10n.titleZA, isDark),
                  _buildSortOption(
                    context,
                    'credits_desc',
                    '${l10n.credits} ↓',
                    isDark,
                  ),
                  _buildSortOption(
                    context,
                    'credits_asc',
                    '${l10n.credits} ↑',
                    isDark,
                  ),
                  _buildSortOption(context, 'date', l10n.recent, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String value,
    String label,
    bool isDark,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF364153),
          fontSize: 14,
        ),
      ),
      trailing: selectedSort == value
          ? Icon(Icons.check, color: const Color(0xFF155DFC))
          : null,
      onTap: () {
        onSortChanged(value);
        Navigator.pop(context);
      },
    );
  }
}
