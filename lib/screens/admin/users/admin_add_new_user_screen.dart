import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

/// Admin Add New User Screen
/// Multi-step form for creating new users with role-based options
class AdminAddNewUserScreen extends StatefulWidget {
  const AdminAddNewUserScreen({super.key});

  @override
  State<AdminAddNewUserScreen> createState() => _AdminAddNewUserScreenState();
}

class _AdminAddNewUserScreenState extends State<AdminAddNewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  String? _selectedRole;
  String? _selectedDepartment;
  String? _selectedAcademicLevel;
  String? _selectedLabSection;
  List<String> _selectedCourses = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _autoGeneratePassword = false;

  // Role-specific toggles
  bool _requiresAIGradingTasks = false;
  bool _userAccessToAnalytics = true;
  bool _viewCourseData = true;
  bool _manageCourses = false;
  bool _manageUsers = false;
  bool _gradeStudents = false;
  bool _aiFeatureAccess = false;
  bool _viewAnalyticsDashboard = false;
  bool _sendGlobalAnnouncements = false;

  final List<String> _departments = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Engineering',
    'Biology',
    'Business',
  ];

  final List<String> _academicLevels = [
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate',
    'PhD',
  ];

  final List<String> _labSections = [
    'Section A',
    'Section B',
    'Section C',
    'Section D',
  ];

  final List<String> _availableCourses = [
    'CS101 - Introduction to Programming',
    'CS201 - Data Structures',
    'MATH101 - Calculus I',
    'PHY101 - Physics I',
    'CHEM101 - Chemistry I',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedRole = null;
      _selectedDepartment = null;
      _selectedAcademicLevel = null;
      _selectedLabSection = null;
      _selectedCourses = [];
      _autoGeneratePassword = false;
      _requiresAIGradingTasks = false;
      _userAccessToAnalytics = true;
      _viewCourseData = true;
      _manageCourses = false;
      _manageUsers = false;
      _gradeStudents = false;
      _aiFeatureAccess = false;
      _viewAnalyticsDashboard = false;
      _sendGlobalAnnouncements = false;
    });
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectRole),
          backgroundColor: AdminColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).userCreatedSuccessfully),
            backgroundColor: AdminColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AdminColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: Column(
                children: [
                  _buildAppBar(isDark, l10n),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRoleSelectionSection(isDark, l10n),
                            const SizedBox(height: 24),
                            _buildUserInfoSection(isDark, l10n),
                            const SizedBox(height: 24),
                            if (_selectedRole != null) ...[
                              _buildRoleSpecificSection(isDark, l10n),
                              const SizedBox(height: 24),
                              _buildPermissionsSection(isDark, l10n),
                              const SizedBox(height: 24),
                            ],
                            _buildAIProfileSummary(isDark, l10n),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomBar(isDark, l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AdminColors.darkDivider
                : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AdminColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addNewUser,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.createAndAssignNewUser,
                  style: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_rounded,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.help_outline_rounded,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.selectUserType,
      borderColor: AdminColors.lightCardBorder,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          _buildRoleCard(
            isDark: isDark,
            role: 'student',
            icon: Icons.school_rounded,
            title: l10n.student,
            description: l10n.learnerEnrolledInCourses,
            gradient: AdminColors.primaryGradient,
          ),
          _buildRoleCard(
            isDark: isDark,
            role: 'instructor',
            icon: Icons.person_rounded,
            title: l10n.instructor,
            description: l10n.courseTeacherAndContentCreator,
            gradient: AdminColors.purpleGradient,
          ),
          _buildRoleCard(
            isDark: isDark,
            role: 'ta',
            icon: Icons.support_agent_rounded,
            title: l10n.teachingAssistant,
            description: l10n.labManagerAndGradingAssistant,
            gradient: AdminColors.cyanGradient,
          ),
          _buildRoleCard(
            isDark: isDark,
            role: 'admin',
            icon: Icons.admin_panel_settings_rounded,
            title: l10n.administrator,
            description: l10n.systemManagerWithFullAccess,
            gradient: const LinearGradient(
              colors: [Color(0xFFFB2C36), Color(0xFFF54900)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required bool isDark,
    required String role,
    required IconData icon,
    required String title,
    required String description,
    required LinearGradient gradient,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
          // Reset role-specific fields
          _selectedAcademicLevel = null;
          _selectedLabSection = null;
          _selectedCourses = [];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark
              ? AdminColors.darkCard.withValues(alpha: isSelected ? 1 : 0.5)
              : Colors.white.withValues(alpha: isSelected ? 1 : 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? gradient.colors.first
                : (isDark
                      ? AdminColors.darkCardBorder
                      : AdminColors.lightDivider),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AdminColors.getTextTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.userInformation,
      borderColor: AdminColors.lightCardBorder,
      child: Column(
        children: [
          _buildTextField(
            controller: _fullNameController,
            label: l10n.fullName,
            hint: 'John Doe',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterFullName;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: l10n.emailAddress,
            hint: 'john.doe@campus.edu',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterEmail;
              }
              if (!value.contains('@')) {
                return l10n.pleaseEnterValidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            value: _selectedDepartment,
            label: l10n.department,
            hint: l10n.selectDepartment,
            icon: Icons.business_outlined,
            items: _departments,
            isDark: isDark,
            onChanged: (value) {
              setState(() => _selectedDepartment = value);
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: '${l10n.phoneNumber} (${l10n.optional})',
            hint: '+1 (555) 123-4567',
            icon: Icons.phone_outlined,
            isDark: isDark,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: l10n.initialPassword,
            hint: l10n.enterPassword,
            icon: Icons.lock_outline_rounded,
            isDark: isDark,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
            ),
            validator: _autoGeneratePassword
                ? null
                : (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterPassword;
                    }
                    if (value.length < 8) {
                      return l10n.passwordTooShort;
                    }
                    return null;
                  },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _autoGeneratePassword,
                onChanged: (value) {
                  setState(() {
                    _autoGeneratePassword = value ?? false;
                    if (_autoGeneratePassword) {
                      _passwordController.text = _generatePassword();
                      _confirmPasswordController.text =
                          _passwordController.text;
                    }
                  });
                },
                activeColor: AdminColors.primary,
              ),
              Text(
                l10n.autoGenerate,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _confirmPasswordController,
            label: l10n.confirmPassword,
            hint: l10n.confirmPassword,
            icon: Icons.lock_outline_rounded,
            isDark: isDark,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return l10n.passwordsDoNotMatch;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificSection(bool isDark, AppLocalizations l10n) {
    switch (_selectedRole) {
      case 'student':
        return _buildStudentSection(isDark, l10n);
      case 'instructor':
        return _buildInstructorSection(isDark, l10n);
      case 'ta':
        return _buildTASection(isDark, l10n);
      case 'admin':
        return _buildAdminSection(isDark, l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStudentSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.studentInformation,
      icon: Icons.school_rounded,
      iconGradient: AdminColors.primaryGradient,
      borderColor: AdminColors.lightCardBorder,
      child: Column(
        children: [
          _buildDropdownField(
            value: _selectedAcademicLevel,
            label: l10n.academicLevel,
            hint: l10n.selectLevel,
            icon: Icons.leaderboard_outlined,
            items: _academicLevels,
            isDark: isDark,
            onChanged: (value) {
              setState(() => _selectedAcademicLevel = value);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            value: _selectedLabSection,
            label: l10n.labSection,
            hint: l10n.selectSection,
            icon: Icons.science_outlined,
            items: _labSections,
            isDark: isDark,
            onChanged: (value) {
              setState(() => _selectedLabSection = value);
            },
          ),
          const SizedBox(height: 16),
          _buildCoursesSelection(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildInstructorSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.instructorSettings,
      icon: Icons.person_rounded,
      iconGradient: AdminColors.purpleGradient,
      borderColor: AdminColors.lightPurpleBorder,
      child: Column(
        children: [
          _buildCoursesSelection(isDark, l10n),
          const SizedBox(height: 16),
          _buildSwitchRow(
            label: l10n.requiresAIGradingTasks,
            subtitle: l10n.enableAIPoweredGrading,
            value: _requiresAIGradingTasks,
            onChanged: (value) {
              setState(() => _requiresAIGradingTasks = value);
            },
            isDark: isDark,
          ),
          _buildSwitchRow(
            label: l10n.userAccessToAnalytics,
            subtitle: l10n.viewCourseStudentAnalytics,
            value: _userAccessToAnalytics,
            onChanged: (value) {
              setState(() => _userAccessToAnalytics = value);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTASection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.teachingAssistantSettings,
      icon: Icons.support_agent_rounded,
      iconGradient: AdminColors.cyanGradient,
      borderColor: const Color(0xFFBFE6ED),
      child: Column(
        children: [
          _buildCoursesSelection(isDark, l10n),
          const SizedBox(height: 16),
          _buildSwitchRow(
            label: l10n.requiresAIGradingTasks,
            subtitle: l10n.enableAIPoweredGrading,
            value: _requiresAIGradingTasks,
            onChanged: (value) {
              setState(() => _requiresAIGradingTasks = value);
            },
            isDark: isDark,
          ),
          _buildSwitchRow(
            label: l10n.userAccessToAnalytics,
            subtitle: l10n.viewCourseStudentAnalytics,
            value: _userAccessToAnalytics,
            onChanged: (value) {
              setState(() => _userAccessToAnalytics = value);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.administratorSettings,
      icon: Icons.admin_panel_settings_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFFFB2C36), Color(0xFFF54900)],
      ),
      borderColor: const Color(0xFFFFCDD2),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AdminColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AdminColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.adminAccessWarning,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSelection(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.enrollInCourses,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.selectCoursesToEnroll,
          style: TextStyle(
            color: AdminColors.getTextTertiaryColor(isDark),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCourses.map((course) {
            final isSelected = _selectedCourses.contains(course);
            final courseCode = course.split(' - ').first;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCourses.remove(course);
                  } else {
                    _selectedCourses.add(course);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AdminColors.primary.withValues(alpha: 0.1)
                      : (isDark ? AdminColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AdminColors.primary
                        : (isDark
                              ? AdminColors.darkCardBorder
                              : AdminColors.lightDivider),
                  ),
                ),
                child: Text(
                  courseCode,
                  style: TextStyle(
                    color: isSelected
                        ? AdminColors.primary
                        : AdminColors.getTextColor(isDark),
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.rolePermissions,
      borderColor: AdminColors.lightCardBorder,
      child: Column(
        children: [
          _buildPermissionRow(
            icon: Icons.visibility_outlined,
            label: l10n.viewCourseData,
            subtitle: l10n.accessToCourseInformation,
            isEnabled: _viewCourseData,
            color: AdminColors.primary,
            isDark: isDark,
          ),
          _buildPermissionRow(
            icon: Icons.school_outlined,
            label: l10n.manageCourses,
            subtitle: l10n.createEditDeleteCourses,
            isEnabled: _manageCourses || _selectedRole == 'admin',
            color: AdminColors.secondary,
            isDark: isDark,
          ),
          _buildPermissionRow(
            icon: Icons.people_outline_rounded,
            label: l10n.manageUsers,
            subtitle: l10n.addEditRemoveUsers,
            isEnabled: _manageUsers || _selectedRole == 'admin',
            color: AdminColors.warning,
            isDark: isDark,
          ),
          _buildPermissionRow(
            icon: Icons.grading_outlined,
            label: l10n.gradeStudents,
            subtitle: l10n.submitAndEditGrades,
            isEnabled:
                _gradeStudents ||
                _selectedRole == 'instructor' ||
                _selectedRole == 'ta' ||
                _selectedRole == 'admin',
            color: AdminColors.success,
            isDark: isDark,
          ),
          _buildPermissionRow(
            icon: Icons.auto_awesome_outlined,
            label: l10n.aiFeaturesAccess,
            subtitle: l10n.useAIPoweredTools,
            isEnabled: _aiFeatureAccess || _selectedRole == 'admin',
            color: const Color(0xFFAD46FF),
            isDark: isDark,
            isHighlighted: true,
          ),
          _buildPermissionRow(
            icon: Icons.analytics_outlined,
            label: l10n.viewAnalyticsDashboard,
            subtitle: l10n.accessPerformanceMetrics,
            isEnabled:
                _viewAnalyticsDashboard ||
                _selectedRole == 'instructor' ||
                _selectedRole == 'admin',
            color: AdminColors.accent,
            isDark: isDark,
          ),
          _buildPermissionRow(
            icon: Icons.campaign_outlined,
            label: l10n.sendGlobalAnnouncements,
            subtitle: l10n.broadcastToAllUsers,
            isEnabled: _sendGlobalAnnouncements || _selectedRole == 'admin',
            color: AdminColors.error,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isEnabled,
    required Color color,
    required bool isDark,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: color.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AdminColors.getTextTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AdminColors.success.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEnabled ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: isEnabled
                  ? AdminColors.success
                  : AdminColors.getTextTertiaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIProfileSummary(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFAF5FF).withValues(alpha: 0.8),
                  const Color(0xFFFDF2F8).withValues(alpha: 0.8),
                ],
              ),
        color: isDark ? AdminColors.darkCard : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightPurpleBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AdminColors.purpleGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.aiProfileSummary,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_selectedRole == null) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.selectARoleToSeeAISuggestions,
                    style: TextStyle(
                      color: AdminColors.getTextTertiaryColor(isDark),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              l10n.basedOnRoleSelection,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ..._getAISuggestions().map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: AdminColors.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Apply AI suggestions
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.aiSuggestionsApplied),
                      backgroundColor: AdminColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(l10n.applyAISuggestions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getAISuggestions() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedRole) {
      case 'student':
        return [
          l10n.welcomeEmailRecommended,
          l10n.enrollInIntroductoryCourses,
          l10n.standardRolePermissions,
          l10n.courseAssignmentNeeded,
        ];
      case 'instructor':
        return [
          l10n.welcomeEmailRecommended,
          l10n.giveAccessToAnalytics,
          l10n.standardRolePermissions,
          l10n.courseAssignmentNeeded,
        ];
      case 'ta':
        return [
          l10n.welcomeEmailRecommended,
          l10n.giveAccessToAnalytics,
          l10n.standardRolePermissions,
          l10n.courseAssignmentNeeded,
        ];
      case 'admin':
        return [
          l10n.welcomeEmailRecommended,
          l10n.fullSystemAccess,
          l10n.securityTrainingRequired,
          l10n.twoFactorAuthRequired,
        ];
      default:
        return [];
    }
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AdminColors.darkDivider
                : AdminColors.lightCardBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.resetForm),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.getTextColor(isDark),
                side: BorderSide(
                  color: isDark
                      ? AdminColors.darkCardBorder
                      : AdminColors.lightDivider,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text(l10n.cancel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.getTextColor(isDark),
              side: BorderSide(
                color: isDark
                    ? AdminColors.darkCardBorder
                    : AdminColors.lightDivider,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: _selectedRole != null
                    ? AdminColors.primaryGradient
                    : null,
                color: _selectedRole == null
                    ? AdminColors.getTextTertiaryColor(isDark)
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _selectedRole != null
                    ? [
                        BoxShadow(
                          color: AdminColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton.icon(
                onPressed: _selectedRole != null && !_isLoading
                    ? _createUser
                    : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_rounded, size: 18),
                label: Text(_isLoading ? l10n.creating : l10n.createUser),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required Widget child,
    IconData? icon,
    LinearGradient? iconGradient,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : borderColor,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: iconGradient ?? AdminColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                title,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
            prefixIcon: Icon(
              icon,
              color: AdminColors.getTextTertiaryColor(isDark),
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? AdminColors.darkSurface : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AdminColors.darkCardBorder
                    : AdminColors.lightDivider,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AdminColors.darkCardBorder
                    : AdminColors.lightDivider,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AdminColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AdminColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required bool isDark,
    required void Function(String?) onChanged,
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
            color: isDark ? AdminColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightDivider,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hint,
              style: TextStyle(color: AdminColors.getTextTertiaryColor(isDark)),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AdminColors.getTextTertiaryColor(isDark),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 14,
            ),
            dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AdminColors.getTextTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AdminColors.primary,
          ),
        ],
      ),
    );
  }

  String _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    return List.generate(12, (index) {
      return chars[(DateTime.now().millisecondsSinceEpoch + index) %
          chars.length];
    }).join();
  }
}
