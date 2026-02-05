import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/profile/profile_cubit.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/profile/profile_header.dart';
import '../../../widgets/student/profile/profile_stats_card.dart';
import '../../../widgets/student/profile/profile_section_card.dart';
import '../../../widgets/student/profile/preferences_section.dart';
import '../../../widgets/student/profile/appearance_section.dart';
import '../../../widgets/student/profile/security_section.dart';
import '../../../widgets/student/profile/profile_footer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    context.read<ProfileCubit>().loadProfile();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is ProfileError) {
            return _buildErrorState(state.message, isDark, l10n);
          }

          if (state is ProfileLoaded) {
            return _buildLoadedState(context, state, isDark, l10n);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: isDark ? Colors.red.shade300 : Colors.red.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.error,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<ProfileCubit>().loadProfile(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    ProfileLoaded state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            title: Text(
              l10n.profileSettings,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/edit-profile'),
                icon: Icon(
                  Icons.edit_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                tooltip: l10n.editProfile,
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Profile Header
                ProfileHeader(
                  profile: state.profile,
                  isDark: isDark,
                  onEditPressed: () => context.push('/edit-profile'),
                ),

                const SizedBox(height: 16),

                // Stats Card
                ProfileStatsCard(
                  profile: state.profile,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Personal Information
                ProfileSectionCard(
                  title: l10n.personalInformation,
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  children: [
                    _buildInfoRow(
                      l10n.fullName,
                      state.profile.fullName,
                      Icons.badge_outlined,
                      isDark,
                    ),
                    _buildInfoRow(
                      l10n.email,
                      state.profile.email,
                      Icons.email_outlined,
                      isDark,
                    ),
                    _buildInfoRow(
                      l10n.phone,
                      state.profile.phoneNumber ?? 'Not set',
                      Icons.phone_outlined,
                      isDark,
                    ),
                    _buildInfoRow(
                      l10n.password,
                      '••••••••',
                      Icons.lock_outline_rounded,
                      isDark,
                      trailing: TextButton(
                        onPressed: () => _showChangePasswordDialog(context, isDark, l10n),
                        child: Text(
                          l10n.change,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _buildInfoRow(
                      l10n.language,
                      state.settings.languageCode == 'en' ? 'English' : 'العربية',
                      Icons.language_rounded,
                      isDark,
                      trailing: TextButton(
                        onPressed: () => _showLanguageDialog(context, state, isDark, l10n),
                        child: Text(
                          l10n.change,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Preferences & Notifications
                PreferencesSection(
                  settings: state.settings,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Appearance & Theme
                AppearanceSection(
                  settings: state.settings,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Security & Account
                SecuritySection(
                  settings: state.settings,
                  connectedDevices: state.connectedDevices,
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Footer
                ProfileFooter(isDark: isDark),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
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
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, bool isDark, AppLocalizations l10n) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.changePassword,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPasswordField(
              controller: currentPasswordController,
              label: l10n.currentPassword,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: newPasswordController,
              label: l10n.newPassword,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: confirmPasswordController,
              label: l10n.confirmPassword,
              isDark: isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text) {
                context.read<ProfileCubit>().changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.passwordChangedSuccess),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    ProfileLoaded state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.selectLanguage,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', 'en', state.settings.languageCode, isDark),
            const SizedBox(height: 8),
            _buildLanguageOption(context, 'العربية', 'ar', state.settings.languageCode, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String code,
    String currentCode,
    bool isDark,
  ) {
    final isSelected = code == currentCode;

    return ListTile(
      onTap: () {
        context.read<ProfileCubit>().setLanguage(code);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: isSelected
          ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
          : Colors.transparent,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected
            ? const Color(0xFF3B82F6)
            : (isDark ? Colors.white54 : Colors.black45),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
