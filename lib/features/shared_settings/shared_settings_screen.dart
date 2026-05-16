import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/language/language_cubit.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_models.dart';
import '../../bloc/profile/profile_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../screens/shared/profile/role_profile_theme.dart';
import '../../utils/navigation/safe_back.dart';
import 'shared_settings_role.dart';
import 'widgets/shared_settings_components.dart';
import 'widgets/shared_settings_glass.dart';

class SharedSettingsScreen extends StatefulWidget {
  final SharedSettingsRole role;

  const SharedSettingsScreen({super.key, required this.role});

  @override
  State<SharedSettingsScreen> createState() => _SharedSettingsScreenState();
}

class _SharedSettingsScreenState extends State<SharedSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  bool _taAutoGradeAssist = true;
  bool _instructorAutoSave = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
    _loadRolePreferences();
  }

  Future<void> _loadRolePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _taAutoGradeAssist = prefs.getBool('ta_auto_grade_assist') ?? true;
      _instructorAutoSave = prefs.getBool('grading_auto_save') ?? true;
    });
  }

  Future<void> _saveBoolPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;
    final role = widget.role;
    final roleTheme = role.theme;

    return SharedSettingsRoleScope(
      role: role,
      child: Scaffold(
        backgroundColor: roleTheme.background(isDark),
        appBar: AppBar(
          backgroundColor: roleTheme.background(isDark),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => safeBack(context, role.fallbackRoute),
            icon: Icon(
              iosBackIcon(context),
              color: roleTheme.textPrimary(isDark),
            ),
          ),
          title: Text(
            l10n.settings,
            style: TextStyle(
              color: roleTheme.textPrimary(isDark),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showSearchDialog(l10n, isDark, roleTheme),
              icon: Icon(
                Icons.search_rounded,
                color: roleTheme.textSecondary(isDark),
              ),
              tooltip: l10n.search,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        constraints.maxWidth >= 720 ? 24 : 16,
                        12,
                        constraints.maxWidth >= 720 ? 24 : 16,
                        32,
                      ),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildProfileHeader(role, roleTheme, isDark, l10n),
                        const SizedBox(height: 24),
                        ..._buildSections(role, roleTheme, isDark, l10n).expand(
                          (section) => <Widget>[
                            section,
                            const SizedBox(height: 16),
                          ],
                        ),
                        _buildDangerZone(roleTheme, isDark, l10n),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    SharedSettingsRole role,
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return SharedSettingsHeader(
            profile: state.profile,
            role: role,
            theme: roleTheme,
            isDark: isDark,
            onTap: () => context.push(role.profileRoute),
          );
        }

        if (state is ProfileError) {
          return SharedSettingsStateCard(
            isDark: isDark,
            theme: roleTheme,
            icon: Icons.error_outline_rounded,
            title: l10n.sharedSettingsProfileErrorTitle,
            subtitle: l10n.sharedSettingsProfileErrorMessage,
            actionLabel: l10n.tryAgain,
            onAction: () =>
                context.read<ProfileCubit>().loadProfile(force: true),
          );
        }

        return SharedSettingsStateCard(
          isDark: isDark,
          theme: roleTheme,
          icon: Icons.person_search_rounded,
          title: l10n.sharedSettingsProfileLoadingTitle,
          subtitle: l10n.sharedSettingsProfileLoadingMessage,
        );
      },
    );
  }

  List<Widget> _buildSections(
    SharedSettingsRole role,
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return [
      SharedSettingsSection(
        title: l10n.account,
        icon: Icons.person_outline_rounded,
        isDark: isDark,
        theme: roleTheme,
        items: _accountItems(role, roleTheme, isDark, l10n),
      ),
      SharedSettingsSection(
        title: l10n.notifications,
        icon: Icons.notifications_outlined,
        isDark: isDark,
        theme: roleTheme,
        items: _notificationItems(role, l10n),
      ),
      SharedSettingsSection(
        title: l10n.appearance,
        icon: Icons.palette_outlined,
        isDark: isDark,
        theme: roleTheme,
        items: _appearanceItems(role, roleTheme, isDark, l10n),
      ),
      SharedSettingsSection(
        title: l10n.privacySecurity,
        icon: Icons.security_outlined,
        isDark: isDark,
        theme: roleTheme,
        items: _privacyItems(role, l10n),
      ),
      SharedSettingsSection(
        title: _roleToolsTitle(role, l10n),
        icon: _roleToolsIcon(role),
        isDark: isDark,
        theme: roleTheme,
        items: _roleToolItems(role, roleTheme, isDark, l10n),
      ),
      SharedSettingsSection(
        title: l10n.storageData,
        icon: Icons.storage_outlined,
        isDark: isDark,
        theme: roleTheme,
        items: _storageItems(role, roleTheme, isDark, l10n),
      ),
      SharedSettingsSection(
        title: l10n.support,
        icon: Icons.help_outline_rounded,
        isDark: isDark,
        theme: roleTheme,
        items: _supportItems(role, roleTheme, isDark, l10n),
      ),
      SharedSettingsSection(
        title: l10n.about,
        icon: Icons.info_outline_rounded,
        isDark: isDark,
        theme: roleTheme,
        items: _aboutItems(role, l10n),
      ),
    ];
  }

  List<SharedSettingsItem> _accountItems(
    SharedSettingsRole role,
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final profileState = context.watch<ProfileCubit>().state;
    final phone = profileState is ProfileLoaded
        ? (profileState.profile.phoneNumber ?? l10n.notSet)
        : '';

    return [
      SharedSettingsItem(
        icon: Icons.person_outline_rounded,
        title: l10n.editProfile,
        subtitle: l10n.editProfileDesc,
        onTap: () => context.push(role.editProfileRoute),
      ),
      SharedSettingsItem(
        icon: Icons.lock_outline_rounded,
        title: l10n.changePassword,
        subtitle: l10n.changePasswordDesc,
        onTap: () => _showChangePasswordSheet(l10n, isDark, roleTheme),
      ),
      SharedSettingsItem(
        icon: Icons.email_outlined,
        title: l10n.emailPreferences,
        subtitle: l10n.emailPreferencesDesc,
        onTap: () => context.push(role.routeTo('/settings/email')),
      ),
      SharedSettingsItem(
        icon: Icons.phone_outlined,
        title: l10n.phoneNumber,
        subtitle: phone,
        onTap: () => _showPhoneSheet(l10n, isDark, roleTheme),
      ),
    ];
  }

  List<SharedSettingsItem> _notificationItems(
    SharedSettingsRole role,
    AppLocalizations l10n,
  ) {
    return [
      SharedSettingsItem(
        icon: Icons.notifications_active_outlined,
        title: l10n.pushNotifications,
        subtitle: l10n.pushNotificationsSettingsDesc,
        onTap: () => context.push(role.routeTo('/settings/notifications')),
      ),
      SharedSettingsItem(
        icon: Icons.email_outlined,
        title: l10n.emailNotifications,
        subtitle: l10n.emailNotificationsDesc,
        onTap: () =>
            context.push(role.routeTo('/settings/email-notifications')),
      ),
      SharedSettingsItem(
        icon: Icons.do_not_disturb_on_outlined,
        title: l10n.doNotDisturb,
        subtitle: l10n.doNotDisturbDesc,
        onTap: () => context.push(role.routeTo('/settings/dnd')),
      ),
    ];
  }

  List<SharedSettingsItem> _appearanceItems(
    SharedSettingsRole role,
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final themeState = context.watch<ThemeBloc>().state;
    final locale = context.watch<LanguageCubit>().state;

    return [
      SharedSettingsItem(
        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        title: l10n.theme,
        subtitle: _themeLabel(themeState.themeMode, l10n),
        onTap: () => _showThemeSheet(l10n, isDark, roleTheme),
      ),
      SharedSettingsItem(
        icon: Icons.language_rounded,
        title: l10n.language,
        subtitle: locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
        onTap: () => _showLanguageSheet(l10n, isDark, roleTheme),
      ),
      SharedSettingsItem(
        icon: Icons.text_fields_rounded,
        title: l10n.fontSize,
        subtitle: _fontSizeLabel(themeState.fontSize, l10n),
        onTap: () => _showFontSizeSheet(l10n, isDark, roleTheme),
      ),
    ];
  }

  List<SharedSettingsItem> _privacyItems(
    SharedSettingsRole role,
    AppLocalizations l10n,
  ) {
    final profileState = context.watch<ProfileCubit>().state;

    return [
      SharedSettingsItem(
        icon: Icons.verified_user_outlined,
        title: l10n.twoFactorAuth,
        subtitle:
            profileState is ProfileLoaded && profileState.settings.twoFactorAuth
            ? l10n.enabled
            : l10n.disabled,
        onTap: () => context.push(role.routeTo('/settings/two-factor-auth')),
      ),
      SharedSettingsItem(
        icon: Icons.devices_rounded,
        title: l10n.connectedDevices,
        subtitle: profileState is ProfileLoaded
            ? l10n.devicesConnected(profileState.connectedDevices.length)
            : '',
        onTap: () => context.push(role.routeTo('/settings/connected-devices')),
      ),
      SharedSettingsItem(
        icon: Icons.privacy_tip_outlined,
        title: l10n.privacySettings,
        subtitle: l10n.privacySettingsDesc,
        onTap: () => context.push(role.routeTo('/settings/privacy')),
      ),
      SharedSettingsItem(
        icon: Icons.history_rounded,
        title: l10n.loginHistory,
        subtitle: l10n.loginHistoryDesc,
        onTap: () => context.push(role.routeTo('/settings/login-history')),
      ),
    ];
  }

  List<SharedSettingsItem> _roleToolItems(
    SharedSettingsRole role,
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    switch (role) {
      case SharedSettingsRole.instructor:
        return [
          SharedSettingsItem(
            icon: Icons.grading_outlined,
            title: l10n.gradingPreferences,
            subtitle: l10n.gradingPreferencesDesc,
            trailing: Switch.adaptive(
              value: _instructorAutoSave,
              activeThumbColor: roleTheme.primary,
              onChanged: (value) {
                setState(() => _instructorAutoSave = value);
                _saveBoolPreference('grading_auto_save', value);
              },
            ),
            onTap: () => _showInstructorGradingSheet(l10n, isDark, roleTheme),
          ),
          SharedSettingsItem(
            icon: Icons.assignment_outlined,
            title: l10n.assignmentDefaults,
            subtitle: l10n.assignmentDefaultsDesc,
            onTap: () => _showAssignmentDefaultsSheet(l10n, isDark, roleTheme),
          ),
          SharedSettingsItem(
            icon: Icons.how_to_reg_outlined,
            title: l10n.attendanceSettings,
            subtitle: l10n.attendanceSettingsDesc,
            onTap: () => _showAttendanceSettingsSheet(l10n, isDark, roleTheme),
          ),
        ];
      case SharedSettingsRole.ta:
        return [
          SharedSettingsItem(
            icon: Icons.auto_fix_high_rounded,
            title: l10n.taSettingsAIGrading,
            subtitle: l10n.taSettingsAIGradingDesc,
            trailing: Switch.adaptive(
              value: _taAutoGradeAssist,
              activeThumbColor: roleTheme.primary,
              onChanged: (value) {
                setState(() => _taAutoGradeAssist = value);
                _saveBoolPreference('ta_auto_grade_assist', value);
              },
            ),
          ),
          SharedSettingsItem(
            icon: Icons.analytics_outlined,
            title: l10n.taSettingsAnalytics,
            subtitle: l10n.taSettingsAnalyticsDesc,
            onTap: () => context.push('/ta/analytics'),
          ),
          SharedSettingsItem(
            icon: Icons.schedule_rounded,
            title: l10n.taSettingsOfficeHours,
            subtitle: l10n.taSettingsOfficeHoursDesc,
            onTap: () => _showOfficeHoursSheet(l10n, isDark, roleTheme),
          ),
          SharedSettingsItem(
            icon: Icons.grading_rounded,
            title: l10n.taSettingsGradingPrefs,
            subtitle: l10n.taSettingsGradingPrefsDesc,
            onTap: () => _showTAGradingSheet(l10n, isDark, roleTheme),
          ),
        ];
      case SharedSettingsRole.student:
        return [
          SharedSettingsItem(
            icon: Icons.auto_awesome_outlined,
            title: l10n.aiSettings,
            subtitle: l10n.aiSettingsDesc,
            onTap: () => context.push(role.routeTo('/settings/ai')),
          ),
          SharedSettingsItem(
            icon: Icons.download_outlined,
            title: l10n.downloadSettings,
            subtitle: l10n.downloadSettingsDesc,
            onTap: () => context.push(role.routeTo('/settings/storage')),
          ),
          SharedSettingsItem(
            icon: Icons.swipe_rounded,
            title: l10n.swipeActions,
            subtitle: l10n.swipeActionsDesc,
            onTap: () => context.push(role.routeTo('/settings/swipe-actions')),
          ),
        ];
    }
  }

  List<SharedSettingsItem> _storageItems(
    SharedSettingsRole role,
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return [
      SharedSettingsItem(
        icon: Icons.cleaning_services_outlined,
        title: l10n.clearCache,
        subtitle: l10n.clearCacheDesc,
        onTap: () => _showClearCacheDialog(l10n, isDark, roleTheme),
      ),
      SharedSettingsItem(
        icon: Icons.download_rounded,
        title: l10n.downloadMyData,
        subtitle: l10n.downloadMyDataSettingsDesc,
        onTap: () => _showExportDataDialog(l10n, isDark, roleTheme),
      ),
      SharedSettingsItem(
        icon: Icons.backup_outlined,
        title: l10n.backup,
        subtitle: l10n.backupDesc,
        onTap: () => context.push(role.routeTo('/settings/storage')),
      ),
    ];
  }

  List<SharedSettingsItem> _supportItems(
    SharedSettingsRole role,
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return [
      SharedSettingsItem(
        icon: Icons.help_outline_rounded,
        title: l10n.helpCenter,
        subtitle: l10n.helpCenterDesc,
        onTap: () => context.push(role.routeTo('/settings/help')),
      ),
      SharedSettingsItem(
        icon: Icons.feedback_outlined,
        title: l10n.sendFeedback,
        subtitle: l10n.sendFeedbackSettingsDesc,
        onTap: () => _showTextEntrySheet(
          title: l10n.sendFeedback,
          hint: l10n.feedbackPlaceholder,
          successMessage: l10n.feedbackSent,
          isDark: isDark,
          roleTheme: roleTheme,
          l10n: l10n,
        ),
      ),
      SharedSettingsItem(
        icon: Icons.bug_report_outlined,
        title: l10n.reportBug,
        subtitle: l10n.reportBugSettingsDesc,
        onTap: () => _showBugReportSheet(l10n, isDark, roleTheme),
      ),
      SharedSettingsItem(
        icon: Icons.star_outline_rounded,
        title: l10n.rateApp,
        subtitle: l10n.rateAppDesc,
        onTap: () => _showRateAppDialog(l10n, isDark, roleTheme),
      ),
      SharedSettingsItem(
        icon: Icons.share_rounded,
        title: l10n.shareApp,
        subtitle: l10n.shareAppDesc,
        onTap: () => context.push(role.routeTo('/settings/share-app')),
      ),
    ];
  }

  List<SharedSettingsItem> _aboutItems(
    SharedSettingsRole role,
    AppLocalizations l10n,
  ) {
    return [
      SharedSettingsItem(
        icon: Icons.article_outlined,
        title: l10n.termsOfService,
        onTap: () => context.push(role.routeTo('/settings/terms')),
      ),
      SharedSettingsItem(
        icon: Icons.privacy_tip_outlined,
        title: l10n.privacyPolicy,
        onTap: () => context.push(role.routeTo('/settings/privacy-policy')),
      ),
      SharedSettingsItem(
        icon: Icons.description_outlined,
        title: l10n.licenses,
        onTap: () => showLicensePage(
          context: context,
          applicationName: 'EduVerse',
          applicationVersion: '1.0.0',
        ),
      ),
      SharedSettingsItem(
        icon: Icons.info_outline_rounded,
        title: l10n.appVersion,
        subtitle: '1.0.0 (Build 100)',
      ),
    ];
  }

  Widget _buildDangerZone(
    RoleProfileTheme roleTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SharedSettingsSection(
      title: l10n.dangerZone,
      icon: Icons.warning_amber_rounded,
      isDark: isDark,
      theme: roleTheme,
      items: [
        SharedSettingsItem(
          icon: Icons.logout_rounded,
          title: l10n.signOut,
          destructive: true,
          onTap: () => _showSignOutDialog(l10n, isDark, roleTheme),
        ),
        SharedSettingsItem(
          icon: Icons.delete_forever_outlined,
          title: l10n.deleteAccount,
          subtitle: l10n.sharedSettingsDeleteAccountUnavailableSubtitle,
          destructive: true,
          onTap: () => _showDeleteUnavailableDialog(l10n, isDark, roleTheme),
        ),
      ],
    );
  }

  void _showChangePasswordSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;
    bool isSaving = false;

    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsSheetHandle(isDark: isDark),
                const SizedBox(height: 20),
                _sheetTitle(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.changePassword,
                  roleTheme: roleTheme,
                  isDark: isDark,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: currentController,
                  label: l10n.currentPassword,
                  isDark: isDark,
                  roleTheme: roleTheme,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: newController,
                  label: l10n.newPassword,
                  isDark: isDark,
                  roleTheme: roleTheme,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: confirmController,
                  label: l10n.confirmPassword,
                  isDark: isDark,
                  roleTheme: roleTheme,
                  obscureText: true,
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorText!,
                    style: TextStyle(
                      color: roleTheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SharedSettingsPrimaryButton(
                  label: isSaving ? l10n.pleaseWait : l10n.updatePassword,
                  accent: roleTheme.primary,
                  icon: Icons.check_rounded,
                  onPressed: isSaving
                      ? null
                      : () async {
                          final current = currentController.text.trim();
                          final next = newController.text.trim();
                          final confirm = confirmController.text.trim();
                          if (current.isEmpty ||
                              next.isEmpty ||
                              confirm.isEmpty) {
                            setSheetState(() => errorText = l10n.fieldRequired);
                            return;
                          }
                          if (next != confirm) {
                            setSheetState(
                              () => errorText = l10n.passwordMismatch,
                            );
                            return;
                          }
                          setSheetState(() {
                            isSaving = true;
                            errorText = null;
                          });
                          final success = await context
                              .read<ProfileCubit>()
                              .changePassword(current, next);
                          if (!sheetContext.mounted) return;
                          if (success) {
                            Navigator.pop(sheetContext);
                            _showSnack(l10n.passwordChangedSuccess, roleTheme);
                          } else {
                            setSheetState(() {
                              isSaving = false;
                              errorText = l10n.sharedSettingsPasswordFailed;
                            });
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPhoneSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is! ProfileLoaded) {
      _showSnack(l10n.sharedSettingsProfileLoadingMessage, roleTheme);
      return;
    }

    final controller = TextEditingController(
      text: profileState.profile.phoneNumber ?? '',
    );
    bool isSaving = false;

    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsSheetHandle(isDark: isDark),
                const SizedBox(height: 20),
                _sheetTitle(
                  icon: Icons.phone_outlined,
                  title: l10n.phoneNumber,
                  roleTheme: roleTheme,
                  isDark: isDark,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: controller,
                  label: l10n.phoneNumber,
                  isDark: isDark,
                  roleTheme: roleTheme,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 22),
                SharedSettingsPrimaryButton(
                  label: isSaving ? l10n.pleaseWait : l10n.save,
                  accent: roleTheme.primary,
                  icon: Icons.check_rounded,
                  onPressed: isSaving
                      ? null
                      : () async {
                          setSheetState(() => isSaving = true);
                          final profile = profileState.profile;
                          final success = await context
                              .read<ProfileCubit>()
                              .updateProfile(
                                UpdateUserProfileRequest(
                                  firstName: profile.firstName,
                                  lastName: profile.lastName,
                                  phone: controller.text.trim(),
                                  profilePictureUrl: profile.profilePictureUrl,
                                  bio: profile.bio,
                                  socialLinks: profile.socialLinks,
                                  academicInterests: profile.academicInterests,
                                  skills: profile.skills,
                                ),
                              );
                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          _showSnack(
                            success
                                ? l10n.phoneUpdated
                                : l10n.sharedSettingsProfileUpdateFailed,
                            roleTheme,
                          );
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showThemeSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    final mode = context.read<ThemeBloc>().state.themeMode;
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => _optionSheet(
        title: l10n.theme,
        icon: Icons.palette_outlined,
        isDark: isDark,
        roleTheme: roleTheme,
        children: AppThemeMode.values.map((themeMode) {
          return _buildOptionTile(
            isDark: isDark,
            roleTheme: roleTheme,
            title: _themeLabel(themeMode, l10n),
            icon: _themeIcon(themeMode),
            selected: mode == themeMode,
            onTap: () {
              context.read<ThemeBloc>().add(SetThemeModeEvent(themeMode));
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showLanguageSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    final languageCode = context.read<LanguageCubit>().state.languageCode;
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => _optionSheet(
        title: l10n.language,
        icon: Icons.language_rounded,
        isDark: isDark,
        roleTheme: roleTheme,
        children: [
          _buildOptionTile(
            isDark: isDark,
            roleTheme: roleTheme,
            title: l10n.english,
            icon: Icons.translate_rounded,
            selected: languageCode == 'en',
            onTap: () {
              context.read<LanguageCubit>().changeLanguage('en');
              Navigator.pop(context);
            },
          ),
          _buildOptionTile(
            isDark: isDark,
            roleTheme: roleTheme,
            title: l10n.arabic,
            icon: Icons.translate_rounded,
            selected: languageCode == 'ar',
            onTap: () {
              context.read<LanguageCubit>().changeLanguage('ar');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFontSizeSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    final currentSize = context.read<ThemeBloc>().state.fontSize;
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => _optionSheet(
        title: l10n.fontSize,
        icon: Icons.text_fields_rounded,
        isDark: isDark,
        roleTheme: roleTheme,
        children: FontSizeOption.values.map((size) {
          return _buildOptionTile(
            isDark: isDark,
            roleTheme: roleTheme,
            title: _fontSizeLabel(size, l10n),
            icon: Icons.text_fields_rounded,
            selected: currentSize == size,
            onTap: () {
              context.read<ThemeBloc>().add(SetFontSizeEvent(size));
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _optionSheet({
    required String title,
    required IconData icon,
    required bool isDark,
    required RoleProfileTheme roleTheme,
    required List<Widget> children,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSheetHandle(isDark: isDark),
        const SizedBox(height: 20),
        _sheetTitle(
          icon: icon,
          title: title,
          roleTheme: roleTheme,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildOptionTile({
    required bool isDark,
    required RoleProfileTheme roleTheme,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? roleTheme.primary.withValues(alpha: isDark ? 0.24 : 0.16)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.62)),
            border: Border.all(
              color: selected
                  ? roleTheme.primary.withValues(alpha: 0.58)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.07)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? roleTheme.primary
                    : roleTheme.textSecondary(isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: roleTheme.textPrimary(isDark),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected) Icon(Icons.check_rounded, color: roleTheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstructorGradingSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    bool showRubric = true;
    bool anonymous = false;
    String scale = 'percentage';
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return _settingsPreferenceSheet(
            l10n: l10n,
            title: l10n.gradingPreferences,
            icon: Icons.grading_outlined,
            isDark: isDark,
            roleTheme: roleTheme,
            children: [
              _switchRow(
                title: l10n.autoSaveGrades,
                subtitle: l10n.autoSaveGradesDesc,
                value: _instructorAutoSave,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) {
                  setState(() => _instructorAutoSave = value);
                  setSheetState(() {});
                  _saveBoolPreference('grading_auto_save', value);
                },
              ),
              _switchRow(
                title: l10n.showRubricByDefault,
                subtitle: l10n.showRubricByDefaultDesc,
                value: showRubric,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => showRubric = value),
              ),
              _switchRow(
                title: l10n.anonymousGrading,
                subtitle: l10n.anonymousGradingDesc,
                value: anonymous,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => anonymous = value),
              ),
              _choiceWrap(
                title: l10n.defaultGradeScale,
                values: [
                  _Choice('percentage', l10n.sharedSettingsPercentage),
                  _Choice('letter', l10n.sharedSettingsLetterGrade),
                  _Choice('points', l10n.sharedSettingsPoints),
                ],
                selected: scale,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => scale = value),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAssignmentDefaultsSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    bool lateSubmissions = true;
    double penalty = 10;
    int defaultDays = 7;
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return _settingsPreferenceSheet(
            l10n: l10n,
            title: l10n.assignmentDefaults,
            icon: Icons.assignment_outlined,
            isDark: isDark,
            roleTheme: roleTheme,
            children: [
              _switchRow(
                title: l10n.allowLateSubmissions,
                subtitle: l10n.allowLateSubmissionsDesc,
                value: lateSubmissions,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) =>
                    setSheetState(() => lateSubmissions = value),
              ),
              _sliderRow(
                title: l10n.latePenaltyPerDay,
                value: penalty,
                suffix: '%',
                max: 25,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => penalty = value),
              ),
              _choiceWrap(
                title: l10n.defaultSubmissionDays,
                values: [3, 5, 7, 14, 21]
                    .map(
                      (days) =>
                          _Choice('$days', l10n.sharedSettingsDaysCount(days)),
                    )
                    .toList(),
                selected: '$defaultDays',
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) =>
                    setSheetState(() => defaultDays = int.parse(value)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAttendanceSettingsSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    bool autoAttendance = false;
    bool lateMarking = true;
    int threshold = 15;
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return _settingsPreferenceSheet(
            l10n: l10n,
            title: l10n.attendanceSettings,
            icon: Icons.how_to_reg_outlined,
            isDark: isDark,
            roleTheme: roleTheme,
            children: [
              _switchRow(
                title: l10n.autoAttendance,
                subtitle: l10n.autoAttendanceDesc,
                value: autoAttendance,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) =>
                    setSheetState(() => autoAttendance = value),
              ),
              _switchRow(
                title: l10n.enableLateMarking,
                subtitle: l10n.enableLateMarkingDesc,
                value: lateMarking,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => lateMarking = value),
              ),
              _choiceWrap(
                title: l10n.lateThreshold,
                values: [5, 10, 15, 20, 30]
                    .map(
                      (minutes) => _Choice(
                        '$minutes',
                        l10n.sharedSettingsMinutesCount(minutes),
                      ),
                    )
                    .toList(),
                selected: '$threshold',
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) =>
                    setSheetState(() => threshold = int.parse(value)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOfficeHoursSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    final selectedDays = <String>{'monday', 'wednesday', 'friday'};
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final days = [
            _Choice('monday', l10n.sharedSettingsMonday),
            _Choice('wednesday', l10n.sharedSettingsWednesday),
            _Choice('friday', l10n.sharedSettingsFriday),
          ];
          return _settingsPreferenceSheet(
            l10n: l10n,
            title: l10n.taSettingsOfficeHours,
            icon: Icons.schedule_rounded,
            isDark: isDark,
            roleTheme: roleTheme,
            children: [
              _choiceWrap(
                title: l10n.sharedSettingsAvailableDays,
                values: days,
                selected: selectedDays.join(','),
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) {
                  setSheetState(() {
                    if (!selectedDays.add(value)) {
                      selectedDays.remove(value);
                    }
                  });
                },
                isSelected: selectedDays.contains,
              ),
              Text(
                l10n.sharedSettingsOfficeHoursNote,
                style: TextStyle(
                  color: roleTheme.textSecondary(isDark),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTAGradingSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    bool showAi = true;
    bool autoSave = true;
    bool plagiarism = false;
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return _settingsPreferenceSheet(
            l10n: l10n,
            title: l10n.taSettingsGradingPrefs,
            icon: Icons.grading_rounded,
            isDark: isDark,
            roleTheme: roleTheme,
            children: [
              _switchRow(
                title: l10n.sharedSettingsShowAISuggestions,
                subtitle: l10n.sharedSettingsShowAISuggestionsDesc,
                value: showAi,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => showAi = value),
              ),
              _switchRow(
                title: l10n.autoSaveGrades,
                subtitle: l10n.sharedSettingsAutoSaveGradesDesc,
                value: autoSave,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => autoSave = value),
              ),
              _switchRow(
                title: l10n.sharedSettingsPlagiarismCheck,
                subtitle: l10n.sharedSettingsPlagiarismCheckDesc,
                value: plagiarism,
                roleTheme: roleTheme,
                isDark: isDark,
                onChanged: (value) => setSheetState(() => plagiarism = value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _settingsPreferenceSheet({
    required AppLocalizations l10n,
    required String title,
    required IconData icon,
    required bool isDark,
    required RoleProfileTheme roleTheme,
    required List<Widget> children,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSheetHandle(isDark: isDark),
        const SizedBox(height: 20),
        _sheetTitle(
          icon: icon,
          title: title,
          roleTheme: roleTheme,
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        ...children.expand((child) => [child, const SizedBox(height: 14)]),
        SharedSettingsPrimaryButton(
          label: l10n.saveChanges,
          accent: roleTheme.primary,
          icon: Icons.check_rounded,
          onPressed: () {
            Navigator.pop(context);
            _showSnack(l10n.settingsSaved, roleTheme);
          },
        ),
      ],
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required RoleProfileTheme roleTheme,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: roleTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: roleTheme.textSecondary(isDark),
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: roleTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _sliderRow({
    required String title,
    required double value,
    required String suffix,
    required double max,
    required RoleProfileTheme roleTheme,
    required bool isDark,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${value.round()}$suffix',
          style: TextStyle(
            color: roleTheme.textPrimary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        Slider(
          value: value,
          min: 0,
          max: max,
          divisions: max.round(),
          activeColor: roleTheme.primary,
          inactiveColor: roleTheme.primary.withValues(alpha: 0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _choiceWrap({
    required String title,
    required List<_Choice> values,
    required String selected,
    required RoleProfileTheme roleTheme,
    required bool isDark,
    required ValueChanged<String> onChanged,
    bool Function(String value)? isSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: roleTheme.textPrimary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((choice) {
            final selectedChoice =
                isSelected?.call(choice.value) ?? selected == choice.value;
            return ChoiceChip(
              selected: selectedChoice,
              label: Text(choice.label),
              onSelected: (_) => onChanged(choice.value),
              selectedColor: roleTheme.primary.withValues(alpha: 0.24),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.65),
              side: BorderSide(
                color: selectedChoice
                    ? roleTheme.primary
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.black.withValues(alpha: 0.08)),
              ),
              labelStyle: TextStyle(
                color: selectedChoice
                    ? (isDark ? Colors.white : roleTheme.primary)
                    : roleTheme.textSecondary(isDark),
                fontWeight: FontWeight.w700,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showClearCacheDialog(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    showSettingsGlassDialog<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => _confirmationContent(
        title: l10n.clearCache,
        message: l10n.clearCacheConfirmation,
        icon: Icons.cleaning_services_outlined,
        confirmLabel: l10n.clear,
        roleTheme: roleTheme,
        isDark: isDark,
        onConfirm: () {
          Navigator.pop(context);
          _showSnack(l10n.cacheCleared, roleTheme);
        },
      ),
    );
  }

  void _showExportDataDialog(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    showSettingsGlassDialog<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => _confirmationContent(
        title: l10n.downloadMyData,
        message: l10n.downloadDataConfirmation,
        icon: Icons.download_rounded,
        confirmLabel: l10n.download,
        roleTheme: roleTheme,
        isDark: isDark,
        onConfirm: () {
          Navigator.pop(context);
          context.read<ProfileCubit>().exportData();
          _showSnack(l10n.dataExportStarted, roleTheme);
        },
      ),
    );
  }

  void _showSignOutDialog(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    showSettingsGlassDialog<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.error,
      builder: (_) => _confirmationContent(
        title: l10n.signOut,
        message: l10n.signOutConfirmation,
        icon: Icons.logout_rounded,
        confirmLabel: l10n.signOut,
        roleTheme: roleTheme,
        isDark: isDark,
        destructive: true,
        onConfirm: () {
          Navigator.pop(context);
          context.read<AuthBloc>().add(const LogoutRequested());
          context.go('/login');
        },
      ),
    );
  }

  void _showDeleteUnavailableDialog(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    showSettingsGlassDialog<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.error,
      builder: (_) => _confirmationContent(
        title: l10n.sharedSettingsDeleteAccountUnavailableTitle,
        message: l10n.sharedSettingsDeleteAccountUnavailableMessage,
        icon: Icons.delete_forever_outlined,
        confirmLabel: l10n.close,
        roleTheme: roleTheme,
        isDark: isDark,
        destructive: true,
        onConfirm: () => Navigator.pop(context),
      ),
    );
  }

  Widget _confirmationContent({
    required String title,
    required String message,
    required IconData icon,
    required String confirmLabel,
    required RoleProfileTheme roleTheme,
    required bool isDark,
    required VoidCallback onConfirm,
    bool destructive = false,
  }) {
    final accent = destructive ? roleTheme.error : roleTheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetTitle(
          icon: icon,
          title: title,
          roleTheme: roleTheme,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        Text(
          message,
          style: TextStyle(
            color: roleTheme.textSecondary(isDark),
            fontSize: 14,
            height: 1.42,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: roleTheme.textPrimary(isDark),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: 0.10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(l10nCancel(context)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SharedSettingsPrimaryButton(
                label: confirmLabel,
                accent: accent,
                destructive: destructive,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String l10nCancel(BuildContext context) =>
      AppLocalizations.of(context).cancel;

  void _showTextEntrySheet({
    required String title,
    required String hint,
    required String successMessage,
    required bool isDark,
    required RoleProfileTheme roleTheme,
    required AppLocalizations l10n,
  }) {
    final controller = TextEditingController();
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSheetHandle(isDark: isDark),
          const SizedBox(height: 20),
          _sheetTitle(
            icon: Icons.feedback_outlined,
            title: title,
            roleTheme: roleTheme,
            isDark: isDark,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: controller,
            label: hint,
            isDark: isDark,
            roleTheme: roleTheme,
            maxLines: 5,
          ),
          const SizedBox(height: 22),
          SharedSettingsPrimaryButton(
            label: l10n.submit,
            accent: roleTheme.primary,
            icon: Icons.send_rounded,
            onPressed: () {
              Navigator.pop(sheetContext);
              _showSnack(successMessage, roleTheme);
            },
          ),
        ],
      ),
    );
  }

  void _showBugReportSheet(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    showSettingsGlassBottomSheet<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSheetHandle(isDark: isDark),
          const SizedBox(height: 20),
          _sheetTitle(
            icon: Icons.bug_report_outlined,
            title: l10n.reportBug,
            roleTheme: roleTheme,
            isDark: isDark,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: titleController,
            label: l10n.bugTitle,
            isDark: isDark,
            roleTheme: roleTheme,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: descriptionController,
            label: l10n.bugDescription,
            isDark: isDark,
            roleTheme: roleTheme,
            maxLines: 4,
          ),
          const SizedBox(height: 22),
          SharedSettingsPrimaryButton(
            label: l10n.submit,
            accent: roleTheme.primary,
            icon: Icons.send_rounded,
            onPressed: () {
              Navigator.pop(sheetContext);
              _showSnack(l10n.bugReportSent, roleTheme);
            },
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    int selectedRating = 0;
    showSettingsGlassDialog<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetTitle(
                icon: Icons.star_rounded,
                title: l10n.rateApp,
                roleTheme: roleTheme,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.rateAppMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: roleTheme.textSecondary(isDark),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 3,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () =>
                        setDialogState(() => selectedRating = index + 1),
                    icon: Icon(
                      index < selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < selectedRating
                          ? Colors.amber
                          : roleTheme.textTertiary(isDark),
                      size: 30,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              SharedSettingsPrimaryButton(
                label: l10n.submit,
                accent: roleTheme.primary,
                onPressed: selectedRating == 0
                    ? null
                    : () {
                        Navigator.pop(context);
                        _showSnack(l10n.thankYouForRating, roleTheme);
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSearchDialog(
    AppLocalizations l10n,
    bool isDark,
    RoleProfileTheme roleTheme,
  ) {
    var query = '';
    showSettingsGlassDialog<void>(
      context: context,
      isDark: isDark,
      accent: roleTheme.primary,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final entries = _searchEntries(l10n)
                .where(
                  (entry) =>
                      entry.title.toLowerCase().contains(query.toLowerCase()) ||
                      entry.subtitle.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetTitle(
                  icon: Icons.search_rounded,
                  title: l10n.searchSettings,
                  roleTheme: roleTheme,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  style: TextStyle(color: roleTheme.textPrimary(isDark)),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: roleTheme.primary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.72),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setDialogState(() => query = value),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: entries.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.noResultsFound,
                              style: TextStyle(
                                color: roleTheme.textSecondary(isDark),
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return _buildOptionTile(
                              isDark: isDark,
                              roleTheme: roleTheme,
                              title: entry.title,
                              icon: entry.icon,
                              selected: false,
                              onTap: () {
                                Navigator.pop(dialogContext);
                                entry.onTap();
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<_SearchEntry> _searchEntries(AppLocalizations l10n) {
    final role = widget.role;
    return [
      _SearchEntry(
        l10n.editProfile,
        l10n.account,
        Icons.person_outline_rounded,
        () => context.push(role.editProfileRoute),
      ),
      _SearchEntry(
        l10n.changePassword,
        l10n.account,
        Icons.lock_outline_rounded,
        () => _showChangePasswordSheet(
          l10n,
          context.read<ThemeBloc>().state.isDark,
          role.theme,
        ),
      ),
      _SearchEntry(
        l10n.pushNotifications,
        l10n.notifications,
        Icons.notifications_active_outlined,
        () => context.push(role.routeTo('/settings/notifications')),
      ),
      _SearchEntry(
        l10n.appearance,
        l10n.theme,
        Icons.palette_outlined,
        () => _showThemeSheet(
          l10n,
          context.read<ThemeBloc>().state.isDark,
          role.theme,
        ),
      ),
      _SearchEntry(
        l10n.language,
        l10n.currentLanguage,
        Icons.language_rounded,
        () => _showLanguageSheet(
          l10n,
          context.read<ThemeBloc>().state.isDark,
          role.theme,
        ),
      ),
      _SearchEntry(
        l10n.privacySettings,
        l10n.privacySecurity,
        Icons.privacy_tip_outlined,
        () => context.push(role.routeTo('/settings/privacy')),
      ),
      _SearchEntry(
        l10n.storageData,
        l10n.downloadSettings,
        Icons.storage_outlined,
        () => context.push(role.routeTo('/settings/storage')),
      ),
      _SearchEntry(
        l10n.helpCenter,
        l10n.support,
        Icons.help_outline_rounded,
        () => context.push(role.routeTo('/settings/help')),
      ),
    ];
  }

  Widget _sheetTitle({
    required IconData icon,
    required String title,
    required RoleProfileTheme roleTheme,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.all(10),
          decoration: BoxDecoration(
            color: roleTheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: roleTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: roleTheme.textPrimary(isDark),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    required RoleProfileTheme roleTheme,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: roleTheme.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: roleTheme.textSecondary(isDark)),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: roleTheme.primary, width: 1.6),
        ),
      ),
    );
  }

  void _showSnack(String message, RoleProfileTheme roleTheme) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: roleTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _roleToolsTitle(SharedSettingsRole role, AppLocalizations l10n) {
    switch (role) {
      case SharedSettingsRole.instructor:
        return l10n.teachingSettings;
      case SharedSettingsRole.ta:
        return l10n.taSettingsTools;
      case SharedSettingsRole.student:
        return l10n.learning;
    }
  }

  IconData _roleToolsIcon(SharedSettingsRole role) {
    switch (role) {
      case SharedSettingsRole.instructor:
        return Icons.school_outlined;
      case SharedSettingsRole.ta:
        return Icons.build_outlined;
      case SharedSettingsRole.student:
        return Icons.school_outlined;
    }
  }

  String _themeLabel(AppThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AppThemeMode.light:
        return l10n.light;
      case AppThemeMode.dark:
        return l10n.dark;
      case AppThemeMode.system:
        return l10n.system;
    }
  }

  IconData _themeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.system:
        return Icons.settings_suggest_rounded;
    }
  }

  String _fontSizeLabel(FontSizeOption size, AppLocalizations l10n) {
    switch (size) {
      case FontSizeOption.small:
        return l10n.small;
      case FontSizeOption.medium:
        return l10n.medium;
      case FontSizeOption.large:
        return l10n.large;
    }
  }
}

class _Choice {
  final String value;
  final String label;

  const _Choice(this.value, this.label);
}

class _SearchEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchEntry(this.title, this.subtitle, this.icon, this.onTap);
}
