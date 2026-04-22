# ChatBloc Contracts

## `ChatEvent`
- `LoadConversations()`
- `SelectConversation(int id)`
- `LoadMoreMessages(int conversationId, int page)`
- `SendMessage(int conversationId, String text, {int? replyToId})`
- `SearchConversations(String query)`
- `SearchUsers(String query)`
- `StartNewConversation(List<int> participantIds, String type, {String? groupName, String? text})`
- `DeleteMessage(int messageId, {bool forEveryone = false})`
- `MarkRead(int conversationId)`
- `TypingChanged(int conversationId, bool isTyping)`
- `WebSocketEventReceived(dynamic eventPayload)` (internal)

## `ChatState`
- `conversations`: `List<ConversationModel>`
- `activeConversationMessages`: `List<ChatMessageModel>`
- `activeConversationId`: `int?`
- `connectionStatus`: `ConnectionStatus` enum (`live`, `offline`, `connecting`)
- `typingUsers`: `Map<int, List<int>>` (ConversationID -> List of typing UserIDs)
- `onlineUsers`: `Set<int>`
- `status`: `Status` enum (`loading`, `success`, `failure`)
- `errorMessage`: `String?`
- `searchResults`: `List<ChatUserModel>?`
