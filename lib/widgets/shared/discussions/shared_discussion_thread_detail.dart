import 'package:flutter/material.dart';

import '../../../models/discussion/discussion_models.dart';
import 'shared_discussion_reply_bubble.dart';
import 'shared_discussion_reply_input.dart';

class SharedDiscussionThreadDetail extends StatelessWidget {
  final DiscussionThread thread;
  final List<DiscussionReply> replies;
  final Color accentColor;
  final bool isError;
  final String? errorMessage;
  final bool canModerate;
  final int? currentUserId;
  final bool hasMoreReplies;
  final bool isPaginatingReplies;
  final VoidCallback? onRetry;
  final VoidCallback onBack;
  final VoidCallback onLoadMoreReplies;
  final Future<bool> Function(String text) onSendReply;
  final VoidCallback? onEditThread;
  final VoidCallback? onDeleteThread;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleLock;
  final ValueChanged<DiscussionReply>? onMarkAnswer;
  final ValueChanged<DiscussionReply>? onEndorse;
  final ValueChanged<DiscussionReply>? onEditReply;
  final ValueChanged<DiscussionReply>? onDeleteReply;

  const SharedDiscussionThreadDetail({
    super.key,
    required this.thread,
    required this.replies,
    required this.accentColor,
    this.isError = false,
    this.errorMessage,
    required this.canModerate,
    required this.currentUserId,
    required this.hasMoreReplies,
    required this.isPaginatingReplies,
    this.onRetry,
    required this.onBack,
    required this.onLoadMoreReplies,
    required this.onSendReply,
    this.onEditThread,
    this.onDeleteThread,
    this.onTogglePin,
    this.onToggleLock,
    this.onMarkAnswer,
    this.onEndorse,
    this.onEditReply,
    this.onDeleteReply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE4E7EC),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${thread.replyCount} replies · ${thread.viewCount} views',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF667085),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_ThreadAction>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (action) {
                  switch (action) {
                    case _ThreadAction.edit:
                      onEditThread?.call();
                      break;
                    case _ThreadAction.delete:
                      onDeleteThread?.call();
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
                  final canEditThread =
                      canModerate ||
                      (currentUserId != null &&
                          currentUserId == thread.createdBy);

                  final items = <PopupMenuEntry<_ThreadAction>>[];
                  if (canEditThread) {
                    items.add(
                      const PopupMenuItem(
                        value: _ThreadAction.edit,
                        child: Text('Edit Thread'),
                      ),
                    );
                  }
                  if (canModerate) {
                    items.add(
                      PopupMenuItem(
                        value: _ThreadAction.pin,
                        child: Text(
                          thread.isPinned ? 'Unpin Thread' : 'Pin Thread',
                        ),
                      ),
                    );
                    items.add(
                      PopupMenuItem(
                        value: _ThreadAction.lock,
                        child: Text(
                          thread.isLocked ? 'Unlock Thread' : 'Lock Thread',
                        ),
                      ),
                    );
                    items.add(
                      const PopupMenuItem(
                        value: _ThreadAction.delete,
                        child: Text('Delete Thread'),
                      ),
                    );
                  }
                  return items;
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (!hasMoreReplies || isPaginatingReplies) {
                return false;
              }
              final metrics = notification.metrics;
              if (metrics.pixels >= metrics.maxScrollExtent - 180) {
                onLoadMoreReplies();
              }
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF16213E)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE4E7EC),
                    ),
                  ),
                  child: Text(
                    thread.description,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF344054),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...replies.map(
                  (reply) => SharedDiscussionReplyBubble(
                    reply: reply,
                    accentColor: accentColor,
                    canModerate: canModerate,
                    isCurrentUser:
                        currentUserId != null && currentUserId == reply.userId,
                    onMarkAnswer: onMarkAnswer == null
                        ? null
                        : () => onMarkAnswer!(reply),
                    onEndorse: onEndorse == null
                        ? null
                        : () => onEndorse!(reply),
                    onEdit: onEditReply == null
                        ? null
                        : () => onEditReply!(reply),
                    onDelete: onDeleteReply == null
                        ? null
                        : () => onDeleteReply!(reply),
                  ),
                ),
                if (isPaginatingReplies)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (replies.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isError
                              ? 'Something went wrong while loading replies.'
                              : 'No replies yet. Start the discussion by posting the first reply.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF667085),
                          ),
                        ),
                        if (isError &&
                            (errorMessage ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF98A2B3),
                            ),
                          ),
                        ],
                        if (isError && onRetry != null) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try again'),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        SharedDiscussionReplyInput(
          isLocked: thread.isLocked,
          accentColor: accentColor,
          onSubmit: onSendReply,
        ),
      ],
    );
  }
}

enum _ThreadAction { edit, delete, pin, lock }
