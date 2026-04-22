# Unified Data Models

## `ConversationModel`
- `conversationId`: `int`
- `type`: `ConversationType` enum (`direct`, `group`)
- `name`: `String?` (for group)
- `participants`: `List<int>`
- `participantUsers`: `List<ChatUserModel>`
- `directDisplayUser`: `ChatUserModel?`
- `lastMessage`: `String?`
- `lastMessageInfo`: `ChatMessageModel?`
- `unreadCount`: `int`
- `lastMessageAt`: `DateTime`

## `ChatMessageModel`
- `id`: `int`
- `text`: `String?`
- `senderId`: `int`
- `senderName`: `String`
- `sentAt`: `DateTime`
- `editedAt`: `DateTime?`
- `isDeleted`: `bool`
- `replyToId`: `int?`
- `conversationId`: `int`
- `status`: `String`

## `ChatUserModel`
- `userId`: `int`
- `firstName`: `String`
- `lastName`: `String`
- `fullName`: `String`
- `email`: `String`

## Notes
- Enums: Drop `ConversationType.course`, drop `OnlineStatus.away`, `OnlineStatus.busy`. Only `isOnline: bool` is kept per API parity.
