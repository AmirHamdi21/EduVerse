# Widget Interface Contracts: Message Detail View

**Branch**: `009-chat-message-detail-ui` | **Date**: 2026-04-06

## Overview

This document defines the public interfaces (props/parameters) for each new widget, enabling parallel development and testing.

---

## 1. SharedChatDetailView

**File**: `lib/widgets/shared/chat/shared_chat_detail_view.dart`

### Constructor Parameters

```dart
class SharedChatDetailView extends StatelessWidget {
  const SharedChatDetailView({
    super.key,
    required this.conversation,
    required this.currentUserId,
    this.currentUserName,
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
    this.showVoiceCall = true,
    this.showVideoCall = true,
    this.showAttachment = true,
    this.showVoiceMessage = true,
    this.showEmojiPicker = true,
    this.onBack,
  });

  /// The conversation being displayed
  final ConversationModel conversation;
  
  /// Current user's ID for determining message alignment
  final int currentUserId;
  
  /// Current user's display name for outgoing messages
  final String? currentUserName;
  
  /// Primary accent color for theming
  final Color accentColor;
  
  /// Dark mode flag
  final bool isDark;
  
  /// Show voice call button (placeholder)
  final bool showVoiceCall;
  
  /// Show video call button (placeholder)
  final bool showVideoCall;
  
  /// Show attachment button (placeholder)
  final bool showAttachment;
  
  /// Show voice message toggle (placeholder)
  final bool showVoiceMessage;
  
  /// Show emoji picker button
  final bool showEmojiPicker;
  
  /// Callback when back button is pressed (mobile navigation)
  final VoidCallback? onBack;
}
```

### Internal Structure

```
SharedChatDetailView
├── _ConversationHeader (connection badge, avatar, name, online, typing, call buttons)
├── _MessageList (scrollable, pagination, auto-scroll)
│   └── SharedMessageBubble (per message)
├── _ReplyPreviewBar (conditionally shown when replying)
├── SharedEmojiRow (conditionally shown when emoji button tapped)
└── _InputBar (attachment, voice, text input, emoji toggle, send)
```

### BLoC Dependencies

- Consumes: `ChatBloc` via `BlocBuilder<ChatBloc, ChatState>`
- Reads: `state.activeConversationMessages`, `state.connectionStatus`, `state.typingUsers`, `state.onlineUsers`, `state.replyToMessage`
- Dispatches: `SendMessage`, `SetReplyContext`, `TypingChanged`, `DeleteMessage`, `LoadMoreMessages`

---

## 2. SharedMessageBubble

**File**: `lib/widgets/shared/chat/shared_message_bubble.dart`

### Constructor Parameters

```dart
class SharedMessageBubble extends StatelessWidget {
  const SharedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isGroup,
    this.showSenderInfo = true,
    this.replyToMessage,
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
    this.onReply,
    this.onDeleteForMe,
    this.onDeleteForEveryone,
    this.onRetry,
    this.onTapReplyContext,
    this.canDeleteForEveryone = false,
  });

  /// The message to display
  final ChatMessageModel message;
  
  /// Whether this message was sent by the current user
  final bool isMe;
  
  /// Whether this is a group conversation (affects sender display)
  final bool isGroup;
  
  /// Whether to show sender name/avatar (false for consecutive messages from same sender)
  final bool showSenderInfo;
  
  /// The message this is replying to (for reply context display)
  final ChatMessageModel? replyToMessage;
  
  /// Primary accent color for sent message bubbles
  final Color accentColor;
  
  /// Dark mode flag
  final bool isDark;
  
  /// Callback when "Reply" action is selected
  final VoidCallback? onReply;
  
  /// Callback when "Delete for me" action is selected
  final VoidCallback? onDeleteForMe;
  
  /// Callback when "Delete for everyone" action is selected
  final VoidCallback? onDeleteForEveryone;
  
  /// Callback when retry button is tapped (for failed messages)
  final VoidCallback? onRetry;
  
  /// Callback when reply context is tapped (scroll to original)
  final VoidCallback? onTapReplyContext;
  
  /// Whether "Delete for everyone" should be shown (24h window + own message)
  final bool canDeleteForEveryone;
}
```

### Visual States

| State | Appearance |
|-------|------------|
| `isMe: true` | Right-aligned, accent color background |
| `isMe: false` | Left-aligned, neutral background |
| `isDeleted: true` | Italicized "This message was deleted" |
| `status: 'pending'` | Dimmed with clock icon |
| `status: 'failed'` | Red tint with retry button |
| `replyToMessage != null` | Reply context box above bubble |

### Long-Press Actions Menu

| Action | Condition | Icon |
|--------|-----------|------|
| Reply | Always | `Icons.reply` |
| Delete for me | Always | `Icons.delete_outline` |
| Delete for everyone | `canDeleteForEveryone` | `Icons.delete_forever` |

---

## 3. SharedEmojiRow

**File**: `lib/widgets/shared/chat/shared_emoji_row.dart`

### Constructor Parameters

```dart
class SharedEmojiRow extends StatelessWidget {
  const SharedEmojiRow({
    super.key,
    required this.onEmojiSelected,
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
  });

  /// Callback when an emoji is tapped
  final void Function(String emoji) onEmojiSelected;
  
  /// Accent color for selection highlight
  final Color accentColor;
  
  /// Dark mode flag
  final bool isDark;
}
```

### Emoji Set (matching website)

```dart
static const List<String> emojis = [
  '😀', '😂', '❤️', '👍', '👎', '😢', '😮', '🔥',
];
```

### Behavior

- Horizontal scrollable row
- Tap emoji → calls `onEmojiSelected(emoji)`
- Container animates in/out based on visibility toggle

---

## 4. SharedTypingIndicator

**File**: `lib/widgets/shared/chat/shared_typing_indicator.dart`

### Constructor Parameters

```dart
class SharedTypingIndicator extends StatefulWidget {
  const SharedTypingIndicator({
    super.key,
    required this.typingUserNames,
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
  });

  /// List of user names currently typing
  final List<String> typingUserNames;
  
  /// Accent color for dots
  final Color accentColor;
  
  /// Dark mode flag
  final bool isDark;
}
```

### Display Logic

| Users Typing | Display Text |
|--------------|--------------|
| 0 | (hidden) |
| 1 | "John is typing..." |
| 2 | "John and Jane are typing..." |
| 3+ | "John, Jane, and 2 others are typing..." |

### Animation

- Three dots with staggered bounce animation
- Animation duration: 1.2 seconds per cycle
- Dots use accent color with varying opacity

---

## Usage Example

```dart
// In a role-specific screen (e.g., StudentChatScreen)
BlocBuilder<ChatBloc, ChatState>(
  builder: (context, state) {
    final conversation = state.activeConversation;
    if (conversation == null) {
      return const SharedChatEmptyState();
    }
    
    return SharedChatDetailView(
      conversation: conversation,
      currentUserId: currentUser.userId,
      currentUserName: currentUser.fullName,
      accentColor: Theme.of(context).primaryColor,
      isDark: Theme.of(context).brightness == Brightness.dark,
      onBack: () => context.read<ChatBloc>().add(
        const SelectConversation(conversationId: null),
      ),
    );
  },
);
```

---

## Test Contract

Each widget must have corresponding tests validating:

1. **Rendering**: Widget builds without errors with minimal required props
2. **Theming**: `accentColor` and `isDark` apply correctly
3. **Actions**: Callbacks are invoked with correct parameters
4. **States**: All visual states render correctly
5. **Accessibility**: Semantic labels present for screen readers
