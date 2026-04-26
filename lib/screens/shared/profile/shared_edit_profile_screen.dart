import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SharedEditProfileScreen extends StatefulWidget {
  final String title;

  const SharedEditProfileScreen({super.key, required this.title});

  @override
  State<SharedEditProfileScreen> createState() => _SharedEditProfileScreenState();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) {
          final previousMessage = previous is ProfileLoaded ? previous.error : '';
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.read<ProfileCubit>().loadProfile(force: true),
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

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _ReadOnlyBanner(email: state.profile.email),
                const SizedBox(height: 16),
                _FormCard(
                  title: l10n.personalInformation,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _InputField(
                            controller: _firstNameController,
                            label: l10n.firstName,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InputField(
                            controller: _lastNameController,
                            label: l10n.lastName,
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InputField(
                      controller: _phoneController,
                      label: l10n.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _InputField(
                      controller: _bioController,
                      label: l10n.bio,
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormCard(
                  title: 'Academic interests & skills',
                  children: [
                    _InputField(
                      controller: _interestsController,
                      label: 'Academic interests (comma separated)',
                    ),
                    const SizedBox(height: 12),
                    _InputField(
                      controller: _skillsController,
                      label: 'Skills (comma separated)',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormCard(
                  title: 'Social links',
                  children: [
                    _InputField(
                      controller: _websiteController,
                      label: l10n.personalWebsite,
                    ),
                    const SizedBox(height: 12),
                    _InputField(controller: _githubController, label: 'GitHub'),
                    const SizedBox(height: 12),
                    _InputField(
                      controller: _linkedinController,
                      label: 'LinkedIn',
                    ),
                    const SizedBox(height: 12),
                    _InputField(controller: _twitterController, label: 'Twitter'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.isSaving ? null : () => context.pop(),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isSaving ? null : () => _save(context, state),
                        child: state.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.saveChanges),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
          SnackBar(
            content: Text(AppLocalizations.of(context).profileUpdated),
          ),
        );
      context.pop();
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

class _ReadOnlyBanner extends StatelessWidget {
  final String email;

  const _ReadOnlyBanner({required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Email is managed by your account and is read only here: $email',
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
