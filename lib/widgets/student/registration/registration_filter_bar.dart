import 'package:flutter/material.dart';

import '../../../common/utils/student_courses_theme.dart';
import '../../../common/utils/student_registration_filters.dart';
import '../../../generated_l10n/app_localizations.dart';

class RegistrationFilterBar extends StatelessWidget {
  const RegistrationFilterBar({
    super.key,
    required this.searchQuery,
    required this.departmentOptions,
    required this.levelOptions,
    required this.selectedDepartment,
    required this.selectedLevel,
    required this.isDark,
    required this.onSearchChanged,
    required this.onDepartmentChanged,
    required this.onLevelChanged,
  });

  final String searchQuery;
  final List<String> departmentOptions;
  final List<String> levelOptions;
  final String selectedDepartment;
  final String selectedLevel;
  final bool isDark;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        TextFormField(
          key: ValueKey<String>('registration_search_$searchQuery'),
          initialValue: searchQuery,
          onChanged: onSearchChanged,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: l10n.searchCoursePlaceholder,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: StudentCoursesTheme.mutedText(isDark),
            ),
            filled: true,
            fillColor: StudentCoursesTheme.cardBackground(isDark),
            border: OutlineInputBorder(
              borderRadius: StudentCoursesTheme.controlRadius,
              borderSide: BorderSide(
                color: StudentCoursesTheme.borderColor(isDark),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: StudentCoursesTheme.controlRadius,
              borderSide: BorderSide(
                color: StudentCoursesTheme.borderColor(isDark),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: StudentCoursesTheme.controlRadius,
              borderSide: BorderSide(color: Color(0xFF155DFC), width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _DropdownField(
                isDark: isDark,
                label: l10n.allDepartments,
                value: _ensureValue(departmentOptions, selectedDepartment),
                items: departmentOptions,
                allLabel: l10n.allDepartments,
                onChanged: onDepartmentChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DropdownField(
                isDark: isDark,
                label: l10n.allLevels,
                value: _ensureValue(levelOptions, selectedLevel),
                items: levelOptions,
                allLabel: l10n.allLevels,
                onChanged: onLevelChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _ensureValue(List<String> options, String selected) {
    if (options.contains(selected)) {
      return selected;
    }
    return StudentRegistrationFilters.allFilterValue;
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.isDark,
    required this.label,
    required this.value,
    required this.items,
    required this.allLabel,
    required this.onChanged,
  });

  final bool isDark;
  final String label;
  final String value;
  final List<String> items;
  final String allLabel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: StudentCoursesTheme.mutedText(isDark)),
        filled: true,
        fillColor: StudentCoursesTheme.cardBackground(isDark),
        border: OutlineInputBorder(
          borderRadius: StudentCoursesTheme.controlRadius,
          borderSide: BorderSide(
            color: StudentCoursesTheme.borderColor(isDark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: StudentCoursesTheme.controlRadius,
          borderSide: BorderSide(
            color: StudentCoursesTheme.borderColor(isDark),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: StudentCoursesTheme.controlRadius,
          borderSide: BorderSide(color: Color(0xFF155DFC), width: 1.4),
        ),
      ),
      dropdownColor: StudentCoursesTheme.cardBackground(isDark),
      items: items.map((item) {
        final bool isAll = item == StudentRegistrationFilters.allFilterValue;
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            isAll ? allLabel : item,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
