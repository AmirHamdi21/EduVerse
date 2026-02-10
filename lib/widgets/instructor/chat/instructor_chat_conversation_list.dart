import 'package:flutter/material.dart';
import '../shared/instructor_colors.dart';
import 'instructor_chat_models.dart';
import 'instructor_chat_conversation_tile.dart';

class InstructorChatConversationList extends StatelessWidget {
  final List<InstructorConversation> conversations;
  final bool isDark;
  final String? selectedConversationId;
  final ValueChanged<InstructorConversation> onConversationTap;
  final ValueChanged<InstructorConversation>? onConversationLongPress;
  final ValueChanged<String>? onDelete;
  final ValueChanged<String>? onPin;
  final ValueChanged<String>? onMute;
  final ValueChanged<String>? onMarkRead;

  const InstructorChatConversationList({
    super.key,
    required this.conversations,
    required this.isDark,
    required this.onConversationTap,
    this.selectedConversationId,
    this.onConversationLongPress,
    this.onDelete,
    this.onPin,
    this.onMute,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return _buildEmptyState();
    }

    // Sort: pinned first, then by timestamp
    final sorted = List<InstructorConversation>.from(conversations)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.timestamp.compareTo(a.timestamp);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final conversation = sorted[index];
        return InstructorChatConversationTile(
          conversation: conversation,
          isDark: isDark,
          isSelected: conversation.id == selectedConversationId,
          onTap: () => onConversationTap(conversation),
          onLongPress: onConversationLongPress != null
              ? () => onConversationLongPress!(conversation)
              : null,
          onDelete: onDelete != null ? () => onDelete!(conversation.id) : null,
          onPin: onPin != null ? () => onPin!(conversation.id) : null,
          onMute: onMute != null ? () => onMute!(conversation.id) : null,
          onMarkRead:
              onMarkRead != null ? () => onMarkRead!(conversation.id) : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: InstructorColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: InstructorColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new conversation with students or colleagues',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: InstructorColors.textTertiaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
