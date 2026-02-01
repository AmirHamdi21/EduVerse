import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class FilterButton extends StatelessWidget {
  final String? selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterButton({
    required this.onFilterChanged,
    this.selectedFilter,
    super.key,
  });

  String _getFilterLabel(String? filter, AppLocalizations l10n) {
    if (filter == null || filter == 'all') return l10n.filter;
    switch (filter) {
      case 'completed':
        return l10n.completed;
      case 'lectures':
        return l10n.lectures;
      case 'labs':
        return l10n.labs;
      default:
        return l10n.filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context)!;

        return Expanded(
          child: GestureDetector(
            onTap: () => _showFilterMenu(context, isDark, l10n),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selectedFilter != null && selectedFilter != 'all'
                      ? const Color(0xFF155DFC)
                      : (isDark ? Colors.white10 : const Color(0xFFD1D5DC)),
                  width: selectedFilter != null && selectedFilter != 'all' ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.tune,
                    color: selectedFilter != null && selectedFilter != 'all'
                        ? const Color(0xFF155DFC)
                        : (isDark ? Colors.white54 : const Color(0xFF495565)),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _getFilterLabel(selectedFilter, l10n),
                      style: TextStyle(
                        color: selectedFilter != null && selectedFilter != 'all'
                            ? const Color(0xFF155DFC)
                            : (isDark ? Colors.white70 : const Color(0xFF364153)),
                        fontSize: 14,
                        fontWeight: selectedFilter != null && selectedFilter != 'all'
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

  void _showFilterMenu(BuildContext context, bool isDark, AppLocalizations l10n) {
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
              l10n.filter,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption(
              context,
              'all',
              l10n.all,
              isDark,
            ),
            _buildFilterOption(
              context,
              'completed',
              '${l10n.completed} (80%+)',
              isDark,
            ),
            _buildFilterOption(
              context,
              'lectures',
              '${l10n.lectures} (<80%)',
              isDark,
            ),
            _buildFilterOption(
              context,
              'labs',
              '${l10n.labs} (50-80%)',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
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
      trailing: selectedFilter == value
          ? Icon(
              Icons.check,
              color: const Color(0xFF155DFC),
            )
          : null,
      onTap: () {
        onFilterChanged(value);
        Navigator.pop(context);
      },
    );
  }
}
