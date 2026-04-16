import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/utils/student_course_filters.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class FilterButton extends StatelessWidget {
  final String selectedFilter;
  final int? selectedSemesterId;
  final List<SemesterFilterOption> semesterOptions;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<int?> onSemesterChanged;

  const FilterButton({
    required this.onFilterChanged,
    required this.onSemesterChanged,
    required this.selectedFilter,
    required this.selectedSemesterId,
    required this.semesterOptions,
    super.key,
  });

  String _getFilterLabel(String filter, AppLocalizations l10n) {
    if (filter == 'all') {
      return l10n.filter;
    }

    switch (filter) {
      case 'active':
        return l10n.active;
      case 'completed':
        return l10n.completed;
      case 'dropped':
        return 'Dropped';
      default:
        return l10n.filter;
    }
  }

  bool get _hasSelection =>
      selectedFilter != 'all' || selectedSemesterId != null;

  String _label(AppLocalizations l10n) {
    if (selectedSemesterId != null) {
      SemesterFilterOption? option;
      for (final SemesterFilterOption candidate in semesterOptions) {
        if (candidate.id == selectedSemesterId) {
          option = candidate;
          break;
        }
      }

      if (option != null) {
        return option.label;
      }
    }

    return _getFilterLabel(selectedFilter, l10n);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Expanded(
          child: GestureDetector(
            onTap: () => _showFilterMenu(context, isDark, l10n),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasSelection
                      ? const Color(0xFF155DFC)
                      : (isDark ? Colors.white10 : const Color(0xFFD1D5DC)),
                  width: _hasSelection ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.tune,
                    color: _hasSelection
                        ? const Color(0xFF155DFC)
                        : (isDark ? Colors.white54 : const Color(0xFF495565)),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _label(l10n),
                      style: TextStyle(
                        color: _hasSelection
                            ? const Color(0xFF155DFC)
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF364153)),
                        fontSize: 14,
                        fontWeight: _hasSelection
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

  void _showFilterMenu(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
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
            Text(
              'Status',
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF364153),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildFilterOption(context, 'all', l10n.all, isDark),
            _buildFilterOption(context, 'active', l10n.active, isDark),
            _buildFilterOption(context, 'completed', l10n.completed, isDark),
            _buildFilterOption(context, 'dropped', 'Dropped', isDark),
            if (semesterOptions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Semester',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF364153),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildSemesterOption(context, null, l10n.allSemesters, isDark),
              ...semesterOptions.map(
                (SemesterFilterOption option) => _buildSemesterOption(
                  context,
                  option.id,
                  option.label,
                  isDark,
                ),
              ),
            ],
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
          ? Icon(Icons.check, color: const Color(0xFF155DFC))
          : null,
      onTap: () {
        onFilterChanged(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSemesterOption(
    BuildContext context,
    int? value,
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
      trailing: selectedSemesterId == value
          ? const Icon(Icons.check, color: Color(0xFF155DFC))
          : null,
      onTap: () {
        onSemesterChanged(value);
        Navigator.pop(context);
      },
    );
  }
}
