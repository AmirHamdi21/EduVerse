import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit() : super(const AiChatState()) {
    _initialize();
  }

  void _initialize() {
    emit(state.copyWith(
      quickActions: _getQuickActions(),
      availableCourses: [
        'Machine Learning',
        'Data Structures',
        'Computer Networks',
        'Database Systems',
        'Software Engineering',
      ],
      messages: [
        ChatMessage(
          id: 'welcome_1',
          content: 'Hello! How can I help you with your studies today?',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          suggestions: [
            'Summarize a topic',
            'Generate quiz questions',
            'Explain a concept',
          ],
        ),
      ],
    ));
  }

  List<QuickAction> _getQuickActions() {
    return const [
      QuickAction(
        id: 'summarize',
        label: 'Summarize my last lecture',
        prompt: 'Please summarize my last lecture',
        iconType: 'summarize',
      ),
      QuickAction(
        id: 'quiz',
        label: 'Generate 5 quiz questions',
        prompt: 'Generate 5 quiz questions about the current topic',
        iconType: 'quiz',
      ),
      QuickAction(
        id: 'explain',
        label: 'Explain this concept',
        prompt: 'Can you explain this concept in simple terms?',
        iconType: 'explain',
      ),
      QuickAction(
        id: 'performance',
        label: 'Show my performance summary',
        prompt: 'Show me a summary of my academic performance',
        iconType: 'performance',
      ),
    ];
  }

  void setChatMode(ChatMode mode) {
    emit(state.copyWith(chatMode: mode));
    
    // Add a system message about mode change
    final modeMessage = switch (mode) {
      ChatMode.generalHelp => "Switched to General Help mode. I can assist you with any study-related questions.",
      ChatMode.courseSpecific => "Switched to Course-Specific mode. Select a course to get targeted help.",
      ChatMode.aiTutor => "Switched to AI Tutor mode. I'll guide you through concepts step by step with interactive learning.",
    };
    
    _addAiMessage(modeMessage);
  }

  void selectCourse(String course) {
    emit(state.copyWith(selectedCourse: course));
    _addAiMessage("Now focusing on $course. Ask me anything about this course!");
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
    ));

    // Update to sent status
    await Future.delayed(const Duration(milliseconds: 300));
    final updatedMessages = state.messages.map((m) {
      if (m.id == userMessage.id) {
        return m.copyWith(status: MessageStatus.sent);
      }
      return m;
    }).toList();
    
    emit(state.copyWith(messages: updatedMessages, isAiTyping: true));

    // Simulate AI thinking
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate AI response based on content
    final response = _generateAiResponse(content);
    
    final aiMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: _getSuggestionsForResponse(content),
    );

    emit(state.copyWith(
      messages: [...state.messages, aiMessage],
      isAiTyping: false,
    ));
  }

  void sendQuickAction(QuickAction action) {
    sendMessage(action.prompt);
  }

  void _addAiMessage(String content) {
    final aiMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, aiMessage],
    ));
  }

  String _generateAiResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('summarize') || lowerMessage.contains('summary')) {
      return "Here's a summary of the key points from your last lecture on Machine Learning:\n\n"
          "📌 **Key Concepts:**\n"
          "1. Supervised vs Unsupervised Learning\n"
          "2. Neural Network Architecture\n"
          "3. Backpropagation Algorithm\n"
          "4. Overfitting and Regularization\n\n"
          "📊 **Main Takeaways:**\n"
          "- Machine learning models learn patterns from data\n"
          "- Training involves optimizing model parameters\n"
          "- Validation helps prevent overfitting\n\n"
          "Would you like me to elaborate on any of these topics?";
    }
    
    if (lowerMessage.contains('quiz') || lowerMessage.contains('question')) {
      return "Here are 5 quiz questions on the current topic:\n\n"
          "**Question 1:** What is the main difference between supervised and unsupervised learning?\n\n"
          "**Question 2:** What is the purpose of the activation function in neural networks?\n\n"
          "**Question 3:** How does gradient descent help in training a model?\n\n"
          "**Question 4:** What is overfitting and how can it be prevented?\n\n"
          "**Question 5:** Explain the concept of feature engineering.\n\n"
          "Would you like me to provide answers or more questions?";
    }
    
    if (lowerMessage.contains('explain') || lowerMessage.contains('what is')) {
      return "Let me explain this concept in simple terms:\n\n"
          "🎓 **Concept Explanation:**\n\n"
          "Think of it like teaching a child to recognize animals. You show them many pictures of cats and dogs, telling them which is which. Over time, they learn to identify them on their own.\n\n"
          "Similarly, machine learning algorithms:\n"
          "1. Receive labeled examples (training data)\n"
          "2. Find patterns in the data\n"
          "3. Use these patterns to make predictions on new data\n\n"
          "📝 **Key Point:** The more diverse and quality data you provide, the better the model learns.\n\n"
          "Would you like a more technical explanation?";
    }
    
    if (lowerMessage.contains('performance') || lowerMessage.contains('grade')) {
      return "📊 **Your Performance Summary:**\n\n"
          "**Overall GPA:** 3.7/4.0\n\n"
          "**Course Performance:**\n"
          "• Machine Learning: A (92%)\n"
          "• Data Structures: A- (88%)\n"
          "• Computer Networks: B+ (85%)\n\n"
          "**Strengths:**\n"
          "✅ Strong in practical assignments\n"
          "✅ Consistent quiz performance\n\n"
          "**Areas to Improve:**\n"
          "📈 Participation in discussions\n"
          "📈 Final exam preparation\n\n"
          "Would you like detailed tips for improvement?";
    }
    
    if (lowerMessage.contains('help') || lowerMessage.contains('can you')) {
      return "I can help you with many things! Here's what I can do:\n\n"
          "📚 **Study Assistance:**\n"
          "• Summarize lectures and materials\n"
          "• Explain complex concepts simply\n"
          "• Generate practice questions\n\n"
          "📊 **Academic Tracking:**\n"
          "• Review your performance\n"
          "• Identify areas for improvement\n"
          "• Create study schedules\n\n"
          "🎯 **Course Help:**\n"
          "• Answer specific course questions\n"
          "• Provide additional resources\n"
          "• Help with assignments\n\n"
          "What would you like to focus on?";
    }
    
    return "I understand you're asking about: \"$userMessage\"\n\n"
        "Let me help you with that. Based on your question, here are some relevant insights:\n\n"
        "1. This topic is commonly covered in your coursework\n"
        "2. I can provide examples or explanations\n"
        "3. Practice questions are available if needed\n\n"
        "Would you like me to:\n"
        "• Explain this in more detail?\n"
        "• Provide examples?\n"
        "• Generate practice questions?";
  }

  List<String>? _getSuggestionsForResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('summarize')) {
      return ['Explain topic 1', 'Generate quiz', 'More details'];
    }
    if (lowerMessage.contains('quiz')) {
      return ['Show answers', 'More questions', 'Different topic'];
    }
    if (lowerMessage.contains('explain')) {
      return ['Simpler explanation', 'More examples', 'Related topics'];
    }
    return null;
  }

  void toggleRecording() {
    emit(state.copyWith(isRecording: !state.isRecording));
    
    if (state.isRecording) {
      // Simulate voice recognition
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed && state.isRecording) {
          emit(state.copyWith(isRecording: false));
          sendMessage("Can you explain neural networks?");
        }
      });
    }
  }

  void clearChat() {
    emit(state.copyWith(
      messages: [
        ChatMessage(
          id: 'welcome_new',
          content: 'Chat cleared. How can I help you today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      successMessage: 'Chat history cleared',
    ));
    _clearSuccessMessage();
  }

  void retryMessage(String messageId) {
    final message = state.messages.firstWhere(
      (m) => m.id == messageId,
      orElse: () => throw Exception('Message not found'),
    );
    
    if (message.status == MessageStatus.error) {
      sendMessage(message.content);
    }
  }

  void _clearSuccessMessage() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(state.copyWith(clearSuccess: true));
      }
    });
  }
}
