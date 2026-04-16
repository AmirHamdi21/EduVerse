import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/utils/student_course_filters.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class CourseFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final int? selectedSemesterId;
  final List<SemesterFilterOption> semesterOptions;
  final ValueChanged<int?> onSemesterChanged;

  const CourseFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.selectedSemesterId,
    required this.semesterOptions,
    required this.onSemesterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton(
                label: l10n.all,
                selected: selectedFilter == 'all',
                isDark: isDark,
                isGradient: true,
                onTap: () => onFilterChanged('all'),
              ),
              const SizedBox(width: 12),
              _buildFilterButton(
                label: l10n.active,
                selected: selectedFilter == 'active',
                isDark: isDark,
                onTap: () => onFilterChanged('active'),
              ),
              const SizedBox(width: 12),
              _buildFilterButton(
                label: l10n.completed,
                selected: selectedFilter == 'completed',
                isDark: isDark,
                onTap: () => onFilterChanged('completed'),
              ),
              const SizedBox(width: 12),
              _buildFilterButton(
                label: 'Dropped',
                selected: selectedFilter == 'dropped',
                isDark: isDark,
                onTap: () => onFilterChanged('dropped'),
              ),
              const SizedBox(width: 12),
              _buildSemesterChip(
                label: l10n.allSemesters,
                selected: selectedSemesterId == null,
                isDark: isDark,
                onTap: () => onSemesterChanged(null),
              ),
              ...semesterOptions.expand(
                (SemesterFilterOption option) => <Widget>[
                  const SizedBox(width: 12),
                  _buildSemesterChip(
                    label: option.label,
                    selected: selectedSemesterId == option.id,
                    isDark: isDark,
                    onTap: () => onSemesterChanged(option.id),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
    bool isGradient = false,
  }) {
    final bool isSelected = selected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected && isGradient
              ? const LinearGradient(
                  colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected && !isGradient
              ? (isDark ? const Color(0xFF2A3F5F) : const Color(0xFFF0F4FF))
              : (isDark ? const Color(0xFF16213E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected && !isGradient
                ? const Color(0xFF155DFC)
                : (isDark ? Colors.white10 : const Color(0xFFD1D5DC)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF155DFC).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected && isGradient
                ? Colors.white
                : (isSelected
                      ? const Color(0xFF155DFC)
                      : (isDark ? Colors.white70 : const Color(0xFF364153))),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? const Color(0xFF2A3F5F) : const Color(0xFFF0F4FF))
              : (isDark ? const Color(0xFF16213E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF155DFC)
                : (isDark ? Colors.white10 : const Color(0xFFD1D5DC)),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFF155DFC)
                : (isDark ? Colors.white70 : const Color(0xFF364153)),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
