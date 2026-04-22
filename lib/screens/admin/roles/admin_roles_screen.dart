import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/roles/roles_barrel.dart';
import '../../../generated_l10n/app_localizations.dart';

/// Admin Role & Permissions Management Screen
class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  String _selectedRole = 'student';
  bool _isLoading = false;
  bool _hasChanges = false;
  List<Permission> _permissions = [];

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  void _loadPermissions() {
    _permissions = _getDefaultPermissions(_selectedRole);
  }

  List<Permission> _getDefaultPermissions(String role) {
    switch (role) {
      case 'student':
        return [
          Permission(
            module: 'Courses',
            moduleKey: 'courses',
            icon: Icons.menu_book_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'Labs',
            moduleKey: 'labs',
            icon: Icons.science_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'Assignments',
            moduleKey: 'assignments',
            icon: Icons.assignment_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'Grades',
            moduleKey: 'grades',
            icon: Icons.grade_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'Discussion',
            moduleKey: 'discussion',
            icon: Icons.forum_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'AI Assistant',
            moduleKey: 'ai_assistant',
            icon: Icons.smart_toy_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'Users',
            moduleKey: 'users',
            icon: Icons.people_rounded,
            canView: false,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'System',
            moduleKey: 'system',
            icon: Icons.settings_rounded,
            canView: false,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
        ];
      case 'instructor':
        return [
          Permission(
            module: 'Courses',
            moduleKey: 'courses',
            icon: Icons.menu_book_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'Labs',
            moduleKey: 'labs',
            icon: Icons.science_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'Assignments',
            moduleKey: 'assignments',
            icon: Icons.assignment_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'Grades',
            moduleKey: 'grades',
            icon: Icons.grade_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'Discussion',
            moduleKey: 'discussion',
            icon: Icons.forum_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'AI Assistant',
            moduleKey: 'ai_assistant',
            icon: Icons.smart_toy_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'Users',
            moduleKey: 'users',
            icon: Icons.people_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'System',
            moduleKey: 'system',
            icon: Icons.settings_rounded,
            canView: false,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
        ];
      case 'ta':
        return [
          Permission(
            module: 'Courses',
            moduleKey: 'courses',
            icon: Icons.menu_book_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'Labs',
            moduleKey: 'labs',
            icon: Icons.science_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'Assignments',
            moduleKey: 'assignments',
            icon: Icons.assignment_rounded,
            canView: true,
            canCreate: false,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'Grades',
            moduleKey: 'grades',
            icon: Icons.grade_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'Discussion',
            moduleKey: 'discussion',
            icon: Icons.forum_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: false,
          ),
          Permission(
            module: 'AI Assistant',
            moduleKey: 'ai_assistant',
            icon: Icons.smart_toy_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'Users',
            moduleKey: 'users',
            icon: Icons.people_rounded,
            canView: true,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
          Permission(
            module: 'System',
            moduleKey: 'system',
            icon: Icons.settings_rounded,
            canView: false,
            canCreate: false,
            canEdit: false,
            canDelete: false,
          ),
        ];
      case 'admin':
        return [
          Permission(
            module: 'Courses',
            moduleKey: 'courses',
            icon: Icons.menu_book_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'Labs',
            moduleKey: 'labs',
            icon: Icons.science_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'Assignments',
            moduleKey: 'assignments',
            icon: Icons.assignment_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'Grades',
            moduleKey: 'grades',
            icon: Icons.grade_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'Discussion',
            moduleKey: 'discussion',
            icon: Icons.forum_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'AI Assistant',
            moduleKey: 'ai_assistant',
            icon: Icons.smart_toy_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'Users',
            moduleKey: 'users',
            icon: Icons.people_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
          Permission(
            module: 'System',
            moduleKey: 'system',
            icon: Icons.settings_rounded,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          ),
        ];
      default:
        return [];
    }
  }

  void _onRoleChanged(String role) {
    if (_hasChanges) {
      _showUnsavedChangesDialog(role);
    } else {
      setState(() {
        _selectedRole = role;
        _loadPermissions();
      });
    }
  }

  void _showUnsavedChangesDialog(String newRole) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesDescription),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _hasChanges = false;
                _selectedRole = newRole;
                _loadPermissions();
              });
            },
            child: Text(l10n.discard),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveChanges();
              setState(() {
                _selectedRole = newRole;
                _loadPermissions();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.saveAndSwitch),
          ),
        ],
      ),
    );
  }

  void _showAddCustomRoleDialog() {
    final l10n = AppLocalizations.of(context);
    final isDark = context.read<ThemeBloc>().state.isDark;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        title: Text(
          l10n.createCustomRole,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.roleName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.customRoleDescription,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.customRoleCreated),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.permissionsSaved),
          backgroundColor: AdminColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildAppBar(isDark, l10n)),
                      SliverToBoxAdapter(child: const SizedBox(height: 16)),
                      SliverToBoxAdapter(
                        child: RoleSelector(
                          isDark: isDark,
                          selectedRole: _selectedRole,
                          onRoleChanged: _onRoleChanged,
                          onAddCustomRole: _showAddCustomRoleDialog,
                        ),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 8)),
                      SliverToBoxAdapter(
                        child: PermissionsTable(
                          isDark: isDark,
                          selectedRole: _selectedRole,
                          permissions: _permissions,
                          onPermissionsChanged: (permissions) {
                            setState(() {
                              _permissions = permissions;
                              _hasChanges = true;
                            });
                          },
                          onSaveChanges: _saveChanges,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: AIRoleRecommendations(
                          isDark: isDark,
                          selectedRole: _selectedRole,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? AdminColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AdminColors.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.savingChanges,
                                style: TextStyle(
                                  color: AdminColors.getTextColor(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AdminColors.darkDivider
                : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AdminColors.secondaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rolePermissionsManagement,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.manageRolesAndPermissions,
                  style: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AdminColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: AdminColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.unsaved,
                    style: TextStyle(
                      color: AdminColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
