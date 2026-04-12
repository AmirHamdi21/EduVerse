import 'package:flutter/material.dart';
import '../../../models/instructor/upload_materials_model.dart';
import 'upload_materials_colors.dart';

/// Course selector dropdown
class CourseSelector extends StatelessWidget {
  final List<CourseOption> courses;
  final String? selectedCourseId;
  final ValueChanged<String?> onCourseChanged;
  final bool isDark;

  const CourseSelector({
    super.key,
    required this.courses,
    required this.selectedCourseId,
    required this.onCourseChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UploadMaterialsColors.borderColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourseId,
          hint: Text(
            'Select Course',
            style: TextStyle(
              color: UploadMaterialsColors.textSecondaryColor(isDark),
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: UploadMaterialsColors.textSecondaryColor(isDark),
          ),
          dropdownColor: isDark ? UploadMaterialsColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: courses.map((course) {
            return DropdownMenuItem<String>(
              value: course.id,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: UploadMaterialsColors.primary.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: UploadMaterialsColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          course.name,
                          style: TextStyle(
                            color: UploadMaterialsColors.textPrimaryColor(
                              isDark,
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          course.code,
                          style: TextStyle(
                            color: UploadMaterialsColors.textSecondaryColor(
                              isDark,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onCourseChanged,
        ),
      ),
    );
  }
}

/// Week selector dropdown
class ModuleSelector extends StatelessWidget {
  final List<CourseModule> modules;
  final String? selectedModuleId;
  final ValueChanged<String?> onModuleChanged;
  final bool isDark;
  final bool enabled;

  const ModuleSelector({
    super.key,
    required this.modules,
    required this.selectedModuleId,
    required this.onModuleChanged,
    required this.isDark,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UploadMaterialsColors.borderColor(isDark)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedModuleId,
            hint: Text(
              enabled ? 'Select Week (Optional)' : 'Select a course first',
              style: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(isDark),
              ),
            ),
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: UploadMaterialsColors.textSecondaryColor(isDark),
            ),
            dropdownColor: isDark
                ? UploadMaterialsColors.darkCard
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            onChanged: enabled ? onModuleChanged : null,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'No Week (Course Level)',
                  style: TextStyle(
                    color: UploadMaterialsColors.textSecondaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
              ),
              ...modules.map((module) {
                return DropdownMenuItem<String>(
                  value: module.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        color: UploadMaterialsColors.textSecondaryColor(isDark),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          module.name,
                          style: TextStyle(
                            color: UploadMaterialsColors.textPrimaryColor(
                              isDark,
                            ),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (module.materialCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: UploadMaterialsColors.surfaceColor(isDark),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${module.materialCount}',
                            style: TextStyle(
                              color: UploadMaterialsColors.textTertiaryColor(
                                isDark,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Material type filter chips
class MaterialTypeFilter extends StatelessWidget {
  final CourseMaterialType? selectedType;
  final ValueChanged<CourseMaterialType?> onTypeChanged;
  final bool isDark;

  const MaterialTypeFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: 'All',
            isSelected: selectedType == null,
            onTap: () => onTypeChanged(null),
          ),
          const SizedBox(width: 8),
          ...CourseMaterialType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: type.title,
                icon: type.icon,
                color: type.color,
                isSelected: selectedType == type,
                onTap: () => onTypeChanged(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? UploadMaterialsColors.primary)
                : (isDark
                      ? UploadMaterialsColors.darkSurface
                      : UploadMaterialsColors.surface),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : UploadMaterialsColors.borderColor(isDark),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : UploadMaterialsColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : UploadMaterialsColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
