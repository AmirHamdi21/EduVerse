import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SortButton extends StatelessWidget {
  final String? selectedSort;
  final ValueChanged<String> onSortChanged;

  const SortButton({required this.onSortChanged, this.selectedSort, super.key});

  String _getSortLabel(String? sort, AppLocalizations l10n) {
    if (sort == null) return l10n.sort;
    switch (sort) {
      case 'title_asc':
        return 'A-Z';
      case 'title_desc':
        return 'Z-A';
      case 'credits_desc':
        return 'Credits ↓';
      case 'credits_asc':
        return 'Credits ↑';
      case 'date':
        return 'Date';
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
          child: GestureDetector(
            onTap: () => _showSortMenu(context, isDark, l10n),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selectedSort != null && selectedSort != 'title_asc'
                      ? const Color(0xFF155DFC)
                      : (isDark ? Colors.white10 : const Color(0xFFD1D5DC)),
                  width: selectedSort != null && selectedSort != 'title_asc'
                      ? 1.5
                      : 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Icon(
                    Icons.swap_vert,
                    color: selectedSort != null && selectedSort != 'title_asc'
                        ? const Color(0xFF155DFC)
                        : (isDark ? Colors.white54 : const Color(0xFF495565)),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _getSortLabel(selectedSort, l10n),
                      style: TextStyle(
                        color:
                            selectedSort != null && selectedSort != 'title_asc'
                            ? const Color(0xFF155DFC)
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF364153)),
                        fontSize: 14,
                        fontWeight:
                            selectedSort != null && selectedSort != 'title_asc'
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
        );
      },
    );
  }

  void _showSortMenu(BuildContext context, bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sort,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption(context, 'title_asc', 'Title (A-Z)', isDark),
            _buildSortOption(context, 'title_desc', 'Title (Z-A)', isDark),
            _buildSortOption(context, 'credits_desc', 'Most Credits', isDark),
            _buildSortOption(context, 'credits_asc', 'Least Credits', isDark),
            _buildSortOption(context, 'date', 'Enrollment Date', isDark),
          ],
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
