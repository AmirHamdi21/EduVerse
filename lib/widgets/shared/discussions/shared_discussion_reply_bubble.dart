import 'package:flutter/material.dart';

import '../../../models/discussion/discussion_models.dart';

class SharedDiscussionReplyBubble extends StatelessWidget {
  final DiscussionReply reply;
  final Color accentColor;
  final bool canModerate;
  final bool isCurrentUser;
  final VoidCallback? onMarkAnswer;
  final VoidCallback? onEndorse;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SharedDiscussionReplyBubble({
    super.key,
    required this.reply,
    required this.accentColor,
    required this.canModerate,
    required this.isCurrentUser,
    this.onMarkAnswer,
    this.onEndorse,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canEdit = isCurrentUser || canModerate;

    return Container(
      margin: EdgeInsets.fromLTRB(
        reply.parentMessageId != null ? 28 : 8,
        6,
        8,
        6,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reply.isAnswer
              ? const Color(0xFF22C55E).withValues(alpha: 0.6)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE4E7EC)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reply.userName.isEmpty
                      ? 'User #${reply.userId}'
                      : reply.userName,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF101828),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _relativeTime(reply.createdAt),
                style: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF667085),
                  fontSize: 11,
                ),
              ),
              if (canEdit || canModerate) _buildMenu(canEdit: canEdit),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.messageText,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF344054),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (reply.isAnswer)
                _buildChip(
                  'Answer',
                  Icons.verified_rounded,
                  const Color(0xFF22C55E),
                ),
              if (reply.isEndorsed)
                _buildChip('Endorsed', Icons.thumb_up_alt_rounded, accentColor),
              if (reply.parentMessageId != null)
                _buildChip(
                  'Reply',
                  Icons.subdirectory_arrow_right_rounded,
                  isDark ? Colors.white54 : const Color(0xFF667085),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu({required bool canEdit}) {
    return PopupMenuButton<_ReplyAction>(
      icon: const Icon(Icons.more_horiz_rounded, size: 20),
      onSelected: (action) {
        switch (action) {
          case _ReplyAction.edit:
            onEdit?.call();
            break;
          case _ReplyAction.delete:
            onDelete?.call();
            break;
          case _ReplyAction.answer:
            onMarkAnswer?.call();
            break;
          case _ReplyAction.endorse:
            onEndorse?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_ReplyAction>>[];

        if (canEdit) {
          items.add(
            const PopupMenuItem<_ReplyAction>(
              value: _ReplyAction.edit,
              child: Text('Edit Reply'),
            ),
          );
        }

        if (canModerate) {
          items.add(
            PopupMenuItem<_ReplyAction>(
              value: _ReplyAction.answer,
              child: Text(reply.isAnswer ? 'Unmark Answer' : 'Mark as Answer'),
            ),
          );
          items.add(
            PopupMenuItem<_ReplyAction>(
              value: _ReplyAction.endorse,
              child: Text(
                reply.isEndorsed ? 'Remove Endorse' : 'Endorse Reply',
              ),
            ),
          );
          items.add(
            const PopupMenuItem<_ReplyAction>(
              value: _ReplyAction.delete,
              child: Text('Delete Reply'),
            ),
          );
        }

        return items;
      },
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }
}

enum _ReplyAction { edit, delete, answer, endorse }
