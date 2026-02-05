import 'package:flutter/material.dart';
import '../../../bloc/chat/chat_models.dart';
import 'chat_conversation_tile.dart';

class ChatConversationList extends StatelessWidget {
  final List<Conversation> conversations;
  final bool isDark;
  final ValueChanged<Conversation> onConversationTap;
  final ValueChanged<Conversation> onConversationLongPress;
  final ValueChanged<String>? onDelete;
  final ValueChanged<String>? onArchive;
  final ValueChanged<String>? onPin;
  final ValueChanged<String>? onMute;
  final ValueChanged<String>? onMarkRead;

  const ChatConversationList({
    super.key,
    required this.conversations,
    required this.isDark,
    required this.onConversationTap,
    required this.onConversationLongPress,
    this.onDelete,
    this.onArchive,
    this.onPin,
    this.onMute,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    // Separate pinned and unpinned
    final pinned = conversations.where((c) => c.isPinned).toList();
    final unpinned = conversations.where((c) => !c.isPinned).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: (pinned.isNotEmpty ? pinned.length + 1 : 0) +
          (unpinned.isNotEmpty ? unpinned.length + 1 : 0),
      itemBuilder: (context, index) {
        // Pinned section
        if (pinned.isNotEmpty) {
          if (index == 0) {
            return _buildSectionHeader('Pinned', Icons.push_pin_rounded, isDark);
          }
          if (index <= pinned.length) {
            final conversation = pinned[index - 1];
            return ChatConversationTile(
              conversation: conversation,
              isDark: isDark,
              onTap: () => onConversationTap(conversation),
              onLongPress: () => onConversationLongPress(conversation),
              onDelete: onDelete != null ? () => onDelete!(conversation.id) : null,
              onArchive: onArchive != null ? () => onArchive!(conversation.id) : null,
              onPin: onPin != null ? () => onPin!(conversation.id) : null,
              onMute: onMute != null ? () => onMute!(conversation.id) : null,
              onMarkRead: onMarkRead != null ? () => onMarkRead!(conversation.id) : null,
            );
          }
        }

        // Unpinned section
        final unpinnedIndex = pinned.isNotEmpty ? index - pinned.length - 1 : index;
        
        if (unpinned.isNotEmpty) {
          if (unpinnedIndex == 0) {
            return _buildSectionHeader(
              pinned.isNotEmpty ? 'Recent' : 'Conversations',
              Icons.access_time_rounded,
              isDark,
            );
          }
          if (unpinnedIndex > 0 && unpinnedIndex <= unpinned.length) {
            final conversation = unpinned[unpinnedIndex - 1];
            return ChatConversationTile(
              conversation: conversation,
              isDark: isDark,
              onTap: () => onConversationTap(conversation),
              onLongPress: () => onConversationLongPress(conversation),
              onDelete: onDelete != null ? () => onDelete!(conversation.id) : null,
              onArchive: onArchive != null ? () => onArchive!(conversation.id) : null,
              onPin: onPin != null ? () => onPin!(conversation.id) : null,
              onMute: onMute != null ? () => onMute!(conversation.id) : null,
              onMarkRead: onMarkRead != null ? () => onMarkRead!(conversation.id) : null,
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }
}
