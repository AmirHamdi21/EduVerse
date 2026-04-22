import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Course details form widget.
class CourseDetailsForm extends StatelessWidget {
  final bool isDark;
  final bool isEditing;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final String? selectedDepartment;
  final String? selectedLevel;
  final String? selectedSemester;
  final int selectedCredits;
  final List<String> departmentOptions;
  final List<String> semesterOptions;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onLevelChanged;
  final ValueChanged<String?> onSemesterChanged;
  final ValueChanged<int> onCreditsChanged;
  final VoidCallback onUploadSyllabus;
  final String? syllabusFileName;
  final Map<String, String> backendErrors;

  const CourseDetailsForm({
    super.key,
    required this.isDark,
    this.isEditing = false,
    required this.formKey,
    required this.nameController,
    required this.codeController,
    required this.descriptionController,
    this.selectedDepartment,
    this.selectedLevel,
    this.selectedSemester,
    this.selectedCredits = 3,
    this.departmentOptions = const <String>[],
    this.semesterOptions = const <String>[],
    required this.onDepartmentChanged,
    required this.onLevelChanged,
    required this.onSemesterChanged,
    required this.onCreditsChanged,
    required this.onUploadSyllabus,
    this.syllabusFileName,
    this.backendErrors = const <String, String>{},
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
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
              errorText: backendErrors['name'],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fillRequiredFields;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: codeController,
              label: '${l10n.courseCode} *',
              hint: l10n.courseCodeHint,
              readOnly: isEditing,
              errorText: backendErrors['code'],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fillRequiredFields;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: '${l10n.credits} *',
              hint: l10n.credits,
              value: selectedCredits.toString(),
              items: const <String>['1', '2', '3', '4', '5', '6'],
              onChanged: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed != null) {
                  onCreditsChanged(parsed);
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fillRequiredFields;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: '${l10n.department} *',
              hint: l10n.selectDepartment,
              value: selectedDepartment,
              readOnly: isEditing,
              items: departmentOptions,
              onChanged: onDepartmentChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fillRequiredFields;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: '${l10n.academicLevel} *',
              hint: l10n.selectLevel,
              value: selectedLevel,
              items: <String>[
                l10n.freshman,
                l10n.sophomore,
                l10n.junior,
                l10n.senior,
                l10n.graduate,
              ],
              onChanged: onLevelChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fillRequiredFields;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: '${l10n.semester} *',
              hint: l10n.selectSemester,
              value: selectedSemester,
              items: semesterOptions,
              onChanged: onSemesterChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fillRequiredFields;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextArea(
              controller: descriptionController,
              label: l10n.courseDescription,
              hint: l10n.courseDescriptionHint,
            ),
            const SizedBox(height: 16),
            _buildUploadSection(l10n),
            if (backendErrors['general'] != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                backendErrors['general']!,
                style: TextStyle(
                  color: AdminColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: validator,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            filled: true,
            fillColor: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            hintStyle: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
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
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    final hasValue = value != null && value.trim().isNotEmpty;
    final dropdownItems = hasValue && !items.contains(value)
        ? <String>[value, ...items]
        : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: hasValue ? value : null,
          validator: validator,
          dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
          ),
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
          items: dropdownItems
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 15,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: readOnly ? null : onChanged,
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
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            hintStyle: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
                ),
              ),
              child: Column(
                children: <Widget>[
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
                  if (syllabusFileName == null) ...<Widget>[
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
