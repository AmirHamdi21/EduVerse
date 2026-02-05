import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../models/chat/chat_swipe_action_model.dart';
import '../../../services/chat_swipe_settings_service.dart';
import '../../../generated_l10n/app_localizations.dart';

class ChatConversationTile extends StatefulWidget {
  final Conversation conversation;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onPin;
  final VoidCallback? onMute;
  final VoidCallback? onMarkRead;

  const ChatConversationTile({
    super.key,
    required this.conversation,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
    this.onDelete,
    this.onArchive,
    this.onPin,
    this.onMute,
    this.onMarkRead,
  });

  @override
  State<ChatConversationTile> createState() => _ChatConversationTileState();
}

class _ChatConversationTileState extends State<ChatConversationTile> with WidgetsBindingObserver {
  ChatSwipeSettings _swipeSettings = const ChatSwipeSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSwipeSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSwipeSettings();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSwipeSettings();
  }

  Future<void> _loadSwipeSettings() async {
    ChatSwipeSettingsService.instance.clearCache();
    final settings = await ChatSwipeSettingsService.instance.getSwipeSettings();
    if (mounted) {
      setState(() {
        _swipeSettings = settings;
      });
    }
  }

  void _executeAction(ChatSwipeAction action) {
    switch (action) {
      case ChatSwipeAction.delete:
        widget.onDelete?.call();
        break;
      case ChatSwipeAction.archive:
        widget.onArchive?.call();
        break;
      case ChatSwipeAction.pin:
        widget.onPin?.call();
        break;
      case ChatSwipeAction.mute:
        widget.onMute?.call();
        break;
      case ChatSwipeAction.markRead:
      case ChatSwipeAction.markUnread:
        widget.onMarkRead?.call();
        break;
      case ChatSwipeAction.none:
        break;
    }
  }

  Future<bool> _confirmAction(BuildContext context, ChatSwipeAction action) async {
    if (!_swipeSettings.confirmBeforeAction || !action.requiresConfirmation) {
      return true;
    }

    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => action == ChatSwipeAction.delete
          ? _DeleteChatDialog(
              isDark: widget.isDark,
              l10n: l10n,
              conversationTitle: widget.conversation.title,
              onCancel: () => Navigator.of(ctx).pop(false),
              onDelete: () => Navigator.of(ctx).pop(true),
            )
          : _ArchiveChatDialog(
              isDark: widget.isDark,
              l10n: l10n,
              conversationTitle: widget.conversation.title,
              onCancel: () => Navigator.of(ctx).pop(false),
              onArchive: () => Navigator.of(ctx).pop(true),
            ),
    );
    return result ?? false;
  }

  String _getActionLabel(ChatSwipeAction action, AppLocalizations l10n) {
    switch (action) {
      case ChatSwipeAction.delete:
        return l10n.delete;
      case ChatSwipeAction.archive:
        return l10n.archive;
      case ChatSwipeAction.pin:
        return widget.conversation.isPinned ? l10n.chatUnpin : l10n.chatPin;
      case ChatSwipeAction.mute:
        return widget.conversation.isMuted ? l10n.chatUnmute : l10n.chatMute;
      case ChatSwipeAction.markRead:
        return widget.conversation.unreadCount > 0 ? l10n.markAsRead : l10n.markAsUnread;
      case ChatSwipeAction.markUnread:
        return l10n.markAsUnread;
      case ChatSwipeAction.none:
        return '';
    }
  }

  IconData _getActionIcon(ChatSwipeAction action) {
    switch (action) {
      case ChatSwipeAction.delete:
        return Icons.delete_outline_rounded;
      case ChatSwipeAction.archive:
        return Icons.archive_outlined;
      case ChatSwipeAction.pin:
        return widget.conversation.isPinned 
            ? Icons.push_pin_rounded 
            : Icons.push_pin_outlined;
      case ChatSwipeAction.mute:
        return widget.conversation.isMuted 
            ? Icons.notifications_active_outlined 
            : Icons.notifications_off_outlined;
      case ChatSwipeAction.markRead:
        return widget.conversation.unreadCount > 0 
            ? Icons.mark_chat_read_outlined 
            : Icons.mark_chat_unread_outlined;
      case ChatSwipeAction.markUnread:
        return Icons.mark_chat_unread_outlined;
      case ChatSwipeAction.none:
        return Icons.block_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final leftAction = _swipeSettings.leftAction;
    final rightAction = _swipeSettings.rightAction;
    
    // Determine dismiss direction based on settings
    DismissDirection direction;
    if (leftAction == ChatSwipeAction.none && rightAction == ChatSwipeAction.none) {
      direction = DismissDirection.none;
    } else if (leftAction == ChatSwipeAction.none) {
      direction = DismissDirection.startToEnd;
    } else if (rightAction == ChatSwipeAction.none) {
      direction = DismissDirection.endToStart;
    } else {
      direction = DismissDirection.horizontal;
    }

    return Dismissible(
      key: Key('chat_${widget.conversation.id}'),
      direction: direction,
      dismissThresholds: {
        DismissDirection.startToEnd: _swipeSettings.swipeSensitivity,
        DismissDirection.endToStart: _swipeSettings.swipeSensitivity,
      },
      confirmDismiss: (dir) async {
        HapticFeedback.lightImpact();
        
        ChatSwipeAction action;
        if (dir == DismissDirection.endToStart) {
          action = leftAction;
        } else {
          action = rightAction;
        }
        
        if (action == ChatSwipeAction.none) return false;
        
        final confirmed = await _confirmAction(context, action);
        if (confirmed) {
          _executeAction(action);
          // Return true only for delete to actually dismiss
          return action == ChatSwipeAction.delete;
        }
        return false;
      },
      background: rightAction != ChatSwipeAction.none
          ? _buildSwipeBackground(
              alignment: Alignment.centerLeft,
              color: rightAction.color,
              icon: _getActionIcon(rightAction),
              label: _getActionLabel(rightAction, l10n),
            )
          : const SizedBox.shrink(),
      secondaryBackground: leftAction != ChatSwipeAction.none
          ? _buildSwipeBackground(
              alignment: Alignment.centerRight,
              color: leftAction.color,
              icon: _getActionIcon(leftAction),
              label: _getActionLabel(leftAction, l10n),
            )
          : const SizedBox.shrink(),
      child: _buildTileContent(context),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 22),
              ],
      ),
    );
  }

  Widget _buildTileContent(BuildContext context) {
    final participant = widget.conversation.primaryParticipant;
    final hasUnread = widget.conversation.unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : (widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: hasUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: hasUnread
                  ? const Color(0xFF3B82F6).withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar with status indicator
                  _buildAvatar(participant),
                  const SizedBox(width: 14),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and time row
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.conversation.title,
                                      style: TextStyle(
                                        color: widget.isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                        fontSize: 15,
                                        fontWeight: hasUnread
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        fontFamily: 'Arimo',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.conversation.isPinned) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.push_pin_rounded,
                                      size: 14,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ],
                                  if (widget.conversation.isMuted) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.notifications_off_rounded,
                                      size: 14,
                                      color: widget.isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(widget.conversation.updatedAt),
                              style: TextStyle(
                                color: hasUnread
                                    ? const Color(0xFF3B82F6)
                                    : (widget.isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8)),
                                fontSize: 12,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Role badge
                        if (participant != null) _buildRoleBadge(participant),
                        
                        const SizedBox(height: 6),
                        
                        // Last message and unread count
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.conversation.lastMessage?.content ?? 'No messages yet',
                                style: TextStyle(
                                  color: hasUnread
                                      ? (widget.isDark ? Colors.white : const Color(0xFF1E293B))
                                      : (widget.isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                  fontSize: 13,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  fontFamily: 'Arimo',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.conversation.unreadCount > 99
                                      ? '99+'
                                      : widget.conversation.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildAvatar(ChatUser? participant) {
    final isGroup = widget.conversation.type == ConversationType.group;
    final isCourse = widget.conversation.type == ConversationType.course;
    
    Widget avatarContent;
    
    if (isCourse) {
      avatarContent = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: 24,
        ),
      );
    } else if (isGroup) {
      avatarContent = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.group_rounded,
          color: Colors.white,
          size: 24,
        ),
      );
    } else if (participant != null) {
      avatarContent = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              participant.avatarColor,
              participant.avatarColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            participant.initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Arimo',
            ),
          ),
        ),
      );
    } else {
      avatarContent = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.person_rounded,
          color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          size: 24,
        ),
      );
    }

    return Stack(
      children: [
        avatarContent,
        if (!isGroup && !isCourse && participant != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _getStatusColor(participant.status),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return const Color(0xFF22C55E);
      case OnlineStatus.away:
        return const Color(0xFFF59E0B);
      case OnlineStatus.busy:
        return const Color(0xFFEF4444);
      case OnlineStatus.offline:
        return const Color(0xFF94A3B8);
    }
  }

  Widget _buildRoleBadge(ChatUser participant) {
    Color bgColor;
    Color textColor;
    
    switch (participant.role) {
      case UserRole.instructor:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        break;
      case UserRole.ta:
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7C3AED);
        break;
      case UserRole.admin:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case UserRole.student:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        participant.roleDisplayName,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Arimo',
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

// Delete Chat Confirmation Dialog
class _DeleteChatDialog extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final String conversationTitle;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _DeleteChatDialog({
    required this.isDark,
    required this.l10n,
    required this.conversationTitle,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  State<_DeleteChatDialog> createState() => _DeleteChatDialogState();
}

class _DeleteChatDialogState extends State<_DeleteChatDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E1E2D) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.15),
                        const Color(0xFFDC2626).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.l10n.chatDeleteConversation,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Warning card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF252D48)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFEF4444),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                widget.l10n.chatDeleteConfirmMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Conversation name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                              color: widget.isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.conversationTitle,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.l10n.cancel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onDelete,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.l10n.delete,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
}

// Archive Chat Confirmation Dialog
class _ArchiveChatDialog extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final String conversationTitle;
  final VoidCallback onCancel;
  final VoidCallback onArchive;

  const _ArchiveChatDialog({
    required this.isDark,
    required this.l10n,
    required this.conversationTitle,
    required this.onCancel,
    required this.onArchive,
  });

  @override
  State<_ArchiveChatDialog> createState() => _ArchiveChatDialogState();
}

class _ArchiveChatDialogState extends State<_ArchiveChatDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E1E2D) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        const Color(0xFF2563EB).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.archive_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.l10n.chatArchiveConversation,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF252D48)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF3B82F6),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                widget.l10n.chatArchiveConfirmMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Conversation name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                              color: widget.isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.conversationTitle,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.l10n.cancel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onArchive,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.l10n.archive,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
}
