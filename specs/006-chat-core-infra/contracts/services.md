# Core Chat Service Contracts

## ChatService API Interface
```dart
abstract class IChatService {
  Future<List<ConversationModel>> listConversations();
  Future<List<ChatMessageModel>> getConversationMessages(int conversationId, {int? page, int? limit});
  Future<ChatMessageModel> sendMessage(int conversationId, String text, {int? fileId, int? replyToId});
  Future<ConversationModel> startConversation({required List<int> participantIds, required String type, String text, String? groupName});
  Future<List<ChatUserModel>> searchUsers(String query, {int limit});
  Future<void> markRead(int messageId);
  Future<ChatMessageModel> editMessage(int messageId, String text);
  Future<bool> deleteForMe(int messageId);
  Future<bool> deleteForEveryone(int messageId);
}
```

## ChatSocketService Interface
```dart
enum ChatConnectionStatus { connected, disconnected, reconnecting }

abstract class IChatSocketService {
  // Streams for bloc consumption
  Stream<ChatConnectionStatus> get connectionStatus;
  Stream<ChatMessageModel> get newMessageStream;
  Stream<ChatMessageModel> get newMessageNotificationStream;
  Stream<UserTypingEvent> get typingStream;
  Stream<int> get messageDeletedStream;
  Stream<ChatMessageModel> get messageEditedStream;
  Stream<Map<String, dynamic>> get userStatusStream;
  Stream<int> get deleteConfirmedStream;

  void connect(String jwtToken);
  void disconnect();

  void joinConversation(int conversationId);
  void leaveConversation(int conversationId);
  
  void sendMessage(int conversationId, String text, {int? fileId, int? replyToId});
  void emitTyping(int conversationId, bool isTyping);
  void markRead(int conversationId);
  void editMessage(int messageId, String text);
  void deleteMessage(int messageId, {bool forEveryone});
}
```
