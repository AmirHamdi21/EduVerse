import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/admin_colors.dart';

class AdminNotificationAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final int unreadCount;
  final bool isDark;
  final bool isSearching;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback? onSwipeSettings;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onClearAll;

  const AdminNotificationAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unreadCount,
    required this.isDark,
    required this.isSearching,
    required this.onBack,
    required this.onSearch,
    this.onSwipeSettings,
    this.onMarkAllRead,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AdminColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          _buildIconButton(
            icon: isSearching ? Icons.close : Icons.search_rounded,
            onTap: onSearch,
          ),
          const SizedBox(width: 8),
          _buildMoreMenu(context),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      color: AdminColors.getCardColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      onSelected: (value) {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'swipe_settings':
            onSwipeSettings?.call();
            break;
          case 'mark_all_read':
            onMarkAllRead?.call();
            break;
          case 'clear_all':
            onClearAll?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem(
          icon: Icons.swipe_rounded,
          label: 'Swipe Actions',
          value: 'swipe_settings',
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          icon: Icons.done_all_rounded,
          label: 'Mark All as Read',
          value: 'mark_all_read',
        ),
        _buildMenuItem(
          icon: Icons.delete_sweep_rounded,
          label: 'Clear All',
          value: 'clear_all',
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required IconData icon,
    required String label,
    required String value,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AdminColors.error
        : AdminColors.getTextColor(isDark);

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
