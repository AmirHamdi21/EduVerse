import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Course details form widget
class CourseDetailsForm extends StatelessWidget {
  final bool isDark;
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final String? selectedDepartment;
  final String? selectedLevel;
  final String? selectedSemester;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onLevelChanged;
  final ValueChanged<String?> onSemesterChanged;
  final VoidCallback onUploadSyllabus;
  final String? syllabusFileName;

  const CourseDetailsForm({
    super.key,
    required this.isDark,
    required this.nameController,
    required this.codeController,
    required this.descriptionController,
    this.selectedDepartment,
    this.selectedLevel,
    this.selectedSemester,
    required this.onDepartmentChanged,
    required this.onLevelChanged,
    required this.onSemesterChanged,
    required this.onUploadSyllabus,
    this.syllabusFileName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.courseDetails,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: nameController,
            label: '${l10n.courseName} *',
            hint: l10n.courseNameHint,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: codeController,
            label: '${l10n.courseCode} *',
            hint: l10n.courseCodeHint,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: '${l10n.department} *',
            hint: l10n.selectDepartment,
            value: selectedDepartment,
            items: [
              'Computer Science',
              'Mathematics',
              'Physics',
              'Engineering',
              'English',
              'Chemistry',
              'Biology',
            ],
            onChanged: onDepartmentChanged,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: '${l10n.academicLevel} *',
            hint: l10n.selectLevel,
            value: selectedLevel,
            items: [
              l10n.freshman,
              l10n.sophomore,
              l10n.junior,
              l10n.senior,
              l10n.graduate,
            ],
            onChanged: onLevelChanged,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: '${l10n.semester} *',
            hint: l10n.selectSemester,
            value: selectedSemester,
            items: [
              l10n.fallSemester,
              l10n.springSemester,
              l10n.summerSemester,
            ],
            onChanged: onSemesterChanged,
          ),
          const SizedBox(height: 16),
          _buildTextArea(
            controller: descriptionController,
            label: l10n.courseDescription,
            hint: l10n.courseDescriptionHint,
          ),
          const SizedBox(height: 16),
          _buildUploadSection(l10n),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                  fontSize: 15,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
              dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.uploadSyllabus,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUploadSyllabus,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AdminColors.primary.withValues(alpha: 0.1)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AdminColors.primary.withValues(alpha: 0.3)
                      : const Color(0xFF8EC5FF),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      syllabusFileName != null
                          ? Icons.description_rounded
                          : Icons.cloud_upload_rounded,
                      color: AdminColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    syllabusFileName ?? l10n.dragDropOrClick,
                    style: TextStyle(
                      color: syllabusFileName != null
                          ? AdminColors.getTextColor(isDark)
                          : AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 14,
                      fontWeight: syllabusFileName != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (syllabusFileName == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.pdfMaxSize,
                      style: TextStyle(
                        color: AdminColors.getTextTertiaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
