import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _dateOfBirth;

  // Academic Info Controllers
  final _universityController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _majorController = TextEditingController();
  final _minorController = TextEditingController();
  final _levelController = TextEditingController();
  final _yearController = TextEditingController();
  final _expectedGraduationController = TextEditingController();

  // Social Links Controllers
  final _websiteController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      final profile = state.profile;
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _emailController.text = profile.email;
      _phoneController.text = profile.phoneNumber ?? '';
      _locationController.text = profile.location ?? '';
      _bioController.text = profile.bio ?? '';
      _dateOfBirth = profile.dateOfBirth;
      _universityController.text = profile.university ?? '';
      _studentIdController.text = profile.studentId ?? '';
      _majorController.text = profile.major ?? '';
      _minorController.text = profile.minor ?? '';
      _levelController.text = profile.level ?? '';
      _yearController.text = profile.year ?? '';
      _expectedGraduationController.text = profile.expectedGraduation ?? '';

      final socialLinks = profile.socialLinks;
      if (socialLinks != null) {
        _websiteController.text = socialLinks.personalWebsite ?? '';
        _githubController.text = socialLinks.github ?? '';
        _linkedinController.text = socialLinks.linkedin ?? '';
        _twitterController.text = socialLinks.twitter ?? '';
      }
    }
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
    _universityController.dispose();
    _studentIdController.dispose();
    _majorController.dispose();
    _minorController.dispose();
    _levelController.dispose();
    _yearController.dispose();
    _expectedGraduationController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is! ProfileLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar with Cover Photo
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: isDark
                      ? const Color(0xFF0F172A)
                      : Colors.white,
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
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Cover Photo
                        state.profile.coverUrl != null
                            ? Image.network(
                                state.profile.coverUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF8B5CF6),
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
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Change cover button
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: _buildChangeButton(
                            context,
                            icon: Icons.camera_alt_rounded,
                            label: l10n.changeCover,
                            onTap: () => _showImageSourceDialog(
                              context,
                              l10n,
                              isDark,
                              true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Photo and Form
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -50),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Profile Photo
                          _buildProfilePhoto(
                            context,
                            state.profile,
                            l10n,
                            isDark,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Personal Information Section
                      _buildSectionTitle(
                        l10n.personalInformation,
                        Icons.person_outline_rounded,
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard(
                        isDark,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _firstNameController,
                                  label: l10n.firstName,
                                  icon: Icons.badge_outlined,
                                  isDark: isDark,
                                  onChanged: (_) => _markChanged(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _lastNameController,
                                  label: l10n.lastName,
                                  icon: Icons.badge_outlined,
                                  isDark: isDark,
                                  onChanged: (_) => _markChanged(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: l10n.email,
                            icon: Icons.email_outlined,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: l10n.phone,
                            icon: Icons.phone_outlined,
                            isDark: isDark,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          _buildDateField(context, l10n, isDark),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _locationController,
                            label: l10n.location,
                            icon: Icons.location_on_outlined,
                            isDark: isDark,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _bioController,
                            label: l10n.bio,
                            icon: Icons.description_outlined,
                            isDark: isDark,
                            maxLines: 3,
                            onChanged: (_) => _markChanged(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Academic Information Section
                      _buildSectionTitle(
                        l10n.academicInformation,
                        Icons.school_outlined,
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard(
                        isDark,
                        children: [
                          _buildTextField(
                            controller: _universityController,
                            label: l10n.university,
                            icon: Icons.account_balance_outlined,
                            isDark: isDark,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _studentIdController,
                            label: l10n.studentId,
                            icon: Icons.badge_outlined,
                            isDark: isDark,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _majorController,
                                  label: l10n.major,
                                  icon: Icons.book_outlined,
                                  isDark: isDark,
                                  onChanged: (_) => _markChanged(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _minorController,
                                  label: l10n.minor,
                                  icon: Icons.book_outlined,
                                  isDark: isDark,
                                  onChanged: (_) => _markChanged(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _levelController,
                                  label: l10n.level,
                                  icon: Icons.stairs_outlined,
                                  isDark: isDark,
                                  onChanged: (_) => _markChanged(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _yearController,
                                  label: l10n.year,
                                  icon: Icons.calendar_today_outlined,
                                  isDark: isDark,
                                  onChanged: (_) => _markChanged(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _expectedGraduationController,
                            label: l10n.expectedGraduation,
                            icon: Icons.school_outlined,
                            isDark: isDark,
                            onChanged: (_) => _markChanged(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social & Professional Links Section
                      _buildSectionTitle(
                        l10n.socialProfessionalLinks,
                        Icons.link_rounded,
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard(
                        isDark,
                        children: [
                          _buildTextField(
                            controller: _websiteController,
                            label: l10n.personalWebsite,
                            icon: Icons.language_rounded,
                            isDark: isDark,
                            keyboardType: TextInputType.url,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _githubController,
                            label: 'GitHub',
                            icon: Icons.code_rounded,
                            isDark: isDark,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _linkedinController,
                            label: 'LinkedIn',
                            icon: Icons.work_outline_rounded,
                            isDark: isDark,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _twitterController,
                            label: 'Twitter',
                            icon: Icons.alternate_email_rounded,
                            isDark: isDark,
                            onChanged: (_) => _markChanged(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _handleBack(context, l10n, isDark),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                l10n.cancel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isSaving
                                  ? null
                                  : () => _saveChanges(context, state, l10n),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                disabledBackgroundColor: isDark
                                    ? Colors.white12
                                    : Colors.black12,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.saveChanges,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePhoto(
    BuildContext context,
    UserProfile profile,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: const Color(0xFF3B82F6),
            backgroundImage: profile.avatarUrl != null
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: profile.avatarUrl == null
                ? Text(
                    '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}'
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        GestureDetector(
          onTap: () => _showImageSourceDialog(context, l10n, isDark, false),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isDark, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.white38 : Colors.black38,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context, isDark),
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: _dateOfBirth != null
                ? DateFormat('MMM dd, yyyy').format(_dateOfBirth!)
                : '',
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: l10n.dateOfBirth,
            labelStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            prefixIcon: Icon(
              Icons.cake_outlined,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 20,
            ),
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 18,
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDark) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: const Color(0xFF3B82F6),
              onPrimary: Colors.white,
              secondary: const Color(0xFF8B5CF6),
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
              surface: isDark ? const Color(0xFF1E293B) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _dateOfBirth = date;
        _hasChanges = true;
      });
    }
  }

  void _showImageSourceDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    bool isCover,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isCover ? l10n.changeCover : l10n.changePhoto,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: l10n.camera,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.selectionClick();
                  },
                ),
                _buildImageOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: l10n.gallery,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.selectionClick();
                  },
                ),
                _buildImageOption(
                  context,
                  icon: Icons.delete_outline_rounded,
                  label: l10n.remove,
                  isDark: isDark,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : (isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isDestructive
                  ? Colors.red
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDestructive
                  ? Colors.red
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBack(BuildContext context, AppLocalizations l10n, bool isDark) {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.discardChanges,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            l10n.discardChangesMessage,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.keepEditing,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.discard),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  void _saveChanges(
    BuildContext context,
    ProfileLoaded state,
    AppLocalizations l10n,
  ) {
    HapticFeedback.mediumImpact();

    final updatedProfile = state.profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      bio: _bioController.text.trim().isNotEmpty
          ? _bioController.text.trim()
          : null,
      dateOfBirth: _dateOfBirth,
      university: _universityController.text.trim().isNotEmpty
          ? _universityController.text.trim()
          : null,
      studentId: _studentIdController.text.trim().isNotEmpty
          ? _studentIdController.text.trim()
          : null,
      major: _majorController.text.trim().isNotEmpty
          ? _majorController.text.trim()
          : null,
      minor: _minorController.text.trim().isNotEmpty
          ? _minorController.text.trim()
          : null,
      level: _levelController.text.trim().isNotEmpty
          ? _levelController.text.trim()
          : null,
      year: _yearController.text.trim().isNotEmpty
          ? _yearController.text.trim()
          : null,
      expectedGraduation: _expectedGraduationController.text.trim().isNotEmpty
          ? _expectedGraduationController.text.trim()
          : null,
      socialLinks: SocialLinks(
        personalWebsite: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        github: _githubController.text.trim().isNotEmpty
            ? _githubController.text.trim()
            : null,
        linkedin: _linkedinController.text.trim().isNotEmpty
            ? _linkedinController.text.trim()
            : null,
        twitter: _twitterController.text.trim().isNotEmpty
            ? _twitterController.text.trim()
            : null,
      ),
    );

    context.read<ProfileCubit>().updateProfile(updatedProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.profileUpdated),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        context.pop();
      }
    });
  }
}
