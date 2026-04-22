import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminBlockedUsersScreen extends StatefulWidget {
  const AdminBlockedUsersScreen({super.key});

  @override
  State<AdminBlockedUsersScreen> createState() =>
      _AdminBlockedUsersScreenState();
}

class _AdminBlockedUsersScreenState extends State<AdminBlockedUsersScreen> {
  final List<_BlockedUser> _blockedUsers = [
    _BlockedUser(
      id: '1',
      name: 'John Smith',
      email: 'john.smith@example.com',
      reason: 'Multiple policy violations',
      blockedDate: DateTime(2025, 12, 15),
      blockedBy: 'Admin',
    ),
    _BlockedUser(
      id: '2',
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      reason: 'Suspicious activity detected',
      blockedDate: DateTime(2026, 1, 3),
      blockedBy: 'System',
    ),
    _BlockedUser(
      id: '3',
      name: 'Bob Wilson',
      email: 'bob.wilson@example.com',
      reason: 'Account abuse',
      blockedDate: DateTime(2026, 2, 10),
      blockedBy: 'Admin',
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final filteredUsers = _blockedUsers
            .where(
              (u) =>
                  u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: Column(
                children: [
                  _buildSearchBar(isDark, l10n, responsive),
                  _buildStatsRow(isDark, l10n, responsive),
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? _buildEmptyState(isDark, l10n)
                        : ListView.builder(
                            padding: responsive.contentPadding,
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) => _buildUserCard(
                              filteredUsers[index],
                              isDark,
                              l10n,
                              responsive,
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

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AdminColors.getBackgroundColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      title: Text(
        l10n.blockedUsers,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Padding(
      padding: EdgeInsets.all(responsive.p16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(color: AdminColors.getTextColor(isDark)),
        decoration: InputDecoration(
          hintText: l10n.searchBlockedUsers,
          hintStyle: TextStyle(color: AdminColors.getTextTertiaryColor(isDark)),
          prefixIcon: Icon(Icons.search_rounded, color: AdminColors.primary),
          filled: true,
          fillColor: AdminColors.getCardColor(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.p16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              isDark,
              Icons.block_rounded,
              _blockedUsers.length.toString(),
              l10n.totalBlocked,
              AdminColors.error,
            ),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: _buildStatCard(
              isDark,
              Icons.admin_panel_settings_rounded,
              _blockedUsers
                  .where((u) => u.blockedBy == 'Admin')
                  .length
                  .toString(),
              l10n.byAdmin,
              AdminColors.primary,
            ),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: _buildStatCard(
              isDark,
              Icons.smart_toy_outlined,
              _blockedUsers
                  .where((u) => u.blockedBy == 'System')
                  .length
                  .toString(),
              l10n.bySystem,
              AdminColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    _BlockedUser user,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AdminColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
                color: AdminColors.getCardColor(isDark),
                onSelected: (value) => _handleMenuAction(value, user, l10n),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'unblock',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                          color: AdminColors.success,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.unblock,
                          style: TextStyle(
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_forever_outlined,
                          size: 20,
                          color: AdminColors.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.deleteAccount,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AdminColors.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.reason,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                '${l10n.blockedOn}: ${_formatDate(user.blockedDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                '${l10n.by}: ${user.blockedBy}',
                style: TextStyle(
                  fontSize: 12,
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: AdminColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noBlockedUsers,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noBlockedUsersDesc,
            style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    String action,
    _BlockedUser user,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case 'unblock':
        _showUnblockDialog(user, l10n);
        break;
      case 'delete':
        _showDeleteDialog(user, l10n);
        break;
    }
  }

  void _showUnblockDialog(_BlockedUser user, AppLocalizations l10n) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: AdminColors.success,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.unblockUser,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '${l10n.unblockUserConfirm(user.name)}?',
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
              setState(() => _blockedUsers.remove(user));
              Navigator.pop(context);
              _showSnackBar(l10n.userUnblocked(user.name));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.unblock),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(_BlockedUser user, AppLocalizations l10n) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AdminColors.error),
            const SizedBox(width: 12),
            Text(
              l10n.deleteAccount,
              style: TextStyle(
                color: AdminColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteAccountWarning,
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
              setState(() => _blockedUsers.remove(user));
              Navigator.pop(context);
              _showSnackBar(l10n.accountDeleted);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _BlockedUser {
  final String id;
  final String name;
  final String email;
  final String reason;
  final DateTime blockedDate;
  final String blockedBy;

  _BlockedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.reason,
    required this.blockedDate,
    required this.blockedBy,
  });
}
