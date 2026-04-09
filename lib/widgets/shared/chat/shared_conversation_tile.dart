import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../bloc/chat/chat_models.dart';

class SharedConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final bool isDark;
  final Color accentColor;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;
  final VoidCallback onTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback onPin;
  final VoidCallback onMute;
  final VoidCallback onDelete;

  const SharedConversationTile({
    super.key,
    required this.conversation,
    required this.isDark,
    required this.accentColor,
    required this.isOnline,
    required this.isPinned,
    required this.isMuted,
    required this.onTap,
    this.onAvatarTap,
    required this.onPin,
    required this.onMute,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle =
        conversation.lastMessage ??
        conversation.lastMessageInfo?.text ??
        'No messages yet';

    return Slidable(
      key: ValueKey('conversation-${conversation.conversationId}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.78,
        children: [
          SlidableAction(
            onPressed: (_) => onPin(),
            icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            label: isPinned ? 'Unpin' : 'Pin',
          ),
          SlidableAction(
            onPressed: (_) => onMute(),
            icon: isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            backgroundColor: const Color(0xFF6D28D9),
            foregroundColor: Colors.white,
            label: isMuted ? 'Unmute' : 'Mute',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            icon: Icons.delete_outline_rounded,
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            label: 'Delete',
          ),
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _avatarColor(),
                        child: _avatarChild(),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 1,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isPinned)
                            Icon(Icons.push_pin, size: 15, color: accentColor),
                          if (isMuted)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.volume_off_rounded,
                                size: 15,
                                color: Color(0xFF64748B),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimestamp(conversation.updatedAt),
                      style: TextStyle(
                        color: conversation.unreadCount > 0
                            ? accentColor
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (conversation.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          conversation.unreadCount > 99
                              ? '99+'
                              : '${conversation.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarChild() {
    if (conversation.type == ConversationType.group) {
      return const Icon(Icons.group_rounded, color: Colors.white, size: 20);
    }

    return Text(
      _initials(conversation.title),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }

  Color _avatarColor() {
    const palette = <Color>[
      Color(0xFF3B82F6),
      Color(0xFF14B8A6),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF10B981),
    ];
    final index = conversation.conversationId.abs() % palette.length;
    return palette[index];
  }

  String _initials(String title) {
    final tokens = title
        .split(RegExp(r'\s+'))
        .where((token) => token.trim().isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return 'U';
    }

    if (tokens.length == 1) {
      final token = tokens.first;
      return token.length > 1
          ? token.substring(0, 2).toUpperCase()
          : token.toUpperCase();
    }

    return '${tokens.first[0]}${tokens[1][0]}'.toUpperCase();
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'now';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }

    if (diff.inHours < 24) {
      return DateFormat('h:mm a').format(dateTime);
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }

    return DateFormat('MMM d').format(dateTime);
  }
}
