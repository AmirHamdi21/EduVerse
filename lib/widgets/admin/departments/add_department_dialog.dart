import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AddDepartmentDialog extends StatefulWidget {
  final bool isDark;
  final Function(Map<String, dynamic>) onSubmit;

  const AddDepartmentDialog({
    super.key,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  State<AddDepartmentDialog> createState() => _AddDepartmentDialogState();
}

class _AddDepartmentDialogState extends State<AddDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedHead;
  final Set<String> _selectedLevels = {};
  bool _isLoading = false;

  final List<String> _academicLevels = ['BSc', 'MSc', 'PhD', 'Diploma'];
  final List<String> _availableHeads = [
    'Dr. Ahmed Hassan',
    'Dr. Sarah Ahmed',
    'Dr. Omar Khalid',
    'Dr. Fatima Hassan',
    'Dr. Mohamed Ali',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 1), () {
        widget.onSubmit({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'head': _selectedHead,
          'levels': _selectedLevels.toList(),
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(widget.isDark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.addNewDepartment ?? 'Add New Department',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n?.createNewAcademicDepartment ??
                                'Create a new academic department',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Form Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Department Name
                      _buildLabel(l10n?.departmentName ?? 'Department Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint:
                            l10n?.enterDepartmentName ??
                            'e.g., Mechanical Engineering',
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return l10n?.departmentNameRequired ??
                                'Department name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Description
                      _buildLabel(l10n?.description ?? 'Description'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _descriptionController,
                        hint:
                            l10n?.briefDescription ??
                            'Brief description of the department...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      // Academic Levels
                      _buildLabel(
                        l10n?.academicLevelsOffered ??
                            'Academic Levels Offered',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _academicLevels.map((level) {
                          final isSelected = _selectedLevels.contains(level);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedLevels.remove(level);
                                } else {
                                  _selectedLevels.add(level);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AdminColors.primary
                                    : AdminColors.getCardColor(widget.isDark),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AdminColors.primary
                                      : AdminColors.getCardBorderColor(
                                          widget.isDark,
                                        ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AdminColors.getTextTertiaryColor(
                                            widget.isDark,
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    level,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AdminColors.getTextColor(
                                              widget.isDark,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Select Department Head
                      _buildLabel(
                        l10n?.selectDepartmentHead ?? 'Select Department Head',
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AdminColors.darkSurface
                              : AdminColors.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AdminColors.getCardBorderColor(
                              widget.isDark,
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedHead,
                            isExpanded: true,
                            hint: Text(
                              l10n?.chooseDepartmentHead ??
                                  'Choose department head...',
                              style: TextStyle(
                                color: AdminColors.getTextTertiaryColor(
                                  widget.isDark,
                                ),
                                fontSize: 14,
                              ),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AdminColors.getTextTertiaryColor(
                                widget.isDark,
                              ),
                            ),
                            dropdownColor: AdminColors.getCardColor(
                              widget.isDark,
                            ),
                            style: TextStyle(
                              color: AdminColors.getTextColor(widget.isDark),
                              fontSize: 14,
                            ),
                            items: _availableHeads.map((head) {
                              return DropdownMenuItem(
                                value: head,
                                child: Text(head),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedHead = value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Upload Logo
                      _buildLabel(
                        l10n?.uploadDepartmentLogo ?? 'Upload Department Logo',
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement file picker
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? AdminColors.darkSurface
                                  : AdminColors.lightBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AdminColors.getCardBorderColor(
                                  widget.isDark,
                                ),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: AdminColors.primary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n?.clickToUploadLogo ??
                                      'Click to upload logo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AdminColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PNG or JPG up to 5MB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AdminColors.getTextTertiaryColor(
                                      widget.isDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: AdminColors.getCardBorderColor(
                                    widget.isDark,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                l10n?.cancel ?? 'Cancel',
                                style: TextStyle(
                                  color: AdminColors.getTextColor(
                                    widget.isDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      l10n?.createDepartment ??
                                          'Create Department',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AdminColors.getTextColor(widget.isDark),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: AdminColors.getTextColor(widget.isDark),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AdminColors.getTextTertiaryColor(widget.isDark),
          fontSize: 14,
        ),
        filled: true,
        fillColor: widget.isDark
            ? AdminColors.darkSurface
            : AdminColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AdminColors.getCardBorderColor(widget.isDark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AdminColors.getCardBorderColor(widget.isDark),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
