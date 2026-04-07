import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/chat/chat_state.dart';
import 'shared_emoji_row.dart';
import 'shared_message_bubble.dart';
import 'shared_typing_indicator.dart';

/// Full message detail view with header, message list, and input bar.
/// Shared across all 5 user roles with BLoC integration.
class SharedChatDetailView extends StatefulWidget {
  /// The conversation being displayed
  final ConversationModel conversation;

  /// Current user's ID for determining message alignment
  final int currentUserId;

  /// Current user's display name for outgoing messages
  final String? currentUserName;

  /// Primary accent color for theming
  final Color accentColor;

  /// Dark mode flag
  final bool isDark;

  /// Show voice call button (placeholder)
  final bool showVoiceCall;

  /// Show video call button (placeholder)
  final bool showVideoCall;

  /// Show attachment button (placeholder)
  final bool showAttachment;

  /// Show voice message toggle (placeholder)
  final bool showVoiceMessage;

  /// Show emoji picker button
  final bool showEmojiPicker;

  /// Callback when back button is pressed (mobile navigation)
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
  bool _showEmojiPicker = false;
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
    // Load more messages when scrolled near top
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        // Auto-scroll on new message
        if (state.activeConversationMessages.isNotEmpty &&
            _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 40),
            child: _ConversationHeader(
              conversation: widget.conversation,
              connectionStatus: state.connectionStatus,
              typingUsers:
                  state.typingUsers[widget.conversation.conversationId] ?? [],
              onlineUsers: state.onlineUsers,
              accentColor: widget.accentColor,
              isDark: widget.isDark,
              showVoiceCall: widget.showVoiceCall,
              showVideoCall: widget.showVideoCall,
              onBack: widget.onBack,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: _MessageList(
                  messages: state.activeConversationMessages
                      .where((msg) => !state.hiddenMessageIds.contains(msg.id))
                      .toList(),
                  conversation: widget.conversation,
                  currentUserId: widget.currentUserId,
                  scrollController: _scrollController,
                  accentColor: widget.accentColor,
                  isDark: widget.isDark,
                  onReply: (message) {
                    context.read<ChatBloc>().add(
                      SetReplyContext(message: message),
                    );
                  },
                  onDeleteForMe: (messageId) {
                    context.read<ChatBloc>().add(HideMessageLocally(messageId));
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
                  onRetry: (messageId) {
                    context.read<ChatBloc>().add(RetryFailedMessage(messageId));
                  },
                ),
              ),
              if (state.replyToMessage != null)
                _ReplyPreviewBar(
                  replyToMessage: state.replyToMessage!,
                  accentColor: widget.accentColor,
                  isDark: widget.isDark,
                  onDismiss: () {
                    context.read<ChatBloc>().add(
                      const SetReplyContext(message: null),
                    );
                  },
                ),
              if (_showEmojiPicker && widget.showEmojiPicker)
                SharedEmojiRow(
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
                  if (text.isEmpty) return;

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

/// Private widget: Conversation header with status and call buttons
class _ConversationHeader extends StatelessWidget {
  final ConversationModel conversation;
  final ConnectionStatus connectionStatus;
  final List<int> typingUsers;
  final Set<int> onlineUsers;
  final Color accentColor;
  final bool isDark;
  final bool showVoiceCall;
  final bool showVideoCall;
  final VoidCallback? onBack;

  const _ConversationHeader({
    required this.conversation,
    required this.connectionStatus,
    required this.typingUsers,
    required this.onlineUsers,
    required this.accentColor,
    required this.isDark,
    required this.showVoiceCall,
    required this.showVideoCall,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final typingUserNames = typingUsers.map((userId) {
      final user = conversation.participantUsers
          .where((u) => u.userId == userId)
          .firstOrNull;
      return user?.displayName ?? 'Someone';
    }).toList();

    final isOnline =
        conversation.type == ConversationType.direct &&
        conversation.directDisplayUser != null &&
        onlineUsers.contains(conversation.directDisplayUser!.userId);

    return AppBar(
      leading: onBack != null
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  conversation.title,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildConnectionBadge(),
            ],
          ),
          if (typingUserNames.isNotEmpty)
            SharedTypingIndicator(
              typingUserNames: typingUserNames,
              accentColor: accentColor,
              isDark: isDark,
            )
          else if (isOnline)
            Text(
              'Online',
              style: TextStyle(fontSize: 12, color: Colors.green[400]),
            ),
        ],
      ),
      actions: [
        if (showVoiceCall)
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
        if (showVideoCall)
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
      ],
    );
  }

