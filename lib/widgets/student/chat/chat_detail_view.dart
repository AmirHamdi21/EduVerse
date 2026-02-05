import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/chat/chat_cubit.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../generated_l10n/app_localizations.dart';
import 'chat_message_bubble.dart';
import 'chat_input_bar.dart';

class ChatDetailView extends StatefulWidget {
  final Conversation conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final ChatMessage? replyingTo;
  final bool isDark;
  final VoidCallback onBack;

  const ChatDetailView({
    super.key,
    required this.conversation,
    required this.messages,
    required this.isLoading,
    required this.isSending,
    required this.replyingTo,
    required this.isDark,
    required this.onBack,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late AnimationController _fadeController;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(ChatDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isAtBottom = _scrollController.offset < 100;
    if (_showScrollToBottom != !isAtBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ChatCubit>().sendMessage(content);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final participant = widget.conversation.primaryParticipant;

    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Header
          _buildHeader(participant, l10n),
          
          // Messages
          Expanded(
            child: Stack(
              children: [
                // Background
                _buildBackground(),
                
                // Messages list
                widget.isLoading
                    ? _buildLoadingState()
                    : widget.messages.isEmpty
                        ? _buildEmptyState()
                        : _buildMessagesList(),
                
                // Scroll to bottom button
                if (_showScrollToBottom)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _buildScrollToBottomButton(),
                  ),
              ],
            ),
          ),
          
          // Reply indicator
          if (widget.replyingTo != null) _buildReplyIndicator(),
          
          // Input bar
          ChatInputBar(
            controller: _messageController,
            isDark: widget.isDark,
            isSending: widget.isSending,
            onSend: _sendMessage,
            onAttachment: _showAttachmentOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ChatUser? participant, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: widget.isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: widget.onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              size: 20,
            ),
          ),
          
          // Avatar
          _buildAvatar(participant, 44),
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.title,
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Arimo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (participant != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(participant.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusText(participant.status),
                        style: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 12,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            onPressed: () => _showChatOptions(context),
            icon: Icon(
              Icons.more_vert_rounded,
              color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ChatUser? participant, double size) {
    final isGroup = widget.conversation.type == ConversationType.group;
    final isCourse = widget.conversation.type == ConversationType.course;

    if (isCourse) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(size / 3),
        ),
        child: Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      );
    }

    if (isGroup) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(size / 3),
        ),
        child: Icon(
          Icons.group_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      );
    }

    if (participant != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              participant.avatarColor,
              participant.avatarColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(size / 3),
        ),
        child: Center(
          child: Text(
            participant.initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.35,
              fontWeight: FontWeight.w700,
              fontFamily: 'Arimo',
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF94A3B8),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildBackground() {
    if (widget.isDark) {
      return Container(color: const Color(0xFF0F172A));
    }
    
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading messages...',
            style: TextStyle(
              color: widget.isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              fontSize: 13,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: widget.isDark
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No messages yet',
            style: TextStyle(
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation by sending a message',
            style: TextStyle(
              color: widget.isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              fontSize: 14,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[widget.messages.length - 1 - index];
        final isMe = message.senderId == 'current_user';
        
        // Check if we need to show date separator
        final showDateSeparator = _shouldShowDateSeparator(index);
        
        return Column(
          children: [
            if (showDateSeparator)
              _buildDateSeparator(message.timestamp),
            ChatMessageBubble(
              message: message,
              isMe: isMe,
              isDark: widget.isDark,
              onLongPress: () => _showMessageOptions(context, message),
              onReply: () {
                context.read<ChatCubit>().setReplyingTo(message);
              },
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == widget.messages.length - 1) return true;
    
    final currentIndex = widget.messages.length - 1 - index;
    final prevIndex = currentIndex + 1;
    
    if (prevIndex >= widget.messages.length) return true;
    
    final current = widget.messages[currentIndex].timestamp;
    final prev = widget.messages[prevIndex].timestamp;
    
    return current.day != prev.day ||
        current.month != prev.month ||
        current.year != prev.year;
  }

  Widget _buildDateSeparator(DateTime date) {
    String text;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      text = 'Today';
    } else if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      text = 'Yesterday';
    } else {
      text = DateFormat('MMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: widget.isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: widget.isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Arimo',
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: widget.isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: _scrollToBottom,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: widget.isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF3B82F6),
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.reply_rounded,
            color: Color(0xFF3B82F6),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to ${widget.replyingTo!.senderName}',
                  style: TextStyle(
                    color: const Color(0xFF3B82F6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
                Text(
                  widget.replyingTo!.content,
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 13,
                    fontFamily: 'Arimo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<ChatCubit>().setReplyingTo(null);
            },
            icon: Icon(
              Icons.close_rounded,
              color: widget.isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              size: 20,
            ),
          ),
        ],
      ),
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

  String _getStatusText(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return 'Online';
      case OnlineStatus.away:
        return 'Away';
      case OnlineStatus.busy:
        return 'Busy';
      case OnlineStatus.offline:
        return 'Offline';
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.image_rounded,
                      label: 'Photo',
                      color: const Color(0xFF22C55E),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showFeatureComingSoon('Photo attachment');
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.description_rounded,
                      label: 'Document',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showFeatureComingSoon('Document attachment');
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showFeatureComingSoon('Camera');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 13,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionItem(
                  icon: Icons.search_rounded,
                  label: 'Search in conversation',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showFeatureComingSoon('Search in conversation');
                  },
                ),
                _buildOptionItem(
                  icon: widget.conversation.isMuted
                      ? Icons.notifications_rounded
                      : Icons.notifications_off_outlined,
                  label: widget.conversation.isMuted ? 'Unmute' : 'Mute notifications',
                  onTap: () {
                    context.read<ChatCubit>().toggleMuteConversation(
                      widget.conversation.id,
                    );
                    Navigator.pop(ctx);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.block_rounded,
                  label: 'Block user',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showFeatureComingSoon('Block user');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, ChatMessage message) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionItem(
                  icon: Icons.reply_rounded,
                  label: 'Reply',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<ChatCubit>().setReplyingTo(message);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                _buildOptionItem(
                  icon: Icons.forward_rounded,
                  label: 'Forward',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showFeatureComingSoon('Forward message');
                  },
                ),
                if (message.senderId == 'current_user')
                  _buildOptionItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(ctx);
                      _showFeatureComingSoon('Delete message');
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFEF4444)
        : (widget.isDark ? Colors.white : const Color(0xFF1E293B));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Arimo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
