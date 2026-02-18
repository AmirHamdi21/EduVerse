import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shared/admin_colors.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final String? senderName;
  final bool isRead;
  final List<String>? attachments;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.senderName,
    this.isRead = false,
    this.attachments,
  });
}

class AdminChatBubble extends StatelessWidget {
  final bool isDark;
  final ChatMessage message;
  final bool showSenderName;
  final VoidCallback? onLongPress;

  const AdminChatBubble({
    super.key,
    required this.isDark,
    required this.message,
    this.showSenderName = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.only(
            left: message.isMe ? 48 : 16,
            right: message.isMe ? 16 : 48,
            top: 4,
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showSenderName && !message.isMe && message.senderName != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    message.senderName!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: message.isMe ? AdminColors.primaryGradient : null,
                  color: message.isMe ? null : (isDark ? AdminColors.darkCard : AdminColors.lightCard),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                    bottomRight: Radius.circular(message.isMe ? 4 : 18),
                  ),
                  border: message.isMe
                      ? null
                      : Border.all(
                          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (message.isMe ? AdminColors.primary : Colors.black).withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: message.isMe
                            ? Colors.white
                            : (isDark ? AdminColors.darkText : AdminColors.lightText),
                      ),
                    ),
                    if (message.attachments != null && message.attachments!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...message.attachments!.map((attachment) => _buildAttachment(attachment)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary,
                      ),
                    ),
                    if (message.isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 14,
                        color: message.isRead ? AdminColors.primary : (isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachment(String attachment) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: message.isMe
            ? Colors.white.withValues(alpha: 0.2)
            : AdminColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file_rounded,
            size: 16,
            color: message.isMe ? Colors.white : AdminColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            attachment,
            style: TextStyle(
              fontSize: 13,
              color: message.isMe ? Colors.white : AdminColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
