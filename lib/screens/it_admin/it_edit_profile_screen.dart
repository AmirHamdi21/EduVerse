import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/it_admin/shared/it_colors.dart';

class ITEditProfileScreen extends StatefulWidget {
  const ITEditProfileScreen({super.key});

  @override
  State<ITEditProfileScreen> createState() => _ITEditProfileScreenState();
}

class _ITEditProfileScreenState extends State<ITEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _employeeIdController;

  // Dropdown values
  String _department = 'IT Division';
  String _timezone = 'UTC-5 (EST)';
  String _language = 'English';

  bool _isSaving = false;
  bool _hasChanges = false;

  final List<String> _departments = [
    'IT Division',
    'Engineering',
    'Support',
    'Security',
    'Infrastructure',
    'Development',
  ];

  final List<String> _timezones = [
    'UTC',
    'UTC-5 (EST)',
    'UTC-8 (PST)',
    'UTC+1 (CET)',
    'UTC+3 (AST)',
    'UTC+8 (CST)',
    'UTC+9 (JST)',
  ];

  final List<String> _languages = [
    'English',
    'Arabic',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with mock data
    _fullNameController = TextEditingController(text: 'Dr. Michael Chen');
    _emailController = TextEditingController(text: 'michael.chen@eduverse.edu');
    _phoneController = TextEditingController(text: '+1 (555) 123-4567');
    _employeeIdController = TextEditingController(text: 'IT-2024-001');

    // Add listeners for change detection
    _fullNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Simulate save
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: ITColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    context.pop();
  }

  void _discardChanges() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? ITColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_rounded, color: ITColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Discard Changes?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ITColors.textPrimaryColor(isDark),
                  ),
                ),
              ],
            ),
            content: Text(
              'You have unsaved changes. Are you sure you want to discard them?',
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Keep Editing',
                  style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ITColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Discard'),
              ),
            ],
          );
        },
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? ITColors.darkBackground
          : ITColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? ITColors.darkCard : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: ITColors.textPrimaryColor(isDark),
          ),
          onPressed: _discardChanges,
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ITColors.textPrimaryColor(isDark),
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ITColors.primary,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ITColors.primary,
                      ),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              _buildAvatarSection(isDark),
              const SizedBox(height: 24),

              // Personal Information
              _buildSectionCard(
                isDark: isDark,
                title: 'Personal Information',
                icon: Icons.person_outline_rounded,
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person_rounded,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!val.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _employeeIdController,
                    label: 'Employee ID',
                    icon: Icons.badge_rounded,
                    enabled: false,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Work Information
              _buildSectionCard(
                isDark: isDark,
                title: 'Work Information',
                icon: Icons.work_outline_rounded,
                children: [
                  _buildDropdownField(
                    label: 'Department',
                    icon: Icons.business_rounded,
                    value: _department,
                    items: _departments,
                    onChanged: (val) {
                      setState(() {
                        _department = val!;
                        _hasChanges = true;
                      });
                    },
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preferences
              _buildSectionCard(
                isDark: isDark,
                title: 'Preferences',
                icon: Icons.settings_outlined,
                children: [
                  _buildDropdownField(
                    label: 'Timezone',
                    icon: Icons.access_time_rounded,
                    value: _timezone,
                    items: _timezones,
                    onChanged: (val) {
                      setState(() {
                        _timezone = val!;
                        _hasChanges = true;
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Preferred Language',
                    icon: Icons.language_rounded,
                    value: _language,
                    items: _languages,
                    onChanged: (val) {
                      setState(() {
                        _language = val!;
                        _hasChanges = true;
                      });
                    },
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button (mobile)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 20),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ITColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ITColors.primary, ITColors.primaryLight],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ITColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'MC',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _showAvatarOptions(isDark);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ITColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? ITColors.darkCard : Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 12,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? ITColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 20),
            _buildAvatarOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Camera opened');
              },
              isDark: isDark,
            ),
            _buildAvatarOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Gallery opened');
              },
              isDark: isDark,
            ),
            _buildAvatarOption(
              icon: Icons.delete_rounded,
              label: 'Remove Photo',
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Photo removed');
              },
              color: ITColors.error,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: color ?? ITColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: color ?? ITColors.textPrimaryColor(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(isDark),
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ITColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            color: enabled
                ? ITColors.textPrimaryColor(isDark)
                : ITColors.textSecondaryColor(isDark),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: ITColors.primary),
            filled: true,
            fillColor: enabled
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.05))
                : (isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.grey.withValues(alpha: 0.08)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ITColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: ITColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: isDark ? ITColors.darkCard : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ITColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
