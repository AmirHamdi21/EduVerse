import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class CourseSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;

  const CourseSearchBar({super.key, required this.onSearchChanged});

  @override
  State<CourseSearchBar> createState() => _CourseSearchBarState();
}

class _CourseSearchBarState extends State<CourseSearchBar> {
  late TextEditingController _controller;

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
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16213E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFD1D5DC),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            // onChanged: widget.onSearchChanged,
            cursorColor: const Color(0xFF155DFC),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101727),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: l10n.searchCourseNameOrInstructor,
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF717182),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? Colors.white54 : const Color(0xFF717182),
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        widget.onSearchChanged('');
                        setState(() {});
                      },
                      child: Icon(
                        Icons.clear,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF717182),
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {});
              widget.onSearchChanged(value);
            },
          ),
        );
      },
    );
  }
}
