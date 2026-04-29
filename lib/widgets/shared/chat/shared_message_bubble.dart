import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/chat/chat_models.dart';
import '../modern_action_sheet.dart';

/// Individual message bubble with alignment, sender info, and actions.
/// Supports reply context, delete states, and long-press menu.
class SharedMessageBubble extends StatelessWidget {
  /// The message to display
  final ChatMessageModel message;

  /// Whether this message was sent by the current user
  final bool isMe;

  /// Whether this is a group conversation (affects sender display)
  final bool isGroup;

  /// Whether to show sender name/avatar (false for consecutive messages from same sender)
  final bool showSenderInfo;

  /// The message this is replying to (for reply context display)
  final ChatMessageModel? replyToMessage;

  /// Participant cache for resolving sender names in reply contexts.
  final Map<int, ChatUserModel> participantCache;

  /// Primary accent color for sent message bubbles
  final Color accentColor;

  /// Dark mode flag
  final bool isDark;

  /// Callback when "Reply" action is selected
  final VoidCallback? onReply;

  /// Callback when "Delete for me" action is selected
  final VoidCallback? onDeleteForMe;

  /// Callback when "Delete for everyone" action is selected
  final VoidCallback? onDeleteForEveryone;

  /// Callback when "Edit" action is selected
  final VoidCallback? onEdit;

  /// Callback when retry button is tapped (for failed messages)
  final VoidCallback? onRetry;

  /// Callback when reply context is tapped (scroll to original)
  final VoidCallback? onTapReplyContext;

  /// Whether "Delete for everyone" should be shown (24h window + own message)
  final bool canDeleteForEveryone;

  /// Whether the current user can edit the message
  final bool canEdit;

  const SharedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isGroup,
    this.showSenderInfo = true,
    this.replyToMessage,
    this.participantCache = const <int, ChatUserModel>{},
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
    this.onReply,
    this.onDeleteForMe,
    this.onDeleteForEveryone,
    this.onEdit,
    this.onRetry,
    this.onTapReplyContext,
    this.canDeleteForEveryone = false,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && isGroup && showSenderInfo) _buildAvatar(),
          if (!isMe && isGroup && showSenderInfo) const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: _showActionsMenu(context),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe && isGroup && showSenderInfo) _buildSenderName(),
                  if (replyToMessage != null) _buildReplyContext(),
                  _buildMessageBubble(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = (message.senderName?.isNotEmpty == true)
        ? message.senderName![0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 16,
      backgroundColor: accentColor.withValues(alpha: 0.2),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _buildSenderName() {
    final resolvedName = message.hydratedReplyToName(participantCache);
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 2),
      child: Text(
        resolvedName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildReplyContext() {
    final replyMsg = replyToMessage!;
    final resolvedReplyName = replyMsg.hydratedReplyToName(participantCache);
    return GestureDetector(
      onTap: onTapReplyContext,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resolvedReplyName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              replyMsg.isDeleted
                  ? replyMsg.deletedText
                  : replyMsg.text.length > 50
                  ? '${replyMsg.text.substring(0, 50)}...'
                  : replyMsg.text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontStyle: replyMsg.isDeleted ? FontStyle.italic : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final isFailed = message.status.toLowerCase() == 'failed';
    final normalizedStatus = message.status.toLowerCase();
    final isPending =
        normalizedStatus == 'pending' || normalizedStatus == 'sending';

    Color bgColor;
    if (message.isDeleted) {
      bgColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;
    } else if (isMe) {
      bgColor = isFailed ? Colors.red.withValues(alpha: 0.2) : accentColor;
    } else {
      bgColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isDeleted)
            Text(
              message.deletedText,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.grey[100] : Colors.grey[900]),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(context, message.sentAt),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.7)
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                ),
              ),
              if (message.editedAt != null && !message.isDeleted) ...[
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context).chatEditedLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : (isDark ? Colors.grey[500] : Colors.grey[600]),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (isMe) ...[
                const SizedBox(width: 4),
                _buildStatusIcon(isPending, isFailed),
              ],
              if (isFailed && onRetry != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onRetry,
                  child: Icon(Icons.refresh, size: 14, color: Colors.red[300]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isPending, bool isFailed) {
    if (isFailed) {
      return Icon(Icons.error_outline, size: 12, color: Colors.red[300]);
    }
    if (isPending) {
      return Icon(
        Icons.access_time,
        size: 12,
        color: Colors.white.withValues(alpha: 0.7),
      );
    }
    return Icon(
      Icons.check,
      size: 12,
      color: Colors.white.withValues(alpha: 0.7),
    );
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat.Md(locale).add_jm().format(dateTime.toLocal());
    }
    return DateFormat.jm(locale).format(dateTime.toLocal());
  }

  VoidCallback? _showActionsMenu(BuildContext context) {
    if (message.isDeleted) return null;

    return () {
      final l10n = AppLocalizations.of(context);
      showModernActionSheet<_MessageAction>(
        context,
        title: l10n.chatMessageActionsTitle,
        subtitle: message.text.trim().isEmpty
            ? l10n.chatMessageActionsSubtitle
            : message.text,
        accentColor: accentColor,
        actions: <ModernActionItem<_MessageAction>>[
          if (onReply != null)
            ModernActionItem<_MessageAction>(
              value: _MessageAction.reply,
              label: l10n.chatActionReply,
              icon: Icons.reply_rounded,
              description: l10n.chatActionReplyDesc,
            ),
          if (canEdit && onEdit != null)
            ModernActionItem<_MessageAction>(
              value: _MessageAction.edit,
              label: l10n.chatActionEditMessage,
              icon: Icons.edit_outlined,
              description: l10n.chatActionEditMessageDesc,
            ),
          if (onDeleteForMe != null)
            ModernActionItem<_MessageAction>(
              value: _MessageAction.deleteForMe,
              label: l10n.chatActionDeleteForMe,
              icon: Icons.delete_outline_rounded,
              description: l10n.chatActionDeleteForMeDesc,
              destructive: true,
            ),
          if (canDeleteForEveryone && onDeleteForEveryone != null)
            ModernActionItem<_MessageAction>(
              value: _MessageAction.deleteForEveryone,
              label: l10n.chatActionDeleteForEveryone,
              icon: Icons.delete_forever_rounded,
              description: l10n.chatActionDeleteForEveryoneDesc,
              destructive: true,
            ),
        ],
      ).then((value) {
        switch (value) {
          case _MessageAction.reply:
            onReply?.call();
            break;
          case _MessageAction.edit:
            onEdit?.call();
            break;
          case _MessageAction.deleteForMe:
            onDeleteForMe?.call();
            break;
          case _MessageAction.deleteForEveryone:
            onDeleteForEveryone?.call();
            break;
          case null:
            break;
        }
      });
    };
  }
}

enum _MessageAction { reply, edit, deleteForMe, deleteForEveryone }
