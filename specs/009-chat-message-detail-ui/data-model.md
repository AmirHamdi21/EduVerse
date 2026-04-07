# Data Model: Unified Chat UI — Message Detail View

**Branch**: `009-chat-message-detail-ui` | **Date**: 2026-04-06

## Overview

Phase 4 uses existing data models from Phase 2. This document describes how those models are consumed by the new message detail widgets and the single state field addition required.

---

## Existing Models (No Changes Required)

### ChatMessageModel

**File**: `lib/bloc/chat/chat_models.dart`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Unique message identifier (negative for optimistic) |
| `text` | `String` | Message content |
| `senderId` | `int` | User ID of sender |
| `senderName` | `String?` | Display name of sender (for group chats) |
| `sentAt` | `DateTime` | Timestamp when message was sent |
| `editedAt` | `DateTime?` | Timestamp if message was edited |
| `isDeleted` | `bool` | Whether message was deleted for everyone |
| `deletedText` | `String` | Placeholder text for deleted messages |
| `replyToId` | `int?` | ID of message being replied to |
| `conversationId` | `int` | Parent conversation ID |
| `status` | `String` | `'pending'`, `'sent'`, `'failed'`, `'deleted'` |

**Validation Rules**:
- `id < 0` indicates optimistic/pending message
- `status == 'pending'` disables "Delete for everyone" action
- `sentAt` checked against 24-hour window for "Delete for everyone" eligibility

### ConversationModel

**File**: `lib/bloc/chat/chat_models.dart`

| Field | Type | Description |
|-------|------|-------------|
| `conversationId` | `int` | Unique conversation identifier |
| `type` | `ConversationType` | `direct` or `group` |
| `name` | `String?` | Group name (null for direct) |
| `participants` | `List<int>` | User IDs in conversation |
| `participantUsers` | `List<ChatUserModel>` | Full user objects |
| `directDisplayUser` | `ChatUserModel?` | Other user in direct chat |
| `lastMessage` | `String?` | Preview text |
| `lastMessageInfo` | `ChatMessageModel?` | Full last message object |
| `unreadCount` | `int` | Unread message count |
| `lastMessageAt` | `DateTime?` | Timestamp of last activity |

**UI Logic**:
- `type == ConversationType.group` → show sender names on messages
- `type == ConversationType.direct` → hide sender names, use left/right alignment

### ChatUserModel

**File**: `lib/bloc/chat/chat_models.dart`

| Field | Type | Description |
|-------|------|-------------|
| `userId` | `int` | Unique user identifier |
| `firstName` | `String?` | First name |
| `lastName` | `String?` | Last name |
| `fullName` | `String?` | Combined full name |
| `email` | `String?` | Email address |

**Computed**: `displayName` getter returns best available name

### UserTypingEvent

**File**: `lib/bloc/chat/chat_models.dart`

| Field | Type | Description |
|-------|------|-------------|
| `conversationId` | `int` | Which conversation |
| `userId` | `int` | Who is typing |
| `isTyping` | `bool` | Started or stopped typing |

---

## State Modification (ChatState)

### Addition: replyToMessage

**File**: `lib/bloc/chat/chat_state.dart`

```dart
class ChatState extends Equatable {
  // ... existing fields ...
  
  /// Message being replied to (shown in reply preview bar)
  final ChatMessageModel? replyToMessage;
  
  const ChatState({
    // ... existing params ...
    this.replyToMessage,
  });
  
  ChatState copyWith({
    // ... existing params ...
    ChatMessageModel? replyToMessage,
    bool clearReplyToMessage = false,
  }) {
    return ChatState(
      // ... existing assignments ...
      replyToMessage: clearReplyToMessage 
          ? null 
          : replyToMessage ?? this.replyToMessage,
    );
  }
  
  @override
  List<Object?> get props => [
    // ... existing props ...
    replyToMessage,
  ];
}
```

**Usage**:
- Set via `SetReplyContext` event when user taps "Reply" on a message
- Cleared via `SetReplyContext(message: null)` when reply is sent or cancelled
- Read by `shared_chat_detail_view.dart` to show/hide reply preview bar

---

## Event Addition (ChatEvent)

### Addition: SetReplyContext

**File**: `lib/bloc/chat/chat_event.dart`

```dart
class SetReplyContext extends ChatEvent {
  final ChatMessageModel? message;
  
  const SetReplyContext({this.message});
  
  @override
  List<Object?> get props => [message];
}
```

**Behavior**:
- `message != null` → set `replyToMessage` in state, show reply preview bar
- `message == null` → clear `replyToMessage`, hide reply preview bar

---

## Message Status State Machine

```
┌──────────┐    send()     ┌─────────┐
│ (draft)  │ ─────────────→│ pending │
└──────────┘               └────┬────┘
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
              ▼                 ▼                 ▼
        ┌─────────┐       ┌─────────┐       ┌────────┐
        │  sent   │       │ failed  │       │ (retry)│
        └────┬────┘       └────┬────┘       └────┬───┘
             │                 │                  │
             │                 │     retry()      │
             │                 │◄─────────────────┘
             │                 │
             ▼                 ▼
        ┌─────────┐       ┌─────────┐
        │ deleted │       │ (error) │
        └─────────┘       └─────────┘
```

**Transitions**:
1. User taps send → `pending` (optimistic add to list)
2. WebSocket `message_sent` event → `sent` (replace temp message)
3. Send fails → retry up to 3 times with backoff
4. All retries exhausted → `failed` (show retry button)
5. User taps "Delete for everyone" → `deleted` (show placeholder text)

---

## Delete Eligibility Rules

A message can be "Deleted for everyone" if ALL conditions are true:

| Condition | Check |
|-----------|-------|
| Own message | `message.senderId == currentUserId` |
| Within 24 hours | `DateTime.now().difference(message.sentAt) < Duration(hours: 24)` |
| Not pending | `message.status != 'pending'` |
| Not already deleted | `message.isDeleted == false` |

If any condition fails, only "Delete for me" is shown.

---

## Reply Context Data Flow

```
User taps "Reply" on message
        │
        ▼
┌───────────────────────────┐
│ bloc.add(SetReplyContext( │
│   message: targetMessage  │
│ ))                        │
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│ state.replyToMessage =    │
│   targetMessage           │
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│ ReplyPreviewBar shows     │
│ quoted message snippet    │
└───────────────────────────┘
        │
        ▼ (user sends reply)
┌───────────────────────────┐
│ bloc.add(SendMessage(     │
│   text: ...,              │
│   replyToId: state        │
│     .replyToMessage?.id   │
│ ))                        │
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│ bloc.add(SetReplyContext( │
│   message: null           │
│ ))                        │
└───────────────────────────┘
```
