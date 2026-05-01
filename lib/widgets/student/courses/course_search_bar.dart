import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';

class CourseSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const CourseSearchBar({super.key, required this.onSearchChanged});

  @override
  State<CourseSearchBar> createState() => _CourseSearchBarState();
}

class _CourseSearchBarState extends State<CourseSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? StudentCoursesTheme.darkSurfaceRaised
                : Colors.white.withValues(alpha: 0.98),
            borderRadius: StudentCoursesTheme.pillRadius,
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
          child: Semantics(
            textField: true,
            label: l10n.searchCourseNameOrInstructor,
            hint: l10n.coursesShellSearchSemanticsHint,
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {});
                widget.onSearchChanged(value);
              },
              cursorColor: StudentCoursesTheme.brandBlue,
              style: TextStyle(
                color: StudentCoursesTheme.primaryText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchCourseNameOrInstructor,
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
                          : StudentCoursesTheme.brandBlue,
                      size: 20,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 60,
                  minHeight: 56,
                ),
                suffixIcon: AnimatedSwitcher(
                  duration: StudentCoursesTheme.controlAnimationDuration,
                  child: _controller.text.isEmpty
                      ? const SizedBox(key: ValueKey('search-empty'))
                      : IconButton(
                          key: const ValueKey('search-clear'),
                          tooltip: l10n.clearSearch,
                          onPressed: () {
                            _controller.clear();
                            widget.onSearchChanged('');
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF667085),
                            size: 20,
                          ),
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
          ),
        );
      },
    );
  }
}
