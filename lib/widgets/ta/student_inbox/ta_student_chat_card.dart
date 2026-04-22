import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

enum TAStudentChatStatus { unread, read, flagged, forwarded, atRisk }

class TAStudentChatItem {
  final String id;
  final String studentName;
  final String studentId;
  final String message;
  final String timeAgo;
  final TAStudentChatStatus status;
  final int attendancePercent;
  final bool isAIFlagged;
  final int unreadCount;
  final String? avatarUrl;

  const TAStudentChatItem({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.message,
    required this.timeAgo,
    required this.status,
    required this.attendancePercent,
    this.isAIFlagged = false,
    this.unreadCount = 0,
    this.avatarUrl,
  });
}

class TAStudentChatCard extends StatelessWidget {
  final TAStudentChatItem chat;
  final bool isDark;
  final VoidCallback? onTap;

  const TAStudentChatCard({
    super.key,
    required this.chat,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: chat.status == TAStudentChatStatus.atRisk
                ? TAColors.error.withValues(alpha: 0.5)
                : TAColors.borderColor(isDark).withValues(alpha: 0.5),
            width: chat.status == TAStudentChatStatus.atRisk ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with unread badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getStatusColor().withValues(alpha: 0.15),
                  child: Text(
                    chat.studentName[0].toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (chat.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: TAColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TAColors.cardColor(isDark),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chat.unreadCount > 9
                              ? '9+'
                              : chat.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.studentName,
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 15,
                            fontWeight:
                                chat.status == TAStudentChatStatus.unread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat.timeAgo,
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chat.studentId,
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chat.message,
                    style: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 13,
                      fontWeight: chat.status == TAStudentChatStatus.unread
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (chat.isAIFlagged)
                        _buildTag(
                          icon: Icons.auto_awesome,
                          label: 'AI Flagged',
                          color: TAColors.warning,
                        ),
                      if (chat.status == TAStudentChatStatus.atRisk) ...[
                        if (chat.isAIFlagged) const SizedBox(width: 8),
                        _buildTag(
                          icon: Icons.warning_rounded,
                          label: 'At-Risk',
                          color: TAColors.error,
                        ),
                      ],
                      if (chat.status == TAStudentChatStatus.forwarded) ...[
                        if (chat.isAIFlagged) const SizedBox(width: 8),
                        _buildTag(
                          icon: Icons.forward_rounded,
                          label: 'Forwarded',
                          color: TAColors.info,
                        ),
                      ],
                      const Spacer(),
                      _buildAttendanceTag(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTag() {
    Color color;
    if (chat.attendancePercent >= 90) {
      color = TAColors.success;
    } else if (chat.attendancePercent >= 70) {
      color = TAColors.warning;
    } else {
      color = TAColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${chat.attendancePercent}% attend',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (chat.status) {
      case TAStudentChatStatus.atRisk:
        return TAColors.error;
      case TAStudentChatStatus.flagged:
        return TAColors.warning;
      case TAStudentChatStatus.forwarded:
        return TAColors.info;
      case TAStudentChatStatus.unread:
        return TAColors.primary;
      case TAStudentChatStatus.read:
        return TAColors.textSecondaryColor(isDark);
    }
  }
}
