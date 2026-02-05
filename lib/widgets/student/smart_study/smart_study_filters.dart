import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/smart_study/smart_study_cubit.dart';
import '../../../bloc/smart_study/smart_study_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SmartStudyFilters extends StatelessWidget {
  final bool isDark;

  const SmartStudyFilters({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SmartStudyCubit, SmartStudyState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown(
                      context: context,
                      label: state.selectedCourse ?? l10n.smartStudyAllCourses,
                      icon: Icons.school_outlined,
                      onTap: () => _showCourseFilter(context, state, l10n),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown(
                      context: context,
                      label: _getDifficultyLabel(
                        state.selectedDifficulty,
                        l10n,
                      ),
                      icon: Icons.trending_up_rounded,
                      onTap: () => _showDifficultyFilter(context, state, l10n),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterDropdown(
                      context: context,
                      label: _getUrgencyLabel(state.selectedUrgency, l10n),
                      icon: Icons.access_time_rounded,
                      onTap: () => _showUrgencyFilter(context, state, l10n),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2939) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF364153) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF4A5565),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF4A5565),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseFilter(
    BuildContext context,
    SmartStudyState state,
    AppLocalizations l10n,
  ) {
    _showFilterBottomSheet(
      context: context,
      title: l10n.smartStudySelectCourse,
      options: [
        FilterOption(
          label: l10n.smartStudyAllCourses,
          isSelected: state.selectedCourse == null,
          onTap: () {
            context.read<SmartStudyCubit>().filterByCourse(null);
            Navigator.pop(context);
          },
        ),
        ...state.availableCourses.map(
          (course) => FilterOption(
            label: course,
            isSelected: state.selectedCourse == course,
            onTap: () {
              context.read<SmartStudyCubit>().filterByCourse(course);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  void _showDifficultyFilter(
    BuildContext context,
    SmartStudyState state,
    AppLocalizations l10n,
  ) {
    _showFilterBottomSheet(
      context: context,
      title: l10n.smartStudySelectDifficulty,
      options: TopicDifficulty.values.map((difficulty) {
        return FilterOption(
          label: _getDifficultyLabel(difficulty, l10n),
          isSelected: state.selectedDifficulty == difficulty,
          onTap: () {
            context.read<SmartStudyCubit>().filterByDifficulty(difficulty);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showUrgencyFilter(
    BuildContext context,
    SmartStudyState state,
    AppLocalizations l10n,
  ) {
    _showFilterBottomSheet(
      context: context,
      title: l10n.smartStudySelectUrgency,
      options: TopicUrgency.values.map((urgency) {
        return FilterOption(
          label: _getUrgencyLabel(urgency, l10n),
          isSelected: state.selectedUrgency == urgency,
          onTap: () {
            context.read<SmartStudyCubit>().filterByUrgency(urgency);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showFilterBottomSheet({
    required BuildContext context,
    required String title,
    required List<FilterOption> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF364153)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => _buildFilterOption(option)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(FilterOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: option.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: option.isSelected
                  ? (isDark
                        ? const Color(0xFF2B7FFF).withValues(alpha: 0.15)
                        : const Color(0xFF2B7FFF).withValues(alpha: 0.1))
                  : (isDark
                        ? const Color(0xFF1E2939).withValues(alpha: 0.5)
                        : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: option.isSelected
                    ? const Color(0xFF2B7FFF)
                    : (isDark
                          ? const Color(0xFF364153)
                          : const Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      color: option.isSelected
                          ? const Color(0xFF2B7FFF)
                          : (isDark
                                ? const Color(0xFFF3F4F6)
                                : const Color(0xFF101828)),
                      fontSize: 15,
                      fontWeight: option.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (option.isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2B7FFF),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDifficultyLabel(
    TopicDifficulty difficulty,
    AppLocalizations l10n,
  ) {
    switch (difficulty) {
      case TopicDifficulty.all:
        return l10n.smartStudyAllDifficulty;
      case TopicDifficulty.easy:
        return l10n.smartStudyEasy;
      case TopicDifficulty.medium:
        return l10n.smartStudyMedium;
      case TopicDifficulty.hard:
        return l10n.smartStudyHard;
    }
  }

  String _getUrgencyLabel(TopicUrgency urgency, AppLocalizations l10n) {
    switch (urgency) {
      case TopicUrgency.all:
        return l10n.smartStudyAllUrgency;
      case TopicUrgency.high:
        return l10n.smartStudyHighUrgency;
      case TopicUrgency.medium:
        return l10n.smartStudyMediumUrgency;
      case TopicUrgency.low:
        return l10n.smartStudyLowUrgency;
    }
  }
}

class FilterOption {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
}
