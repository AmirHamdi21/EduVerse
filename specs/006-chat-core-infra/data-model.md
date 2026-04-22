# Data Model: Phase 1: Core Chat Infrastructure

> This phase primarily adds services, not local persistent databases, but establishes structural payloads expected by APIs and WebSockets.

## API Payload Entities

**Search Users**
- Request: `query: String`, `limit?: int`
- Response Entity (`ChatUser`): `userId`, `firstName`, `lastName`, `email`

**Conversation**
- Representation: `ConversationId`, `Type` (Strictly typed Enum `ConversationType` with values `direct` and `group`), `Name`, `Participants`
- Message Fetch: paginated query -> `ChatMessageApi` list

**Send Message Payload (Rest/Socket)**
- Fields:
  - `conversationId`: int (Required)
  - `text`: String (Required)
  - `fileId`: int? (Optional)
  - `replyToId`: int? (Optional)

**User Typing Status**
- Payload: `conversationId`, `userId`, `isTyping`

## Interfaces / Contracts

Defined via API endpoints and socket events directly in `contracts/`.
