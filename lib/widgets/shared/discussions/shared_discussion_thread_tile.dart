import 'package:flutter/material.dart';

import '../../../models/discussion/discussion_models.dart';

class SharedDiscussionThreadTile extends StatelessWidget {
  final DiscussionThread thread;
  final Color accentColor;
  final bool isSelected;
  final bool canModerate;
  final int? currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleLock;

  const SharedDiscussionThreadTile({
    super.key,
    required this.thread,
    required this.accentColor,
    required this.isSelected,
    required this.canModerate,
    required this.currentUserId,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onTogglePin,
    this.onToggleLock,
  });

  bool get _canEdit =>
      canModerate ||
      (currentUserId != null && currentUserId == thread.createdBy);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isSelected
          ? accentColor.withValues(alpha: isDark ? 0.22 : 0.12)
          : (isDark ? const Color(0xFF16213E) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? accentColor.withValues(alpha: 0.55)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE4E7EC)),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      thread.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildActions(context),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                thread.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF667085),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (thread.isPinned)
                    _buildChip('Pinned', Icons.push_pin_rounded, accentColor),
                  if (thread.isLocked)
                    _buildChip(
                      'Locked',
                      Icons.lock_rounded,
                      const Color(0xFFD97706),
                    ),
                  _buildChip(
                    '${thread.viewCount} Views',
                    Icons.visibility_outlined,
                    isDark ? Colors.white54 : const Color(0xFF667085),
                  ),
                  _buildChip(
                    '${thread.replyCount} Replies',
                    Icons.forum_outlined,
                    isDark ? Colors.white54 : const Color(0xFF667085),
                  ),
                  _buildChip(
                    _relativeTime(thread.createdAt),
                    Icons.schedule_rounded,
                    isDark ? Colors.white54 : const Color(0xFF667085),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final hasMenuActions = _canEdit || canModerate;
    if (!hasMenuActions) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<_ThreadAction>(
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (action) {
        switch (action) {
          case _ThreadAction.edit:
            onEdit?.call();
            break;
          case _ThreadAction.delete:
            onDelete?.call();
            break;
          case _ThreadAction.pin:
            onTogglePin?.call();
            break;
          case _ThreadAction.lock:
            onToggleLock?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_ThreadAction>>[];

        if (_canEdit) {
          items.add(
            const PopupMenuItem<_ThreadAction>(
              value: _ThreadAction.edit,
              child: Text('Edit Thread'),
            ),
          );
        }

        if (canModerate) {
          items.add(
            PopupMenuItem<_ThreadAction>(
              value: _ThreadAction.pin,
              child: Text(thread.isPinned ? 'Unpin Thread' : 'Pin Thread'),
            ),
          );
          items.add(
            PopupMenuItem<_ThreadAction>(
              value: _ThreadAction.lock,
              child: Text(thread.isLocked ? 'Unlock Thread' : 'Lock Thread'),
            ),
          );
        }

        if (canModerate) {
          items.add(
            const PopupMenuItem<_ThreadAction>(
              value: _ThreadAction.delete,
              child: Text('Delete Thread'),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
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
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }
}

enum _ThreadAction { edit, delete, pin, lock }
