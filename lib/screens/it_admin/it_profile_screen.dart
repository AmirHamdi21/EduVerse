import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/it_admin/profile/it_profile_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';

class ITProfileScreen extends StatefulWidget {
  const ITProfileScreen({super.key});

  @override
  State<ITProfileScreen> createState() => _ITProfileScreenState();
}

class _ITProfileScreenState extends State<ITProfileScreen> {
  ProfileTab _selectedTab = ProfileTab.personal;
  bool _isLoading = false;
  String? _error;

  // Mock data
  late ITAdminProfile _profile;
  late NotificationPreferences _notificationPrefs;
  late UIPreferences _uiPrefs;
  late List<ActiveSession> _sessions;
  late List<ApiToken> _apiTokens;
  late List<ActivityLogEntry> _activityLog;
  bool _mfaEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _profile = ITAdminProfile(
          id: 'it-001',
          fullName: 'Dr. Michael Chen',
          email: 'michael.chen@eduverse.edu',
          employeeId: 'IT-2024-001',
          role: 'IT Administrator',
          department: 'IT Division',
          phone: '+1 (555) 123-4567',
          timezone: 'UTC-5 (EST)',
          language: 'English',
          isActive: true,
          lastLogin: DateTime.now().subtract(const Duration(minutes: 15)),
          permissions: [
            'Full System Access',
            'User Management',
            'Security Configuration',
            'Database Administration',
            'API Management',
            'Backup & Recovery',
            'Integration Management',
            'AI Model Configuration',
          ],
        );

        _notificationPrefs = const NotificationPreferences(
          securityAlerts: true,
          systemOutageUpdates: true,
          integrationWarnings: true,
          aiAnomalyNotifications: false,
          emailDelivery: true,
          smsDelivery: false,
          inAppDelivery: true,
          slackDelivery: true,
        );

        _uiPrefs = const UIPreferences(
          themeMode: ThemeModeOption.auto,
          accentColor: AccentColorOption.cyan,
          uiDensity: 'Standard',
          advancedMetricsMode: true,
        );

        _sessions = [
          ActiveSession(
            id: 'session-1',
            name: 'Desktop - Chrome',
            device: SessionDevice.desktop,
            ip: '192.168.1.100',
            location: 'New York, USA',
            lastActive: DateTime.now(),
            isCurrentSession: true,
          ),
          ActiveSession(
            id: 'session-2',
            name: 'Mobile - Safari',
            device: SessionDevice.mobile,
            ip: '192.168.1.105',
            location: 'New York, USA',
            lastActive: DateTime.now().subtract(const Duration(hours: 2)),
            isCurrentSession: false,
          ),
          ActiveSession(
            id: 'session-3',
            name: 'Tablet - Edge',
            device: SessionDevice.tablet,
            ip: '192.168.1.110',
            location: 'Boston, USA',
            lastActive: DateTime.now().subtract(const Duration(days: 1)),
            isCurrentSession: false,
          ),
        ];

        _apiTokens = [
          ApiToken(
            id: 'token-1',
            name: 'Production API Token',
            preview: 'sk_prod_****4567',
            expiresAt: DateTime.now().add(const Duration(days: 30)),
            isActive: true,
          ),
          ApiToken(
            id: 'token-2',
            name: 'Development Token',
            preview: 'sk_dev_****8901',
            expiresAt: DateTime.now().add(const Duration(days: 90)),
            isActive: true,
          ),
        ];