  Widget _buildConnectionBadge() {
    String label;
    Color color;

    switch (connectionStatus) {
      case ConnectionStatus.live:
        label = 'Live';
        color = Colors.green;
        break;
      case ConnectionStatus.connecting:
        label = 'Connecting...';
        color = Colors.orange;
        break;
      case ConnectionStatus.offline:
        label = 'Offline';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Private widget: Scrollable message list with pagination
class _MessageList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final ConversationModel conversation;
  final int currentUserId;
  final ScrollController scrollController;
  final Color accentColor;
  final bool isDark;
  final void Function(ChatMessageModel) onReply;
  final void Function(int) onDeleteForMe;
  final void Function(int) onDeleteForEveryone;
  final void Function(int) onRetry;

  const _MessageList({
    required this.messages,
    required this.conversation,
    required this.currentUserId,
    required this.scrollController,
    required this.accentColor,
    required this.isDark,
    required this.onReply,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final isGroup = conversation.type == ConversationType.group;

        // Show sender info if group and not consecutive message from same sender
        final showSenderInfo =
            isGroup &&
            !isMe &&
            (index == messages.length - 1 ||
                messages[index + 1].senderId != message.senderId);

        // Find reply-to message if exists
        ChatMessageModel? replyToMsg;
        if (message.replyToId != null) {
          replyToMsg = messages
              .where((m) => m.id == message.replyToId)
              .firstOrNull;
        }

        // Calculate if can delete for everyone (24h window)
        final canDeleteForEveryone =
            isMe &&
            !message.isDeleted &&
            message.status != 'pending' &&
            DateTime.now().difference(message.sentAt).inHours < 24;

        return SharedMessageBubble(
          message: message,
          isMe: isMe,
          isGroup: isGroup,
          showSenderInfo: showSenderInfo,
          replyToMessage: replyToMsg,
          accentColor: accentColor,
          isDark: isDark,
          canDeleteForEveryone: canDeleteForEveryone,
          onReply: () => onReply(message),
          onDeleteForMe: () => onDeleteForMe(message.id),
          onDeleteForEveryone: () => onDeleteForEveryone(message.id),
          onRetry: message.isFailed ? () => onRetry(message.id) : null,
        );
      },
    );
  }
}

/// Private widget: Reply preview bar showing quoted message
class _ReplyPreviewBar extends StatelessWidget {
  final ChatMessageModel replyToMessage;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onDismiss;

  const _ReplyPreviewBar({
    required this.replyToMessage,
    required this.accentColor,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        border: Border(
          top: BorderSide(color: accentColor.withOpacity(0.3), width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${replyToMessage.senderName ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyToMessage.isDeleted
                      ? replyToMessage.deletedText
                      : replyToMessage.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
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
            icon: const Icon(Icons.close, size: 20),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

/// Private widget: Text input bar with send button and placeholders
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAttachment)
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Coming soon')));
              },
            ),
          if (showVoiceMessage)
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Coming soon')));
              },
            ),
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          if (showEmojiPicker)
            IconButton(
              icon: Icon(
                emojiPickerVisible ? Icons.keyboard : Icons.emoji_emotions,
              ),
              onPressed: onToggleEmojiPicker,
            ),
          IconButton(
            icon: Icon(Icons.send, color: accentColor),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
