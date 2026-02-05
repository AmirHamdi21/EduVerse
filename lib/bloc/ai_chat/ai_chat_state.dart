import 'package:equatable/equatable.dart';

// Models
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final List<String>? suggestions;
  final bool isTyping;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.suggestions,
    this.isTyping = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    List<String>? suggestions,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  error,
}

enum ChatMode {
  generalHelp,
  courseSpecific,
  aiTutor,
}

class QuickAction {
  final String id;
  final String label;
  final String prompt;
  final String iconType;

  const QuickAction({
    required this.id,
    required this.label,
    required this.prompt,
    required this.iconType,
  });
}

// State
class AiChatState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<ChatMessage> messages;
  final ChatMode chatMode;
  final bool isAiTyping;
  final String? selectedCourse;
  final List<String> availableCourses;
  final bool isRecording;
  final String? successMessage;
  final List<QuickAction> quickActions;

  const AiChatState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.chatMode = ChatMode.generalHelp,
    this.isAiTyping = false,
    this.selectedCourse,
    this.availableCourses = const [],
    this.isRecording = false,
    this.successMessage,
    this.quickActions = const [],
  });

  AiChatState copyWith({
    bool? isLoading,
    String? error,
    List<ChatMessage>? messages,
    ChatMode? chatMode,
    bool? isAiTyping,
    String? selectedCourse,
    List<String>? availableCourses,
    bool? isRecording,
    String? successMessage,
    List<QuickAction>? quickActions,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AiChatState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      messages: messages ?? this.messages,
      chatMode: chatMode ?? this.chatMode,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      availableCourses: availableCourses ?? this.availableCourses,
      isRecording: isRecording ?? this.isRecording,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      quickActions: quickActions ?? this.quickActions,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        messages,
        chatMode,
        isAiTyping,
        selectedCourse,
        availableCourses,
        isRecording,
        successMessage,
        quickActions,
      ];
}
