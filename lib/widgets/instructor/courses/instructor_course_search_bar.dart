import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/instructor_courses_theme.dart';

class InstructorCourseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final String hintText;
  final String clearTooltip;

  const InstructorCourseSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.hintText,
    required this.clearTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? InstructorCoursesTheme.darkSurfaceRaised
                    : Colors.white.withValues(alpha: 0.98),
                borderRadius: InstructorCoursesTheme.pillRadius,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFD5E1F3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                cursorColor: InstructorCoursesTheme.brandBlue,
                style: TextStyle(
                  color: InstructorCoursesTheme.primaryText(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF667085),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 10,
                      end: 10,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: isDark
                            ? Colors.white70
                            : InstructorCoursesTheme.brandBlue,
                        size: 20,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 60,
                    minHeight: 56,
                  ),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: clearTooltip,
                          onPressed: () {
                            controller.clear();
                            onSearchChanged('');
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF667085),
                            size: 20,
                          ),
                        ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 56,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsetsDirectional.only(
                    end: 14,
                    top: 16,
                    bottom: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
