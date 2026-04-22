# Research: Unified Chat UI — Message Detail View

**Branch**: `009-chat-message-detail-ui` | **Date**: 2026-04-06

## Research Summary

All technical unknowns have been resolved. The Phase 4 implementation builds entirely on established infrastructure from Phases 1-3.

---

## 1. Existing Infrastructure Analysis

### Decision: Leverage existing ChatBloc and services without modification to core architecture

**Rationale**: Phase 1 and Phase 2 have already established:
- `ChatService` (REST API) with all required endpoints
- `ChatSocketService` (WebSocket) with all required events
- `ChatBloc` with full event handling for messages, typing, deletions
- `ChatMessageModel`, `ConversationModel` with exact backend/website parity

**Alternatives Considered**:
- Creating a separate `MessageDetailBloc`: Rejected — would duplicate state management and complicate conversation switching
- Direct service calls in widgets: Rejected — violates Constitution Principle I

---

## 2. Optimistic Update Strategy

### Decision: Use local temp ID (-1, -2, ...) for optimistic messages, reconcile on `message_sent` event

**Rationale**: Website uses this exact pattern:
1. Generate negative temp ID (`_tempIdCounter--`)
2. Add message with `status: 'pending'`
3. On `message_sent` event, find message by temp ID and replace with server-confirmed message
4. On send failure after 3 retries, mark as `status: 'failed'`

**Alternatives Considered**:
- UUID-based temp IDs: Rejected — backend uses integer IDs, matching IDs simplifies reconciliation
- No optimistic update (wait for server): Rejected — violates <100ms perceived delay requirement

---

## 3. Retry Strategy

### Decision: 3 retries with exponential backoff (1s, 2s, 4s)

**Rationale**: Per clarification session, this matches industry standard patterns and provides:
- Quick recovery from transient network issues
- Total wait time of 7 seconds before showing error (reasonable UX)
- Progressive backoff prevents server overload

**Implementation**:
```dart
const _retryDelays = [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)];
```

**Alternatives Considered**:
- Fixed 1-second retries: Rejected — can overwhelm server during recovery
- No automatic retry: Rejected — poor UX for transient failures

---

## 4. Pagination Strategy

### Decision: 30 messages per page, load-on-scroll-to-top

**Rationale**: Per clarification session, 30 messages balances:
- Memory efficiency on mobile devices
- Smooth scrolling UX (enough content to avoid constant loading)
- Matches common chat app patterns (WhatsApp ~30, Telegram ~20-50)

**Implementation**: Use existing `LoadMoreMessages` event in ChatBloc with `limit: 30`

**Alternatives Considered**:
- 50 messages: Rejected — higher memory usage, longer initial load
- 20 messages: Rejected — too frequent pagination triggers

---

## 5. Delete-for-Everyone Time Window

### Decision: 24-hour window from message send time

**Rationale**: Per clarification session, 24 hours provides:
- Longer window than typical (WhatsApp: 2 days, but declining)
- User flexibility for error correction
- Balance between privacy and conversation integrity

**Implementation**: Check `sentAt` timestamp against `DateTime.now()` before showing "Delete for everyone" option

**Alternatives Considered**:
- No time limit: Rejected — enables abuse of retroactive deletion
- 15 minutes: Rejected — too restrictive per user preference

---

## 6. Typing Indicator Behavior

### Decision: Match website's 1.5-second debounce and auto-stop

**Rationale**: Constitution Principle VI requires matching website behavior:
- Emit `typing: true` on first keystroke
- Debounce subsequent keystrokes for 1.5 seconds
- Emit `typing: false` after 1.5 seconds of inactivity

**Implementation**: Already implemented in `ChatBloc._onTypingChanged` with `_typingDebounceDuration`

---

## 7. Emoji Row Design

### Decision: Inline row with 8 commonly used emojis matching website

**Rationale**: Website's MessagingChat shows a simple inline emoji row, not a full picker:
- 😀 😂 ❤️ 👍 👎 😢 😮 🔥

**Implementation**: Static list in `shared_emoji_row.dart`, toggle visibility on emoji button tap

**Alternatives Considered**:
- Full emoji keyboard: Rejected — website doesn't use full picker, would break parity
- External emoji_picker package: Rejected — overkill for simple row

---

## 8. Reply Context Display

### Decision: Swipe-to-reply with reply preview bar above input

**Rationale**: Matches website behavior:
1. Long-press message → "Reply" action
2. Reply preview bar appears above input with quoted message snippet
3. Send includes `replyToId` in message payload
4. Received messages with `replyToId` show quoted context above bubble

**Implementation**: 
- Add `replyToMessage` field to `ChatState`
- Add `SetReplyContext` event to `ChatBloc`
- `shared_message_bubble.dart` renders reply context if `replyToId` is set

---

## 9. Connection Status Badge

### Decision: Green "Live" badge when connected, red "Offline" badge when disconnected

**Rationale**: Matches website's connection indicator in header. Already implemented in `ChatState.connectionStatus` enum.

**Implementation**: `shared_chat_detail_view.dart` reads `state.connectionStatus` and renders appropriate badge

---

## 10. Group Chat Sender Display

### Decision: Show sender name and avatar for group messages, hide for direct messages

**Rationale**: Matches website behavior per spec User Story 7:
- Group: Show sender name above first message in sequence, avatar on all messages
- Direct: Hide sender names (implicit from left/right alignment)

**Implementation**: Check `conversation.type == ConversationType.group` in `shared_message_bubble.dart`

---

## Conclusion

No NEEDS CLARIFICATION items remain. All technical decisions align with:
- Existing Phase 1-3 infrastructure
- Website frontend behavior (MessagingChat component)
- Backend API contracts
- Constitution principles

Ready to proceed to Phase 1: Design & Contracts.
