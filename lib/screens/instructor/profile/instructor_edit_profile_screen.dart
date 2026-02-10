import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/instructor/profile/instructor_profile_barrel.dart';

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
                    InstructorProfilePicture(
                      initials: 'AM',
                      isDark: isDark,
                      onChangePicture: () {
                        HapticFeedback.lightImpact();
                        // Change profile picture
                      },
                    ),
                    const SizedBox(height: 24),

                    // Personal Information Section
                    InstructorProfileSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      children: [
                        InstructorProfileTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _emailController,
                          label: l10n.email,
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _phoneController,
                          label: l10n.phone,
                          icon: Icons.phone_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _locationController,
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileDateField(
                          label: 'Date of Birth',
                          value: _dateOfBirth,
                          isDark: isDark,
                          onTap: () => _selectDate(context),
                        ),
                        InstructorProfileTextField(
                          controller: _bioController,
                          label: l10n.bio,
                          icon: Icons.info_outline_rounded,
                          isDark: isDark,
                          maxLines: 3,
                          onChanged: (_) => _markChanged(),
                        ),
                      ],
                    ),

                    // Professional Information Section
                    InstructorProfileSection(
                      title: 'Professional Information',
                      icon: Icons.work_outline_rounded,
                      isDark: isDark,
                      children: [
                        InstructorProfileTextField(
                          controller: _titleController,
                          label: 'Title',
                          icon: Icons.badge_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _departmentController,
                          label: 'Department',
                          icon: Icons.business_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _employeeIdController,
                          label: 'Employee ID',
                          icon: Icons.badge_outlined,
                          isDark: isDark,
                          enabled: false,
                        ),
                        InstructorProfileTextField(
                          controller: _specializationController,
                          label: l10n.specialization,
                          icon: Icons.psychology_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _officeController,
                          label: l10n.office,
                          icon: Icons.meeting_room_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _officeHoursController,
                          label: l10n.officeHours,
                          icon: Icons.access_time_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                      ],
                    ),

                    // Social Links Section
                    InstructorProfileSection(
                      title: 'Social & Academic Links',
                      icon: Icons.link_rounded,
                      isDark: isDark,
                      children: [
                        InstructorProfileTextField(
                          controller: _websiteController,
                          label: 'Website',
                          icon: Icons.language_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.url,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _linkedinController,
                          label: 'LinkedIn',
                          icon: Icons.link_rounded,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _googleScholarController,
                          label: 'Google Scholar',
                          icon: Icons.school_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
                        ),
                        InstructorProfileTextField(
                          controller: _researchGateController,
                          label: 'ResearchGate',
                          icon: Icons.science_outlined,
                          isDark: isDark,
                          onChanged: (_) => _markChanged(),
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
