import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Permission model
class Permission {
  final String module;
  final String moduleKey;
  final IconData icon;
  bool canView;
  bool canCreate;
  bool canEdit;
  bool canDelete;

  Permission({
    required this.module,
    required this.moduleKey,
    required this.icon,
    this.canView = false,
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
  });
}

/// Column widths — single source of truth so header & rows always align
const double _moduleColWidth = 180.0;
const double _toggleColWidth = 80.0;

/// Permissions table widget
class PermissionsTable extends StatelessWidget {
  final bool isDark;
  final String selectedRole;
  final List<Permission> permissions;
  final ValueChanged<List<Permission>> onPermissionsChanged;
  final VoidCallback onSaveChanges;

  const PermissionsTable({
    super.key,
    required this.isDark,
    required this.selectedRole,
    required this.permissions,
    required this.onPermissionsChanged,
    required this.onSaveChanges,
  });

  // Total table width: module column + 4 toggle columns
  double get _tableMinWidth => _moduleColWidth + (_toggleColWidth * 4);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roleColor = _getRoleColor(selectedRole);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header is full-width — no scroll needed
          _buildHeader(l10n, roleColor),

          // Table header + rows share one horizontal scroll view
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: _tableMinWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(l10n),
                  ...permissions.asMap().entries.map((entry) {
                    return _buildPermissionRow(entry.value, entry.key, l10n);
                  }),
                ],
              ),
            ),
          ),

          _buildSaveButton(l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, Color roleColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AdminColors.darkDivider : AdminColors.lightDivider,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoleIcon(selectedRole),
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
                      _getRoleName(selectedRole, l10n),
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.managePermissions,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton.icon(
              onPressed: onSaveChanges,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(l10n.saveChanges),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.primary,
                side: BorderSide(color: AdminColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.3)
            : AdminColors.lightBackground.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AdminColors.darkDivider : AdminColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          // Module column header — matches _moduleColWidth
          SizedBox(
            width: _moduleColWidth,
            child: Text(
              l10n.module,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildColumnHeader(l10n.view, AdminColors.primary),
          _buildColumnHeader(l10n.create, AdminColors.success),
          _buildColumnHeader(l10n.edit, AdminColors.warning),
          _buildColumnHeader(l10n.delete, AdminColors.error),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String label, Color color) {
    return SizedBox(
      width: _toggleColWidth,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRow(
    Permission permission,
    int index,
    AppLocalizations l10n,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: index.isEven
            ? Colors.transparent
            : (isDark
                  ? AdminColors.darkSurface.withValues(alpha: 0.2)
                  : AdminColors.lightBackground.withValues(alpha: 0.3)),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AdminColors.darkDivider.withValues(alpha: 0.5)
                : AdminColors.lightDivider.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        // crossAxisAlignment ensures toggles sit centered on the same line
        // as the module label regardless of content height
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Module cell — fixed width, clips overflow with ellipsis
          SizedBox(
            width: _moduleColWidth,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    permission.icon,
                    size: 16,
                    color: AdminColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getModuleName(permission.moduleKey, l10n),
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // Toggle cells — each fixed to _toggleColWidth
          _buildToggle(permission.canView, (value) {
            permission.canView = value;
            onPermissionsChanged(permissions);
          }),
          _buildToggle(permission.canCreate, (value) {
            permission.canCreate = value;
            onPermissionsChanged(permissions);
          }),
          _buildToggle(permission.canEdit, (value) {
            permission.canEdit = value;
            onPermissionsChanged(permissions);
          }),
          _buildToggle(permission.canDelete, (value) {
            permission.canDelete = value;
            onPermissionsChanged(permissions);
          }),
        ],
      ),
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return SizedBox(
      width: _toggleColWidth,
      child: Center(
        child: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AdminColors.primary,
            activeTrackColor: AdminColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AdminColors.getTextTertiaryColor(isDark),
            inactiveTrackColor: isDark
                ? AdminColors.darkDivider
                : AdminColors.lightDivider,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onSaveChanges,
          icon: const Icon(Icons.save_rounded),
          label: Text(l10n.saveChanges),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  String _getModuleName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'courses':
        return l10n.courses;
      case 'labs':
        return l10n.labs;
      case 'assignments':
        return l10n.assignments;
      case 'grades':
        return l10n.grades;
      case 'discussion':
        return l10n.discussions;
      case 'ai_assistant':
        return l10n.aiAssistant;
      case 'users':
        return l10n.users;
      case 'system':
        return l10n.systemSettings;
      default:
        return key;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return AdminColors.primary;
      case 'instructor':
        return AdminColors.secondary;
      case 'ta':
        return AdminColors.accent;
      case 'admin':
        return AdminColors.error;
      default:
        return AdminColors.primary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.school_rounded;
      case 'instructor':
        return Icons.person_rounded;
      case 'ta':
        return Icons.support_agent_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getRoleName(String role, AppLocalizations l10n) {
    switch (role) {
      case 'student':
        return l10n.student;
      case 'instructor':
        return l10n.instructor;
      case 'ta':
        return l10n.ta;
      case 'admin':
        return l10n.admin;
      default:
        return role;
    }
  }
}
