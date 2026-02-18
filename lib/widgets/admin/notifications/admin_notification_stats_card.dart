import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminNotificationStatsCard extends StatelessWidget {
  final int totalNotifications;
  final int unreadCount;
  final int pendingActions;
  final int announcementsCount;
  final bool isDark;

  const AdminNotificationStatsCard({
    super.key,
    required this.totalNotifications,
    required this.unreadCount,
    required this.pendingActions,
    required this.announcementsCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.notifications_rounded,
            value: totalNotifications.toString(),
            label: 'Total',
            color: AdminColors.primary,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.mark_email_unread_rounded,
            value: unreadCount.toString(),
            label: 'Unread',
            color: AdminColors.warning,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.pending_actions_rounded,
            value: pendingActions.toString(),
            label: 'Pending',
            color: AdminColors.error,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.campaign_rounded,
            value: announcementsCount.toString(),
            label: 'Posted',
            color: AdminColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.06),
    );
  }
}
