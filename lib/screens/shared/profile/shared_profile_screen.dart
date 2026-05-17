import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../utils/navigation/safe_back.dart';
import 'role_profile_theme.dart';

class SharedProfileScreen extends StatefulWidget {
  final String editRoute;
  final String roleFallbackLabel;
  final String title;
  final RoleProfileTheme theme;
  final String fallbackRoute;

  const SharedProfileScreen({
    super.key,
    required this.editRoute,
    required this.roleFallbackLabel,
    required this.title,
    required this.theme,
    required this.fallbackRoute,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(widget.editRoute),
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: Text(
          l10n.editProfile,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) {
          final previousMessage = previous is ProfileLoaded
              ? previous.error
              : '';
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
            return Center(
              child: CircularProgressIndicator(color: theme.primary),
            );
          }

          if (state is ProfileError) {
            return _ErrorView(
              message: state.message,
              theme: theme,
              onRetry: () =>
                  context.read<ProfileCubit>().loadProfile(force: true),
            );
          }

          if (state is! ProfileLoaded) {
            return const SizedBox.shrink();
          }

          final profile = state.profile;
          final roleLabel = profile.roles.isNotEmpty
              ? profile.primaryRoleLabel
              : widget.roleFallbackLabel;
          final socialEntries = profile.socialLinks.entries;

          return Stack(
            children: [
              _buildBackgroundDecorations(isDark, theme),
              SafeArea(
                child: RefreshIndicator(
                  color: theme.primary,
                  onRefresh: () =>
                      context.read<ProfileCubit>().loadProfile(force: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 112),
                    children: [
                      _buildTopBar(context, isDark, l10n, theme),
                      const SizedBox(height: 10),
                      _buildHeroCard(
                        profile: profile,
                        roleLabel: roleLabel,
                        subtitle: widget.title,
                        memberSince: _formatCreatedDate(profile.createdAt),
                        isDark: isDark,
                        theme: theme,
                      ),
                      const SizedBox(height: 14),
                      _buildStatsCard(
                        profile: profile,
                        isDark: isDark,
                        l10n: l10n,
                        theme: theme,
                      ),
                      const SizedBox(height: 14),
                      _buildQuickActionsCard(context, isDark, l10n, theme),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: l10n.personalInformation,
                        subtitle:
                            'Core account details and contact information.',
                        icon: Icons.badge_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: Column(
                          children: [
                            _buildInfoTile(
                              icon: Icons.person_outline_rounded,
                              label: l10n.fullName,
                              value: profile.displayName,
                              isDark: isDark,
                              theme: theme,
                            ),
                            _buildInfoTile(
                              icon: Icons.alternate_email_rounded,
                              label: l10n.email,
                              value: profile.email,
                              isDark: isDark,
                              theme: theme,
                            ),
                            _buildInfoTile(
                              icon: Icons.phone_rounded,
                              label: l10n.phone,
                              value: (profile.phone ?? '').trim().isEmpty
                                  ? 'Not set'
                                  : profile.phone!,
                              isDark: isDark,
                              theme: theme,
                            ),
                            _buildInfoTile(
                              icon: Icons.workspace_premium_rounded,
                              label: l10n.role,
                              value: roleLabel,
                              isDark: isDark,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                      if ((profile.bio ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildSectionCard(
                          title: l10n.bio,
                          subtitle: 'A concise introduction to this profile.',
                          icon: Icons.auto_stories_rounded,
                          isDark: isDark,
                          theme: theme,
                          child: Text(
                            profile.bio!,
                            style: TextStyle(
                              color: theme.textPrimary(isDark),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: 'Academic Interests',
                        subtitle:
                            'Topics and areas this profile is currently focused on.',
                        icon: Icons.interests_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: _buildTagWrap(
                          items: profile.academicInterests,
                          emptyLabel: 'No academic interests added yet.',
                          isDark: isDark,
                          color: theme.primary,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: 'Skills',
                        subtitle: 'Practical strengths and areas of expertise.',
                        icon: Icons.bolt_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: _buildTagWrap(
                          items: profile.skills,
                          emptyLabel: 'No skills added yet.',
                          isDark: isDark,
                          color: theme.accent,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: 'Social Links',
                        subtitle:
                            'Connected public profiles and personal links.',
                        icon: Icons.link_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: socialEntries.isEmpty
                            ? _buildEmptyInlineState(
                                'No social links added yet.',
                                isDark,
                                theme,
                              )
                            : Column(
                                children: socialEntries
                                    .map(
                                      (entry) => _buildInfoTile(
                                        icon: _socialIcon(entry.key),
                                        label: entry.key,
                                        value: entry.value,
                                        isDark: isDark,
                                        theme: theme,
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: l10n.securityAccount,
                        subtitle:
                            'Update your password and keep account access secure.',
                        icon: Icons.shield_rounded,
                        isDark: isDark,
                        theme: theme,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoTile(
                              icon: Icons.mark_email_read_rounded,
                              label: 'Email Verification',
                              value: profile.emailVerified
                                  ? 'Verified'
                                  : 'Pending verification',
                              isDark: isDark,
                              theme: theme,
                              highlight: profile.emailVerified
                                  ? theme.success
                                  : theme.warning,
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showPasswordDialog(context, l10n, isDark),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.lock_reset_rounded),
                                label: Text(
                                  l10n.changePassword,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSupportCard(isDark, l10n, theme),
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
        const Spacer(),
        _buildUtilityButton(
          onTap: () => context.push(widget.editRoute),
          isDark: isDark,
          theme: theme,
          child: Icon(
            Icons.edit_outlined,
            size: 18,
            color: theme.textPrimary(isDark),
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

  Widget _buildHeroCard({
    required UserProfile profile,
    required String roleLabel,
    required String subtitle,
    required String memberSince,
    required bool isDark,
    required RoleProfileTheme theme,
  }) {
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
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.75),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (profile.profilePictureUrl ?? '').trim().isNotEmpty
                          ? NetworkImage(profile.profilePictureUrl!)
                          : null,
                      child: (profile.profilePictureUrl ?? '').trim().isEmpty
                          ? Text(
                              profile.initials,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: theme.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: profile.emailVerified
                            ? theme.success
                            : theme.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeroPill(
                  icon: Icons.workspace_premium_rounded,
                  label: roleLabel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroPill(
                  icon: Icons.timelapse_rounded,
                  label: memberSince,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required UserProfile profile,
    required bool isDark,
    required AppLocalizations l10n,
    required RoleProfileTheme theme,
  }) {
    return _buildSurfaceCard(
      isDark: isDark,
      theme: theme,
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
        children: [
          _buildStatItem(
            value: '${profile.profileCompleteness.toStringAsFixed(0)}%',
            label: 'Complete',
            icon: Icons.auto_graph_rounded,
            color: theme.primary,
            isDark: isDark,
            theme: theme,
          ),
          _buildStatItem(
            value: '${profile.academicInterests.length}',
            label: 'Interests',
            icon: Icons.interests_rounded,
            color: theme.accent,
            isDark: isDark,
            theme: theme,
          ),
          _buildStatItem(
            value: '${profile.skills.length}',
            label: 'Skills',
            icon: Icons.bolt_rounded,
            color: theme.success,
            isDark: isDark,
            theme: theme,
          ),
          _buildStatItem(
            value: profile.emailVerified ? l10n.verified : 'Pending',
            label: 'Email',
            icon: Icons.verified_rounded,
            color: profile.emailVerified ? theme.success : theme.warning,
            isDark: isDark,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required RoleProfileTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textPrimary(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textSecondary(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    RoleProfileTheme theme,
  ) {
    return _buildSurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit_note_rounded,
              label: l10n.editProfile,
              color: theme.primary,
              isDark: isDark,
              theme: theme,
              onTap: () => context.push(widget.editRoute),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              icon: Icons.lock_reset_rounded,
              label: l10n.changePassword,
              color: theme.accent,
              isDark: isDark,
              theme: theme,
              onTap: () => _showPasswordDialog(context, l10n, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required RoleProfileTheme theme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required RoleProfileTheme theme,
    Color? highlight,
  }) {
    final activeColor = highlight ?? theme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight != null
              ? activeColor.withValues(alpha: 0.2)
              : theme.border(isDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: activeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.textSecondary(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: highlight ?? theme.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagWrap({
    required List<String> items,
    required String emptyLabel,
    required bool isDark,
    required Color color,
    required RoleProfileTheme theme,
  }) {
    if (items.isEmpty) {
      return _buildEmptyInlineState(emptyLabel, isDark, theme);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color.withValues(alpha: 0.16)),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEmptyInlineState(
    String label,
    bool isDark,
    RoleProfileTheme theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(color: theme.textSecondary(isDark), fontSize: 13),
      ),
    );
  }

  Widget _buildSupportCard(
    bool isDark,
    AppLocalizations l10n,
    RoleProfileTheme theme,
  ) {
    return _buildSurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support & Info',
            style: TextStyle(
              color: theme.textPrimary(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Helpful links for policy, support, and product details.',
            style: TextStyle(
              color: theme.textSecondary(isDark),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSupportTile(
                  icon: Icons.help_outline_rounded,
                  label: l10n.helpCenter,
                  color: theme.primary,
                  isDark: isDark,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSupportTile(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.privacyPolicy,
                  color: theme.accent,
                  isDark: isDark,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSupportTile(
                  icon: Icons.info_outline_rounded,
                  label: l10n.about,
                  color: theme.success,
                  isDark: isDark,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required RoleProfileTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textSecondary(isDark),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
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

  IconData _socialIcon(String label) {
    switch (label.toLowerCase()) {
      case 'website':
        return Icons.language_rounded;
      case 'github':
        return Icons.code_rounded;
      case 'linkedin':
        return Icons.work_outline_rounded;
      case 'twitter':
        return Icons.alternate_email_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  String _formatCreatedDate(String createdAt) {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return 'Member';
    }
    final month = parsed.month.toString().padLeft(2, '0');
    return 'Joined $month/${parsed.year}';
  }

  Future<void> _showPasswordDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final theme = widget.theme;

    final success = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
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
                setState(
                  () => validationMessage = 'All password fields are required.',
                );
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

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.card(isDark),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.border(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? theme.darkHeaderGradient
                            : theme.headerGradient,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.changePassword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Keep your account secure with a fresh password.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.86),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(dialogContext).pop(false),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildPasswordField(
                            controller: currentPasswordController,
                            label: l10n.currentPassword,
                            icon: Icons.key_rounded,
                            isDark: isDark,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: newPasswordController,
                            label: l10n.newPassword,
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            theme: theme,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: confirmPasswordController,
                            label: l10n.confirmPassword,
                            icon: Icons.verified_user_outlined,
                            isDark: isDark,
                            theme: theme,
                          ),
                          if (validationMessage != null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                validationMessage!,
                                style: TextStyle(
                                  color: theme.error,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.of(
                                          dialogContext,
                                        ).pop(false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.textSecondary(
                                      isDark,
                                    ),
                                    side: BorderSide(
                                      color: theme.border(isDark),
                                    ),
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
                                  onPressed: isSubmitting ? null : submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isSubmitting
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
                                      : Text(l10n.save),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required RoleProfileTheme theme,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.textSecondary(isDark)),
        filled: true,
        fillColor: theme.surface(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.border(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final RoleProfileTheme theme;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.theme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.card(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.border(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.error_outline_rounded, color: theme.primary),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
