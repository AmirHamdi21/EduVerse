import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/chat/chat_models.dart';
import 'shared_emoji_row.dart';
import 'shared_message_bubble.dart';
import 'shared_typing_indicator.dart';

class SharedChatDetailView extends StatefulWidget {
  final ConversationModel conversation;
  final int currentUserId;
  final String? currentUserName;
  final Color accentColor;
  final bool isDark;
  final bool showVoiceCall;
  final bool showVideoCall;
  final bool showAttachment;
  final bool showVoiceMessage;
  final bool showEmojiPicker;
  final VoidCallback? onBack;

  const SharedChatDetailView({
    super.key,
    required this.conversation,
    required this.currentUserId,
    this.currentUserName,
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
    this.showVoiceCall = true,
    this.showVideoCall = true,
    this.showAttachment = true,
    this.showVoiceMessage = true,
    this.showEmojiPicker = true,
    this.onBack,
  });

  @override
  State<SharedChatDetailView> createState() => _SharedChatDetailViewState();
}

class _SharedChatDetailViewState extends State<SharedChatDetailView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Map<int, GlobalKey> _messageKeys = <int, GlobalKey>{};
  final Map<int, int> _messageIndexById = <int, int>{};
  bool _showEmojiPicker = false;
  int _newMessageCount = 0;
  bool _isNearBottom = true;
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final isNear = _scrollController.position.pixels <= 200;
    if (isNear != _isNearBottom) {
      setState(() {
        _isNearBottom = isNear;
        if (_isNearBottom) {
          _newMessageCount = 0;
        }
      });
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final bloc = context.read<ChatBloc>();
      if (!bloc.state.isLoadingMore) {
        bloc.add(
          LoadMoreMessages(
            conversationId: widget.conversation.conversationId,
            page: bloc.state.activePage + 1,
          ),
        );
      }
    }
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _typingDebounce?.cancel();
      context.read<ChatBloc>().add(
        TypingChanged(
          conversationId: widget.conversation.conversationId,
          isTyping: false,
        ),
      );
    } else {
      _typingDebounce?.cancel();
      context.read<ChatBloc>().add(
        TypingChanged(
          conversationId: widget.conversation.conversationId,
          isTyping: true,
        ),
      );
      _typingDebounce = Timer(const Duration(milliseconds: 1500), () {
        context.read<ChatBloc>().add(
          TypingChanged(
            conversationId: widget.conversation.conversationId,
            isTyping: false,
          ),
        );
      });
    }
  }

  void _syncMessageAnchors(List<ChatMessageModel> messages) {
    final activeIds = messages.map((message) => message.id).toSet();
    _messageKeys.removeWhere((id, _) => !activeIds.contains(id));

    _messageIndexById
      ..clear()
      ..addEntries(
        messages.asMap().entries.map((entry) {
          return MapEntry(entry.value.id, entry.key);
        }),
      );

    for (final message in messages) {
      _messageKeys.putIfAbsent(
        message.id,
        () => GlobalKey(debugLabel: 'msg-${message.id}'),
      );
    }
  }

  void _showMissingMessageToast() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.chatMessageTooOld)));
  }

  void _scrollToMessage(int messageId) {
    if (!_messageIndexById.containsKey(messageId)) {
      _showMissingMessageToast();
      return;
    }

    _attemptScrollToMessage(messageId, attempt: 0);
  }

  void _attemptScrollToMessage(int messageId, {required int attempt}) {
    final targetKey = _messageKeys[messageId];
    final targetContext = targetKey?.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
      return;
    }

    if (!_scrollController.hasClients || attempt >= 6) {
      _showMissingMessageToast();
      return;
    }

    final targetIndex = _messageIndexById[messageId];
    final messageCount = _messageIndexById.length;
    if (targetIndex == null || messageCount <= 1) {
      _showMissingMessageToast();
      return;
    }

    final maxExtent = _scrollController.position.maxScrollExtent;
    final ratio = targetIndex / (messageCount - 1);
    final nextOffset = (maxExtent * ratio).clamp(0.0, maxExtent);

    _scrollController
        .animateTo(
          nextOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          if (!mounted) {
            return;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _attemptScrollToMessage(messageId, attempt: attempt + 1);
          });
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() {
      _newMessageCount = 0;
      _isNearBottom = true;
    });
  }

  Future<void> _editMessage(ChatMessageModel message) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: message.text);
    final nextText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.chatEditMessageDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            minLines: 1,
            decoration: InputDecoration(
              hintText: l10n.chatEditMessageDialogHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || nextText == null) {
      return;
    }

    if (nextText.trim().isEmpty || nextText.trim() == message.text.trim()) {
      return;
    }

    context.read<ChatBloc>().add(
      EditMessage(
        messageId: message.id,
        conversationId: message.conversationId,
        text: nextText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) {
        if (current.activeConversationId !=
            widget.conversation.conversationId) {
          return false;
        }

        if (previous.activeConversationMessages.length ==
            current.activeConversationMessages.length) {
          return false;
        }

        if (current.activeConversationMessages.isEmpty) {
          return false;
        }

        final previousNewestId = previous.activeConversationMessages.isNotEmpty
            ? previous.activeConversationMessages.first.id
            : null;
        final currentNewestId = current.activeConversationMessages.first.id;

        return previousNewestId != currentNewestId;
      },
      listener: (context, state) {
        if (state.activeConversationMessages.isNotEmpty &&
            _scrollController.hasClients) {
          if (_isNearBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else {
            setState(() {
              _newMessageCount++;
            });
          }
        }
      },
      builder: (context, state) {
        final visibleMessages = state.activeConversationMessages
            .where((msg) => !state.hiddenMessageIds.contains(msg.id))
            .toList(growable: false);
        _syncMessageAnchors(visibleMessages);
        final backgroundColor = widget.isDark
            ? const Color(0xFF020617)
            : const Color(0xFFF8FAFC);

        return Container(
          color: backgroundColor,
          child: Column(
            children: [
              _ConversationHeader(
                conversation: widget.conversation,
                connectionStatus: state.connectionStatus,
                typingUsers:
                    state.typingUsers[widget.conversation.conversationId] ?? [],
                onlineUsers: state.onlineUsers,
                userLastSeen: state.userLastSeen,
                accentColor: widget.accentColor,
                isDark: widget.isDark,
                showVoiceCall: widget.showVoiceCall,
                showVideoCall: widget.showVideoCall,
                onOpenConversationInfo: () {
                  if (widget.conversation.type == ConversationType.group) {
                    context.push(
                      '/messages/group/${widget.conversation.conversationId}',
                    );
                    return;
                  }

                  final directUserId =
                      widget.conversation.directDisplayUser?.userId;
                  if (directUserId != null && directUserId > 0) {
                    context.push('/messages/profile/$directUserId');
                  }
                },
                onBack: widget.onBack,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              backgroundColor,
                              widget.accentColor.withValues(
                                alpha: widget.isDark ? 0.08 : 0.04,
                              ),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -40,
                      top: 10,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(
                            alpha: widget.isDark ? 0.08 : 0.05,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -50,
                      bottom: 30,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(
                            alpha: widget.isDark ? 0.06 : 0.04,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    _MessageList(
                      messages: visibleMessages,
                      conversation: widget.conversation,
                      currentUserId: widget.currentUserId,
                      scrollController: _scrollController,
                      messageKeys: _messageKeys,
                      accentColor: widget.accentColor,
                      isDark: widget.isDark,
                      status: state.status,
                      errorMessage: state.errorMessage,
                      participantCache: state.participantCache,
                      onReply: (message) {
                        context.read<ChatBloc>().add(
                          SetReplyContext(message: message),
                        );
                      },
                      onTapReplyContext: _scrollToMessage,
                      onDeleteForMe: (messageId) {
                        context.read<ChatBloc>().add(
                          DeleteMessage(
                            messageId: messageId,
                            forEveryone: false,
                            conversationId: widget.conversation.conversationId,
                          ),
                        );
                      },
                      onDeleteForEveryone: (messageId) {
                        context.read<ChatBloc>().add(
                          DeleteMessage(
                            messageId: messageId,
                            forEveryone: true,
                            conversationId: widget.conversation.conversationId,
                          ),
                        );
                      },
                      onEdit: _editMessage,
                      onRetry: (messageId) {
                        context.read<ChatBloc>().add(
                          RetryFailedMessage(messageId),
                        );
                      },
                      onRetryLoad: () {
                        context.read<ChatBloc>().add(
                          SelectConversation(
                            widget.conversation.conversationId,
                          ),
                        );
                      },
                    ),
                    if (_newMessageCount > 0)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _NewMessagesIndicator(
                            count: _newMessageCount,
                            onTap: _scrollToBottom,
                            accentColor: widget.accentColor,
                            isDark: widget.isDark,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (state.replyToMessage != null)
                _ReplyPreviewBar(
                  replyToMessage: state.replyToMessage!,
                  participantCache: state.participantCache,
                  accentColor: widget.accentColor,
                  isDark: widget.isDark,
                  onDismiss: () {
                    context.read<ChatBloc>().add(
                      const SetReplyContext(message: null),
                    );
                  },
                ),
              if (_showEmojiPicker && widget.showEmojiPicker)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SharedEmojiRow(
                    onEmojiSelected: (emoji) {
                      final cursorPos = _textController.selection.base.offset;
                      final text = _textController.text;
                      final newText =
                          text.substring(0, cursorPos) +
                          emoji +
                          text.substring(cursorPos);
                      _textController.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(
                          offset: cursorPos + emoji.length,
                        ),
                      );
                      setState(() {
                        _showEmojiPicker = false;
                      });
                    },
                    accentColor: widget.accentColor,
                    isDark: widget.isDark,
                  ),
                ),
              _InputBar(
                textController: _textController,
                focusNode: _focusNode,
                showAttachment: widget.showAttachment,
                showVoiceMessage: widget.showVoiceMessage,
                showEmojiPicker: widget.showEmojiPicker,
                emojiPickerVisible: _showEmojiPicker,
                accentColor: widget.accentColor,
                isDark: widget.isDark,
                connectionStatus: state.connectionStatus,
                onSend: () {
                  final text = _textController.text.trim();
                  if (text.isEmpty) {
                    return;
                  }

                  context.read<ChatBloc>().add(
                    SendMessage(
                      conversationId: widget.conversation.conversationId,
                      text: text,
                      replyToId: state.replyToMessage?.id,
                    ),
                  );

                  _textController.clear();
                  if (state.replyToMessage != null) {
                    context.read<ChatBloc>().add(
                      const SetReplyContext(message: null),
                    );
                  }
                },
                onToggleEmojiPicker: () {
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  final ConversationModel conversation;
  final ConnectionStatus connectionStatus;
  final List<int> typingUsers;
  final Set<int> onlineUsers;
  final Map<int, DateTime> userLastSeen;
  final Color accentColor;
  final bool isDark;
  final bool showVoiceCall;
  final bool showVideoCall;
  final VoidCallback? onOpenConversationInfo;
  final VoidCallback? onBack;

  const _ConversationHeader({
    required this.conversation,
    required this.connectionStatus,
    required this.typingUsers,
    required this.onlineUsers,
    required this.userLastSeen,
    required this.accentColor,
    required this.isDark,
    required this.showVoiceCall,
    required this.showVideoCall,
    this.onOpenConversationInfo,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typingUserNames = typingUsers.map((userId) {
      final user = conversation.participantUsers
          .where((u) => u.userId == userId)
          .firstOrNull;
      return user?.displayName ?? l10n.unknown;
    }).toList();

    final directUser = conversation.directDisplayUser;
    final isOnline =
        conversation.type == ConversationType.direct &&
        directUser != null &&
        onlineUsers.contains(directUser.userId);
    final canOpenConversationInfo =
        onOpenConversationInfo != null &&
        (conversation.type == ConversationType.group || directUser != null);
    final lastSeen = directUser != null
        ? userLastSeen[directUser.userId]
        : null;
    final subtitleText = isOnline
        ? l10n.chatOnlineNow
        : (lastSeen != null
              ? l10n.chatLastSeen(_formatLastSeen(context, lastSeen))
              : l10n.chatConnectionOffline);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              accentColor,
              Color.lerp(accentColor, Colors.white, 0.16)!,
              Color.lerp(accentColor, const Color(0xFF06B6D4), 0.24)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.24 : 0.16),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (onBack != null)
                      _HeaderActionButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: onBack,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                      ),
                    if (onBack != null) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: canOpenConversationInfo
                          ? onOpenConversationInfo
                          : null,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: conversation.type == ConversationType.group
                              ? const Icon(
                                  Icons.groups_rounded,
                                  color: Colors.white,
                                  size: 22,
                                )
                              : Text(
                                  _titleInitial(conversation.title),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            onTap: canOpenConversationInfo
                                ? onOpenConversationInfo
                                : null,
                            child: Text(
                              conversation.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (typingUserNames.isNotEmpty)
                            SharedTypingIndicator(
                              typingUserNames: typingUserNames,
                              accentColor: Colors.white,
                              isDark: true,
                            )
                          else
                            Text(
                              subtitleText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.90),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (showVoiceCall)
                      _HeaderActionButton(
                        icon: Icons.call_rounded,
                        onPressed: () => _showComingSoon(context),
                        tooltip: l10n.chatVoiceCallTooltip,
                      ),
                    if (showVoiceCall) const SizedBox(width: 6),
                    if (showVideoCall)
                      _HeaderActionButton(
                        icon: Icons.videocam_rounded,
                        onPressed: () => _showComingSoon(context),
                        tooltip: l10n.chatVideoCallTooltip,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: <Widget>[
                    _HeaderChip(
                      icon: Icons.circle,
                      label: _connectionLabel(l10n, connectionStatus),
                    ),
                    _HeaderChip(
                      icon: conversation.type == ConversationType.group
                          ? Icons.groups_rounded
                          : Icons.person_rounded,
                      label: conversation.type == ConversationType.group
                          ? l10n.chatGroupConversationLabel
                          : l10n.chatDirectConversationLabel,
                    ),
                    _HeaderChip(
                      icon: Icons.people_outline_rounded,
                      label: l10n.chatParticipantsCount(
                        conversation.participants.length,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  String _titleInitial(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return '?';
    }
    return normalized[0].toUpperCase();
  }

  String _connectionLabel(AppLocalizations l10n, ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.live:
        return l10n.chatConnectionLive;
      case ConnectionStatus.connecting:
        return l10n.chatConnectionConnecting;
      case ConnectionStatus.offline:
        return l10n.chatConnectionOffline;
    }
  }

  String _formatLastSeen(BuildContext context, DateTime lastSeen) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 1) {
      return l10n.chatRelativeNow;
    }
    if (diff.inMinutes < 60) {
      return l10n.chatRelativeMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return l10n.chatRelativeHoursAgo(diff.inHours);
    }
    return MaterialLocalizations.of(
      context,
    ).formatShortDate(lastSeen.toLocal());
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _HeaderActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        icon: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final ConversationModel conversation;
  final int currentUserId;
  final ScrollController scrollController;
  final Map<int, GlobalKey> messageKeys;
  final Color accentColor;
  final bool isDark;
  final ChatStatus status;
  final String? errorMessage;
  final Map<int, ChatUserModel> participantCache;
  final void Function(ChatMessageModel) onReply;
  final void Function(int) onTapReplyContext;
  final void Function(int) onDeleteForMe;
  final void Function(int) onDeleteForEveryone;
  final void Function(ChatMessageModel message) onEdit;
  final void Function(int) onRetry;
  final VoidCallback onRetryLoad;

  const _MessageList({
    required this.messages,
    required this.conversation,
    required this.currentUserId,
    required this.scrollController,
    required this.messageKeys,
    required this.accentColor,
    required this.isDark,
    required this.status,
    required this.errorMessage,
    required this.participantCache,
    required this.onReply,
    required this.onTapReplyContext,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
    required this.onEdit,
    required this.onRetry,
    required this.onRetryLoad,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (status == ChatStatus.loading && messages.isEmpty) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (status == ChatStatus.failure && messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_chat_read_rounded,
                  size: 42,
                  color: accentColor,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.chatLoadFailedTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (errorMessage ?? '').trim().isNotEmpty
                      ? errorMessage!
                      : l10n.chatMessagesLoadFailedSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onRetryLoad,
                  style: FilledButton.styleFrom(backgroundColor: accentColor),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.waving_hand_rounded,
                    color: accentColor,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noMessagesYet,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chatNoMessagesConversationSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 18),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final isGroup = conversation.type == ConversationType.group;

        final showSenderInfo =
            isGroup &&
            !isMe &&
            (index == messages.length - 1 ||
                messages[index + 1].senderId != message.senderId);

        ChatMessageModel? replyToMsg;
        if (message.replyToId != null) {
          replyToMsg = messages
              .where((m) => m.id == message.replyToId)
              .firstOrNull;

          replyToMsg ??= ChatMessageModel(
            id: message.replyToId!,
            text: l10n.chatOriginalMessageUnavailable,
            senderId: 0,
            senderName: l10n.unknown,
            sentAt: message.sentAt,
            conversationId: message.conversationId,
            status: 'sent',
          );
        }

        final bubbleKey = messageKeys[message.id]!;
        final canDeleteForEveryone =
            isMe &&
            !message.isDeleted &&
            message.status != 'pending' &&
            message.status != 'sending' &&
            DateTime.now().difference(message.sentAt).inHours < 24;
        final canEdit =
            isMe &&
            !message.isDeleted &&
            message.status != 'pending' &&
            message.status != 'sending' &&
            !message.isFailed;

        return KeyedSubtree(
          key: bubbleKey,
          child: SharedMessageBubble(
            message: message,
            isMe: isMe,
            isGroup: isGroup,
            showSenderInfo: showSenderInfo,
            replyToMessage: replyToMsg,
            participantCache: participantCache,
            accentColor: accentColor,
            isDark: isDark,
            canDeleteForEveryone: canDeleteForEveryone,
            canEdit: canEdit,
            onReply: () => onReply(message),
            onEdit: () => onEdit(message),
            onDeleteForMe: () => onDeleteForMe(message.id),
            onDeleteForEveryone: () => onDeleteForEveryone(message.id),
            onTapReplyContext: message.replyToId == null
                ? null
                : () => onTapReplyContext(message.replyToId!),
            onRetry: message.isFailed ? () => onRetry(message.id) : null,
          ),
        );
      },
    );
  }
}

class _ReplyPreviewBar extends StatelessWidget {
  final ChatMessageModel replyToMessage;
  final Map<int, ChatUserModel> participantCache;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onDismiss;

  const _ReplyPreviewBar({
    required this.replyToMessage,
    required this.participantCache,
    required this.accentColor,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.reply_rounded, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chatReplyingTo(
                      replyToMessage.hydratedReplyToName(participantCache),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    replyToMessage.isDeleted
                        ? replyToMessage.deletedText
                        : replyToMessage.text,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                      fontStyle: replyToMessage.isDeleted
                          ? FontStyle.italic
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool showAttachment;
  final bool showVoiceMessage;
  final bool showEmojiPicker;
  final bool emojiPickerVisible;
  final Color accentColor;
  final bool isDark;
  final ConnectionStatus connectionStatus;
  final VoidCallback onSend;
  final VoidCallback onToggleEmojiPicker;

  const _InputBar({
    required this.textController,
    required this.focusNode,
    required this.showAttachment,
    required this.showVoiceMessage,
    required this.showEmojiPicker,
    required this.emojiPickerVisible,
    required this.accentColor,
    required this.isDark,
    required this.connectionStatus,
    required this.onSend,
    required this.onToggleEmojiPicker,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;
    final mutedText = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final activeAccent = connectionStatus == ConnectionStatus.offline
        ? const Color(0xFFF97316)
        : accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: activeAccent.withValues(alpha: isDark ? 0.16 : 0.10),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: activeAccent.withValues(alpha: isDark ? 0.16 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: textController,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        if (showEmojiPicker)
                          _ComposerIconButton(
                            icon: emojiPickerVisible
                                ? Icons.keyboard_rounded
                                : Icons.emoji_emotions_outlined,
                            color: mutedText,
                            onPressed: onToggleEmojiPicker,
                          ),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            focusNode: focusNode,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: l10n.typeMessage,
                              hintStyle: TextStyle(color: mutedText),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        if (showAttachment)
                          _ComposerIconButton(
                            icon: Icons.attach_file_rounded,
                            color: mutedText,
                            onPressed: () =>
                                _showAttachmentSheet(context, activeAccent),
                          ),
                        // if (!hasText)
                        //   _ComposerIconButton(
                        //     icon: Icons.camera_alt_rounded,
                        //     color: mutedText,
                        //     onPressed: () {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         SnackBar(content: Text(l10n.comingSoon)),
                        //       );
                        //     },
                        //   ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        activeAccent,
                        Color.lerp(
                          activeAccent,
                          const Color(0xFF06B6D4),
                          0.28,
                        )!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: IconButton(
                    onPressed: hasText
                        ? onSend
                        : (showVoiceMessage
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.comingSoon)),
                                  );
                                }
                              : null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 48,
                      height: 48,
                    ),
                    icon: Icon(
                      hasText ? Icons.send_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: hasText ? 22 : 24,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAttachmentSheet(
    BuildContext context,
    Color activeAccent,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isSheetDark =
            Theme.of(sheetContext).brightness == Brightness.dark;
        final cardColor = isSheetDark ? const Color(0xFF111827) : Colors.white;
        final options = <_AttachmentOption>[
          _AttachmentOption(
            icon: Icons.photo_library_rounded,
            label: l10n.gallery,
            color: const Color(0xFF3B82F6),
          ),
          _AttachmentOption(
            icon: Icons.camera_alt_rounded,
            label: l10n.camera,
            color: const Color(0xFFEC4899),
          ),
          _AttachmentOption(
            icon: Icons.location_on_rounded,
            label: l10n.chatAttachmentLocation,
            color: const Color(0xFF14B8A6),
          ),
          _AttachmentOption(
            icon: Icons.person_rounded,
            label: l10n.chatAttachmentContact,
            color: const Color(0xFF3B82F6),
          ),
          _AttachmentOption(
            icon: Icons.description_rounded,
            label: l10n.document,
            color: const Color(0xFF8B5CF6),
          ),
          _AttachmentOption(
            icon: Icons.headphones_rounded,
            label: l10n.chatAttachmentAudio,
            color: const Color(0xFFF97316),
          ),
          _AttachmentOption(
            icon: Icons.poll_rounded,
            label: l10n.chatAttachmentPoll,
            color: const Color(0xFFF59E0B),
          ),
          _AttachmentOption(
            icon: Icons.event_rounded,
            label: l10n.chatAttachmentEvent,
            color: const Color(0xFFEC4899),
          ),
          _AttachmentOption(
            icon: Icons.auto_awesome_rounded,
            label: l10n.chatAttachmentAiImages,
            color: activeAccent,
          ),
        ];

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.attachments,
                    style: TextStyle(
                      color: isSheetDark
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.chatAttachmentSheetSubtitle,
                    style: TextStyle(
                      color: isSheetDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 42) / 4;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: options
                            .map((option) {
                              return SizedBox(
                                width: itemWidth.clamp(68.0, 84.0).toDouble(),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.of(sheetContext).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.comingSoon)),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: option.color.withValues(
                                            alpha: 0.10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Icon(
                                          option.icon,
                                          color: option.color,
                                          size: 25,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        option.label,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSheetDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ComposerIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
      splashRadius: 20,
      icon: Icon(icon, color: color, size: 20),
    );
  }
}

class _AttachmentOption {
  final IconData icon;
  final String label;
  final Color color;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _NewMessagesIndicator extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final Color accentColor;
  final bool isDark;

  const _NewMessagesIndicator({
    required this.count,
    required this.onTap,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.45 : 0.30),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.chatNewMessagesCount(count),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
