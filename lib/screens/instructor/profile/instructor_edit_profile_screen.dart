import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class InstructorEditProfileScreen extends StatefulWidget {
  const InstructorEditProfileScreen({super.key});

  @override
  State<InstructorEditProfileScreen> createState() =>
      _InstructorEditProfileScreenState();
}

class _InstructorEditProfileScreenState
    extends State<InstructorEditProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Personal Info Controllers
  final _firstNameController = TextEditingController(text: 'Ahmed');
  final _lastNameController = TextEditingController(text: 'Mohamed');
  final _emailController = TextEditingController(text: 'dr.ahmed@university.edu');
  final _phoneController = TextEditingController(text: '+20 123 456 7890');
  final _locationController = TextEditingController(text: 'Cairo, Egypt');
  final _bioController = TextEditingController(
    text: 'Associate Professor of Computer Science with 15 years of teaching experience. Specialized in Data Structures, Algorithms, and Machine Learning.',
  );
  DateTime? _dateOfBirth = DateTime(1980, 5, 15);

  // Professional Info Controllers
  final _departmentController = TextEditingController(text: 'Computer Science');
  final _titleController = TextEditingController(text: 'Associate Professor');
  final _employeeIdController = TextEditingController(text: 'EMP-2010-001');
  final _specializationController = TextEditingController(text: 'Data Structures & Algorithms');
  final _officeController = TextEditingController(text: 'Building A, Room 215');
  final _officeHoursController = TextEditingController(text: 'Mon, Wed 2:00 PM - 4:00 PM');

  // Social Links Controllers
  final _websiteController = TextEditingController(text: 'https://ahmed.university.edu');
  final _linkedinController = TextEditingController(text: 'linkedin.com/in/drahmed');
  final _googleScholarController = TextEditingController(text: 'scholar.google.com/drahmed');
  final _researchGateController = TextEditingController();

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _departmentController.dispose();
    _titleController.dispose();
    _employeeIdController.dispose();
    _specializationController.dispose();
    _officeController.dispose();
    _officeHoursController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _googleScholarController.dispose();
    _researchGateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with Cover Photo
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              elevation: 0,
              backgroundColor:
                  isDark ? const Color(0xFF0F172A) : Colors.white,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => _handleBack(context, l10n, isDark),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                l10n.editProfile,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                if (_hasChanges)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () => _saveProfile(context, l10n),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF155CFB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Photo
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF155CFB),
                            Color(0xFF7C3AED),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                    // Edit cover button
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Change cover photo
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Edit Cover',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -50),
                child: Column(
                  children: [
                    // Profile Picture
                    _buildProfilePicture(isDark),
                    const SizedBox(height: 24),

                    // Personal Information Section
                    _buildSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      children: [
                        _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: l10n.email,
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: l10n.phone,
                          icon: Icons.phone_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: _locationController,
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                          isDark: isDark,
                        ),
                        _buildDateField(
                          label: 'Date of Birth',
                          value: _dateOfBirth,
                          isDark: isDark,
                          onTap: () => _selectDate(context),
                        ),
                        _buildTextField(
                          controller: _bioController,
                          label: l10n.bio,
                          icon: Icons.info_outline_rounded,
                          isDark: isDark,
                          maxLines: 3,
                        ),
                      ],
                    ),

                    // Professional Information Section
                    _buildSection(
                      title: 'Professional Information',
                      icon: Icons.work_outline_rounded,
                      isDark: isDark,
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Title',
                          icon: Icons.badge_outlined,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _departmentController,
                          label: 'Department',
                          icon: Icons.business_outlined,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _employeeIdController,
                          label: 'Employee ID',
                          icon: Icons.badge_outlined,
                          isDark: isDark,
                          enabled: false,
                        ),
                        _buildTextField(
                          controller: _specializationController,
                          label: l10n.specialization,
                          icon: Icons.psychology_outlined,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _officeController,
                          label: l10n.office,
                          icon: Icons.meeting_room_outlined,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _officeHoursController,
                          label: l10n.officeHours,
                          icon: Icons.access_time_outlined,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Social Links Section
                    _buildSection(
                      title: 'Social & Academic Links',
                      icon: Icons.link_rounded,
                      isDark: isDark,
                      children: [
                        _buildTextField(
                          controller: _websiteController,
                          label: 'Website',
                          icon: Icons.language_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.url,
                        ),
                        _buildTextField(
                          controller: _linkedinController,
                          label: 'LinkedIn',
                          icon: Icons.link_rounded,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _googleScholarController,
                          label: 'Google Scholar',
                          icon: Icons.school_outlined,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _researchGateController,
                          label: 'ResearchGate',
                          icon: Icons.science_outlined,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hasChanges
                              ? () => _saveProfile(context, l10n)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF155CFB),
                            disabledBackgroundColor: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n.saveChanges,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _hasChanges
                                  ? Colors.white
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 56,
            backgroundColor: const Color(0xFF155CFB),
            child: const Text(
              'AM',
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
              HapticFeedback.lightImpact();
              // Change profile picture
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF155CFB),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF155CFB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF155CFB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color:
                isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
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
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        onChanged: (_) => _markChanged(),
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          filled: true,
          fillColor:
              isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF155CFB), width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value != null
                          ? '${value.month}/${value.day}/${value.year}'
                          : 'Select date',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1980),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _dateOfBirth = date;
        _markChanged();
      });
    }
  }

  void _handleBack(BuildContext context, AppLocalizations l10n, bool isDark) {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Discard Changes?',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: TextStyle(
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Discard',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  void _saveProfile(BuildContext context, AppLocalizations l10n) {
    // Save profile logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.profileUpdated),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    setState(() => _hasChanges = false);
  }
}
