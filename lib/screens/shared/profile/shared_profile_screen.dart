import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SharedProfileScreen extends StatefulWidget {
  final String editRoute;
  final String roleFallbackLabel;
  final String title;

  const SharedProfileScreen({
    super.key,
    required this.editRoute,
    required this.roleFallbackLabel,
    required this.title,
  });

  @override
  State<SharedProfileScreen> createState() => _SharedProfileScreenState();
}

class _SharedProfileScreenState extends State<SharedProfileScreen> {
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
        actions: [
          IconButton(
            onPressed: () => context.push(widget.editRoute),
            icon: const Icon(Icons.edit_rounded),
            tooltip: l10n.editProfile,
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) {
          final previousMessage = previous is ProfileLoaded ? previous.error : '';
          final currentMessage = current is ProfileLoaded ? current.error : '';
          return previousMessage != currentMessage &&
              currentMessage != null &&
              currentMessage.isNotEmpty;
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
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<ProfileCubit>().loadProfile(force: true),
            );
          }

          if (state is! ProfileLoaded) {
            return const SizedBox.shrink();
          }

          final profile = state.profile;
          final roleLabel = profile.roles.isNotEmpty
              ? profile.primaryRoleLabel
              : widget.roleFallbackLabel;

          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _ProfileHero(profile: profile, roleLabel: roleLabel),
                const SizedBox(height: 16),
                _SectionCard(
                  title: l10n.personalInformation,
                  children: [
                    _InfoRow(label: l10n.fullName, value: profile.displayName),
                    _InfoRow(label: l10n.email, value: profile.email),
                    _InfoRow(
                      label: l10n.phone,
                      value: profile.phone ?? 'Not set',
                    ),
                    _InfoRow(label: 'Role', value: roleLabel),
                    _InfoRow(
                      label: 'Profile completeness',
                      value:
                          '${profile.profileCompleteness.toStringAsFixed(0)}%',
                    ),
                    _InfoRow(
                      label: 'Email verification',
                      value: profile.emailVerified ? 'Verified' : 'Not verified',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if ((profile.bio ?? '').trim().isNotEmpty)
                  _SectionCard(
                    title: l10n.bio,
                    children: [
                      Text(
                        profile.bio!,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                if ((profile.bio ?? '').trim().isNotEmpty)
                  const SizedBox(height: 16),
                _SectionCard(
                  title: 'Academic interests',
                  children: [
                    if (profile.academicInterests.isEmpty)
                      const _MutedText('No academic interests added yet.')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.academicInterests
                            .map((item) => Chip(label: Text(item)))
                            .toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Skills',
                  children: [
                    if (profile.skills.isEmpty)
                      const _MutedText('No skills added yet.')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.skills
                            .map((item) => Chip(label: Text(item)))
                            .toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Social links',
                  children: [
                    if (!profile.socialLinks.hasAny)
                      const _MutedText('No social links added yet.')
                    else
                      ...profile.socialLinks.entries.map(
                        (entry) => _InfoRow(
                          label: entry.key,
                          value: entry.value,
                          dense: true,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: l10n.securityAccount,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPasswordDialog(context, l10n),
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: Text(l10n.changePassword),
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

  Future<void> _showPasswordDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;
        String? validationMessage;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> submit() async {
              final currentPassword = currentPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (currentPassword.isEmpty ||
                  newPassword.isEmpty ||
                  confirmPassword.isEmpty) {
                setState(() => validationMessage = 'All password fields are required.');
                return;
              }

              if (newPassword != confirmPassword) {
                setState(() => validationMessage = l10n.passwordsDontMatch);
                return;
              }

              setState(() {
                isSubmitting = true;
                validationMessage = null;
              });

              final changed = await context.read<ProfileCubit>().changePassword(
                currentPassword,
                newPassword,
              );

              if (!context.mounted) {
                return;
              }

              if (changed) {
                Navigator.of(dialogContext).pop(true);
              } else {
                setState(() {
                  isSubmitting = false;
                  validationMessage =
                      'Failed to change password. Please try again.';
                });
              }
            }

            return AlertDialog(
              title: Text(l10n.changePassword),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.currentPassword),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.newPassword),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.confirmPassword),
                  ),
                  if (validationMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      validationMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (success == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.passwordChangedSuccess)));
      context.read<AuthBloc>().add(const RefreshUserDataRequested());
    }
  }
}

class _ProfileHero extends StatelessWidget {
  final UserProfile profile;
  final String roleLabel;

  const _ProfileHero({required this.profile, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            backgroundImage: (profile.profilePictureUrl ?? '').trim().isNotEmpty
                ? NetworkImage(profile.profilePictureUrl!)
                : null,
            child: (profile.profilePictureUrl ?? '').trim().isEmpty
                ? Text(
                    profile.initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roleLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroChip(label: profile.status),
                    _HeroChip(
                      label: profile.emailVerified ? 'Verified email' : 'Email pending',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;

  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool dense;

  const _InfoRow({
    required this.label,
    required this.value,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 10 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  final String text;

  const _MutedText(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white54 : const Color(0xFF64748B),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
