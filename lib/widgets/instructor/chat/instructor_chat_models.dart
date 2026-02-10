/// Models for instructor chat functionality

enum InstructorConversationType { student, colleague, group }

class InstructorConversation {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;
  final InstructorConversationType type;
  final String? courseName;
  final int? memberCount;
  final bool isPinned;
  final bool isMuted;

  const InstructorConversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.type,
    this.courseName,
    this.memberCount,
    this.isPinned = false,
    this.isMuted = false,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${timestamp.day}/${timestamp.month}';
  }

  InstructorConversation copyWith({
    String? id,
    String? name,
    String? avatar,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
    bool? isOnline,
    InstructorConversationType? type,
    String? courseName,
    int? memberCount,
    bool? isPinned,
    bool? isMuted,
  }) {
    return InstructorConversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      type: type ?? this.type,
      courseName: courseName ?? this.courseName,
      memberCount: memberCount ?? this.memberCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class InstructorChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final String? senderName;
  final String? senderAvatar;
  final MessageStatus status;
  final List<String>? attachments;
  final InstructorChatMessage? replyTo;

  const InstructorChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.senderName,
    this.senderAvatar,
    this.status = MessageStatus.sent,
    this.attachments,
    this.replyTo,
  });

  String get timeString {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

enum MessageStatus { sending, sent, delivered, read, failed }
