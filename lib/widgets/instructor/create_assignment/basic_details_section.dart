import 'package:flutter/material.dart';
import '../../../models/instructor/assignment_model.dart';
import 'create_assignment_colors.dart';

class BasicDetailsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCourseId;
  final String? selectedModuleId;
  final List<CourseOption> courses;
  final Function(String?) onCourseChanged;
  final Function(String?) onModuleChanged;
  final bool isDark;
  final Color? accentColor;

  const BasicDetailsSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCourseId,
    required this.selectedModuleId,
    required this.courses,
    required this.onCourseChanged,
    required this.onModuleChanged,
    required this.isDark,
    this.accentColor,
  });

  Color get _accent => accentColor ?? CreateAssignmentColors.primary;

  CourseOption? get selectedCourse {
    if (selectedCourseId == null) return null;
    return courses.firstWhere(
      (c) => c.id == selectedCourseId,
      orElse: () => courses.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        _buildLabel('Title'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: titleController,
          hintText: 'Enter assignment title...',
        ),
        const SizedBox(height: 16),

        // Short Description
        _buildLabel('Short Description'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: descriptionController,
          hintText: 'Brief overview of the task...',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Course & Module Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Course'),
                  const SizedBox(height: 8),
                  _buildDropdown<String>(
                    value: selectedCourseId,
                    hint: 'Select Course',
                    items: courses.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.displayName,
                        style: TextStyle(
                          color: CreateAssignmentColors.textPrimaryColor(isDark),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: onCourseChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Module'),
                  const SizedBox(height: 8),
                  _buildDropdown<String>(
                    value: selectedModuleId,
                    hint: 'Select Module',
                    items: selectedCourse?.modules.map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(
                        m.name,
                        style: TextStyle(
                          color: CreateAssignmentColors.textPrimaryColor(isDark),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList() ?? [],
                    onChanged: onModuleChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: CreateAssignmentColors.textSecondaryColor(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: CreateAssignmentColors.textPrimaryColor(isDark),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: CreateAssignmentColors.textTertiaryColor(isDark),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _accent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: CreateAssignmentColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: CreateAssignmentColors.textSecondaryColor(isDark),
          ),
          dropdownColor: isDark
              ? CreateAssignmentColors.darkCard
              : Colors.white,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
