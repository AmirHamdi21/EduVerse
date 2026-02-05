import 'package:flutter/material.dart';

enum UserRole { instructor, student, ta, admin }

enum OnlineStatus { online, offline, away, busy }

enum MessageType { text, image, file, audio, system }

enum ConversationType { private, group, course }

class ChatUser {
  final String id;
  final String name;
  final String initials;
  final String? avatarUrl;
  final UserRole role;
  final OnlineStatus status;
  final DateTime lastSeen;
  final String? email;
  final Color avatarColor;

  const ChatUser({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.lastSeen,
    this.email,
    this.avatarColor = const Color(0xFF155DFC),
  });

  ChatUser copyWith({
    String? id,
    String? name,
    String? initials,
    String? avatarUrl,
    UserRole? role,
    OnlineStatus? status,
    DateTime? lastSeen,
    String? email,
    Color? avatarColor,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      email: email ?? this.email,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.student:
        return 'Student';
      case UserRole.ta:
        return 'TA';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isSent;
  final bool isDelivered;
  final String? replyToId;
  final String? attachmentUrl;
  final String? attachmentName;
  final List<String>? reactions;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isSent = true,
    this.isDelivered = false,
    this.replyToId,
    this.attachmentUrl,
    this.attachmentName,
    this.reactions,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isSent,
    bool? isDelivered,
    String? replyToId,
    String? attachmentUrl,
    String? attachmentName,
    List<String>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      isDelivered: isDelivered ?? this.isDelivered,
      replyToId: replyToId ?? this.replyToId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      reactions: reactions ?? this.reactions,
    );
  }
}

class Conversation {
  final String id;
  final String title;
  final ConversationType type;
  final List<ChatUser> participants;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isMuted;
  final String? courseId;
  final String? courseName;

  const Conversation({
    required this.id,
    required this.title,
    required this.type,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.isPinned = false,
    this.isMuted = false,
    this.courseId,
    this.courseName,
  });

  Conversation copyWith({
    String? id,
    String? title,
    ConversationType? type,
    List<ChatUser>? participants,
    ChatMessage? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isMuted,
    String? courseId,
    String? courseName,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
    );
  }

  ChatUser? get primaryParticipant {
    if (participants.isEmpty) return null;
    // For private chats, get the other participant
    return participants.firstWhere(
      (p) => p.id != 'current_user',
      orElse: () => participants.first,
    );
  }
}

enum ChatFilter { all, unread, instructors, students, groups, courses }

class ChatFilterOption {
  final ChatFilter filter;
  final String label;
  final IconData icon;

  const ChatFilterOption({
    required this.filter,
    required this.label,
    required this.icon,
  });
}
