import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shared/admin_colors.dart';

class Conversation {
  final String id;
  final String name;
  final String avatar;
  final String type; // student, instructor, ta, group, system
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? department;
  final int? memberCount;

  const Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.type,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.department,
    this.memberCount,
  });
}

class AdminConversationList extends StatelessWidget {
  final bool isDark;
  final List<Conversation> conversations;
  final String? selectedId;
  final Function(Conversation) onConversationTap;
  final String searchQuery;

  const AdminConversationList({
    super.key,
    required this.isDark,
    required this.conversations,
    this.selectedId,
    required this.onConversationTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final filtered = searchQuery.isEmpty
        ? conversations
        : conversations.where((c) =>
            c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.lastMessage.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildConversationItem(filtered[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AdminColors.darkText : AdminColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Start a new conversation',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    final isSelected = conversation.id == selectedId;
    final hasUnread = conversation.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AdminColors.primary.withValues(alpha: 0.1)
            : (isDark ? AdminColors.darkCard : AdminColors.lightCard),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AdminColors.primary
              : (isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onConversationTap(conversation),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(conversation),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                                color: isDark ? AdminColors.darkText : AdminColors.lightText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(conversation.lastMessageTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: hasUnread
                                  ? AdminColors.primary
                                  : (isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary),
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              style: TextStyle(
                                fontSize: 13,
                                color: hasUnread
                                    ? (isDark ? AdminColors.darkText : AdminColors.lightText)
                                    : (isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary),
                                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AdminColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Conversation conversation) {
    final color = _getTypeColor(conversation.type);
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: conversation.type == 'group'
                ? Icon(Icons.groups_rounded, color: Colors.white, size: 24)
                : Text(
                    conversation.avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        if (conversation.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AdminColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'student':
        return AdminColors.primary;
      case 'instructor':
        return AdminColors.secondary;
      case 'ta':
        return AdminColors.accent;
      case 'group':
        return AdminColors.warning;
      case 'system':
        return AdminColors.error;
      default:
        return AdminColors.primary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
