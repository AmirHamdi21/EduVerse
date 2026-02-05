import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../bloc/chat/chat_models.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isDark;
  final VoidCallback onLongPress;
  final VoidCallback onReply;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isDark,
    required this.onLongPress,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              onDoubleTap: onReply,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMe
                      ? null
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  border: isMe
                      ? null
                      : Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? const Color(0xFF3B82F6).withOpacity(0.2)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender name for group chats
                      if (!isMe && message.senderName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              color: _getSenderColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ),
                      
                      // Message content
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : (isDark ? Colors.white : const Color(0xFF1E293B)),
                          fontSize: 15,
                          height: 1.4,
                          fontFamily: 'Arimo',
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Time and status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(message.timestamp),
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8)),
                              fontSize: 11,
                              fontFamily: 'Arimo',
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSenderColor(),
            _getSenderColor().withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          _getInitials(message.senderName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Arimo',
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getSenderColor() {
    // Generate a consistent color based on sender name
    final hash = message.senderName.hashCode;
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    return colors[hash.abs() % colors.length];
  }

  Widget _buildStatusIcon() {
    if (!message.isSent) {
      return Icon(
        Icons.access_time_rounded,
        size: 14,
        color: Colors.white.withOpacity(0.7),
      );
    }
    
    if (message.isRead) {
      return Icon(
        Icons.done_all_rounded,
        size: 14,
        color: Colors.white.withOpacity(0.9),
      );
    }
    
    if (message.isDelivered) {
      return Icon(
        Icons.done_all_rounded,
        size: 14,
        color: Colors.white.withOpacity(0.7),
      );
    }
    
    return Icon(
      Icons.done_rounded,
      size: 14,
      color: Colors.white.withOpacity(0.7),
    );
  }
}
