import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/profile/profile_barrel.dart';
import '../../../common/utils/responsive.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  // Admin profile data (in real app, this would come from a BLoC/Cubit)
  final Map<String, dynamic> _adminProfile = {
    'firstName': 'Ahmed',
    'lastName': 'Hassan',
    'email': 'ahmed.hassan@eduverse.com',
    'phone': '+20 100 123 4567',
    'role': 'Super Administrator',
    'department': 'IT Administration',
    'employeeId': 'ADM-001',
    'joinDate': DateTime(2023, 1, 15),
    'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
    'language': 'en',
    'timezone': 'Africa/Cairo (UTC+2)',
    'twoFactorEnabled': true,
    'usersManaged': 15420,
    'coursesCreated': 342,
    'reportsGenerated': 1256,
    'systemUptime': 99,
  };

  final List<ActivityItem> _recentActivities = [
    ActivityItem(
      title: 'User Account Created',
      description: 'Created new instructor account for Dr. Sarah',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.person_add_rounded,
      color: AdminColors.success,
    ),
    ActivityItem(
      title: 'System Settings Updated',
      description: 'Modified email notification settings',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      icon: Icons.settings_rounded,
      color: AdminColors.primary,
    ),
    ActivityItem(
      title: 'Report Generated',
      description: 'Monthly user engagement report',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.assessment_rounded,
      color: AdminColors.chartCyan,
    ),
    ActivityItem(
      title: 'Course Approved',
      description: 'Approved "Advanced Flutter" course',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.check_circle_rounded,
      color: AdminColors.secondary,
    ),
    ActivityItem(
      title: 'Security Alert Reviewed',
      description: 'Cleared suspicious login attempt alert',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      icon: Icons.shield_rounded,
      color: AdminColors.warning,
    ),
  ];

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

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showChangePasswordDialog(bool isDark, AppLocalizations l10n) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.changePassword,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
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
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text ==
                      confirmPasswordController.text &&
                  newPasswordController.text.isNotEmpty) {
                Navigator.pop(context);
                _showSnackBar(l10n.passwordChangedSuccess);
              } else {
                _showSnackBar(l10n.passwordsDontMatch);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
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
      style: TextStyle(color: AdminColors.getTextColor(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        filled: true,
        fillColor: isDark
            ? AdminColors.darkBackground
            : const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showTwoFactorDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.security_rounded, color: AdminColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.twoFactorAuthentication,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.twoFactorDescription,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AdminColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AdminColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.twoFactorEnabled,
                      style: TextStyle(
                        color: AdminColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(l10n.twoFactorSettingsUpdated);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.manageSettings),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.confirmLogout,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
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
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
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
              child: _isLoading
                  ? _buildLoadingState(isDark)
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // App Bar
                          SliverAppBar(
                            expandedHeight: 0,
                            floating: true,
                            pinned: true,
                            elevation: 0,
                            backgroundColor: isDark
                                ? AdminColors.darkBackground
                                : Colors.white.withValues(alpha: 0.9),
                            surfaceTintColor: Colors.transparent,
                            leading: IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: AdminColors.getTextColor(isDark),
                              ),
                            ),
                            title: Text(
                              l10n.myProfile,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.getTextColor(isDark),
                              ),
                            ),
                            actions: [
                              IconButton(
                                onPressed: () =>
                                    context.push('/admin/edit-profile'),
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: AdminColors.getTextSecondaryColor(
                                    isDark,
                                  ),
                                ),
                                tooltip: l10n.editProfile,
                              ),
                            ],
                          ),

                          // Content
                          SliverPadding(
                            padding: responsive.contentPadding,
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                const SizedBox(height: 8),

                                // Profile Header
                                AdminProfileHeader(
                                  firstName: _adminProfile['firstName'],
                                  lastName: _adminProfile['lastName'],
                                  email: _adminProfile['email'],
                                  role: _adminProfile['role'],
                                  department: _adminProfile['department'],
                                  isDark: isDark,
                                  onEditPressed: () =>
                                      context.push('/admin/edit-profile'),
                                  onImageTap: () =>
                                      _showSnackBar(l10n.changeProfilePhoto),
                                ),

                                const SizedBox(height: 16),

                                // Stats Card
                                AdminProfileStatsCard(
                                  isDark: isDark,
                                  usersManaged: _adminProfile['usersManaged'],
                                  coursesCreated:
                                      _adminProfile['coursesCreated'],
                                  reportsGenerated:
                                      _adminProfile['reportsGenerated'],
                                  systemUptime: _adminProfile['systemUptime'],
                                ),

                                const SizedBox(height: 16),

                                // Personal Information
                                AdminProfileInfoCard(
                                  isDark: isDark,
                                  title: l10n.personalInformation,
                                  icon: Icons.person_outline_rounded,
                                  items: [
                                    ProfileInfoItem(
                                      label: l10n.fullName,
                                      value:
                                          '${_adminProfile['firstName']} ${_adminProfile['lastName']}',
                                      icon: Icons.badge_outlined,
                                    ),
                                    ProfileInfoItem(
                                      label: l10n.email,
                                      value: _adminProfile['email'],
                                      icon: Icons.email_outlined,
                                    ),
                                    ProfileInfoItem(
                                      label: l10n.phone,
                                      value: _adminProfile['phone'],
                                      icon: Icons.phone_outlined,
                                    ),
                                    ProfileInfoItem(
                                      label: l10n.employeeId,
                                      value: _adminProfile['employeeId'],
                                      icon: Icons.numbers_rounded,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Work Information
                                AdminProfileInfoCard(
                                  isDark: isDark,
                                  title: l10n.workInformation,
                                  icon: Icons.work_outline_rounded,
                                  items: [
                                    ProfileInfoItem(
                                      label: l10n.department,
                                      value: _adminProfile['department'],
                                      icon: Icons.business_rounded,
                                    ),
                                    ProfileInfoItem(
                                      label: l10n.role,
                                      value: _adminProfile['role'],
                                      icon: Icons.admin_panel_settings_outlined,
                                    ),
                                    ProfileInfoItem(
                                      label: l10n.joinDate,
                                      value: _formatDate(
                                        _adminProfile['joinDate'],
                                      ),
                                      icon: Icons.calendar_today_rounded,
                                    ),
                                    ProfileInfoItem(
                                      label: l10n.lastLogin,
                                      value: _formatDateTime(
                                        _adminProfile['lastLogin'],
                                      ),
                                      icon: Icons.access_time_rounded,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Preferences
                                AdminProfileInfoCard(
                                  isDark: isDark,
                                  title: l10n.preferences,
                                  icon: Icons.tune_rounded,
                                  items: [
                                    ProfileInfoItem(
                                      label: l10n.language,
                                      value: _adminProfile['language'] == 'en'
                                          ? 'English'
                                          : 'العربية',
                                      icon: Icons.language_rounded,
                                      trailing: TextButton(
                                        onPressed: () => _showSnackBar(
                                          l10n.languageSettings,
                                        ),
                                        child: Text(
                                          l10n.change,
                                          style: TextStyle(
                                            color: AdminColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ProfileInfoItem(
                                      label: l10n.timezone,
                                      value: _adminProfile['timezone'],
                                      icon: Icons.schedule_rounded,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Recent Activity
                                AdminProfileActivityCard(
                                  isDark: isDark,
                                  activities: _recentActivities,
                                  onViewAll: () => context.push('/admin/audit'),
                                ),

                                const SizedBox(height: 16),

                                // Quick Actions
                                AdminProfileActionsCard(
                                  isDark: isDark,
                                  onEditProfile: () =>
                                      context.push('/admin/edit-profile'),
                                  onChangePassword: () =>
                                      _showChangePasswordDialog(isDark, l10n),
                                  onTwoFactorAuth: () =>
                                      _showTwoFactorDialog(isDark, l10n),
                                  onExportData: () =>
                                      _showSnackBar(l10n.exportingData),
                                  onLogout: () =>
                                      _showLogoutDialog(isDark, l10n),
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

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AdminColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_formatDate(date)} $hour:$minute';
  }
}