        _activityLog = [
          ActivityLogEntry(
            id: 'log-1',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            action: 'Password changed',
            severity: 'High',
            result: 'success',
          ),
          ActivityLogEntry(
            id: 'log-2',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            action: 'MFA device added',
            severity: 'High',
            result: 'success',
          ),
          ActivityLogEntry(
            id: 'log-3',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            action: 'Profile updated',
            severity: 'Low',
            result: 'success',
          ),
          ActivityLogEntry(
            id: 'log-4',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            action: 'API token generated',
            severity: 'Medium',
            result: 'success',
          ),
          ActivityLogEntry(
            id: 'log-5',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            action: 'Login from new device',
            severity: 'Medium',
            result: 'success',
          ),
        ];

        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? ITColors.darkBackground
          : ITColors.lightBackground,
      body: _isLoading
          ? _buildLoadingState(isDark)
          : _error != null
          ? _buildErrorState(isDark)
          : _buildContent(isDark),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ITColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: ITColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ITColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 60,
          floating: true,
          pinned: true,
          backgroundColor: isDark ? ITColors.darkCard : Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ITColors.textPrimaryColor(isDark),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ITColors.textPrimaryColor(isDark),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: ITColors.primary),
              onPressed: () => context.push('/it-admin/edit-profile'),
              tooltip: 'Edit Profile',
            ),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Profile Header
              ITProfileHeader(isDark: isDark, profile: _profile),
              const SizedBox(height: 16),

              // Quick Actions
              ITProfileQuickActions(
                isDark: isDark,
                onEditProfile: () => context.push('/it-admin/edit-profile'),
                onManageSecurity: () {
                  setState(() => _selectedTab = ProfileTab.security);
                },
                onViewActivityLogs: () {
                  setState(() => _selectedTab = ProfileTab.preferences);
                },
              ),
              const SizedBox(height: 16),

              // Permissions Section
              ITProfilePermissionsSection(
                isDark: isDark,
                role: _profile.role,
                accessLevel: 'Full System Access',
                permissions: _profile.permissions,
                onViewFullPermissions: () {
                  _showPermissionsDialog(isDark);
                },
              ),
              const SizedBox(height: 20),

              // Tab Bar
              ITProfileTabBar(
                isDark: isDark,
                selectedTab: _selectedTab,
                onTabChanged: (tab) => setState(() => _selectedTab = tab),
              ),
              const SizedBox(height: 16),

              // Tab Content
              _buildTabContent(isDark),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(bool isDark) {
    switch (_selectedTab) {
      case ProfileTab.personal:
        return ITProfilePersonalTab(
          isDark: isDark,
          profile: _profile,
          onSave: (updated) {
            setState(() => _profile = updated);
          },
        );
      case ProfileTab.notifications:
        return ITProfileNotificationsTab(
          isDark: isDark,
          preferences: _notificationPrefs,
          onSave: (updated) {
            setState(() => _notificationPrefs = updated);
          },
        );
      case ProfileTab.security:
        return ITProfileSecurityTab(
          isDark: isDark,
          mfaEnabled: _mfaEnabled,
          sessions: _sessions,
          apiTokens: _apiTokens,
          onChangePassword: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Password changed successfully'),
                backgroundColor: ITColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          onSetupMfa: () {
            showDialog(
              context: context,
              builder: (ctx) => ITSetupMfaDialog(
                isDark: isDark,
                onComplete: () {
                  setState(() => _mfaEnabled = true);
                },
              ),
            );
          },
          onAddDevice: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Device added for MFA'),
                backgroundColor: ITColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          onTerminateSession: (sessionId) {
            setState(() {
              _sessions.removeWhere((s) => s.id == sessionId);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Session terminated'),
                backgroundColor: ITColors.warning,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          onTerminateAllSessions: () {
            _showConfirmDialog(
              isDark: isDark,
              title: 'Terminate All Sessions',
              message:
                  'This will log you out from all devices except the current one. Continue?',
              onConfirm: () {
                setState(() {
                  _sessions.removeWhere((s) => !s.isCurrentSession);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All other sessions terminated'),
                    backgroundColor: ITColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            );
          },
          onGenerateToken: () {
            final newToken = ApiToken(
              id: 'token-${DateTime.now().millisecondsSinceEpoch}',
              name: 'New API Token',
              preview:
                  'sk_new_****${DateTime.now().second}${DateTime.now().millisecond}',
              expiresAt: DateTime.now().add(const Duration(days: 90)),
              isActive: true,
            );
            setState(() => _apiTokens.add(newToken));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('New API token generated'),
                backgroundColor: ITColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          onRevokeToken: (tokenId) {
            _showConfirmDialog(
              isDark: isDark,
              title: 'Revoke Token',
              message:
                  'This will immediately invalidate this API token. Continue?',
              onConfirm: () {
                setState(() {
                  _apiTokens.removeWhere((t) => t.id == tokenId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('API token revoked'),
                    backgroundColor: ITColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            );
          },
        );
      case ProfileTab.preferences:
        return ITProfilePreferencesTab(
          isDark: isDark,
          preferences: _uiPrefs,
          activityLog: _activityLog,
          onSave: (updated) {
            setState(() => _uiPrefs = updated);
          },
          onRevokeApiKeys: () {
            _showConfirmDialog(
              isDark: isDark,
              title: 'Revoke All API Keys',
              message:
                  'This will invalidate ALL your API tokens. This action cannot be undone. Continue?',
              onConfirm: () {
                setState(() => _apiTokens.clear());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All API keys revoked'),
                    backgroundColor: ITColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            );
          },
          onResetSecuritySettings: () {
            _showConfirmDialog(
              isDark: isDark,
              title: 'Reset Security Settings',
              message:
                  'This will reset MFA and all security preferences. You will need to set them up again. Continue?',
              onConfirm: () {
                setState(() => _mfaEnabled = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Security settings reset'),
                    backgroundColor: ITColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            );
          },
          onRequestRoleDowngrade: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Role downgrade request submitted'),
                backgroundColor: ITColors.info,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        );
    }
  }

  void _showPermissionsDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ITColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.security_rounded, color: ITColors.primary),
            const SizedBox(width: 8),
            Text(
              'Full Permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _profile.permissions.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: ITColors.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 14,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: ITColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog({
    required bool isDark,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ITColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: ITColors.warning),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ITColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
