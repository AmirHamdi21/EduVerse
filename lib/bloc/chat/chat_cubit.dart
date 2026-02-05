import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_models.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatInitial());

  // Sample data for demonstration
  final String _currentUserId = 'current_user';

  Future<void> loadConversations() async {
    emit(const ChatLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final conversations = _generateSampleConversations();
      final availableUsers = _generateAvailableUsers();

      emit(ChatLoaded(
        conversations: conversations,
        filteredConversations: conversations,
        availableUsers: availableUsers,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void searchConversations(String query) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final filtered = currentState.conversations.where((conv) {
      final titleMatch = conv.title.toLowerCase().contains(query.toLowerCase());
      final messageMatch = conv.lastMessage?.content
              .toLowerCase()
              .contains(query.toLowerCase()) ??
          false;
      final participantMatch = conv.participants.any(
          (p) => p.name.toLowerCase().contains(query.toLowerCase()));
      return titleMatch || messageMatch || participantMatch;
    }).toList();

    emit(currentState.copyWith(
      searchQuery: query,
      filteredConversations: filtered,
    ));
  }

  void applyFilter(ChatFilter filter) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    List<Conversation> filtered;

    switch (filter) {
      case ChatFilter.all:
        filtered = currentState.conversations;
        break;
      case ChatFilter.unread:
        filtered = currentState.conversations
            .where((c) => c.unreadCount > 0)
            .toList();
        break;
      case ChatFilter.instructors:
        filtered = currentState.conversations.where((c) {
          return c.participants.any((p) => p.role == UserRole.instructor);
        }).toList();
        break;
      case ChatFilter.students:
        filtered = currentState.conversations.where((c) {
          return c.participants.every((p) => p.role == UserRole.student);
        }).toList();
        break;
      case ChatFilter.groups:
        filtered = currentState.conversations
            .where((c) => c.type == ConversationType.group)
            .toList();
        break;
      case ChatFilter.courses:
        filtered = currentState.conversations
            .where((c) => c.type == ConversationType.course)
            .toList();
        break;
    }

    // Apply search query if exists
    if (currentState.searchQuery.isNotEmpty) {
      filtered = filtered.where((conv) {
        final query = currentState.searchQuery.toLowerCase();
        return conv.title.toLowerCase().contains(query) ||
            (conv.lastMessage?.content.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    emit(currentState.copyWith(
      currentFilter: filter,
      filteredConversations: filtered,
    ));
  }

  Future<void> selectConversation(Conversation conversation) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    emit(currentState.copyWith(
      selectedConversation: conversation,
      isLoadingMessages: true,
    ));

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final messages = _generateSampleMessages(conversation.id);

      // Mark conversation as read
      final updatedConversations = currentState.conversations.map((c) {
        if (c.id == conversation.id) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();

      final updatedFiltered = currentState.filteredConversations.map((c) {
        if (c.id == conversation.id) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();

      emit(currentState.copyWith(
        selectedConversation: conversation.copyWith(unreadCount: 0),
        currentMessages: messages,
        isLoadingMessages: false,
        conversations: updatedConversations,
        filteredConversations: updatedFiltered,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isLoadingMessages: false,
        error: e.toString(),
      ));
    }
  }

  void clearSelectedConversation() {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    emit(currentState.copyWith(
      clearSelectedConversation: true,
      currentMessages: [],
      clearReplyingTo: true,
    ));
  }

  Future<void> sendMessage(String content, {MessageType type = MessageType.text}) async {
    final currentState = state;
    if (currentState is! ChatLoaded || 
        currentState.selectedConversation == null ||
        content.trim().isEmpty) return;

    emit(currentState.copyWith(isSendingMessage: true));

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: currentState.selectedConversation!.id,
        senderId: _currentUserId,
        senderName: 'Me',
        content: content,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        isSent: true,
        isDelivered: true,
        replyToId: currentState.replyingTo?.id,
      );

      final updatedMessages = [...currentState.currentMessages, newMessage];

      // Update conversation with new last message
      final updatedConversation = currentState.selectedConversation!.copyWith(
        lastMessage: newMessage,
        updatedAt: DateTime.now(),
      );

      final updatedConversations = currentState.conversations.map((c) {
        if (c.id == updatedConversation.id) {
          return updatedConversation;
        }
        return c;
      }).toList();

      // Sort by updated time
      updatedConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final updatedFiltered = currentState.filteredConversations.map((c) {
        if (c.id == updatedConversation.id) {
          return updatedConversation;
        }
        return c;
      }).toList();
      updatedFiltered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(currentState.copyWith(
        currentMessages: updatedMessages,
        isSendingMessage: false,
        clearReplyingTo: true,
        selectedConversation: updatedConversation,
        conversations: updatedConversations,
        filteredConversations: updatedFiltered,
      ));

      // Simulate receiving a reply after a delay
      _simulateReply(updatedConversation);
    } catch (e) {
      emit(currentState.copyWith(
        isSendingMessage: false,
        error: e.toString(),
      ));
    }
  }

  void _simulateReply(Conversation conversation) async {
    await Future.delayed(const Duration(seconds: 2));

    final currentState = state;
    if (currentState is! ChatLoaded ||
        currentState.selectedConversation?.id != conversation.id) return;

    final participant = conversation.primaryParticipant;
    if (participant == null) return;

    final replies = [
      'Thanks for reaching out! I\'ll get back to you soon.',
      'Got it! Let me check on that.',
      'That\'s a great question. Here\'s what I think...',
      'I understand. We can discuss this further.',
      'Sure, I\'ll look into it.',
    ];

    final replyMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      senderId: participant.id,
      senderName: participant.name,
      content: replies[DateTime.now().second % replies.length],
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: true,
      isSent: true,
      isDelivered: true,
    );

    final updatedMessages = [...currentState.currentMessages, replyMessage];

    final updatedConversation = conversation.copyWith(
      lastMessage: replyMessage,
      updatedAt: DateTime.now(),
    );

    final updatedConversations = currentState.conversations.map((c) {
      if (c.id == updatedConversation.id) {
        return updatedConversation;
      }
      return c;
    }).toList();
    updatedConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final updatedFiltered = currentState.filteredConversations.map((c) {
      if (c.id == updatedConversation.id) {
        return updatedConversation;
      }
      return c;
    }).toList();
    updatedFiltered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    emit(currentState.copyWith(
      currentMessages: updatedMessages,
      selectedConversation: updatedConversation,
      conversations: updatedConversations,
      filteredConversations: updatedFiltered,
    ));
  }

  void setReplyingTo(ChatMessage? message) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    if (message == null) {
      emit(currentState.copyWith(clearReplyingTo: true));
    } else {
      emit(currentState.copyWith(replyingTo: message));
    }
  }

  void togglePinConversation(String conversationId) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final updatedConversations = currentState.conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(isPinned: !c.isPinned);
      }
      return c;
    }).toList();

    // Sort: pinned first, then by updated time
    updatedConversations.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    final updatedFiltered = currentState.filteredConversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(isPinned: !c.isPinned);
      }
      return c;
    }).toList();
    updatedFiltered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    emit(currentState.copyWith(
      conversations: updatedConversations,
      filteredConversations: updatedFiltered,
    ));
  }

  void toggleMuteConversation(String conversationId) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final updatedConversations = currentState.conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(isMuted: !c.isMuted);
      }
      return c;
    }).toList();

    final updatedFiltered = currentState.filteredConversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(isMuted: !c.isMuted);
      }
      return c;
    }).toList();

    emit(currentState.copyWith(
      conversations: updatedConversations,
      filteredConversations: updatedFiltered,
    ));
  }

  void deleteConversation(String conversationId) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final updatedConversations = currentState.conversations
        .where((c) => c.id != conversationId)
        .toList();

    final updatedFiltered = currentState.filteredConversations
        .where((c) => c.id != conversationId)
        .toList();

    emit(currentState.copyWith(
      conversations: updatedConversations,
      filteredConversations: updatedFiltered,
      clearSelectedConversation: currentState.selectedConversation?.id == conversationId,
    ));
  }

  void archiveConversation(String conversationId) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // For now, we'll just remove it from the list (as if archived)
    // In a real app, you'd move it to an archived list
    final updatedConversations = currentState.conversations
        .where((c) => c.id != conversationId)
        .toList();

    final updatedFiltered = currentState.filteredConversations
        .where((c) => c.id != conversationId)
        .toList();

    emit(currentState.copyWith(
      conversations: updatedConversations,
      filteredConversations: updatedFiltered,
      clearSelectedConversation: currentState.selectedConversation?.id == conversationId,
    ));
  }

  void markConversationAsRead(String conversationId) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final conversation = currentState.conversations
        .firstWhere((c) => c.id == conversationId, orElse: () => currentState.conversations.first);
    
    final newUnreadCount = conversation.unreadCount > 0 ? 0 : 3; // Toggle between read/unread

    final updatedConversations = currentState.conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(unreadCount: newUnreadCount);
      }
      return c;
    }).toList();

    final updatedFiltered = currentState.filteredConversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(unreadCount: newUnreadCount);
      }
      return c;
    }).toList();

    emit(currentState.copyWith(
      conversations: updatedConversations,
      filteredConversations: updatedFiltered,
    ));
  }

  Future<void> createConversation(ChatUser user) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // Check if conversation already exists
    final existing = currentState.conversations.where((c) {
      return c.type == ConversationType.private &&
          c.participants.any((p) => p.id == user.id);
    }).toList();

    if (existing.isNotEmpty) {
      selectConversation(existing.first);
      return;
    }

    final newConversation = Conversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      title: user.name,
      type: ConversationType.private,
      participants: [user],
      updatedAt: DateTime.now(),
    );

    final updatedConversations = [newConversation, ...currentState.conversations];
    final updatedFiltered = [newConversation, ...currentState.filteredConversations];

    emit(currentState.copyWith(
      conversations: updatedConversations,
      filteredConversations: updatedFiltered,
    ));

    selectConversation(newConversation);
  }

  void searchUsers(String query) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    if (query.isEmpty) {
      emit(currentState.copyWith(isSearchingUsers: false));
      return;
    }

    emit(currentState.copyWith(isSearchingUsers: true));

    final filtered = currentState.availableUsers.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
          (user.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    emit(currentState.copyWith(
      availableUsers: filtered,
      isSearchingUsers: false,
    ));
  }

  void clearError() {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    emit(currentState.copyWith(clearError: true));
  }

  // Sample data generators
  List<Conversation> _generateSampleConversations() {
    return [
      Conversation(
        id: 'conv_1',
        title: 'Dr. Alan Turing',
        type: ConversationType.private,
        participants: [
          ChatUser(
            id: 'user_1',
            name: 'Dr. Alan Turing',
            initials: 'AT',
            role: UserRole.instructor,
            status: OnlineStatus.online,
            lastSeen: DateTime.now(),
            avatarColor: const Color(0xFF9810FA),
          ),
        ],
        lastMessage: ChatMessage(
          id: 'msg_1',
          conversationId: 'conv_1',
          senderId: 'user_1',
          senderName: 'Dr. Alan Turing',
          content: 'Great work on the assignment!',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        unreadCount: 0,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isPinned: true,
      ),
      Conversation(
        id: 'conv_2',
        title: 'Sarah Johnson',
        type: ConversationType.private,
        participants: [
          ChatUser(
            id: 'user_2',
            name: 'Sarah Johnson',
            initials: 'SJ',
            role: UserRole.ta,
            status: OnlineStatus.online,
            lastSeen: DateTime.now(),
            avatarColor: const Color(0xFF155DFC),
          ),
        ],
        lastMessage: ChatMessage(
          id: 'msg_2',
          conversationId: 'conv_2',
          senderId: 'user_2',
          senderName: 'Sarah Johnson',
          content: 'Lab session is at 2 PM tomorrow',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        unreadCount: 2,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Conversation(
        id: 'conv_3',
        title: 'Prof. Grace Hopper',
        type: ConversationType.private,
        participants: [
          ChatUser(
            id: 'user_3',
            name: 'Prof. Grace Hopper',
            initials: 'GH',
            role: UserRole.instructor,
            status: OnlineStatus.away,
            lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
            avatarColor: const Color(0xFF00C950),
          ),
        ],
        lastMessage: ChatMessage(
          id: 'msg_3',
          conversationId: 'conv_3',
          senderId: 'user_3',
          senderName: 'Prof. Grace Hopper',
          content: 'Check the lecture notes I shared',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        unreadCount: 1,
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Conversation(
        id: 'conv_4',
        title: 'AI Course Discussion',
        type: ConversationType.course,
        courseId: 'course_ai',
        courseName: 'Introduction to AI',
        participants: [
          ChatUser(
            id: 'user_1',
            name: 'Dr. Alan Turing',
            initials: 'AT',
            role: UserRole.instructor,
            status: OnlineStatus.online,
            lastSeen: DateTime.now(),
            avatarColor: const Color(0xFF9810FA),
          ),
          ChatUser(
            id: 'user_4',
            name: 'Michael Chen',
            initials: 'MC',
            role: UserRole.student,
            status: OnlineStatus.online,
            lastSeen: DateTime.now(),
            avatarColor: const Color(0xFF155DFC),
          ),
        ],
        lastMessage: ChatMessage(
          id: 'msg_4',
          conversationId: 'conv_4',
          senderId: 'user_4',
          senderName: 'Michael Chen',
          content: 'Has anyone started the neural network project?',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        unreadCount: 5,
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Conversation(
        id: 'conv_5',
        title: 'Study Group - Data Structures',
        type: ConversationType.group,
        participants: [
          ChatUser(
            id: 'user_5',
            name: 'Emma Wilson',
            initials: 'EW',
            role: UserRole.student,
            status: OnlineStatus.offline,
            lastSeen: DateTime.now().subtract(const Duration(days: 1)),
            avatarColor: const Color(0xFFFF6B6B),
          ),
          ChatUser(
            id: 'user_6',
            name: 'James Brown',
            initials: 'JB',
            role: UserRole.student,
            status: OnlineStatus.online,
            lastSeen: DateTime.now(),
            avatarColor: const Color(0xFF00B8DB),
          ),
        ],
        lastMessage: ChatMessage(
          id: 'msg_5',
          conversationId: 'conv_5',
          senderId: 'user_5',
          senderName: 'Emma Wilson',
          content: 'Let\'s meet at the library at 4 PM',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        unreadCount: 0,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Conversation(
        id: 'conv_6',
        title: 'Dr. Ada Lovelace',
        type: ConversationType.private,
        participants: [
          ChatUser(
            id: 'user_7',
            name: 'Dr. Ada Lovelace',
            initials: 'AL',
            role: UserRole.instructor,
            status: OnlineStatus.busy,
            lastSeen: DateTime.now(),
            avatarColor: const Color(0xFFFF9500),
          ),
        ],
        lastMessage: ChatMessage(
          id: 'msg_6',
          conversationId: 'conv_6',
          senderId: 'current_user',
          senderName: 'Me',
          content: 'Thank you for the feedback, professor!',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
        unreadCount: 0,
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<ChatMessage> _generateSampleMessages(String conversationId) {
    switch (conversationId) {
      case 'conv_1':
        return [
          ChatMessage(
            id: 'msg_1_1',
            conversationId: conversationId,
            senderId: 'current_user',
            senderName: 'Me',
            content: 'Hello Professor, I had a question about the assignment.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'msg_1_2',
            conversationId: conversationId,
            senderId: 'user_1',
            senderName: 'Dr. Alan Turing',
            content: 'Of course! What would you like to know?',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
          ),
          ChatMessage(
            id: 'msg_1_3',
            conversationId: conversationId,
            senderId: 'current_user',
            senderName: 'Me',
            content: 'I was wondering about the deadline for the machine learning project. Is it possible to get an extension?',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
          ),
          ChatMessage(
            id: 'msg_1_4',
            conversationId: conversationId,
            senderId: 'user_1',
            senderName: 'Dr. Alan Turing',
            content: 'I understand. Given the complexity of the project, I can grant a 3-day extension. Please make sure to submit by next Monday.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          ),
          ChatMessage(
            id: 'msg_1_5',
            conversationId: conversationId,
            senderId: 'current_user',
            senderName: 'Me',
            content: 'Thank you so much, Professor! I really appreciate it.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
          ),
          ChatMessage(
            id: 'msg_1_6',
            conversationId: conversationId,
            senderId: 'user_1',
            senderName: 'Dr. Alan Turing',
            content: 'Great work on the assignment!',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        ];
      case 'conv_2':
        return [
          ChatMessage(
            id: 'msg_2_1',
            conversationId: conversationId,
            senderId: 'user_2',
            senderName: 'Sarah Johnson',
            content: 'Hi! Just a reminder about the upcoming lab session.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'msg_2_2',
            conversationId: conversationId,
            senderId: 'current_user',
            senderName: 'Me',
            content: 'Thanks for the reminder! What time is it again?',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          ),
          ChatMessage(
            id: 'msg_2_3',
            conversationId: conversationId,
            senderId: 'user_2',
            senderName: 'Sarah Johnson',
            content: 'Lab session is at 2 PM tomorrow',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];
      default:
        return [
          ChatMessage(
            id: 'msg_default_1',
            conversationId: conversationId,
            senderId: 'other_user',
            senderName: 'Participant',
            content: 'Hello! How can I help you today?',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];
    }
  }

  List<ChatUser> _generateAvailableUsers() {
    return [
      ChatUser(
        id: 'user_8',
        name: 'Dr. John Smith',
        initials: 'JS',
        role: UserRole.instructor,
        status: OnlineStatus.online,
        lastSeen: DateTime.now(),
        email: 'john.smith@edu.com',
        avatarColor: const Color(0xFF6366F1),
      ),
      ChatUser(
        id: 'user_9',
        name: 'Lisa Anderson',
        initials: 'LA',
        role: UserRole.student,
        status: OnlineStatus.online,
        lastSeen: DateTime.now(),
        email: 'lisa.a@edu.com',
        avatarColor: const Color(0xFFEC4899),
      ),
      ChatUser(
        id: 'user_10',
        name: 'Robert Taylor',
        initials: 'RT',
        role: UserRole.ta,
        status: OnlineStatus.away,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
        email: 'r.taylor@edu.com',
        avatarColor: const Color(0xFF14B8A6),
      ),
      ChatUser(
        id: 'user_11',
        name: 'Dr. Emily Chen',
        initials: 'EC',
        role: UserRole.instructor,
        status: OnlineStatus.offline,
        lastSeen: DateTime.now().subtract(const Duration(hours: 5)),
        email: 'e.chen@edu.com',
        avatarColor: const Color(0xFFF59E0B),
      ),
      ChatUser(
        id: 'user_12',
        name: 'David Kim',
        initials: 'DK',
        role: UserRole.student,
        status: OnlineStatus.online,
        lastSeen: DateTime.now(),
        email: 'd.kim@edu.com',
        avatarColor: const Color(0xFF8B5CF6),
      ),
    ];
  }
}
