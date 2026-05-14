import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../utils/navigation/safe_back.dart';
import 'role_profile_theme.dart';

class SharedEditProfileScreen extends StatefulWidget {
  final String title;
  final RoleProfileTheme theme;
  final String roleLabel;
  final String fallbackRoute;

  const SharedEditProfileScreen({
    super.key,
    required this.title,
    required this.theme,
    required this.roleLabel,
    required this.fallbackRoute,
  });

  @override
  State<SharedEditProfileScreen> createState() =>
      _SharedEditProfileScreenState();
}

class _SharedEditProfileScreenState extends State<SharedEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _interestsController = TextEditingController();
  final _skillsController = TextEditingController();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ProfileCubit>();
      if (cubit.state is! ProfileLoaded && cubit.state is! ProfileLoading) {
        cubit.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _interestsController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background(isDark),
      floatingActionButton: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final isSaving = state is ProfileLoaded && state.isSaving;
          return FloatingActionButton.extended(
            onPressed: state is ProfileLoaded && !isSaving
                ? () => _save(context, state)
                : null,
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              l10n.saveChanges,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) {
          final previousMessage = previous is ProfileLoaded
              ? previous.error
              : '';
          final currentMessage = current is ProfileLoaded ? current.error : '';
          return previousMessage != currentMessage;
        },
        listener: (context, state) {
          if (state is ProfileLoaded &&
              state.error != null &&
              state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return Center(
              child: CircularProgressIndicator(color: theme.primary),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: ElevatedButton(
                onPressed: () =>
                    context.read<ProfileCubit>().loadProfile(force: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            );
          }

          if (state is! ProfileLoaded) {
            return const SizedBox.shrink();
          }

          if (!_initialized) {
            _seedControllers(state.profile);
            _initialized = true;
          }

          return Stack(
            children: [
              _buildBackgroundDecorations(isDark, theme),
              SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 112),
                    children: [
                      _buildTopBar(context, isDark, l10n, theme),
                      const SizedBox(height: 10),
                      _buildHeroCard(state.profile, isDark, theme),
                      const SizedBox(height: 14),
                      _buildReadOnlyBanner(
                        email: state.profile.email,
                        isDark: isDark,
                        theme: theme,
                      ),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: l10n.personalInformation,
                        subtitle:
                            'Update your core identity and communication details.',
                        icon: Icons.badge_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInputField(
                                    controller: _firstNameController,
                                    label: l10n.firstName,
                                    icon: Icons.person_outline_rounded,
                                    isDark: isDark,
                                    theme: theme,
                                    validator: _requiredValidator,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInputField(
                                    controller: _lastNameController,
                                    label: l10n.lastName,
                                    icon: Icons.person_rounded,
                                    isDark: isDark,
                                    theme: theme,
                                    validator: _requiredValidator,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInputField(
                              controller: _phoneController,
                              label: l10n.phone,
                              icon: Icons.phone_rounded,
                              isDark: isDark,
                              theme: theme,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            _buildInputField(
                              controller: _bioController,
                              label: l10n.bio,
                              icon: Icons.auto_stories_rounded,
                              isDark: isDark,
                              theme: theme,
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: 'Academic Interests & Skills',
                        subtitle:
                            'Keep your study direction and strengths up to date.',
                        icon: Icons.interests_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _interestsController,
                              label: 'Academic interests (comma separated)',
                              icon: Icons.explore_rounded,
                              isDark: isDark,
                              theme: theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInputField(
                              controller: _skillsController,
                              label: 'Skills (comma separated)',
                              icon: Icons.bolt_rounded,
                              isDark: isDark,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: 'Social Links',
                        subtitle:
                            'Share the links you want visible on your profile.',
                        icon: Icons.link_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _websiteController,
                              label: l10n.personalWebsite,
                              icon: Icons.language_rounded,
                              isDark: isDark,
                              theme: theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInputField(
                              controller: _githubController,
                              label: 'GitHub',
                              icon: Icons.code_rounded,
                              isDark: isDark,
                              theme: theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInputField(
                              controller: _linkedinController,
                              label: 'LinkedIn',
                              icon: Icons.work_outline_rounded,
                              isDark: isDark,
                              theme: theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInputField(
                              controller: _twitterController,
                              label: 'Twitter',
                              icon: Icons.alternate_email_rounded,
                              isDark: isDark,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSurfaceCard(
                        isDark: isDark,
                        theme: theme,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: state.isSaving
                                    ? null
                                    : () => safeBack(
                                        context,
                                        widget.fallbackRoute,
                                      ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.textSecondary(isDark),
                                  side: BorderSide(color: theme.border(isDark)),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(l10n.cancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state.isSaving
                                    ? null
                                    : () => _save(context, state),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: state.isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(l10n.saveChanges),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isDark, RoleProfileTheme theme) {
    return Stack(
      children: [
        Positioned(
          top: -110,
          right: -70,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.primary.withValues(alpha: isDark ? 0.2 : 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 220,
          left: -90,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.accent.withValues(alpha: isDark ? 0.14 : 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    RoleProfileTheme theme,
  ) {
    return Row(
      children: [
        _buildUtilityButton(
          onTap: () => safeBack(context, widget.fallbackRoute),
          isDark: isDark,
          theme: theme,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iosBackIcon(context),
                size: 16,
                color: theme.textPrimary(isDark),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.back,
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityButton({
    required VoidCallback onTap,
    required bool isDark,
    required RoleProfileTheme theme,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.card(isDark).withValues(alpha: isDark ? 0.92 : 0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.border(isDark)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    UserProfile profile,
    bool isDark,
    RoleProfileTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? theme.darkHeaderGradient : theme.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: isDark ? 0.22 : 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Refine ${profile.displayName} for the ${widget.roleLabel.toLowerCase()} experience in one focused flow.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBanner({
    required String email,
    required bool isDark,
    required RoleProfileTheme theme,
  }) {
    return _buildSurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.info_outline_rounded, color: theme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Email',
                  style: TextStyle(
                    color: theme.textPrimary(isDark),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Email is managed by your account and stays read-only here: $email',
                  style: TextStyle(
                    color: theme.textSecondary(isDark),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required RoleProfileTheme theme,
    required Widget child,
  }) {
    return _buildSurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.textPrimary(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSecondary(isDark),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSurfaceCard({
    required bool isDark,
    required RoleProfileTheme theme,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required RoleProfileTheme theme,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.textSecondary(isDark)),
        filled: true,
        fillColor: theme.surface(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: theme.border(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: theme.border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: theme.primary, width: 1.5),
        ),
      ),
    );
  }

  void _seedControllers(UserProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone ?? '';
    _bioController.text = profile.bio ?? '';
    _websiteController.text = profile.socialLinks.personalWebsite ?? '';
    _githubController.text = profile.socialLinks.github ?? '';
    _linkedinController.text = profile.socialLinks.linkedin ?? '';
    _twitterController.text = profile.socialLinks.twitter ?? '';
    _interestsController.text = profile.academicInterests.join(', ');
    _skillsController.text = profile.skills.join(', ');
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  Future<void> _save(BuildContext context, ProfileLoaded state) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = UpdateUserProfileRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? ''
          : _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      socialLinks: SocialLinks(
        personalWebsite: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        github: _githubController.text.trim().isEmpty
            ? null
            : _githubController.text.trim(),
        linkedin: _linkedinController.text.trim().isEmpty
            ? null
            : _linkedinController.text.trim(),
        twitter: _twitterController.text.trim().isEmpty
            ? null
            : _twitterController.text.trim(),
      ),
      academicInterests: _splitValues(_interestsController.text),
      skills: _splitValues(_skillsController.text),
    );

    final saved = await context.read<ProfileCubit>().updateProfile(request);
    if (!context.mounted) {
      return;
    }

    if (saved) {
      context.read<AuthBloc>().add(const RefreshUserDataRequested());
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).profileUpdated)),
        );
      safeBack(context, widget.fallbackRoute);
    }
  }

  List<String> _splitValues(String raw) {
    return raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }
}
