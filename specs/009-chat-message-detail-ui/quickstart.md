# Quick Start: Phase 4 — Message Detail View

**Branch**: `009-chat-message-detail-ui` | **Target**: 4 new widgets + BLoC modifications

---

## Prerequisites

1. **Phase 1-3 Complete**: Ensure `chat_bloc.dart`, `chat_state.dart`, `chat_service.dart`, and Phase 3 widgets are implemented
2. **Backend Running**: Chat WebSocket server available at configured endpoint
3. **Flutter SDK**: 3.16.0+ with Dart 3.2+

---

## Setup Commands

```bash
# Switch to feature branch
git checkout 009-chat-message-detail-ui

# Install dependencies (if not already)
flutter pub get

# Verify existing tests pass
flutter test test/bloc/chat/
```

---

## Implementation Order

### Step 1: State Modifications (15 min)

**File**: `lib/bloc/chat/chat_state.dart`

Add `replyToMessage` field to `ChatState`:

```dart
// Add to ChatState class
final ChatMessageModel? replyToMessage;

// Update copyWith
ChatState copyWith({
  // ... existing fields ...
  ChatMessageModel? replyToMessage,
  bool clearReplyToMessage = false,
}) {
  return ChatState(
    // ... existing fields ...
    replyToMessage: clearReplyToMessage ? null : replyToMessage ?? this.replyToMessage,
  );
}
```

**File**: `lib/bloc/chat/chat_event.dart`

Add `SetReplyContext` event:

```dart
class SetReplyContext extends ChatEvent {
  final ChatMessageModel? message;
  const SetReplyContext(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**File**: `lib/bloc/chat/chat_bloc.dart`

Add handler:

```dart
on<SetReplyContext>((event, emit) {
  emit(state.copyWith(
    replyToMessage: event.message,
    clearReplyToMessage: event.message == null,
  ));
});
```

---

### Step 2: Typing Indicator Widget (20 min)

**File**: `lib/widgets/shared/chat/shared_typing_indicator.dart`

Simplest widget, no BLoC dependency—good starting point:

```dart
// See contracts/widget-interfaces.md for full interface
class SharedTypingIndicator extends StatefulWidget {
  // Animated dots + "X is typing..." text
}
```

**Test**: `test/widgets/shared/chat/shared_typing_indicator_test.dart`

---

### Step 3: Emoji Row Widget (15 min)

**File**: `lib/widgets/shared/chat/shared_emoji_row.dart`

Simple horizontal scrollable emoji picker:

```dart
// See contracts/widget-interfaces.md for full interface
class SharedEmojiRow extends StatelessWidget {
  // 8 emoji buttons in horizontal row
}
```

**Test**: `test/widgets/shared/chat/shared_emoji_row_test.dart`

---

### Step 4: Message Bubble Widget (45 min)

**File**: `lib/widgets/shared/chat/shared_message_bubble.dart`

Core message display with all states:

```dart
// See contracts/widget-interfaces.md for full interface
class SharedMessageBubble extends StatelessWidget {
  // Handles: sent/received, pending/failed/deleted, reply context, long-press menu
}
```

**Test**: `test/widgets/shared/chat/shared_message_bubble_test.dart`

---

### Step 5: Detail View Widget (90 min)

**File**: `lib/widgets/shared/chat/shared_chat_detail_view.dart`

Main orchestrating widget:

```dart
// See contracts/widget-interfaces.md for full interface
class SharedChatDetailView extends StatelessWidget {
  // Header + MessageList + ReplyBar + EmojiRow + InputBar
}
```

**Test**: `test/widgets/shared/chat/shared_chat_detail_view_test.dart`

---

## Verification Checklist

```bash
# 1. Run all widget tests
flutter test test/widgets/shared/chat/

# 2. Run bloc tests (ensure no regressions)
flutter test test/bloc/chat/

# 3. Analyze for errors
flutter analyze lib/widgets/shared/chat/ lib/bloc/chat/

# 4. Test UI manually
flutter run -d chrome
# Navigate to chat, open a conversation, send messages, test reply/delete
```

---

## Key Test Scenarios

| Scenario | Verify |
|----------|--------|
| Send message | Optimistic update appears immediately, status changes on WebSocket ack |
| Failed message | Retry button visible, tap retries send |
| Reply | Reply context shows above input, clears after send |
| Delete for me | Message removed from local state |
| Delete for everyone | Message shows "deleted" state after WebSocket event |
| Typing indicator | Appears when other user types, disappears after 3s |
| Pagination | Scroll to top loads older messages |
| Connection lost | Banner shows "Connecting...", auto-reconnect works |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Messages not appearing | Check `activeConversationMessages` in BLoC state |
| WebSocket events not received | Verify `ChatSocketService.init()` called with valid token |
| Reply context not clearing | Ensure `SetReplyContext(null)` called after send |
| Pagination not working | Check `hasMoreMessages` flag and `LoadMoreMessages` event |

---

## Files Modified/Created

**New Files (4)**:
- `lib/widgets/shared/chat/shared_chat_detail_view.dart`
- `lib/widgets/shared/chat/shared_message_bubble.dart`
- `lib/widgets/shared/chat/shared_emoji_row.dart`
- `lib/widgets/shared/chat/shared_typing_indicator.dart`

**Modified Files (3)**:
- `lib/bloc/chat/chat_state.dart` — add `replyToMessage`
- `lib/bloc/chat/chat_event.dart` — add `SetReplyContext`
- `lib/bloc/chat/chat_bloc.dart` — add `SetReplyContext` handler

**Test Files (4)**:
- `test/widgets/shared/chat/shared_chat_detail_view_test.dart`
- `test/widgets/shared/chat/shared_message_bubble_test.dart`
- `test/widgets/shared/chat/shared_emoji_row_test.dart`
- `test/widgets/shared/chat/shared_typing_indicator_test.dart`
