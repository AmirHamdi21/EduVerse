import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/instructor_courses_theme.dart';

class InstructorLevelFilterButton extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final String Function(String category) labelBuilder;
  final ValueChanged<String> onCategoryChanged;

  const InstructorLevelFilterButton({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.labelBuilder,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final isActive = selectedCategory != 'all';

        return PopupMenuButton<String>(
          tooltip: labelBuilder(selectedCategory),
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          padding: EdgeInsets.zero,
          color: InstructorCoursesTheme.elevatedCardBackground(isDark),
          surfaceTintColor: Colors.transparent,
          elevation: 14,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: InstructorCoursesTheme.borderColor(isDark)),
          ),
          onSelected: onCategoryChanged,
          itemBuilder: (context) => categories
              .map(
                (category) => PopupMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labelBuilder(category),
                          style: TextStyle(
                            color: selectedCategory == category
                                ? InstructorCoursesTheme.accentPurple
                                : InstructorCoursesTheme.primaryText(isDark),
                            fontSize: 14,
                            fontWeight: selectedCategory == category
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        selectedCategory == category
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selectedCategory == category
                            ? InstructorCoursesTheme.accentPurple
                            : InstructorCoursesTheme.secondaryText(isDark),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bounded =
                  constraints.hasBoundedWidth &&
                  constraints.maxWidth != double.infinity;

              return Container(
                width: bounded ? double.infinity : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: InstructorCoursesTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? InstructorCoursesTheme.accentPurple
                        : InstructorCoursesTheme.borderColor(isDark),
                    width: isActive ? 1.4 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.18 : 0.04,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: InstructorCoursesTheme.accentPurple.withValues(
                          alpha: isDark ? 0.18 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: InstructorCoursesTheme.accentPurple,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Level',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorCoursesTheme.primaryText(isDark),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            labelBuilder(selectedCategory),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive
                                  ? InstructorCoursesTheme.accentPurple
                                  : InstructorCoursesTheme.secondaryText(
                                      isDark,
                                    ),
                              fontSize: 11.5,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: InstructorCoursesTheme.secondaryText(isDark),
                      size: 20,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
