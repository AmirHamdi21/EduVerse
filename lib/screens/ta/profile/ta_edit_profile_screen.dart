import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class TAEditProfileScreen extends StatefulWidget {
  const TAEditProfileScreen({super.key});

  @override
  State<TAEditProfileScreen> createState() => _TAEditProfileScreenState();
}

class _TAEditProfileScreenState extends State<TAEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _officeLocationController;
  late TextEditingController _linkedinController;

  // Dropdown values
  String _selectedDepartment = 'Computer Science';
  String _selectedSpecialization = 'Data Structures';

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Data Science',
    'Cybersecurity',
  ];

  final List<String> _specializations = [
    'Data Structures',
    'Algorithms',
    'Database Systems',
    'Web Development',
    'Machine Learning',
    'Operating Systems',
    'Computer Networks',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Ahmed Hassan');
    _emailController = TextEditingController(text: 'ta@eduverse.dev');
    _phoneController = TextEditingController(text: '+1 234 567 8900');
    _bioController = TextEditingController(
      text:
          'Passionate about helping students understand complex programming concepts.',
    );
    _officeLocationController = TextEditingController(
      text: 'Building A, Room 205',
    );
    _linkedinController = TextEditingController(
      text: 'linkedin.com/in/ahmedhassan',
    );

    // Add listeners to track changes
    for (var controller in [
      _nameController,
      _emailController,
      _phoneController,
      _bioController,
      _officeLocationController,
      _linkedinController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _officeLocationController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;

        return WillPopScope(
          onWillPop: () async {
            if (_hasChanges) {
              return await _showDiscardDialog(isDark, l10n) ?? false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: TAColors.scaffoldColor(isDark),
            appBar: _buildAppBar(l10n, isDark),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(isDark),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(l10n, isDark),
                    const SizedBox(height: 20),
                    _buildContactInfoSection(l10n, isDark),
                    const SizedBox(height: 20),
                    _buildProfessionalInfoSection(l10n, isDark),
                    const SizedBox(height: 20),
                    _buildBioSection(l10n, isDark),
                    const SizedBox(height: 20),
                    _buildSocialLinksSection(l10n, isDark),
                    const SizedBox(height: 32),
                    _buildSaveButton(l10n, isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, bool isDark) {
    return AppBar(
      backgroundColor: TAColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.close_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
        onPressed: () async {
          if (_hasChanges) {
            final shouldPop = await _showDiscardDialog(isDark, l10n);
            if (shouldPop == true && mounted) {
              context.pop();
            }
          } else {
            context.pop();
          }
        },
      ),
      title: Text(
        l10n.editProfile,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_hasChanges)
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: TAColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      TAColors.primary,
                      TAColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TAColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _changePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TAColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TAColors.scaffoldColor(isDark),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _changePhoto,
            child: const Text(
              'Change Photo',
              style: TextStyle(
                color: TAColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(AppLocalizations l10n, bool isDark) {
    return _buildSection(
      title: l10n.taEditProfilePersonalInfo,
      icon: Icons.person_outline_rounded,
      isDark: isDark,
      children: [
        _buildTextField(
          controller: _nameController,
          label: l10n.fullName,
          icon: Icons.person_outline_rounded,
          isDark: isDark,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _emailController,
          label: l10n.email,
          icon: Icons.email_outlined,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
          enabled: false,
          helperText: 'Contact admin to change email',
        ),
      ],
    );
  }

  Widget _buildContactInfoSection(AppLocalizations l10n, bool isDark) {
    return _buildSection(
      title: l10n.taEditProfileContactInfo,
      icon: Icons.contact_phone_outlined,
      isDark: isDark,
      children: [
        _buildTextField(
          controller: _phoneController,
          label: l10n.phoneNumber,
          icon: Icons.phone_outlined,
          isDark: isDark,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _officeLocationController,
          label: l10n.taEditProfileOfficeLocation,
          icon: Icons.location_on_outlined,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection(AppLocalizations l10n, bool isDark) {
    return _buildSection(
      title: l10n.taEditProfileProfessionalInfo,
      icon: Icons.work_outline_rounded,
      isDark: isDark,
      children: [
        _buildDropdownField(
          value: _selectedDepartment,
          label: l10n.taProfileDepartment,
          icon: Icons.apartment_rounded,
          items: _departments,
          isDark: isDark,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDepartment = value;
                _hasChanges = true;
              });
            }
          },
        ),
        const SizedBox(height: 14),
        _buildDropdownField(
          value: _selectedSpecialization,
          label: l10n.taEditProfileSpecialization,
          icon: Icons.school_outlined,
          items: _specializations,
          isDark: isDark,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSpecialization = value;
                _hasChanges = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBioSection(AppLocalizations l10n, bool isDark) {
    return _buildSection(
      title: l10n.taProfileBio,
      icon: Icons.info_outline_rounded,
      isDark: isDark,
      children: [
        TextField(
          controller: _bioController,
          maxLines: 4,
          maxLength: 250,
          decoration: InputDecoration(
            hintText: 'Tell students about yourself...',
            hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TAColors.borderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TAColors.borderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TAColors.primary),
            ),
            counterStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
          ),
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
      ],
    );
  }

  Widget _buildSocialLinksSection(AppLocalizations l10n, bool isDark) {
    return _buildSection(
      title: l10n.taEditProfileSocialLinks,
      icon: Icons.link_rounded,
      isDark: isDark,
      children: [
        _buildTextField(
          controller: _linkedinController,
          label: 'LinkedIn',
          icon: Icons.link_rounded,
          isDark: isDark,
          keyboardType: TextInputType.url,
          prefixText: 'https://',
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: TAColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool enabled = true,
    String? helperText,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        helperText: helperText,
        helperStyle: TextStyle(
          color: TAColors.textTertiaryColor(isDark),
          fontSize: 11,
        ),
        prefixText: prefixText,
        prefixStyle: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: enabled
              ? TAColors.textSecondaryColor(isDark)
              : TAColors.textTertiaryColor(isDark),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TAColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TAColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TAColors.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
          ),
        ),
        filled: !enabled,
        fillColor: enabled
            ? null
            : TAColors.borderColor(isDark).withValues(alpha: 0.1),
      ),
      style: TextStyle(
        color: enabled
            ? TAColors.textPrimaryColor(isDark)
            : TAColors.textTertiaryColor(isDark),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: TAColors.textSecondaryColor(isDark),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TAColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TAColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TAColors.primary),
        ),
      ),
      style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
      dropdownColor: TAColors.cardColor(isDark),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: TAColors.textSecondaryColor(isDark),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: TAColors.primary,
          disabledBackgroundColor: TAColors.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.saveChanges,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.themeMode == AppThemeMode.dark;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.scaffoldColor(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPhotoOption(
                  Icons.camera_alt_rounded,
                  'Take Photo',
                  TAColors.primary,
                  isDark,
                  () {
                    Navigator.pop(context);
                    _showSnackBar('Camera opened...');
                  },
                ),
                const SizedBox(height: 10),
                _buildPhotoOption(
                  Icons.photo_library_rounded,
                  'Choose from Gallery',
                  TAColors.info,
                  isDark,
                  () {
                    Navigator.pop(context);
                    _showSnackBar('Gallery opened...');
                  },
                ),
                const SizedBox(height: 10),
                _buildPhotoOption(
                  Icons.delete_outline_rounded,
                  'Remove Photo',
                  TAColors.error,
                  isDark,
                  () {
                    Navigator.pop(context);
                    _showSnackBar('Photo removed');
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoOption(
    IconData icon,
    String label,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDiscardDialog(bool isDark, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Discard Changes?',
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.error),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      _showSnackBar('Profile updated successfully!');
      context.pop();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
