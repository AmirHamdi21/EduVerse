import 'package:flutter/material.dart';
import '../shared/instructor_colors.dart';
import 'instructor_chat_models.dart';

class InstructorChatConversationTile extends StatelessWidget {
  final InstructorConversation conversation;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final VoidCallback? onMute;
  final VoidCallback? onMarkRead;

  const InstructorChatConversationTile({
    super.key,
    required this.conversation,
    required this.isDark,
    required this.onTap,
    this.isSelected = false,
    this.onLongPress,
    this.onDelete,
    this.onPin,
    this.onMute,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) => onDelete?.call(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: InstructorColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? InstructorColors.primary.withValues(alpha: 0.1)
                : InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? InstructorColors.primary.withValues(alpha: 0.3)
                  : InstructorColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (conversation.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.push_pin,
                              size: 14,
                              color: InstructorColors.primary,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            conversation.name,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontSize: 15,
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          conversation.timeAgo,
                          style: TextStyle(
                            color: conversation.unreadCount > 0
                                ? InstructorColors.primary
                                : InstructorColors.textTertiaryColor(isDark),
                            fontSize: 12,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (conversation.courseName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: InstructorColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              conversation.courseName!,
                              style: TextStyle(
                                color: InstructorColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            style: TextStyle(
                              color: conversation.unreadCount > 0
                                  ? InstructorColors.textPrimaryColor(isDark)
                                  : InstructorColors.textTertiaryColor(isDark),
                              fontSize: 13,
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: InstructorColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (conversation.isMuted)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 16,
                              color: InstructorColors.textTertiaryColor(isDark),
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
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: conversation.type == InstructorConversationType.group
                ? InstructorColors.accent.withValues(alpha: 0.1)
                : InstructorColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: conversation.type == InstructorConversationType.group
                ? Icon(
                    Icons.group_outlined,
                    color: InstructorColors.accent,
                    size: 24,
                  )
                : Text(
                    conversation.avatar,
                    style: TextStyle(
                      color: InstructorColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                color: InstructorColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: InstructorColors.cardColor(isDark),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: InstructorColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Conversation?',
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will permanently delete the conversation with ${conversation.name}.',
          style: TextStyle(
            color: InstructorColors.textSecondaryColor(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: InstructorColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
