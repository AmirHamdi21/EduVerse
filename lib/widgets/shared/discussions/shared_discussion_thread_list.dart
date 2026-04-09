import 'package:flutter/material.dart';

import '../../../models/discussion/discussion_models.dart';
import 'shared_discussion_empty_state.dart';
import 'shared_discussion_thread_tile.dart';

class SharedDiscussionThreadList extends StatelessWidget {
  final List<DiscussionThread> threads;
  final int? selectedThreadId;
  final Color accentColor;
  final bool isError;
  final String? errorMessage;
  final bool canModerate;
  final int? currentUserId;
  final bool hasMore;
  final bool isPaginating;
  final VoidCallback? onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<DiscussionThread> onThreadTap;
  final ValueChanged<DiscussionThread>? onEditThread;
  final ValueChanged<DiscussionThread>? onDeleteThread;
  final ValueChanged<DiscussionThread>? onTogglePin;
  final ValueChanged<DiscussionThread>? onToggleLock;

  const SharedDiscussionThreadList({
    super.key,
    required this.threads,
    required this.selectedThreadId,
    required this.accentColor,
    this.isError = false,
    this.errorMessage,
    required this.canModerate,
    required this.currentUserId,
    required this.hasMore,
    required this.isPaginating,
    this.onRetry,
    required this.onLoadMore,
    required this.onThreadTap,
    this.onEditThread,
    this.onDeleteThread,
    this.onTogglePin,
    this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      if (isError) {
        return SharedDiscussionEmptyState(
          title: 'Something went wrong',
          message: (errorMessage ?? '').trim().isNotEmpty
              ? errorMessage!
              : "We couldn't load discussions. Please try again.",
          icon: Icons.error_outline_rounded,
          onAction: onRetry,
          actionLabel: onRetry == null ? null : 'Try again',
          accentColor: accentColor,
        );
      }

      return SharedDiscussionEmptyState(
        title: 'No discussion threads yet',
        message: 'Start the first thread to ask a question or share knowledge.',
        accentColor: accentColor,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!hasMore || isPaginating) {
          return false;
        }

        final metrics = notification.metrics;
        final isNearBottom = metrics.pixels >= metrics.maxScrollExtent - 180;
        if (isNearBottom) {
          onLoadMore();
        }

        return false;
      },
      child: ListView.builder(
        itemCount: threads.length + (isPaginating ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= threads.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final thread = threads[index];
          return SharedDiscussionThreadTile(
            thread: thread,
            accentColor: accentColor,
            isSelected: selectedThreadId == thread.id,
            canModerate: canModerate,
            currentUserId: currentUserId,
            onTap: () => onThreadTap(thread),
            onEdit: onEditThread == null ? null : () => onEditThread!(thread),
            onDelete: onDeleteThread == null
                ? null
                : () => onDeleteThread!(thread),
            onTogglePin: onTogglePin == null
                ? null
                : () => onTogglePin!(thread),
            onToggleLock: onToggleLock == null
                ? null
                : () => onToggleLock!(thread),
          );
        },
      ),
    );
  }
}
