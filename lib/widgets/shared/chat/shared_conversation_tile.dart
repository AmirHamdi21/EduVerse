import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../bloc/chat/chat_models.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../modern_action_sheet.dart';

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
    final l10n = AppLocalizations.of(context);
    final subtitle = _buildSubtitle(l10n);
    final primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final hasUnread = conversation.unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          onLongPress: () => _openActions(context),
          child: Ink(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: hasUnread
                    ? accentColor.withValues(alpha: 0.20)
                    : (isDark
                          ? const Color(0xFF233047)
                          : const Color(0xFFE2E8F0)),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accentColor.withValues(alpha: hasUnread ? 0.12 : 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: -12,
                  top: -10,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    _avatarColor(),
                                    Color.lerp(
                                      _avatarColor(),
                                      accentColor,
                                      0.35,
                                    )!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(child: _avatarChild()),
                            ),
                            if (isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cardColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        conversation.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: primaryText,
                                          fontSize: 16,
                                          fontWeight: hasUnread
                                              ? FontWeight.w800
                                              : FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: <Widget>[
                                          if (conversation.type ==
                                              ConversationType.group)
                                            _MetaChip(
                                              label: l10n.chatFilterGroups,
                                              icon: Icons.groups_rounded,
                                              color: accentColor,
                                              isDark: isDark,
                                            ),
                                          if (isOnline)
                                            _MetaChip(
                                              label: l10n.chatOnlineNow,
                                              icon: Icons.circle,
                                              color: const Color(0xFF22C55E),
                                              isDark: isDark,
                                            ),
                                          if (isPinned)
                                            _MetaChip(
                                              label: l10n.chatPinnedLabel,
                                              icon: Icons.push_pin_rounded,
                                              color: accentColor,
                                              isDark: isDark,
                                            ),
                                          if (isMuted)
                                            _MetaChip(
                                              label: l10n.chatMutedLabel,
                                              icon: Icons.volume_off_rounded,
                                              color: const Color(0xFFF59E0B),
                                              isDark: isDark,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    _TopActionButton(
                                      onPressed: () => _openActions(context),
                                      icon: Icons.more_horiz_rounded,
                                      accentColor: accentColor,
                                      isDark: isDark,
                                      tooltip: l10n.chatConversationOptions,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _formatTimestamp(
                                        context,
                                        conversation.updatedAt,
                                      ),
                                      style: TextStyle(
                                        color: hasUnread
                                            ? accentColor
                                            : secondaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13.5,
                                height: 1.38,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    conversation.type == ConversationType.group
                                        ? l10n.chatGroupConversationLabel
                                        : l10n.chatDirectConversationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (hasUnread)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
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
                                        fontWeight: FontWeight.w800,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showModernActionSheet<_ConversationAction>(
      context,
      title: conversation.title,
      subtitle: conversation.type == ConversationType.group
          ? l10n.chatActionSheetGroupSubtitle
          : l10n.chatActionSheetDirectSubtitle,
      accentColor: accentColor,
      actions: <ModernActionItem<_ConversationAction>>[
        if (onAvatarTap != null)
          ModernActionItem<_ConversationAction>(
            value: _ConversationAction.profile,
            label: l10n.chatActionOpenProfile,
            icon: Icons.person_outline_rounded,
            description: l10n.chatActionOpenProfileDesc,
          ),
        ModernActionItem<_ConversationAction>(
          value: _ConversationAction.pin,
          label: isPinned ? l10n.chatActionUnpin : l10n.chatActionPin,
          icon: isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
          description: isPinned
              ? l10n.chatActionUnpinDesc
              : l10n.chatActionPinDesc,
        ),
        ModernActionItem<_ConversationAction>(
          value: _ConversationAction.mute,
          label: isMuted ? l10n.chatActionUnmute : l10n.chatActionMute,
          icon: isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          description: isMuted
              ? l10n.chatActionUnmuteDesc
              : l10n.chatActionMuteDesc,
          color: const Color(0xFFF59E0B),
        ),
        ModernActionItem<_ConversationAction>(
          value: _ConversationAction.delete,
          label: l10n.chatActionDeleteConversation,
          icon: Icons.delete_outline_rounded,
          description: l10n.chatActionDeleteConversationDesc,
          destructive: true,
        ),
      ],
    );

    switch (result) {
      case _ConversationAction.profile:
        onAvatarTap?.call();
        break;
      case _ConversationAction.pin:
        onPin();
        break;
      case _ConversationAction.mute:
        onMute();
        break;
      case _ConversationAction.delete:
        onDelete();
        break;
      case null:
        break;
    }
  }

  String _buildSubtitle(AppLocalizations l10n) {
    final lastMessageText =
        conversation.lastMessage ?? conversation.lastMessageInfo?.text ?? '';
    final normalized = lastMessageText.trim();
    if (normalized.isEmpty) {
      return l10n.noMessagesYet;
    }
    if (conversation.type == ConversationType.group &&
        (conversation.lastMessageInfo?.senderName ?? '').trim().isNotEmpty) {
      return '${conversation.lastMessageInfo!.senderName}: $normalized';
    }
    return normalized;
  }

  Widget _avatarChild() {
    if (conversation.type == ConversationType.group) {
      return const Icon(Icons.groups_rounded, color: Colors.white, size: 24);
    }

    return Text(
      _initials(conversation.title),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 14,
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

  String _formatTimestamp(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return l10n.chatRelativeNow;
    }
    if (diff.inMinutes < 60) {
      return l10n.chatRelativeMinutes(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return DateFormat.jm(locale).format(dateTime.toLocal());
    }
    if (diff.inDays < 7) {
      return l10n.chatRelativeDays(diff.inDays);
    }

    return DateFormat.MMMd(locale).format(dateTime.toLocal());
  }
}

enum _ConversationAction { profile, pin, mute, delete }

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MetaChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final String tooltip;

  const _TopActionButton({
    required this.onPressed,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accentColor.withValues(alpha: isDark ? 0.14 : 0.08),
      borderRadius: BorderRadius.circular(16),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: accentColor),
      ),
    );
  }
}
