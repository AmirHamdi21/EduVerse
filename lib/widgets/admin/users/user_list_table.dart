import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// User model for the list
class UserListItem {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? avatar;

  UserListItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.avatar,
  });
}

/// User list table widget
class UserListTable extends StatelessWidget {
  final bool isDark;
  final List<UserListItem> users;
  final Set<String> selectedUsers;
  final ValueChanged<String> onUserSelected;
  final ValueChanged<String> onViewUser;
  final ValueChanged<String> onEditUser;
  final ValueChanged<String> onToggleStatus;
  final ValueChanged<String> onDeleteUser;

  const UserListTable({
    super.key,
    required this.isDark,
    required this.users,
    required this.selectedUsers,
    required this.onUserSelected,
    required this.onViewUser,
    required this.onEditUser,
    required this.onToggleStatus,
    required this.onDeleteUser,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(l10n),
          ...users.map((user) => _buildUserRow(user, l10n)),
          _buildPagination(l10n),
        ],
      ),
    );
  }

  Widget _buildTableHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AdminColors.darkDivider : AdminColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(
              value: selectedUsers.length == users.length && users.isNotEmpty,
              onChanged: (_) {},
              activeColor: AdminColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              l10n.user,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              l10n.role,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              l10n.actions,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(UserListItem user, AppLocalizations l10n) {
    final roleColor = _getRoleColor(user.role);
    final isSelected = selectedUsers.contains(user.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AdminColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AdminColors.darkDivider.withValues(alpha: 0.5)
                : AdminColors.lightDivider.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (_) => onUserSelected(user.id),
              activeColor: AdminColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildAvatar(user),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              color: AdminColors.getTextColor(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildRoleBadge(user.role, roleColor, l10n),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: AdminColors.getTextTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: _buildRoleBadge(user.role, roleColor, l10n)),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionIcon(
                  icon: Icons.edit_outlined,
                  onTap: () => onEditUser(user.id),
                  tooltip: l10n.edit,
                ),
                _buildActionIcon(
                  icon: Icons.visibility_outlined,
                  onTap: () => onViewUser(user.id),
                  tooltip: l10n.viewDetails,
                ),
                _buildActionIcon(
                  icon: user.status == 'active'
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onTap: () => onToggleStatus(user.id),
                  tooltip: user.status == 'active' ? l10n.disable : l10n.enable,
                ),
                _buildActionIcon(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => onDeleteUser(user.id),
                  tooltip: l10n.delete,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserListItem user) {
    final roleColor = _getRoleColor(user.role);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [roleColor, roleColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role, Color color, AppLocalizations l10n) {
    String roleText;
    IconData? roleIcon;

    switch (role.toLowerCase()) {
      case 'student':
        roleText = l10n.student;
        roleIcon = Icons.school_rounded;
        break;
      case 'instructor':
        roleText = l10n.instructor;
        roleIcon = Icons.person_rounded;
        break;
      case 'ta':
        roleText = l10n.ta;
        roleIcon = Icons.support_agent_rounded;
        break;
      case 'admin':
        roleText = l10n.admin;
        roleIcon = Icons.admin_panel_settings_rounded;
        break;
      default:
        roleText = role;
        roleIcon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (roleIcon != null) ...[
            Icon(roleIcon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            roleText,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive
                ? AdminColors.error
                : AdminColors.getTextSecondaryColor(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                l10n.show,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AdminColors.darkCardBorder
                        : AdminColors.lightDivider,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      '10',
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.of_} ${users.length} ${l10n.users.toLowerCase()}',
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                l10n.page,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '1 ${l10n.of_} 1',
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
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
}
