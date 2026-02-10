import 'package:flutter/material.dart';
import '../shared/instructor_colors.dart';
import 'instructor_chat_models.dart';

class InstructorChatDetailView extends StatefulWidget {
  final InstructorConversation conversation;
  final List<InstructorChatMessage> messages;
  final bool isDark;
  final bool isLoading;
  final bool isSending;
  final VoidCallback onBack;
  final Function(String message)? onSendMessage;
  final Function(String messageId)? onReply;

  const InstructorChatDetailView({
    super.key,
    required this.conversation,
    required this.messages,
    required this.isDark,
    required this.onBack,
    this.isLoading = false,
    this.isSending = false,
    this.onSendMessage,
    this.onReply,
  });

  @override
  State<InstructorChatDetailView> createState() => _InstructorChatDetailViewState();
}

class _InstructorChatDetailViewState extends State<InstructorChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    widget.onSendMessage?.call(_messageController.text.trim());
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: widget.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: InstructorColors.primary,
                  ),
                )
              : widget.messages.isEmpty
                  ? _buildEmptyChat()
                  : _buildMessageList(),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(widget.isDark),
        border: Border(
          bottom: BorderSide(
            color: InstructorColors.borderColor(widget.isDark),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: InstructorColors.textPrimaryColor(widget.isDark),
                size: 20,
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.conversation.type == InstructorConversationType.group
                    ? InstructorColors.accent.withValues(alpha: 0.1)
                    : InstructorColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: widget.conversation.type == InstructorConversationType.group
                    ? Icon(
                        Icons.group_outlined,
                        color: InstructorColors.accent,
                        size: 22,
                      )
                    : Text(
                        widget.conversation.avatar,
                        style: TextStyle(
                          color: InstructorColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.name,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(widget.isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.conversation.isOnline)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: InstructorColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        widget.conversation.isOnline
                            ? 'Online'
                            : (widget.conversation.type ==
                                    InstructorConversationType.group
                                ? '${widget.conversation.memberCount ?? 0} members'
                                : widget.conversation.courseName ?? ''),
                        style: TextStyle(
                          color: widget.conversation.isOnline
                              ? InstructorColors.success
                              : InstructorColors.textTertiaryColor(widget.isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.videocam_outlined,
                color: InstructorColors.textSecondaryColor(widget.isDark),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert_rounded,
                color: InstructorColors.textSecondaryColor(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: InstructorColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(widget.isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to ${widget.conversation.name}',
            style: TextStyle(
              color: InstructorColors.textTertiaryColor(widget.isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[widget.messages.length - 1 - index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(InstructorChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  message.senderAvatar ?? widget.conversation.avatar,
                  style: TextStyle(
                    color: InstructorColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMe
                    ? InstructorColors.primary
                    : InstructorColors.cardColor(widget.isDark),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      message.isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight:
                      message.isMe ? Radius.zero : const Radius.circular(16),
                ),
                border: message.isMe
                    ? null
                    : Border.all(
                        color: InstructorColors.borderColor(widget.isDark),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isMe &&
                      widget.conversation.type ==
                          InstructorConversationType.group &&
                      message.senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName!,
                        style: TextStyle(
                          color: InstructorColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isMe
                          ? Colors.white
                          : InstructorColors.textPrimaryColor(widget.isDark),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeString,
                        style: TextStyle(
                          color: message.isMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : InstructorColors.textTertiaryColor(widget.isDark),
                          fontSize: 11,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: message.status == MessageStatus.read
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(widget.isDark),
        border: Border(
          top: BorderSide(
            color: InstructorColors.borderColor(widget.isDark),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.attach_file_rounded,
              color: InstructorColors.textSecondaryColor(widget.isDark),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(widget.isDark),
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: InstructorColors.textTertiaryColor(widget.isDark),
                ),
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: InstructorColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.isSending ? null : _sendMessage,
              icon: widget.isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
