import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_profile_barrel.dart';

class ITProfilePersonalTab extends StatefulWidget {
  final bool isDark;
  final ITAdminProfile profile;
  final Function(ITAdminProfile) onSave;

  const ITProfilePersonalTab({
    super.key,
    required this.isDark,
    required this.profile,
    required this.onSave,
  });

  @override
  State<ITProfilePersonalTab> createState() => _ITProfilePersonalTabState();
}

class _ITProfilePersonalTabState extends State<ITProfilePersonalTab> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _department;
  late String _timezone;
  late String _language;

  final List<String> _departments = [
    'IT Division',
    'Engineering',
    'Support',
    'Security',
    'Infrastructure',
  ];

  final List<String> _timezones = [
    'UTC',
    'UTC-5 (EST)',
    'UTC-8 (PST)',
    'UTC+1 (CET)',
    'UTC+3 (AST)',
    'UTC+8 (CST)',
  ];

  final List<String> _languages = [
    'English',
    'Arabic',
    'Spanish',
    'French',
    'German',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _department = widget.profile.department;
    _timezone = widget.profile.timezone;
    _language = widget.profile.language;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _resetFields() {
    setState(() {
      _nameController.text = widget.profile.fullName;
      _emailController.text = widget.profile.email;
      _phoneController.text = widget.profile.phone;
      _department = widget.profile.department;
      _timezone = widget.profile.timezone;
      _language = widget.profile.language;
    });
  }

  void _saveChanges() {
    final updated = widget.profile.copyWith(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      department: _department,
      timezone: _timezone,
      language: _language,
    );
    widget.onSave(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: ITColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: ITColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(widget.isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Full Name
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 14),

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),

          // Department dropdown
          _buildDropdownField(
            label: 'Department',
            icon: Icons.business_rounded,
            value: _department,
            items: _departments,
            onChanged: (val) => setState(() => _department = val!),
          ),
          const SizedBox(height: 14),

          // Timezone dropdown
          _buildDropdownField(
            label: 'Timezone',
            icon: Icons.access_time_rounded,
            value: _timezone,
            items: _timezones,
            onChanged: (val) => setState(() => _timezone = val!),
          ),
          const SizedBox(height: 14),

          // Language dropdown
          _buildDropdownField(
            label: 'Preferred Language',
            icon: Icons.language_rounded,
            value: _language,
            items: _languages,
            onChanged: (val) => setState(() => _language = val!),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetFields,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset Fields'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ITColors.textSecondaryColor(widget.isDark),
                    side: BorderSide(
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ITColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ITColors.textSecondaryColor(widget.isDark),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: ITColors.textPrimaryColor(widget.isDark),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: ITColors.primary),
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.primary, width: 1.5),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ITColors.textSecondaryColor(widget.isDark),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark
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
                          color: ITColors.textPrimaryColor(widget.isDark),
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
              dropdownColor: widget.isDark ? ITColors.darkCard : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
