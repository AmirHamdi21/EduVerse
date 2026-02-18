import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminEditProfileScreen extends StatefulWidget {
  const AdminEditProfileScreen({super.key});

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _bioController = TextEditingController();

  // Work Info Controllers
  final _employeeIdController = TextEditingController();
  final _roleController = TextEditingController();
  final _timezoneController = TextEditingController();

  bool _hasChanges = false;
  bool _isSaving = false;
  String _selectedLanguage = 'en';

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

    // Initialize with sample data
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController.text = 'Ahmed';
    _lastNameController.text = 'Hassan';
    _emailController.text = 'ahmed.hassan@eduverse.com';
    _phoneController.text = '+20 100 123 4567';
    _departmentController.text = 'IT Administration';
    _bioController.text = 'System administrator with 5+ years of experience in educational platforms.';
    _employeeIdController.text = 'ADM-001';
    _roleController.text = 'Super Administrator';
    _timezoneController.text = 'Africa/Cairo (UTC+2)';
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
    _departmentController.dispose();
    _bioController.dispose();
    _employeeIdController.dispose();
    _roleController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });
      
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdated),
          backgroundColor: AdminColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      context.pop();
    }
  }

  void _showDiscardDialog(bool isDark, AppLocalizations l10n) {
    if (!_hasChanges) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.discardChanges,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.discardChangesMessage,
          style: TextStyle(
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: Container(
            decoration: isDark
                ? null
                : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 180,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: isDark
                          ? AdminColors.darkBackground
                          : Colors.white.withValues(alpha: 0.9),
                      leading: IconButton(
                        onPressed: () => _showDiscardDialog(isDark, l10n),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      title: Text(
                        l10n.editProfile,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.getTextColor(isDark),
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
                                      color: AdminColors.primary,
                                    ),
                                  )
                                : Text(
                                    l10n.save,
                                    style: TextStyle(
                                      color: AdminColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: AdminColors.primaryGradient,
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                _buildProfileAvatar(isDark, l10n),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    SliverPadding(
                      padding: responsive.contentPadding,
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 20),

                          // Personal Information Section
                          _buildSectionTitle(l10n.personalInformation, Icons.person_outline_rounded, isDark),
                          const SizedBox(height: 12),
                          _buildCard(isDark, [
                            _buildTextField(
                              controller: _firstNameController,
                              label: l10n.firstName,
                              icon: Icons.person_rounded,
                              isDark: isDark,
                            ),
                            _buildTextField(
                              controller: _lastNameController,
                              label: l10n.lastName,
                              icon: Icons.person_rounded,
                              isDark: isDark,
                            ),
                            _buildTextField(
                              controller: _emailController,
                              label: l10n.email,
                              icon: Icons.email_rounded,
                              isDark: isDark,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _buildTextField(
                              controller: _phoneController,
                              label: l10n.phone,
                              icon: Icons.phone_rounded,
                              isDark: isDark,
                              keyboardType: TextInputType.phone,
                            ),
                            _buildTextField(
                              controller: _bioController,
                              label: l10n.bio,
                              icon: Icons.info_outline_rounded,
                              isDark: isDark,
                              maxLines: 3,
                            ),
                          ]),

                          const SizedBox(height: 24),

                          // Work Information Section
                          _buildSectionTitle(l10n.workInformation, Icons.work_outline_rounded, isDark),
                          const SizedBox(height: 12),
                          _buildCard(isDark, [
                            _buildTextField(
                              controller: _employeeIdController,
                              label: l10n.employeeId,
                              icon: Icons.badge_rounded,
                              isDark: isDark,
                              enabled: false,
                            ),
                            _buildTextField(
                              controller: _departmentController,
                              label: l10n.department,
                              icon: Icons.business_rounded,
                              isDark: isDark,
                            ),
                            _buildTextField(
                              controller: _roleController,
                              label: l10n.role,
                              icon: Icons.admin_panel_settings_rounded,
                              isDark: isDark,
                              enabled: false,
                            ),
                          ]),

                          const SizedBox(height: 24),

                          // Preferences Section
                          _buildSectionTitle(l10n.preferences, Icons.tune_rounded, isDark),
                          const SizedBox(height: 12),
                          _buildCard(isDark, [
                            _buildLanguageSelector(isDark, l10n),
                            _buildTextField(
                              controller: _timezoneController,
                              label: l10n.timezone,
                              icon: Icons.schedule_rounded,
                              isDark: isDark,
                            ),
                          ]),

                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _hasChanges && !_isSaving ? _saveProfile : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AdminColors.primary.withValues(alpha: 0.3),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.saveChanges,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(bool isDark, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.changeProfilePhoto),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: Text(
                'AH',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: AdminColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AdminColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AdminColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.getCardBorderColor(isDark),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        onChanged: (_) => _markChanged(),
        style: TextStyle(
          color: enabled 
              ? AdminColors.getTextColor(isDark) 
              : AdminColors.getTextTertiaryColor(isDark),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
          prefixIcon: Icon(
            icon,
            color: enabled 
                ? AdminColors.primary 
                : AdminColors.getTextTertiaryColor(isDark),
            size: 20,
          ),
          filled: true,
          fillColor: enabled
              ? (isDark ? AdminColors.darkSurface : const Color(0xFFF8FAFC))
              : (isDark ? AdminColors.darkBackground.withValues(alpha: 0.5) : const Color(0xFFF1F5F9)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AdminColors.getCardBorderColor(isDark),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AdminColors.getCardBorderColor(isDark),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AdminColors.primary,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AdminColors.getCardBorderColor(isDark).withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.language,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLanguageOption(
                  label: 'English',
                  code: 'en',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLanguageOption(
                  label: 'العربية',
                  code: 'ar',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String code,
    required bool isDark,
  }) {
    final isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
          _markChanged();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AdminColors.primary.withValues(alpha: 0.1)
              : (isDark ? AdminColors.darkSurface : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AdminColors.primary 
                : AdminColors.getCardBorderColor(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected 
                  ? AdminColors.primary 
                  : AdminColors.getTextSecondaryColor(isDark),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? AdminColors.primary 
                    : AdminColors.getTextColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
